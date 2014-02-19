#import <SpriteKit/SpriteKit.h>

/**
 *  Category that adds tag support to instances of SKNode
 *
 *  @discussion Tags allow you to group your nodes using
 *  integer identifiers, and query for a node's child nodes,
 *  or nodes at a point, that has a certain tag.
 *
 *  This category uses SKNode's userData dictionary to store
 *  the tag information, and thus requires other categories
 *  and node classes using this category to be good citizens
 *  regarding this dictionary. That is, not overwrite it
 *  when initialized, and instead just appending data to it.
 *
 *  The tag will be stored under the key "SuperSpriteKit_Tag"
 *  in the node's userData dictionary.
 */
@interface SKNode (SSKTags)

/**
 *  The node's tag
 *
 *  @discussion Defaults to 0
 */
@property (nonatomic, setter = ssk_setTag:) NSUInteger ssk_tag;

/**
 *  Get the first direct child node of this node that has a certain tag
 *
 *  @param tag The tag to look for
 *
 *  @return The node that was found, or nil if no node was found
 */
- (SKNode *)ssk_childNodeWithTag:(NSUInteger)tag;

/**
 *  Get the first child node of this node that has a certain tag, optionally
 *  performing a recusive search, looking at all nodes within this node's
 *  tree hierarchy, until a node with the specified tag is found.
 *
 *  @param tag The tag to look for
 *  @param recursive Whether a recrusive search should be performed
 *
 *  @discussion Since a full recurisve search can be quite expensive to
 *  perform (especially when complex and deep node trees are used), consider
 *  disabling recursive searching if only the direct children of this node
 *  should be searched.
 */
- (SKNode *)ssk_childNodeWithTag:(NSUInteger)tag recursive:(BOOL)recursive;

/**
 *  Get all direct child nodes of this node that has a certain tag
 *
 *  @param tag The tag to look for
 */
- (NSArray *)ssk_childNodesWithTag:(NSUInteger)tag;

/**
 *  Get all child nodes of this node that has a certain tag, optionally
 *  performing a recusive search, looking at all nodes within this node's
 *  tree hierarchy.
 *
 *  @param tag The tag to look for
 *  @param recursive Whether a recrusive search should be performed
 *
 *  @discussion Since a full recurisve search can be quite expensive to
 *  perform (especially when complex and deep node trees are used), consider
 *  disabling recursive searching if only the direct children of this node
 *  should be searched, or use the -ssk_childNodeWithTag:recursive: API, to
 *  return the first found child who has the tag that is being searched for.
 */
- (NSArray *)ssk_childNodesWithTag:(NSUInteger)tag recursive:(BOOL)recursive;

/**
 *  Get all child nodes at a point that has a certain tag
 *
 *  @param tag The tag to look for
 *
 *  @discussion This method will find nodes in the node's full tree hierarchy,
 *  using SpriteKit's built-in -nodesAtPoint:.
 */
- (NSArray *)ssk_nodesAtPoint:(CGPoint)point withTag:(NSUInteger)tag;

@end
