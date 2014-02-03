#import <SpriteKit/SpriteKit.h>

@interface SKNode (Extra)

@property (nonatomic) NSInteger tag;

- (instancetype)childNodeWithTag:(NSInteger)tag;
- (void)centerOnNode:(SKNode *)node;
- (void)runActionForever:(SKAction *)action withKey:(NSString *)key;
- (void)runActionSequence:(NSArray *)sequence withKey:(NSString *)key;

@end
