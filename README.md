SuperSpriteKit
==============

#### Extensions to Apple's SpriteKit game engine

(The name is more of a homage to retro games than a claim that this is better than the original spritekit ^_^)

While SpriteKit is incredibly awesome, it doesn't contain all the classes or functionality that many games will need (nor should it).
This collection of categories & classes attempts to fill some of those needs.
Most of SuperSpriteKit's components can be used as-is, but some have dependencies on some of its siblings.
All dependencies are clearly listed in the documentation and always #imported in the header files, for clearity.

#### Meet the family

##### SSKTileableNode

A node that allows you to tile a texture across a size. The default SKSpriteNode only allows for stretching of a texture, but in some cases (backgrounds, etc.) tiling is very useful.

##### SSKStretchableNode

A node that allows you to gracefully stretch a texture across a size, using edge insets. This node works pretty much like UIImage's -resizableImageWithCapInsets:, and is very useful for dynamically sized UI components and allows you to use a smaller texture asset for game objects that have textures with large parts that should just be repeated.

##### SSKMultiLineLabelNode

A label node that can render multiple lines of text. It provides a simple API for creating instances using a max-width and a set number of lines (if desired). It also supports setting styles like font, font size and text color.

##### SSKButtonNode

A button node that makes it really easy to create in-game button-type controls. Its API mimics parts of NS/UIButton's API, with support for background textures, background colors, titles, icons, etc. for various states. It also supports a set of different selection styles to enable creation of different type of controls.

##### SSKInteractionHandler

A class dedicated to input in a platform-agnostic manner. By using this interaction handler a lot of platform-specific and/or boilerplate input code can be removed from scenes and nodes throught the game. At the moment, the supported interactions are: touch & mouse click events & mouse move events & keyboard events, but more is coming soon!

##### SKSpriteNode+SSKAnimation

A category on SKSpriteNode that enables easy animation without having to create new actions. It also provides a utility function for generating an array of SKTexture instances from a texture atlas.

##### SKNode+SSKTags

A category on SKNode that adds support for tags to SKNode instances. These tags works similarly to how UIView and NSView's tag API works, but also provides some additional methods for getting all nodes at a point that has a certain tag, or performing a recursive search for all nodes that has a certain tag.

#### Hope that you'll enjoy using SuperSpriteKit

This is just the beginning! I would love to get pull requests if you have created a generic SpriteKit-extension that you would like to be included!

Why not give me a shout on Twitter: [@johnsundell](https://twitter.com/johnsundell)