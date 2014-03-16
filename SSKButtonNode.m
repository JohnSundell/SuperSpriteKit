#import "SSKButtonNode.h"

#pragma mark - C Utilities

static NSArray *SSKButtonNodeGetArrayForEdgeInsets(SSKEdgeInsetsType edgeInsets)
{
    return @[@(edgeInsets.top), @(edgeInsets.left), @(edgeInsets.bottom), @(edgeInsets.right)];
}

static SSKEdgeInsetsType SSKButtonNodeGetEdgeInsetsForArray(NSArray *edgeInsetsArray)
{
    SSKEdgeInsetsType edgeInsets;
    edgeInsets.top = [[edgeInsetsArray objectAtIndex:0] doubleValue];
    edgeInsets.left = [[edgeInsetsArray objectAtIndex:1] doubleValue];
    edgeInsets.bottom = [[edgeInsetsArray objectAtIndex:2] doubleValue];
    edgeInsets.right = [[edgeInsetsArray objectAtIndex:3] doubleValue];
    
    return edgeInsets;
}

#pragma mark - SSKButtonTargetActionPair

@interface SSKButtonTargetActionPair : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, strong) NSString *actionSelectorString;

@end

@implementation SSKButtonTargetActionPair

+ (instancetype)pairForTarget:(id)target action:(SEL)action
{
    SSKButtonTargetActionPair *pair = [self new];
    
    pair.target = target;
    pair.actionSelectorString = NSStringFromSelector(action);
    
    return pair;
}

- (BOOL)isEqual:(id)object
{
    if (![self isKindOfClass:[object class]]) {
        return NO;
    }
    
    if ([object target] != self.target) {
        return NO;
    }
    
    if (![[object actionSelectorString] isEqualToString:self.actionSelectorString]) {
        return NO;
    }
    
    return YES;
}

@end

#pragma mark - SSKButtonNode

@interface SSKButtonNode()

@property (nonatomic, strong) NSDictionary *targetActionPairs;
@property (nonatomic, strong) NSMutableDictionary *backgroundColors;
@property (nonatomic, strong) NSMutableDictionary *backgroundTextures;
@property (nonatomic, strong) NSMutableDictionary *stretchableBackgroundTextureCapInsets;
@property (nonatomic, strong) NSMutableDictionary *iconTextures;
@property (nonatomic, strong) NSMutableDictionary *titles;
@property (nonatomic, strong) NSMutableDictionary *titleEdgeInsets;

@property (nonatomic, strong, readwrite) SKLabelNode *titleLabelNode;
@property (nonatomic, strong) SSKStretchableNode *backgroundNode;
@property (nonatomic, strong) SKSpriteNode *iconNode;

@end

@implementation SSKButtonNode

+ (instancetype)buttonNodeWithSize:(CGSize)size
{
    SSKButtonNode *buttonNode = [self node];
    
    buttonNode.iconLabelMargin = 5;
    buttonNode.enabled = YES;
    
    NSArray *states = @[@(SSKButtonStateNormal), @(SSKButtonStateHighlighted), @(SSKButtonStateSelected)];
    
    NSMutableDictionary *targetActionPairs = [NSMutableDictionary new];
    
    for (NSNumber *stateKey in states) {
        [targetActionPairs setObject:[NSMutableArray new] forKey:stateKey];
    }
    
    buttonNode.targetActionPairs = targetActionPairs;
    buttonNode.backgroundColors = [NSMutableDictionary new];
    buttonNode.backgroundTextures = [NSMutableDictionary new];
    buttonNode.stretchableBackgroundTextureCapInsets = [NSMutableDictionary new];
    buttonNode.iconTextures = [NSMutableDictionary new];
    buttonNode.titles = [NSMutableDictionary new];
    buttonNode.titleEdgeInsets = [NSMutableDictionary new];
    
    CGFloat systemFontSize = [SSKFontType systemFontSize];
    SSKFontType *systemFont = [SSKFontType systemFontOfSize:systemFontSize];
    
    buttonNode.titleLabelNode = [SKLabelNode labelNodeWithFontNamed:nil];
    buttonNode.titleLabelNode.fontName = systemFont.fontName;
    buttonNode.titleLabelNode.fontSize = systemFontSize;
    buttonNode.titleLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    buttonNode.titleLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [buttonNode addChild:buttonNode.titleLabelNode];
    
    SSKEdgeInsetsType defaultBackgroundCapInsets = SSKEdgeInsetsMake(0, 0, 0, 0);
    buttonNode.backgroundNode = [SSKStretchableNode stretchableNodeWithSize:CGSizeZero
                                                                    texture:nil
                                                                  capInsets:defaultBackgroundCapInsets];
    [buttonNode addChild:buttonNode.backgroundNode];
    
    buttonNode.iconNode = [SKSpriteNode node];
    buttonNode.iconNode.anchorPoint = CGPointZero;
    [buttonNode addChild:buttonNode.iconNode];
    
    buttonNode.size = size;
    buttonNode.zPosition = 0;
    
    return buttonNode;
}

#pragma mark - Public API

- (void)addTarget:(id)target action:(SEL)action forState:(SSKButtonState)state
{
    if (!target || !action) {
        return;
    }
    
    NSMutableArray *targetActionPairs = [self targetActionPairsForState:state];
    SSKButtonTargetActionPair *pair = [SSKButtonTargetActionPair pairForTarget:target action:action];
    
    if ([targetActionPairs containsObject:pair]) {
        return;
    }
    
    [targetActionPairs addObject:pair];
}

- (void)removeTarget:(id)target forState:(SSKButtonState)state
{
    NSMutableArray *targetActionPairs = [self targetActionPairsForState:state];
    
    for (SSKButtonTargetActionPair *pair in targetActionPairs) {
        if (pair.target == target) {
            [targetActionPairs removeObject:pair];
            
            break;
        }
    }
}

- (SKColor *)backgroundColorForState:(SSKButtonState)state
{
    return [self.backgroundColors objectForKey:@(state)];
}

- (void)setBackgroundColor:(SKColor *)color forState:(SSKButtonState)state
{
    id objectToInsert = color;
    
    if (!objectToInsert) {
        objectToInsert = [NSNull null];
    }
    
    [self.backgroundColors setObject:objectToInsert forKey:@(state)];
    
    if (self.state == state) {
        [self updateLayout];
    }
}

- (SKTexture *)backgroundTextureForState:(SSKButtonState)state
{
    return [self.backgroundTextures objectForKey:@(state)];
}

- (void)setBackgroundTexture:(SKTexture *)texture forState:(SSKButtonState)state
{
    id objectToInsert = texture;
    
    if (!objectToInsert) {
        objectToInsert = [NSNull null];
    }
    
    [self.backgroundTextures setObject:objectToInsert forKey:@(state)];
    
    if (self.state == state) {
        [self updateLayout];
    }
}

- (SSKEdgeInsetsType)stretchableBackgoundCapInsetsForState:(SSKButtonState)state
{
    NSArray *capInsetsArray = [self.stretchableBackgroundTextureCapInsets objectForKey:@(state)];
    
    return SSKButtonNodeGetEdgeInsetsForArray(capInsetsArray);
}

- (void)setStretchableBackgroundCapInsets:(SSKEdgeInsetsType)capInsets forState:(SSKButtonState)state
{
    NSArray *capInsetsArray = SSKButtonNodeGetArrayForEdgeInsets(capInsets);
    
    [self.stretchableBackgroundTextureCapInsets setObject:capInsetsArray
                                                   forKey:@(state)];
    
    if (self.state == state) {
        [self updateLayout];
    }
}

- (SKTexture *)iconTextureForState:(SSKButtonState)state
{
    return [self.iconTextures objectForKey:@(state)];
}

- (void)setIconTexture:(SKTexture *)texture forState:(SSKButtonState)state
{
    id objectToInsert = texture;
    
    if (!objectToInsert) {
        objectToInsert = [NSNull null];
    }
    
    [self.iconTextures setObject:objectToInsert forKey:@(state)];
    
    if (self.state == state) {
        [self updateLayout];
    }
}

- (NSString *)titleForState:(SSKButtonState)state
{
    return [self.titles objectForKey:@(state)];
}

- (void)setTitle:(NSString *)title forState:(SSKButtonState)state
{
    id objectToInsert = title;
    
    if (!objectToInsert) {
        objectToInsert = [NSNull null];
    }
    
    [self.titles setObject:objectToInsert forKey:@(state)];
    
    if (self.state == state) {
        [self updateLayout];
    }
}

- (SSKEdgeInsetsType)titleEdgeInsetsForState:(SSKButtonState)state
{
    NSArray *edgeInsetsArray = [self.titleEdgeInsets objectForKey:@(state)];
    
    return SSKButtonNodeGetEdgeInsetsForArray(edgeInsetsArray);
}

- (void)setTitleEdgeInsets:(NSEdgeInsets)edgeInsets forState:(SSKButtonState)state
{
    NSArray *edgeInsetsArray = SSKButtonNodeGetArrayForEdgeInsets(edgeInsets);
    
    [self.titleEdgeInsets setObject:edgeInsetsArray
                             forKey:@(state)];
    
    if (self.state == state) {
        [self updateLayout];
    }
}

#pragma mark - Accessor overrides

- (void)setZPosition:(CGFloat)zPosition
{
    [super setZPosition:zPosition];
    
    self.backgroundNode.zPosition = zPosition;
    self.iconNode.zPosition = zPosition + 1;
    self.titleLabelNode.zPosition = zPosition + 1;
}

- (CGSize)size
{
    return self.backgroundNode.size;
}

- (void)setSize:(CGSize)size
{
    self.backgroundNode.size = size;
    
    [self updateLayout];
}

- (void)setState:(SSKButtonState)state
{
    if (!self.isEnabled) {
        state = SSKButtonStateDisabled;
    }
    
    if (_state == state) {
        return;
    }
    
    _state = state;
    
    if (state == SSKButtonStateSelected) {
        _selected = YES;
    } else if (state != SSKButtonStateHighlighted) {
        _selected = NO;
    }
    
    [self updateLayout];
    [self triggerActionsForState];
    
    if (self.selectionStyle == SSKButtonSelectionStyleNone) {
        if (state == SSKButtonStateSelected) {
            self.state = SSKButtonStateNormal;
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    if (_selected == selected) {
        return;
    }
    
    _selected = selected;
    
    if (selected) {
        self.state = SSKButtonStateSelected;
    } else {
        self.state = SSKButtonStateNormal;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled == enabled) {
        return;
    }
    
    _enabled = enabled;
    
    if (enabled) {
        self.state = SSKButtonStateNormal;
    } else {
        self.state = SSKButtonStateDisabled;
    }
}

#pragma mark - Utilities

- (NSMutableArray *)targetActionPairsForState:(SSKButtonState)state
{
    return [self.targetActionPairs objectForKey:@(state)];
}

- (void)updateLayout
{
    NSString *titleForState = [self titleForState:self.state];
    
    if (!titleForState && self.state != SSKButtonStateNormal) {
        titleForState = [self titleForState:SSKButtonStateNormal];
    }
    
    if (titleForState) {
        if (![titleForState isKindOfClass:[NSString class]]) {
            titleForState = @"";
        }
        
        self.titleLabelNode.text = titleForState;
    }
    
    SKTexture *iconTexture = [self iconTextureForState:self.state];
    
    if (!iconTexture && self.state != SSKButtonStateNormal) {
        iconTexture = [self iconTextureForState:SSKButtonStateNormal];
    }
    
    if (iconTexture) {
        if (![iconTexture isKindOfClass:[SKTexture class]]) {
            iconTexture = nil;
        }
        
        self.iconNode.texture = iconTexture;
        self.iconNode.size = iconTexture.size;
    }
    
    SKLabelHorizontalAlignmentMode labelAlignmentMode;
    
    if (self.iconNode.texture) {
        labelAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    } else {
        labelAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    }
    
    self.titleLabelNode.horizontalAlignmentMode = labelAlignmentMode;
    
    CGPoint titleNodePosition = self.titleLabelNode.position;
    
    if (self.iconNode.texture) {
        CGFloat iconLabelWidth = self.iconNode.size.width + self.iconLabelMargin + CGRectGetWidth(self.titleLabelNode.frame);
        
        CGPoint iconNodePosition = self.iconNode.position;
        iconNodePosition.x = floorf((self.size.width - iconLabelWidth) / 2);
        iconNodePosition.y = floorf((self.size.height - self.iconNode.size.height) / 2);
        self.iconNode.position = iconNodePosition;
        
        titleNodePosition.x = iconNodePosition.x + self.iconNode.size.width + self.iconLabelMargin;
    } else {
        titleNodePosition.x = floorf(self.size.width / 2);
    }
    
    titleNodePosition.y = floorf(self.size.height / 2);
    
    SSKEdgeInsetsType titleEdgeInsets;

    if ([self.titleEdgeInsets objectForKey:@(self.state)]) {
        titleEdgeInsets = [self titleEdgeInsetsForState:self.state];
    } else {
        titleEdgeInsets = [self titleEdgeInsetsForState:SSKButtonStateNormal];
    }
    
    titleNodePosition.y -= titleEdgeInsets.top;
    titleNodePosition.x += titleEdgeInsets.left;
    titleNodePosition.y += titleEdgeInsets.bottom;
    titleNodePosition.x -= titleEdgeInsets.right;
    
    self.titleLabelNode.position = titleNodePosition;
    
    SKTexture *backgroundTexture = [self backgroundTextureForState:self.state];
    
    if (!backgroundTexture && self.state != SSKButtonStateNormal) {
        backgroundTexture = [self backgroundTextureForState:SSKButtonStateNormal];
    }
    
    if (backgroundTexture) {
        if (![backgroundTexture isKindOfClass:[SKTexture class]]) {
            backgroundTexture = nil;
        }
        
        SSKEdgeInsetsType backgroundTextureCapInsets = SSKEdgeInsetsMake(0, 0, 0, 0);
        
        if ([self.stretchableBackgroundTextureCapInsets objectForKey:@(self.state)]) {
            backgroundTextureCapInsets = [self stretchableBackgoundCapInsetsForState:self.state];
        } else if (self.state != SSKButtonStateNormal) {
            backgroundTextureCapInsets = [self stretchableBackgoundCapInsetsForState:SSKButtonStateNormal];
        }
        
        [self.backgroundNode setTexture:backgroundTexture capInsets:backgroundTextureCapInsets];
    } else {
        SKColor *backgroundColor = [self backgroundColorForState:self.state];
        
        if (!backgroundColor && self.state != SSKButtonStateNormal) {
            backgroundColor = [self backgroundColorForState:SSKButtonStateNormal];
        }
        
        if (backgroundColor) {
            if (![backgroundColor isKindOfClass:[SKColor class]]) {
                backgroundColor = nil;
            }
            
            self.backgroundNode.texture = nil;
            self.backgroundNode.color = backgroundColor;
        }
    }
}

- (void)triggerActionsForState
{
    NSMutableArray *targetActionPairs = [self targetActionPairsForState:self.state];
    
    for (SSKButtonTargetActionPair *pair in targetActionPairs) {
        SEL selector = NSSelectorFromString(pair.actionSelectorString);
        
        NSMethodSignature *methodSignature = [pair.target methodSignatureForSelector:selector];
        
        NSAssert(methodSignature, @"Invalid selector \"%@\" for target %@", pair.actionSelectorString, pair.target);
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.target = pair.target;
        invocation.selector = selector;
        
        SSKButtonNode *_self = self;
        
        if ([methodSignature numberOfArguments] > 2) {
            [invocation setArgument:&_self atIndex:2];
        }
        
        [invocation invoke];
    }
}

#pragma mark - SSKInteractiveNode

- (void)pointInteractionWithType:(SSKInteractionType)type startedAtPoint:(CGPoint)point
{
    self.state = SSKButtonStateHighlighted;
}

- (void)pointInteractionCancelled
{
    self.state = SSKButtonStateNormal;
}

- (void)pointInteractionWithType:(SSKInteractionType)type endedAtPoint:(CGPoint)point
{
    if (self.selectionStyle == SSKButtonSelectionStyleToggle) {
        if (self.isSelected) {
            self.state = SSKButtonStateNormal;
            
            return;
        }
    }
    
    self.state = SSKButtonStateSelected;
}

@end
