#import <SpriteKit/SpriteKit.h>

/**
 *  Block type used for completion handlers by this category
 */
typedef dispatch_block_t SSKAnimationCompletionBlock;

/**
 *  The key used by this category for animation actions
 */
extern NSString * const SSKAnimationActionKey;

/**
 *  Generate an array of SKTexture instances for an animation
 *
 *  @param atlas The texture atlas in which the frame textures for
 *  the animations are contained, or nil if no texture atlas is used.
 *  @param animationName The name of the animation. See the @discussion of this
 *  function for the naming scheme that is assumed.
 *  @param numberOfFrames The number of frames that the animation has.
 *
 *  @discussion This function assumes that the frame textures are named according
 *  to the following convention; <animationName>-<frameNumber>. So for an animation
 *  called "attack", which has 2 frames, the frame textures would be called "attack-0"
 *  and "attack-1".
 *
 *  When a texture cannot be found, an error message is outputted in the log, but no
 *  exception is thrown.
 */
extern NSArray *SSKAnimationTexturesFromAtlas(SKTextureAtlas *atlas, NSString *animationName, NSUInteger numberOfFrames);

/**
 *  Category that enables easy sprite node animations
 */
@interface SKSpriteNode (SSKAnimation)

/**
 *  Make the sprite node display an animation with a set of textues
 *
 *  @param textures The textures to animate with. The array is assumed
 *  to only contain SKTexture instances. See the SSKAnimationTexturesFromAtlas
 *  function for en easy way to generate these textures.
 *  @param duration The duration of each cycle of the animation.
 *  @param repeat Whether the animation should be repeated or not.
 *  @param resize Whether the sprite node should be resized to fit each texture's
 *  size when animating.
 *  @param onComplete A completion block to be run when the animation has finished.
 *  This parameter is ignored if repeat is set to YES.
 *
 *  @discussion If the textures array only contains 1 item, that texture is simply
 *  assigned to the sprite, without running an animation action.
 */
- (void)ssk_animateWithTextures:(NSArray *)textures
                       duration:(NSTimeInterval)duration
                         repeat:(BOOL)repeat
                         resize:(BOOL)resize
                     onComplete:(SSKAnimationCompletionBlock)onComplete;

@end
