#import <SpriteKit/SpriteKit.h>

/**
 *  A node capable of seamlessly tiling its texture according to its size
 */
@interface SSKTileableNode : SKNode

/**
 *  The current size of the node
 *
 *  @discussion Set this property to resize the node.
 *  Setting this property will update the node's tiled textures.
 */
@property (nonatomic) CGSize size;

/**
 *  The texture the node is currently using
 *
 *  @discussion Set this property to change the node's texture.
 *  Setting this property will redraw the node's tiled textures.
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
 *  Allocate and initialize a new instance of SSKTileableNode
 *
 *  @param size The size the node should have
 *  @param imageName The name of an image that will be used for the
 *  node's texture. If this parameter is nil, this method will return
 *  nil, and no node will be created.
 */
+ (instancetype)tileableNodeWithSize:(CGSize)size
                          imageNamed:(NSString *)imageName;

/**
 *  Allocate and initialize a new instance of SSKTileableNode
 *
 *  @param size The size the node should have
 *  @param texture The texture to use for the node. If this parameter
 *  is nil, this method will return nil, and no node will be created.
 */
+ (instancetype)tileableNodeWithSize:(CGSize)size
                             texture:(SKTexture *)texture;

@end

#pragma mark - SKActions

/**
 *  Convenience category for creating SKActions for resizing an
 *  instance of SSKTileableNode
 */
@interface SKAction (SSKTileableNodeActions)

/**
 *  Resize an instance of SSKTileableNode to a new width, optionally
 *  animated over a duration
 *
 *  @param width The new width the node will have
 *  @param duration The duration of the action
 *
 *  @discussion This action can only be performed by an instance of SSKTileableNode.
 */
+ (SKAction *)resizeTileableNodeToWidth:(CGFloat)width duration:(NSTimeInterval)duration;

/**
 *  Resize an instance of SSKTileableNode to a new height, optionally
 *  animated over a duration
 *
 *  @param height The new height the node will have
 *  @param duration The duration of the action
 *
 *  @discussion This action can only be performed by an instance of SSKTileableNode.
 */
+ (SKAction *)resizeTileableNodeToHeight:(CGFloat)height duration:(NSTimeInterval)duration;

/**
 *  Resize an instance of SSKTileableNode to a new width and height, optionally
 *  animated over a duration
 *
 *  @param width The new width the node will have
 *  @param height The new height the node will have
 *  @param duration The duration of the action
 *
 *  @discussion This action can only be performed by an instance of SSKTileableNode.
 */
+ (SKAction *)resizeTileableNodeToWidth:(CGFloat)width
                                 height:(CGFloat)height
                               duration:(NSTimeInterval)duration;

@end
