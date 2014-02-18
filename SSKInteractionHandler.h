#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "SSKMultiplatform.h"

#pragma mark - Enums

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
 *  Enum describing various special keys available on a standard Mac keyboard
 */
typedef enum : NSUInteger {
    SSKSpecialKeyShift,
    SSKSpecialKeyControl,
    SSKSpecialKeyAlt,
    SSKSpecialKeyCommand,
    SSKSpecialKeyFn
} SSKSpecialKey;

#pragma mark - SSKInteractiveNode

/**
 *  Protocol implemented by nodes to receive interaction events
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

/**
 *  Sent to an interactive node when the on-screen pointer (mouse) was moved over it
 *
 *  @param point The point to which the pointer was moved
 *
 *  @discussion As OSX is the only platform that utilizes an on-screen pointer,
 *  this method is irrelevant for iOS.
 *
 *  @note Be sure to set acceptsMouseMovedEvents = YES on your application's key window
 *  in order to receive these type of events.
 */
- (void)pointerMovedInteractionAtPoint:(CGPoint)point;

@end

#pragma mark - SSKInteractiveScene

/**
 *  Protocol implemented by scenes to receive interaction events
 *
 *  @discussion Since all SKScenes are also SKNodes, scenes may also implement
 *  the <SSKInteractiveNode> protocol.
 */
@protocol SSKInteractiveScene <NSObject>

@optional

/**
 *  Sent to an interactive scene when a standard keyboard key was pressed
 *
 *  @param keyCode The key code of the key that was pressed
 */
- (void)keyboardKeyPressed:(unsigned short)keyCode;

/**
 *  Sent to an interactive scene when a standard keyboard key was released
 *
 *  @param keyCode The key code of the key that was released
 */
- (void)keyboardKeyReleased:(unsigned short)keyCode;

/**
 *  Sent to an interactive scene when a special keyboard key was pressed
 *
 *  @param specialKey The special key that was pressed
 *
 *  @discussion See SSKSpecialKey for available keys
 */
- (void)keyboardSpecialKeyPressed:(SSKSpecialKey)specialKey;

/**
 *  Sent to an interactive scene when a special keyboard key was released
 *
 *  @param specialKey The special key that was released
 *
 *  @discussion See SSKSpecialKey for available keys
 */
- (void)keyboardSpecialKeyReleased:(SSKSpecialKey)specialKey;

@end

#pragma mark - SSKInteractionHandler

/**
 *  A multiplatform interaction handler that makes it easy to handle
 *  user interactions across both iOS & OSX in SpriteKit-powered games
 *
 *  @discussion To use SSKInteractionHandler, create a new instance of it and
 *  hold onto it strongly. Then, add your interaction handler to any SKView
 *  you want it to handle interactions for; using -ssk_addInteractionHandler:.
 *  Finally, make the scenes/nodes you wish to receive interaction events for
 *  conform to the <SSKInteractiveNode> protocol and implement any methods
 *  corresponding to the events you wish to receive.
 *
 *  For more information see <SSKInteractiveNode>.
 */
@interface SSKInteractionHandler : NSObject

@end

#pragma mark - SKView+SSKInteractionHandler

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
