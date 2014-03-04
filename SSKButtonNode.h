#import <SpriteKit/SpriteKit.h>
#import "SSKMultiplatform.h"
#import "SSKInteractionHandler.h"
#import "SSKStretchableNode.h"

#pragma mark - Enums

/**
 *  Enum describing various states a SSKButton instance can be in
 */
typedef enum : NSUInteger {
    /**
     *  The normal state, when the button is idle and unselected
     */
    SSKButtonStateNormal,
    
    /**
     *  The state that the button will be in when the user is currently
     *  interacting with it.
     */
    SSKButtonStateHighlighted,
    
    /**
     *  The state the button will be in when it's currently selected.
     *  See SSKButtonSelectionStyle for more information about selection.
     */
    SSKButtonStateSelected,
    
    /**
     *  The state the button will be in when it has been disabled when
     *  setting the "enabled" property to NO.
     */
    SSKButtonStateDisabled
} SSKButtonState;

/**
 *  Enum describing various selection styles a SSKButton instance can use
 */
typedef enum : NSUInteger {
    /**
     *  This style causes the button never to appear in a selected state
     *  visually. Actions will still be run for the SSKButtonStateSelected
     *  state though. Whenever selected, the button will simply revert to
     *  its normal state as soon as interactions on it stopped.
     */
    SSKButtonSelectionStyleNone,
    
    /**
     *  This style will cause the button to remain selected once selected
     *  by a user interaction. The "selected" property on the button must
     *  be programmatically set to NO, before the button will return to its
     *  normal state, or the "state" property set to another value.
     */
    SSKButtonSelectionStyleRemainSelected,
    
    /**
     *  This style will cause the button to toggle between its selected
     *  and normal state whenever a user interaction ended on it.
     */
    SSKButtonSelectionStyleToggle
} SSKButtonSelectionStyle;

#pragma mark - SSKButtonNode

/**
 *  A node that acts like a button-type control, well suited for
 *  in-game user interfaces
 *
 *  @discussion It's API is heavily inspired by UI/NSButton.
 *
 *  @note To be able to respond to user interactions, SSKButtonNode
 *  requires the SKView it's being displayed in to have an SSKInteractionHandler
 *  attached to it. For more information about interaction handling in
 *  SuperSpriteKit, see SSKInteractionHandler.
 */
@interface SSKButtonNode : SKNode <SSKInteractiveNode>

/**
 *  The size of the button
 */
@property (nonatomic) CGSize size;

/**
 *  The selection style of the button
 *
 *  @discussion See SSKButtonSelectionStyle for more information.
 *
 *  The selection style will cause the button to behave differently
 *  when moving in between different states as the user interacts
 *  with it.
 *
 *  Regardless of selection style, the button will always go to
 *  the SSKButtonStateHighlighted whenever a user interaction
 *  is occuring on it.
 */
@property (nonatomic) SSKButtonSelectionStyle selectionStyle;

/**
 *  The current state of the button
 *
 *  @discussion See SSKButtonState for more information.
 *
 *  The state of the button is automatically set as the user interacts
 *  with it, depending on the chosen selection style. The value of this
 *  property may also be set programmatically to change the button's state.
 */
@property (nonatomic) SSKButtonState state;

/**
 *  Whether the button is currently enabled
 *
 *  @discussion Setting this to NO will cause the button to go to the
 *  SSKButtonStateDisabled state. Setting it back to YES after that will
 *  cause the button to go to the SSKButtonStateNormal state.
 *
 *  Programmatically setting the button's state to SSKButtonStateDisabled
 *  will not affect the value of this property.
 */
@property (nonatomic, getter = isEnabled) BOOL enabled;

/**
 *  Whether the button is currently selected
 *
 *  @discussion The value of this property is automatically changed as
 *  the button moves in between different states according to its selection style.
 *
 *  Setting this to YES will cause the button to go to the SSKButtonStateSelected
 *  state. Setting it to NO will cause the button to go the SSKButtonStateNormal state.
 */
@property (nonatomic, getter = isSelected) BOOL selected;

/**
 *  The margin between the button's icon and title if they both exist
 */
@property (nonatomic) CGFloat iconLabelMargin;

/**
 *  The label node used to draw the button's title
 */
@property (nonatomic, strong, readonly) SKLabelNode *titleLabelNode;

/**
 *  Allocate & initialize an instance of SSKButtonNode
 *
 *  @param size The size the button should have
 */
+ (instancetype)buttonNodeWithSize:(CGSize)size;

#pragma mark Targets & actions

/**
 *  Add a target & action that should be called when the button enters a state
 *
 *  @param target The target to send a message to
 *  @param action The message to send to the target
 *  @param state The state to trigger this action for
 */
- (void)addTarget:(id)target
           action:(SEL)action
         forState:(SSKButtonState)state;

/**
 *  Remove a target for a state
 *
 *  @param target The target to remove
 *  @param state The state for which to remove the target
 */
- (void)removeTarget:(id)target
            forState:(SSKButtonState)state;

#pragma mark Backgrounds

/**
 *  Return the background color for a state
 *
 *  @param state The state to get the background color for
 *
 *  @return An SKColor instance representing the background
 *  color for the specified state, if such a definition exists.
 *
 *  Nil will be returned if no definition exists at all, and
 *  an instance of NSNull will be returned if nil or NSNull has
 *  been specified as the color for the state.
 */
- (SKColor *)backgroundColorForState:(SSKButtonState)state;

/**
 *  Set the background color for a state
 *
 *  @param color The background color to set
 *  @param state The state to set the background color for
 *
 *  @discussion The background color for a state will only be used if
 *  that state does not have a background texture assigned to it.
 *
 *  Whenever a state doesn't have a background color, or a background
 *  texture assigned to it, the background color or texture (depending
 *  on what's assigned) for the SSKButtonStateNormal state will be used.
 *
 *  To disable this behavior for a state, set the background color for
 *  that state to nil or NSNull.
 */
- (void)setBackgroundColor:(SKColor *)color
                  forState:(SSKButtonState)state;

/**
 *  Return the background texture for a state
 *
 *  @param state The state to get the background texture for
 *
 *  @return An SKTexture instance representing the background
 *  texture for the specified state, if such a definition exists.
 *
 *  Nil will be returned if no definition exists at all, and
 *  an instance of NSNull will be returned if nil or NSNull has
 *  been specified as the background texture for the state.
 */
- (SKTexture *)backgroundTextureForState:(SSKButtonState)state;

/**
 *  Set the background texture for a state
 *
 *  @param texture The background texture to set
 *  @param state The state to set the background texture for
 *
 *  @discussion The button will always use the background texture assigned to
 *  its current state if set, and fall back to any set background color when it's not.
 *  
 *  Whenever a state doesn't have a background texture, or a
 *  background color assigned to it, the background color or texture (depending
 *  on what's assigned) for the SSKButtonStateNormal state will be used.
 *
 *  To disable this behavior for a state, set the background texture for
 *  that state to nil or NSNull.
 */
- (void)setBackgroundTexture:(SKTexture *)texture
                    forState:(SSKButtonState)state;

/**
 *  Return the cap insets used to stretch the background texture for a state
 *
 *  @param state The state to get the stretchable background cap insets for
 *
 *  @discussion See the documentation for SSKStretchableNode for an explanation
 *  on how texture streching works in SuperSpriteKit. The default value for every
 *  state is an edge insets struct with all of its members set to zero.
 */
- (SSKEdgeInsetsType)stretchableBackgoundCapInsetsForState:(SSKButtonState)state;

/**
 *  Set the cap insets used to stretch the background texture for a state
 *
 *  @param capInsets The cap insets to use for this state
 *  @param state The state to set the stretchable background cap insets for
 *
 *  @discussion You only need to use this API if you actually want the button's
 *  background texture to stretch.
 *
 *  See the documentation for SSKStretchableNode for an explanation
 *  on how texture streching works in SuperSpriteKit.
 */
- (void)setStretchableBackgroundCapInsets:(SSKEdgeInsetsType)capInsets
                                 forState:(SSKButtonState)state;

#pragma mark Icons & titles

/**
 *  Return the texture used for the button's icon for a state
 *
 *  @param state The state to get the icon texture for
 *
 *  @return An SKTexture instance representing the icon texture
 *  for the specified state, if such a definition exists.
 *
 *  Nil will be returned if no definition exists at all, and
 *  an instance of NSNull will be returned if nil or NSNull has
 *  been specified as the icon texture for the state.
 */
- (SKTexture *)iconTextureForState:(SSKButtonState)state;

/**
 *  Set the texture used for the button's icon for a state
 *
 *  @param texture The icon texture to set
 *  @param state The state to set the icon texture for
 *
 *  Whenever a state doesn't have a icon texture, the icon texture for
 *  the SSKButtonStateNormal state will be used.
 *
 *  To disable this behavior for a state, set the icon texture for
 *  that state to nil or NSNull.
 */
- (void)setIconTexture:(SKTexture *)texture
              forState:(SSKButtonState)state;

/**
 *  Return the title for a state
 *
 *  @param state The state to get the title for
 *
 *  @return An NSString instance representing the title for the specified
 *  state, if such a definition exists.
 *
 *  Nil will be returned if no definition exists at all, and
 *  an instance of NSNull will be returned if nil or NSNull has
 *  been specified as the icon texture for the state.
 */
- (NSString *)titleForState:(SSKButtonState)state;

/**
 *  Set the title for a state
 *
 *  @param title The title to set
 *  @param state The state to set the title for
 *
 *  Whenever a state doesn't have a title assigned to it, the title for
 *  the SSKButtonStateNormal state will be used.
 *
 *  To disable this behavior for a state, set the title for
 *  that state to nil or NSNull.
 */
- (void)setTitle:(NSString *)title
        forState:(SSKButtonState)state;

#pragma mark Layout

/**
 *  Update the button's layout, according to its layout properties
 *
 *  @discussion You don't have to call this method manually, as it gets
 *  called every time you update a property that requires the button to
 *  relayout itself.
 *
 *  You may override this method in any SSKButtonNode subclass to
 *  apply your own layout to the button.
 */
- (void)updateLayout;

@end
