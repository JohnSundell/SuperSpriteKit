#import "SSKMultiLineLabelNode.h"

static CGFloat SSKMultiLineLabelNodeGetFontLineHeight(SSKFontType *font)
{
#if TARGET_OS_IPHONE
    return font.lineHeight;
#else
    return [[NSLayoutManager new] defaultLineHeightForFont:font];
#endif
}

static NSString *SSKMultiLineLabelNodeGetStringForWord(NSString *word)
{
    return [word stringByAppendingString:@" "];
}

@interface SSKMultiLineLabelNode()

@property (nonatomic, strong) NSArray *lineLabelNodes;
@property (nonatomic) NSUInteger numberOfLines;
@property (nonatomic) NSUInteger lineHeightMultiplier;
@property (nonatomic) CGFloat maximumWidth;

@end

@implementation SSKMultiLineLabelNode

+ (instancetype)multiLineLabelNodeWithFontNamed:(NSString *)fontName fontSize:(CGFloat)fontSize maximumWidth:(CGFloat)maximumWidth text:(NSString *)text
{
    return [self multiLineLabelNodeWithFontNamed:fontName
                                        fontSize:fontSize
                                       fontColor:[SKColor blackColor]
                                   numberOfLines:0
                                    maximumWidth:maximumWidth
                                            text:text];
}

+ (instancetype)multiLineLabelNodeWithFontNamed:(NSString *)fontName fontSize:(CGFloat)fontSize fontColor:(SKColor *)fontColor numberOfLines:(NSUInteger)numberOfLines maximumWidth:(CGFloat)maximumWidth text:(NSString *)text
{
    return [self multiLineLabelNodeWithFontNamed:fontName
                                        fontSize:fontSize
                                       fontColor:[SKColor blackColor]
                                   numberOfLines:0
                            lineHeightMultiplier:1
                                    maximumWidth:maximumWidth
                                            text:text];
}

+ (instancetype)multiLineLabelNodeWithFontNamed:(NSString *)fontName fontSize:(CGFloat)fontSize fontColor:(SKColor *)fontColor numberOfLines:(NSUInteger)numberOfLines lineHeightMultiplier:(CGFloat)lineHeightMultiplier maximumWidth:(CGFloat)maximumWidth text:(NSString *)text
{
    SSKMultiLineLabelNode *label = [SSKMultiLineLabelNode node];
    
    label.numberOfLines = numberOfLines;
    label.lineHeightMultiplier = lineHeightMultiplier;
    label.fontName = fontName;
    label.fontSize = fontSize;
    label.fontColor = fontColor;
    label.maximumWidth = maximumWidth;
    label.text = text;
    
    return label;
}

- (void)setFontSize:(CGFloat)fontSize
{
    if (_fontSize == fontSize) {
        return;
    }
    
    _fontSize = fontSize;
    
    [self drawLineLabelNodes];
}

- (void)setFontColor:(SKColor *)fontColor
{
    if (!fontColor) {
        return;
    }
    
    if ([_fontColor isEqual:fontColor]) {
        return;
    }
    
    _fontColor = fontColor;
    
    for (SKLabelNode *labelNode in self.lineLabelNodes) {
        labelNode.fontColor = fontColor;
    }
}

- (void)setText:(NSString *)text
{
    if ([_text isEqualToString:text]) {
        return;
    }
    
    _text = text;
    
    [self drawLineLabelNodes];
}

- (void)drawLineLabelNodes
{
    [self.lineLabelNodes makeObjectsPerformSelector:@selector(removeFromParent)];
    self.lineLabelNodes = nil;
    
    if ([self.text length] == 0 || self.maximumWidth <= 0) {
        return;
    }
    
    NSString *text = [self.text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n "];
    
    NSMutableArray *lineLabelNodes = [NSMutableArray new];
    NSArray *wordsInText = [text componentsSeparatedByString:@" "];
    NSUInteger numberOfParsedWords = 0;
    
    SSKFontType *font = [SSKFontType fontWithName:self.fontName size:self.fontSize];
    CGFloat fontLineHeight = SSKMultiLineLabelNodeGetFontLineHeight(font);
    fontLineHeight *= self.lineHeightMultiplier;
    NSDictionary *textAttributes = @{NSFontAttributeName: font};
    NSCharacterSet *newLineCharacterSet = [NSCharacterSet newlineCharacterSet];
    
    while (numberOfParsedWords < [wordsInText count]) {
        NSMutableString *lineText = [NSMutableString string];
        
        while ([lineText sizeWithAttributes:textAttributes].width < self.maximumWidth) {
            if (numberOfParsedWords == [wordsInText count]) {
                break;
            }
            
            NSString *word = [wordsInText objectAtIndex:numberOfParsedWords];
            NSArray *wordLines = [word componentsSeparatedByCharactersInSet:newLineCharacterSet];
            
            if ([wordLines count] > 1) {
                NSRange newLineCharacterRange = [word rangeOfCharacterFromSet:newLineCharacterSet];
                word = [word stringByReplacingCharactersInRange:newLineCharacterRange withString:@""];
            }
            
            [lineText appendString:SSKMultiLineLabelNodeGetStringForWord(word)];
            numberOfParsedWords++;
            
            if ([wordLines count] > 1) {
                break;
            }
        }
        
        while ([lineText sizeWithAttributes:textAttributes].width > self.maximumWidth) {
            if (numberOfParsedWords == 1) {
                [lineText deleteCharactersInRange:NSMakeRange([lineText length] - 1, 1)];
                
                NSString *suffix = @"...";
                [lineText replaceCharactersInRange:NSMakeRange([lineText length] - [suffix length], [suffix length]) withString:suffix];
            } else {
                NSString *lastWord = SSKMultiLineLabelNodeGetStringForWord([wordsInText objectAtIndex:numberOfParsedWords - 1]);
                NSRange deleteRange = NSMakeRange([lineText length] - [lastWord length], [lastWord length]);
                [lineText deleteCharactersInRange:deleteRange];
                numberOfParsedWords--;
            }
        }
        
        SKLabelNode *lineLabelNode = [SKLabelNode labelNodeWithFontNamed:self.fontName];
        lineLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        lineLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
        lineLabelNode.fontSize = self.fontSize;
        lineLabelNode.fontColor = self.fontColor;
        lineLabelNode.text = lineText;
        
        [self addChild:lineLabelNode];
        [lineLabelNodes addObject:lineLabelNode];
        
        if (self.numberOfLines > 0 && self.numberOfLines == [lineLabelNodes count]) {
            break;
        }
    }
    
    NSUInteger lineNumber = 1;
    NSUInteger numberOfLines = [lineLabelNodes count];
    
    for (SKLabelNode *labelNode in lineLabelNodes) {
        CGPoint labelPosition;
        labelPosition.x = 0;
        labelPosition.y = (numberOfLines - lineNumber) * fontLineHeight;
        labelNode.position = labelPosition;
        
        lineNumber++;
    }
    
    self.lineLabelNodes = lineLabelNodes;
}

- (CGSize)size
{
    CGSize size;
    size.width = 0;
    size.height = CGRectGetMaxY([[self.lineLabelNodes firstObject] frame]);

    for (SKLabelNode *labelNode in self.lineLabelNodes) {
        if (CGRectGetMaxX(labelNode.frame) > size.width) {
            size.width = CGRectGetMaxX(labelNode.frame);
        }
    }
    
    return size;
}

@end
