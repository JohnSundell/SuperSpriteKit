#import "SSKInteractionHandler.h"

typedef enum : NSUInteger {
    SSKInteractionHandlerEventStarted,
    SSKInteractionHandlerEventCancelled,
    SSKInteractionHandlerEventEnded
} SSKInteractionHandlerEvent;

#pragma mark - SSKInteractionView interface

#if TARGET_OS_IPHONE
@interface SSKInteractionView : UIView
#else
@interface SSKInteractionView : NSView
#endif

@property (nonatomic, weak) SSKInteractionHandler *interactionHandler;
@property (nonatomic, strong, readonly) SKScene *scene;

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
    NSArray *nodesAtPoint = [self.view.scene nodesAtPoint:point];
    
    for (SKNode *node in nodesAtPoint) {
        if (![node conformsToProtocol:@protocol(SSKInteractiveNode)]) {
            continue;
        }
        
        SKNode<SSKInteractiveNode> *interactiveNode = (SKNode<SSKInteractiveNode> *)node;
        CGPoint nodePoint = [interactiveNode convertPoint:point fromNode:self.view.scene];
        
        switch (event) {
            case SSKInteractionHandlerEventStarted: {
                [self.currentInteractionNodes addObject:interactiveNode];
                
                if ([interactiveNode respondsToSelector:@selector(pointInteractionWithType:startedAtPoint:)]) {
                    [interactiveNode pointInteractionWithType:type startedAtPoint:nodePoint];
                }
            }
                break;
            case SSKInteractionHandlerEventEnded: {
                [self.currentInteractionNodes removeObject:interactiveNode];
                
                if ([interactiveNode respondsToSelector:@selector(pointInteractionWithType:endedAtPoint:)]) {
                    [interactiveNode pointInteractionWithType:type endedAtPoint:nodePoint];
                }
            }
                break;
            case SSKInteractionHandlerEventCancelled:
                break;
        }
    }
    
    if (event == SSKInteractionHandlerEventEnded) {
        for (SKNode<SSKInteractiveNode> *node in self.currentInteractionNodes) {
            if ([node respondsToSelector:@selector(pointInteractionCancelled)]) {
                [node pointInteractionCancelled];
            }
        }
        
        [self.currentInteractionNodes removeAllObjects];
    }
}

@end

#pragma mark - SSKInteractionView implementation

@implementation SSKInteractionView

- (instancetype)initWithFrame:(CGRect)frame interactionHandler:(SSKInteractionHandler *)interactionHandler
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    _interactionHandler = interactionHandler;
    
    return self;
}

- (SKScene *)scene
{
    return self.interactionHandler.view.scene;
}

#if TARGET_OS_IPHONE

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
