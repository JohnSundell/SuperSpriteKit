#import <SpriteKit/SpriteKit.h>
#import "SSKMultiplatform.h"

/**
 *  A label node capable of rendering multiple lines of text
 *
 *  This class depends on the SSKMultiplatform header
 */
@interface SSKMultiLineLabelNode : SKNode

/**
 *  The name of the font to use when rendering the node's text
 */
@property (nonatomic, copy) NSString *fontName;

/**
 *  The font size to use when rendering the node's text
 */
@property (nonatomic) CGFloat fontSize;

/**
 *  The font color to use when rendering the node's text
 */
@property (nonatomic, strong) SKColor *fontColor;

/**
 *  The text the node is displaying
 *
 *  @discussion Setting this property will cause the node to re-render its text.
 */
@property (nonatomic, copy) NSString *text;

/**
 *  The total size of the node
 */
@property (nonatomic, readonly) CGSize size;

/**
 *  Allocate and initialize a new instance of JSMultiLineLabelNode
 *
 *  @param fontName The name of the font to use when rendering the node's text.
 *  @param fontSize The font size to use when rendering the node's text.
 *  @param maximumWidth The maximum width the node should have. When a line of
 *  text has reached the maximum width, the text will be wrapped to a new line.
 *  @param text The text the node should display.
 */
+ (instancetype)multiLineLabelNodeWithFontNamed:(NSString *)fontName
                                       fontSize:(CGFloat)fontSize
                                   maximumWidth:(CGFloat)maximumWidth
                                           text:(NSString *)text;

/**
 *  Allocate and initialize a new instance of JSMultiLineLabelNode
 *
 *  @param fontName The name of the font to use when rendering the node's text.
 *  @param fontSize The font size to use when rendering the node's text.
 *  @param fontColor The font color to use when rednering the node's text.
 *  @param numberOfLines The maximum number of lines the node should have.
 *  When the maximum number of lines has been reached, the node will stop
 *  rendering text.
 *  @param maximumWidth The maximum width the node should have. When a line of
 *  text has reached the maximum width, the text will be wrapped to a new line.
 *  @param text The text the node should display.
 */
+ (instancetype)multiLineLabelNodeWithFontNamed:(NSString *)fontName
                                       fontSize:(CGFloat)fontSize
                                      fontColor:(SKColor *)fontColor
                                  numberOfLines:(NSUInteger)numberOfLines
                                   maximumWidth:(CGFloat)maximumWidth
                                           text:(NSString *)text;

/**
 *  Allocate and initialize a new instance of JSMultiLineLabelNode
 *
 *  @param fontName The name of the font to use when rendering the node's text.
 *  @param fontSize The font size to use when rendering the node's text.
 *  @param fontColor The font color to use when rednering the node's text.
 *  @param numberOfLines The maximum number of lines the node should have.
 *  When the maximum number of lines has been reached, the node will stop
 *  rendering text.
 *  @param lineHeightMultiplier Modifies the lineheight by multiplying the current
 *  font lineheight with this value.
 *  @param maximumWidth The maximum width the node should have. When a line of
 *  text has reached the maximum width, the text will be wrapped to a new line.
 *  @param text The text the node should display.
 */

+ (instancetype)multiLineLabelNodeWithFontNamed:(NSString *)fontName
                                       fontSize:(CGFloat)fontSize
                                      fontColor:(SKColor *)fontColor
                                  numberOfLines:(NSUInteger)numberOfLines
                           lineHeightMultiplier:(CGFloat)lineHeightMultiplier
                                   maximumWidth:(CGFloat)maximumWidth
                                           text:(NSString *)text;

@end








