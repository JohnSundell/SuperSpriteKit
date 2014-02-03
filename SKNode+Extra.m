#import "SKNode+Extra.h"
#import <objc/runtime.h>

static char *kTag;

@implementation SKNode (Extra)
@dynamic tag;

- (void)setTag:(NSInteger)tag
{
    objc_setAssociatedObject(self, kTag, @(tag), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)tag
{
    return [objc_getAssociatedObject(self, kTag) intValue];
}

- (instancetype)childNodeWithTag:(NSInteger)tag
{
    for (SKNode *node in self.children)
    {
        if (node.tag == tag)
            return node;
    }
    
    return nil;
}

- (void)centerOnNode:(SKNode *)node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x, node.parent.position.y - cameraPositionInScene.y);
}

- (void)runActionForever:(SKAction *)action withKey:(NSString *)key
{
    [self runAction:[SKAction repeatActionForever:action] withKey:key];
}

- (void)runActionSequence:(NSArray *)sequence withKey:(NSString *)key
{
    [self runAction:[SKAction sequence:sequence] withKey:key];
}



@end
