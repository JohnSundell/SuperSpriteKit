#import "SSKInteractionHandler.h"

typedef enum : NSUInteger {
    SSKInteractionHandlerEventStarted,
    SSKInteractionHandlerEventCancelled,
    SSKInteractionHandlerEventEnded
} SSKInteractionHandlerEvent;

static BOOL SSKEventModifierFlagsContainNewKeyDown(NSUInteger newFlags, NSUInteger lastFlags, NSUInteger keyMask)
{
    if (newFlags & keyMask) {
        if (!(lastFlags & keyMask)) {
            return YES;
        }
    }
    
    return NO;
}

static BOOL SSKEventModifierFlagsContainNewKeyUp(NSUInteger newFlags, NSUInteger lastFlags, NSUInteger keyMask)
{
    if (lastFlags & keyMask) {
        if (!(newFlags & keyMask)) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - SSKInteractionView interface

#if TARGET_OS_IPHONE
@interface SSKInteractionView : UIView
#else
@interface SSKInteractionView : NSView
#endif

@property (nonatomic, weak) SSKInteractionHandler *interactionHandler;
@property (nonatomic, strong, readonly) SKScene *scene;
@property (nonatomic) NSUInteger eventModifierFlags;

- (instancetype)initWithFrame:(CGRect)frame interactionHandler:(SSKInteractionHandler *)interactionHandler;

@end

#pragma mark - SSKInteractionHandler implementation

@interface SSKInteractionHandler()

@property (nonatomic, strong, readonly) SKView *view;
@property (nonatomic, strong) SSKInteractionView *interactionView;
@property (nonatomic, strong) NSHashTable *currentInteractionNodes;

@end

@implementation SSKInteractionHandler

- (id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _currentInteractionNodes = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    self.interactionView = [[SSKInteractionView alloc] initWithFrame:view.bounds interactionHandler:self];
    [view addSubview:self.interactionView];
}

- (void)didMoveFromView:(SKView *)view
{
    if (self.interactionView.superview != view) {
        return;
    }
    
    [self.interactionView removeFromSuperview];
    self.interactionView = nil;
}

- (SKView *)view
{
    return (SKView *)self.interactionView.superview;
}

- (void)handlePointInteractionEvent:(SSKInteractionHandlerEvent)event type:(SSKInteractionType)type point:(CGPoint)point
{
    switch (event) {
        case SSKInteractionHandlerEventStarted: {
            [self forEachInteractiveNodeAtPoint:point
                         thatRespondsToSelector:@selector(pointInteractionWithType:startedAtPoint:)
                                       runBlock:^(SKNode<SSKInteractiveNode> *node) {
                                           [self.currentInteractionNodes addObject:node];
                                           
                                           CGPoint nodePoint = [node convertPoint:point fromNode:self.view.scene];
                                           [node pointInteractionWithType:type startedAtPoint:nodePoint];
                                       }];
            
            if ([self.view.scene conformsToProtocol:@protocol(SSKInteractiveNode)]) {
                if ([self.view.scene respondsToSelector:@selector(pointInteractionWithType:startedAtPoint:)]) {
                    [(SKView<SSKInteractiveNode> *)self.view.scene pointInteractionWithType:type startedAtPoint:point];
                }
            }
        }
            break;
        case SSKInteractionHandlerEventCancelled:
            [self pointInteractionCancelledOrEnded];
            
            if ([self.view.scene conformsToProtocol:@protocol(SSKInteractiveNode)]) {
                if ([self.view.scene respondsToSelector:@selector(pointInteractionCancelled)]) {
                    [(SKView<SSKInteractiveNode> *)self.view.scene pointInteractionCancelled];
                }
            }
            
            break;
        case SSKInteractionHandlerEventEnded: {
            [self forEachInteractiveNodeAtPoint:point
                         thatRespondsToSelector:@selector(pointInteractionWithType:endedAtPoint:)
                                       runBlock:^(SKNode<SSKInteractiveNode> *node) {
                                           [self.currentInteractionNodes removeObject:node];
                                           
                                           CGPoint nodePoint = [node convertPoint:point fromNode:self.view.scene];
                                           [node pointInteractionWithType:type endedAtPoint:nodePoint];
                                       }];
            
            [self pointInteractionCancelledOrEnded];
            
            if ([self.view.scene conformsToProtocol:@protocol(SSKInteractiveNode)]) {
                if ([self.view.scene respondsToSelector:@selector(pointInteractionWithType:endedAtPoint:)]) {
                    [(SKView<SSKInteractiveNode> *)self.view.scene pointInteractionWithType:type endedAtPoint:point];
                }
            }
        }
            break;
    }
}

- (void)pointInteractionCancelledOrEnded
{
    for (SKNode<SSKInteractiveNode> *node in self.currentInteractionNodes) {
        if ([node respondsToSelector:@selector(pointInteractionCancelled)]) {
            [node pointInteractionCancelled];
        }
    }
    
    [self.currentInteractionNodes removeAllObjects];
}

- (void)handlePointerMovedEventAtPoint:(CGPoint)point
{
    [self forEachInteractiveNodeAtPoint:point
                 thatRespondsToSelector:@selector(pointerMovedInteractionAtPoint:)
                               runBlock:^(SKNode<SSKInteractiveNode> *node) {
                                   CGPoint nodePoint = [node convertPoint:point fromNode:self.view.scene];
                                   [node pointerMovedInteractionAtPoint:nodePoint];
                               }];
    
    if ([self.view.scene conformsToProtocol:@protocol(SSKInteractiveNode)]) {
        if ([self.view.scene respondsToSelector:@selector(pointerMovedInteractionAtPoint:)]) {
            [(SKView<SSKInteractiveNode> *)self.view.scene pointerMovedInteractionAtPoint:point];
        }
    }
}

- (void)forEachInteractiveNodeAtPoint:(CGPoint)point thatRespondsToSelector:(SEL)selector runBlock:(void(^)(SKNode<SSKInteractiveNode> *node))block
{
    NSAssert(block, @"A block must be supplied");
    
    NSArray *nodesAtPoint = [self.view.scene nodesAtPoint:point];
    
    for (SKNode *node in nodesAtPoint) {
        if (![node conformsToProtocol:@protocol(SSKInteractiveNode)]) {
            continue;
        }
        
        if ([node respondsToSelector:selector]) {
            block((SKNode<SSKInteractiveNode> *)node);
        }
    }
}

- (void)handleKeyboardEvent:(SSKInteractionHandlerEvent)event keyCode:(unsigned short)keyCode
{
    if (![self.view.scene conformsToProtocol:@protocol(SSKInteractiveScene)]) {
        return;
    }
    
    SKScene<SSKInteractiveScene> *interactiveScene = (SKScene<SSKInteractiveScene> *)self.view.scene;
    
    switch (event) {
        case SSKInteractionHandlerEventStarted:
            if ([interactiveScene respondsToSelector:@selector(keyboardKeyPressed:)]) {
                [interactiveScene keyboardKeyPressed:keyCode];
            }
            
            break;
        case SSKInteractionHandlerEventEnded:
            if ([interactiveScene respondsToSelector:@selector(keyboardKeyReleased:)]) {
                [interactiveScene keyboardKeyReleased:keyCode];
            }
            
            break;
        case SSKInteractionHandlerEventCancelled:
            break;
    }
}

- (void)handleKeyboardEvent:(SSKInteractionHandlerEvent)event specialKey:(SSKSpecialKey)specialKey
{
    if (![self.view.scene conformsToProtocol:@protocol(SSKInteractiveScene)]) {
        return;
    }
    
    SKScene<SSKInteractiveScene> *interactiveScene = (SKScene<SSKInteractiveScene> *)self.view.scene;
    
    switch (event) {
        case SSKInteractionHandlerEventStarted:
            if ([interactiveScene respondsToSelector:@selector(keyboardSpecialKeyPressed:)]) {
                [interactiveScene keyboardSpecialKeyPressed:specialKey];
            }
            
            break;
        case SSKInteractionHandlerEventEnded:
            if ([interactiveScene respondsToSelector:@selector(keyboardSpecialKeyReleased:)]) {
                [interactiveScene keyboardSpecialKeyReleased:specialKey];
            }
            
            break;
        case SSKInteractionHandlerEventCancelled:
            break;
    }
}

@end

#pragma mark - SSKInteractionView implementation

@implementation SSKInteractionView

- (instancetype)initWithFrame:(CGRect)frame interactionHandler:(SSKInteractionHandler *)interactionHandler
{
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    
    _interactionHandler = interactionHandler;
    
    return self;
}

- (SKScene *)scene
{
    return self.interactionHandler.view.scene;
}

#if TARGET_OS_IPHONE

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        [self.interactionHandler handlePointInteractionEvent:SSKInteractionHandlerEventStarted
                                                        type:SSKInteractionTypePrimary
                                                       point:[touch locationInNode:self.scene]];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        [self.interactionHandler handlePointInteractionEvent:SSKInteractionHandlerEventCancelled
                                                        type:SSKInteractionTypePrimary
                                                       point:[touch locationInNode:self.scene]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        [self.interactionHandler handlePointInteractionEvent:SSKInteractionHandlerEventEnded
                                                        type:SSKInteractionTypePrimary
                                                       point:[touch locationInNode:self.scene]];
    }
}

#else

#pragma mark - Mouse handling

- (void)mouseDown:(NSEvent *)event
{
    [self.window makeFirstResponder:self];
    
    [self.interactionHandler handlePointInteractionEvent:SSKInteractionHandlerEventStarted
                                                    type:SSKInteractionTypePrimary
                                                   point:[event locationInNode:self.scene]];
}

- (void)rightMouseDown:(NSEvent *)event
{
    [self.window makeFirstResponder:self];
    
    [self.interactionHandler handlePointInteractionEvent:SSKInteractionHandlerEventStarted
                                                    type:SSKInteractionTypeSecondary
                                                   point:[event locationInNode:self.scene]];
}

- (void)mouseUp:(NSEvent *)event
{
    [self.interactionHandler handlePointInteractionEvent:SSKInteractionHandlerEventEnded
                                                    type:SSKInteractionTypePrimary
                                                   point:[event locationInNode:self.scene]];
}

- (void)rightMouseUp:(NSEvent *)event
{
    [self.interactionHandler handlePointInteractionEvent:SSKInteractionHandlerEventEnded
                                                    type:SSKInteractionTypeSecondary
                                                   point:[event locationInNode:self.scene]];
}

- (void)mouseMoved:(NSEvent *)event
{
    [self.interactionHandler handlePointerMovedEventAtPoint:[event locationInNode:self.scene]];
}

#pragma mark - Keyboard handling

- (void)keyDown:(NSEvent *)event
{
    [self.interactionHandler handleKeyboardEvent:SSKInteractionHandlerEventStarted
                                         keyCode:[event keyCode]];
}

- (void)keyUp:(NSEvent *)event
{
    [self.interactionHandler handleKeyboardEvent:SSKInteractionHandlerEventEnded
                                         keyCode:[event keyCode]];
}

- (void)flagsChanged:(NSEvent *)event
{
    self.eventModifierFlags = [event modifierFlags];
}

- (void)setEventModifierFlags:(NSUInteger)eventModifierFlags
{
    if (_eventModifierFlags == eventModifierFlags) {
        return;
    }
    
    NSArray *specialKeyMasks = @[
        @(NSShiftKeyMask),
        @(NSControlKeyMask),
        @(NSAlternateKeyMask),
        @(NSCommandKeyMask),
        @(NSFunctionKeyMask)
    ];
    
    for (NSNumber *encodedSpecialKeyMask in specialKeyMasks) {
        NSUInteger specialKeyMask = [encodedSpecialKeyMask unsignedIntegerValue];
        SSKSpecialKey specialKey = 0;
        
        switch (specialKeyMask) {
            case NSShiftKeyMask:
                specialKey = SSKSpecialKeyShift;
                break;
            case NSControlKeyMask:
                specialKey = SSKSpecialKeyControl;
                break;
            case NSAlternateKeyMask:
                specialKey = SSKSpecialKeyAlt;
                break;
            case NSCommandKeyMask:
                specialKey = SSKSpecialKeyCommand;
                break;
            case NSFunctionKeyMask:
                specialKey = SSKSpecialKeyFn;
                break;
        }
        
        if (SSKEventModifierFlagsContainNewKeyDown(eventModifierFlags, _eventModifierFlags, specialKeyMask)) {
            [self.interactionHandler handleKeyboardEvent:SSKInteractionHandlerEventStarted
                                              specialKey:specialKey];
        } else if (SSKEventModifierFlagsContainNewKeyUp(eventModifierFlags, _eventModifierFlags, specialKeyMask)) {
            [self.interactionHandler handleKeyboardEvent:SSKInteractionHandlerEventEnded
                                              specialKey:specialKey];
        }
    }
    
    _eventModifierFlags = eventModifierFlags;
}

#endif

@end

#pragma mark - SKView+SSKInteractionHandler

@implementation SKView (SSKInteractionHandler)

- (void)ssk_addInteractionHandler:(SSKInteractionHandler *)interactionHandler
{
    [interactionHandler didMoveToView:self];
}

- (void)ssk_removeInteractionHandler:(SSKInteractionHandler *)interactionHandler
{
    [interactionHandler didMoveFromView:self];
}

@end
