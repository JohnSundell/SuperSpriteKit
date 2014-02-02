#import "SSKStretchableNode.h"

#pragma mark - C Utilities

typedef enum : NSUInteger {
    JSStretchableNodePartTopLeft,
    JSStretchableNodePartTop,
    JSStretchableNodePartTopRight,
    JSStretchableNodePartRight,
    JSStretchableNodePartBottomRight,
    JSStretchableNodePartBottom,
    JSStretchableNodePartBottomLeft,
    JSStretchableNodePartLeft,
    JSStretchableNodePartCenter
} JSStretchableNodePart;

static CGFloat JSStretchableNodeNoResizing = -9999;

static CGRect JSStretchableNodeGetRectForPart(CGSize totalSize, SSKEdgeInsetsType capInsets, JSStretchableNodePart part)
{
    CGRect rect = CGRectZero;
    
    switch (part) {
        case JSStretchableNodePartTopLeft: {
            rect.origin.y = totalSize.height - capInsets.top;
            rect.size = CGSizeMake(capInsets.left, capInsets.top);
        }
            break;
        case JSStretchableNodePartTop: {
            rect.origin.x = capInsets.left;
            rect.origin.y = totalSize.height - capInsets.top;
            rect.size.width = totalSize.width - capInsets.left - capInsets.right;
            rect.size.height = capInsets.top;
        }
            break;
        case JSStretchableNodePartTopRight: {
            rect.origin.x = totalSize.width - capInsets.right;
            rect.origin.y = totalSize.height - capInsets.top;
            rect.size = CGSizeMake(capInsets.right, capInsets.top);
        }
            break;
        case JSStretchableNodePartRight: {
            rect.origin.x = totalSize.width - capInsets.right;
            rect.origin.y = capInsets.bottom;
            rect.size.width = capInsets.right;
            rect.size.height = totalSize.height - capInsets.top - capInsets.bottom;
        }
            break;
        case JSStretchableNodePartBottomRight: {
            rect.origin.x = totalSize.width - capInsets.right;
            rect.size = CGSizeMake(capInsets.right, capInsets.bottom);
        }
            break;
        case JSStretchableNodePartBottom: {
            rect.origin.x = capInsets.left;
            rect.size.width = totalSize.width - capInsets.left - capInsets.right;
            rect.size.height = capInsets.bottom;
        }
            break;
        case JSStretchableNodePartBottomLeft:
            rect.size = CGSizeMake(capInsets.left, capInsets.bottom);
            break;
        case JSStretchableNodePartLeft: {
            rect.origin.y = capInsets.bottom;
            rect.size.width = capInsets.left;
            rect.size.height = totalSize.height - capInsets.top - capInsets.bottom;
        }
            break;
        case JSStretchableNodePartCenter: {
            rect.origin = CGPointMake(capInsets.left, capInsets.bottom);
            rect.size.width = totalSize.width - capInsets.left - capInsets.right;
            rect.size.height = totalSize.height - capInsets.top - capInsets.bottom;
        }
            break;
    }
    
    return rect;
}

static CGRect JSStretchableNodeTextureRectFromPartRect(SKTexture *texture, CGRect partRect)
{
    const CGSize textureSize = texture.size;
    
    CGRect textureRect;
    textureRect.origin.x = partRect.origin.x / textureSize.width;
    textureRect.origin.y = partRect.origin.y / textureSize.height;
    textureRect.size.width = partRect.size.width / textureSize.width;
    textureRect.size.height = partRect.size.height / textureSize.height;

    return textureRect;
}

#pragma mark - JSStretchableNode

@interface SSKStretchableNode()

@property (nonatomic, strong) NSArray *partNodes;
@property (nonatomic) SSKEdgeInsetsType textureCapInsets;

@end

@implementation SSKStretchableNode

+ (instancetype)stretchableNodeWithSize:(CGSize)size imageNamed:(NSString *)imageName capInsets:(SSKEdgeInsetsType)capInsets
{
    if (!imageName) {
        return nil;
    }
    
    return [self stretchableNodeWithSize:size
                                 texture:[SKTexture textureWithImageNamed:imageName]
                               capInsets:capInsets];
}

+ (instancetype)stretchableNodeWithSize:(CGSize)size texture:(SKTexture *)texture capInsets:(SSKEdgeInsetsType)capInsets
{
    if (!texture) {
        return nil;
    }
    
    SSKStretchableNode *node = [self node];
    [node setSize:size drawPartNodes:NO];
    [node setTexture:texture capInsets:capInsets];
    
    return node;
}

- (void)drawPartNodes
{
    [self.partNodes makeObjectsPerformSelector:@selector(removeFromParent)];
    
    if (self.size.width == 0 || self.size.height == 0) {
        self.partNodes = nil;
        
        return;
    }
    
    NSMutableArray *partNodes = [NSMutableArray new];
    
    const CGSize textureSize = self.texture.size;
    
    for (JSStretchableNodePart part = 0; part <= JSStretchableNodePartCenter; part++) {
        CGRect partRect = JSStretchableNodeGetRectForPart(textureSize, self.textureCapInsets, part);
        CGRect partTextureRect = JSStretchableNodeTextureRectFromPartRect(self.texture, partRect);
        CGRect partNodeRect = JSStretchableNodeGetRectForPart(self.size, self.textureCapInsets, part);
        
        SKTexture *partTexture = [SKTexture textureWithRect:partTextureRect inTexture:self.texture];
        SSKTileableNode *partNode = [SSKTileableNode tileableNodeWithSize:partNodeRect.size texture:partTexture];
        partNode.position = partNodeRect.origin;
        
        [self addChild:partNode];
        [partNodes addObject:partNode];
    }
    
    self.partNodes = partNodes;
}

#pragma mark - Accessor overrides

- (void)setTexture:(SKTexture *)texture capInsets:(SSKEdgeInsetsType)capInsets
{
    _texture = texture;
    _textureCapInsets = capInsets;
    
    [self drawPartNodes];
}

- (void)setTexture:(SKTexture *)texture
{
    if (_texture == texture) {
        return;
    }
    
    _texture = texture;
    
    [self drawPartNodes];
}

- (void)setZPosition:(CGFloat)zPosition
{
    BOOL changed = (self.zPosition != zPosition);
    
    [super setZPosition:zPosition];
    
    if (!changed) {
        return;
    }
    
    for (SKSpriteNode *partNode in self.partNodes) {
        partNode.zPosition = zPosition;
    }
}

- (void)setSize:(CGSize)size
{
    [self setSize:size drawPartNodes:YES];
}

- (void)setSize:(CGSize)size drawPartNodes:(BOOL)drawPartNodes
{
    if (CGSizeEqualToSize(_size, size)) {
        return;
    }
    
    _size = size;
    
    if (!drawPartNodes) {
        return;
    }
    
    if (!self.partNodes) {
        [self drawPartNodes];
        return;
    }
    
    for (JSStretchableNodePart part = 0; part <= JSStretchableNodePartCenter; part++) {
        SSKTileableNode *partNode = [self.partNodes objectAtIndex:part];
        
        CGRect partNodeRect = JSStretchableNodeGetRectForPart(size, self.textureCapInsets, part);
        partNode.position = partNodeRect.origin;
        partNode.size = partNodeRect.size;
    }
}

- (void)setColor:(SKColor *)color
{
    if ([_color isEqual:color]) {
        return;
    }
    
    _color = color;
    
    for (SSKTileableNode *partNode in self.partNodes) {
        partNode.color = color;
    }
}

- (void)setColorBlendFactor:(CGFloat)colorBlendFactor
{
    if (_colorBlendFactor == colorBlendFactor) {
        return;
    }
    
    _colorBlendFactor = colorBlendFactor;
    
    for (SSKTileableNode *partNode in self.partNodes) {
        partNode.colorBlendFactor = colorBlendFactor;
    }
}

@end

#pragma mark - SKActions

@implementation SKAction (SSKStretchableNodeActions)

+ (SKAction *)resizeStretchableNodeToWidth:(CGFloat)width duration:(NSTimeInterval)duration
{
    return [SKAction resizeStretchableNodeToWidth:width
                                           height:JSStretchableNodeNoResizing
                                         duration:duration];
}

+ (SKAction *)resizeStretchableNodeToHeight:(CGFloat)height duration:(NSTimeInterval)duration
{
    return [SKAction resizeStretchableNodeToWidth:JSStretchableNodeNoResizing
                                           height:height
                                         duration:duration];
}

+ (SKAction *)resizeStretchableNodeToWidth:(CGFloat)width height:(CGFloat)height duration:(NSTimeInterval)duration
{
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        if (![node isKindOfClass:[SSKStretchableNode class]]) {
           return;
        }
        
        CGFloat percentageComplete = elapsedTime / duration;
        SSKStretchableNode *stretchableNode = (SSKStretchableNode *)node;
        CGSize nodeSize = stretchableNode.size;
        
        if (width != JSStretchableNodeNoResizing) {
            nodeSize.width += (width - nodeSize.width) * percentageComplete;
        }
        
        if (height != JSStretchableNodeNoResizing) {
            nodeSize.height += (height - nodeSize.height) * percentageComplete;
        }
        
        stretchableNode.size = nodeSize;
    }];
}

@end