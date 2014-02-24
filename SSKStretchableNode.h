#import <SpriteKit/SpriteKit.h>
#import "SSKTileableNode.h"
#import "SSKMultiplatform.h"

#pragma mark - SSKStretchableNode

/**
 *  A node capable of stretching its texture according to its size.
 *  Using cap insets, it allows for cutting its texture up into tilable parts,
 *  to allow for graceful stretching without quality loss.
 *
 *  @discussion This class depends on SSKTilableNode.
 */
@interface SSKStretchableNode : SKNode

/**
 *  The current size of the node
 *
 *  @discussion Set this property to resize the node.
 *  Setting this property will reposition and resize the node's
 *  texture's tiled parts.
 */
@property (nonatomic) CGSize size;

/**
 *  The texture the node is currently using
 *
 *  @discussion Set this property to change the node's texture.
 *  Setting this property will redraw the node's tiled parts.
 */
@property (nonatomic, strong) SKTexture *texture;

/**
 *  Color that the node is tinted with
 *
 *  @discussion The default is nil, meaning that the node won't
 *  be tinted at all.
 */
@property (nonatomic, strong) SKColor *color;

/**
 *  The blending factor between the node's texture and color.
 *
 *  @discussion The valid interval is 0.0 - 1.0. Values above/below
 *  the valid interval will be clamped.
 */
@property (nonatomic) CGFloat colorBlendFactor;

/**
 *  Allocate and initialize a new instance of JSStretchableNode
 *
 *  @param size The size the node should have.
 *  @param imageName The name of an image that will be used for the
 *  node's texture.
 *  @param capInsets Edge insets defining the cap insets to use when
 *  streching the node's texture.
 */
+ (instancetype)stretchableNodeWithSize:(CGSize)size
                             imageNamed:(NSString *)imageName
                              capInsets:(SSKEdgeInsetsType)capInsets;

/**
 *  Allocate and initialize a new instance of JSStretchableNode
 *
 *  @param size The size the node should have.
 *  @param texture The texture to use for the node.
 *  @param capInsets Edge insets defining the cap insets to use when
 *  streching the node's texture.
 */
+ (instancetype)stretchableNodeWithSize:(CGSize)size
                                texture:(SKTexture *)texture
                              capInsets:(SSKEdgeInsetsType)capInsets;

/**
 *  Update the node's texture and cap insets
 *
 *  @param texture The new texture the node should have.
 *  @param capInsets The new cap insets to use when stretching
 *  the node's texture.
 *
 *  @discussion Invoking this method will redraw the node's tiled parts.
 */
- (void)setTexture:(SKTexture *)texture capInsets:(SSKEdgeInsetsType)capInsets;

@end

#pragma mark - SKActions

/**
 *  Convenience category for creating SKActions for resizing an
 *  instance of JSStrechableNode
 */
@interface SKAction (SSKStretchableNodeActions)

/**
 *  Resize an instance of JSStretchableNode to a new width, optionally
 *  animated over a duration
 *
 *  @param width The new width the node will have
 *  @param duration The duration of the action
 *
 *  @discussion This action can only be performed by an instance of SSKStretchableNode.
 */
+ (SKAction *)resizeStretchableNodeToWidth:(CGFloat)width duration:(NSTimeInterval)duration;

/**
 *  Resize an instance of JSStretchableNode to a new height, optionally
 *  animated over a duration
 *
 *  @param height The new height the node will have
 *  @param duration The duration of the action
 *
 *  @discussion This action can only be performed by an instance of SSKStretchableNode.
 */
+ (SKAction *)resizeStretchableNodeToHeight:(CGFloat)height duration:(NSTimeInterval)duration;

/**
 *  Resize an instance of JSStretchableNode to a new width and height, optionally
 *  animated over a duration
 *
 *  @param width The new width the node will have
 *  @param height The new height the node will have
 *  @param duration The duration of the action
 *
 *  @discussion This action can only be performed by an instance of SSKStretchableNode.
 */
+ (SKAction *)resizeStretchableNodeToWidth:(CGFloat)width
                                    height:(CGFloat)height
                                  duration:(NSTimeInterval)duration;

@end