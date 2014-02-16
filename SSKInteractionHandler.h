#import <Foundation/Foundation.h>
#import <SpriteKit/SKView.h>

/**
 *  Enum describing possible interaction types
 */
typedef enum : NSUInteger {
    /**
     *  The primary interaction type for the platform. On iOS, this is the
     *  only type of interaction, and corresponds to a touch. On OSX, this
     *  corresponds to a left mouse button click.
     */
    SSKInteractionTypePrimary,
    
    /**
     *  The secondary interaction type for the platform. This is only
     *  relevant for OSX, where it corresponds to a right mouse button click.
     */
    SSKInteractionTypeSecondary
} SSKInteractionType;

/**
 *  Protocol implemented by nodes to recieve interaction events
 */
@protocol SSKInteractiveNode <NSObject>

@optional

/**
 *  Sent to an interactive node when a point interaction started on it
 *
 *  @param type The type of interaction that was started.
 *  @param point The point (in the node's coordinate space), where the
 *  interaction took place.
 */
- (void)pointInteractionWithType:(SSKInteractionType)type startedAtPoint:(CGPoint)point;

/**
 *  Sent to an interactive node when a point interaction on it was cancelled
 *
 *  @discussion An interaction is considered cancelled whenever an interaction on the
 *  screen ended, and an interaction was started on a node, but not ended on the same node.
 *
 *  On iOS, this is also sent if the system considered the user's touch to be cancelled,
 *  such as if it moved off screen.
 */
- (void)pointInteractionCancelled;

/**
 *  Sent to an interactive node when a point interaction was ended on it
 *
 *  @param type The type of interaction that was ended.
 *  @param point The point (in the node's coordinate space) where the
 *  interaction took place.
 */
- (void)pointInteractionWithType:(SSKInteractionType)type endedAtPoint:(CGPoint)point;

@end

/**
 *  A multiplatform interaction handler that makes it easy to handle
 *  user interactions across both iOS & OSX in SpriteKit-powered games
 */
@interface SSKInteractionHandler : NSObject

@end

/**
 *  Category to add/remove interaction handlers to/from an SKView
 */
@interface SKView (SSKInteractionHandler)

/**
 *  Add an interaction handler to the view
 *
 *  @param interactionHandler The interaction handler to add
 *
 *  @discussion The interaction handler will add a transparent view to the view
 *  that it is added to. The interaction handler uses this view to observe user
 *  interactions.
 */
- (void)ssk_addInteractionHandler:(SSKInteractionHandler *)interactionHandler;

/**
 *  Remove an interaction handler from the view
 *
 *  @param interactionHandler The interaction handler to remove
 *
 *  @discussion When removed, the interaction handler will clear up and remove
 *  the view that it added when added to the view.
 */
- (void)ssk_removeInteractionHandler:(SSKInteractionHandler *)interactionHandler;

@end
