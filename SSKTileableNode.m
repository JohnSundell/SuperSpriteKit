#import "SSKTileableNode.h"

static CGFloat SSKTileableNodeNoResizing = -9999;

@interface SSKTileableNode()

@property (nonatomic, strong) NSMutableArray *partNodes;

@end

@implementation SSKTileableNode

+ (instancetype)tileableNodeWithSize:(CGSize)size imageNamed:(NSString *)imageName
{
    if (!imageName) {
        return nil;
    }
    
    return [self tileableNodeWithSize:size
                              texture:[SKTexture textureWithImageNamed:imageName]];
}

+ (instancetype)tileableNodeWithSize:(CGSize)size texture:(SKTexture *)texture
{
    if (!texture) {
        return nil;
    }
    
    SSKTileableNode *node = [self node];
    node.partNodes = [NSMutableArray new];
    node.texture = texture;
    node.size = size;
    
    return node;
}

- (void)drawPartNodes
{
    [self.partNodes makeObjectsPerformSelector:@selector(removeFromParent)];
    [self.partNodes removeAllObjects];
    
    if (self.size.width <= 0 || self.size.height <= 0) {
        return;
    }
    
    const CGSize textureSize = self.texture.size;
    
    CGPoint drawPoint = CGPointZero;
    
    while (true) {
        CGSize tileSize;
        tileSize.width = MIN(self.size.width - drawPoint.x, textureSize.width);
        tileSize.height = MIN(self.size.height - drawPoint.y, textureSize.height);
        
        SKTexture *tileTexture;
        
        if (tileSize.width < textureSize.width || tileSize.height < textureSize.height) {
            CGRect textureRect = self.texture.textureRect;
            textureRect.size.width *= tileSize.width / textureSize.width;
            textureRect.size.height *= tileSize.height / textureSize.height;
            
            tileTexture = [SKTexture textureWithRect:textureRect inTexture:self.texture];
        } else {
            tileTexture = self.texture;
        }
        
        SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithTexture:tileTexture];
        tileNode.anchorPoint = CGPointZero;
        tileNode.position = drawPoint;
        tileNode.size = tileSize;
        
        [self addChild:tileNode];
        [self.partNodes addObject:tileNode];
        
        drawPoint.x += tileSize.width;
        
        if (drawPoint.x >= self.size.width) {
            drawPoint.x = 0;
            drawPoint.y += tileSize.height;
            
            if (drawPoint.y >= self.size.height) {
                break;
            }
        }
    }
}

#pragma mark - Accessor overrides

- (void)setSize:(CGSize)size
{
    if (CGSizeEqualToSize(_size, size)) {
        return;
    }
    
    _size = size;
    
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

- (void)setColor:(SKColor *)color
{
    if ([_color isEqual:color]) {
        return;
    }
    
    _color = color;
    
    [self.partNodes makeObjectsPerformSelector:@selector(setColor:) withObject:color];
}

- (void)setColorBlendFactor:(CGFloat)colorBlendFactor
{
    if (_colorBlendFactor == colorBlendFactor) {
        return;
    }
    
    _colorBlendFactor = colorBlendFactor;
    
    [self.partNodes makeObjectsPerformSelector:@selector(setColorBlendFactor:) withObject:@(colorBlendFactor)];
}

@end

#pragma mark - SKActions

@implementation SKAction (SSKTileableNodeActions)

+ (SKAction *)resizeTileableNodeToWidth:(CGFloat)width duration:(NSTimeInterval)duration
{
    return [SKAction resizeTileableNodeToWidth:width
                                           height:SSKTileableNodeNoResizing
                                         duration:duration];
}

+ (SKAction *)resizeTileableNodeToHeight:(CGFloat)height duration:(NSTimeInterval)duration
{
    return [SKAction resizeTileableNodeToWidth:SSKTileableNodeNoResizing
                                           height:height
                                         duration:duration];
}

+ (SKAction *)resizeTileableNodeToWidth:(CGFloat)width height:(CGFloat)height duration:(NSTimeInterval)duration
{
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        if (![node isKindOfClass:[SSKTileableNode class]]) {
            return;
        }
        
        CGFloat percentageComplete = elapsedTime / duration;
        SSKTileableNode *tileableNode = (SSKTileableNode *)node;
        CGSize nodeSize = tileableNode.size;
        
        if (width != SSKTileableNodeNoResizing) {
            nodeSize.width += (width - nodeSize.width) * percentageComplete;
        }
        
        if (height != SSKTileableNodeNoResizing) {
            nodeSize.height += (height - nodeSize.height) * percentageComplete;
        }
        
        tileableNode.size = nodeSize;
    }];
}

@end
