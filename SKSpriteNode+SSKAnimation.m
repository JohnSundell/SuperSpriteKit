#import "SKSpriteNode+SSKAnimation.h"
#import "SKNode+Extra.h"

NSString * const SSKAnimationActionKey = @"SSKAnimation";

NSArray *SSKAnimationTexturesFromAtlas(SKTextureAtlas *atlas, NSString *animationName, NSUInteger numberOfFrames)
{
    if ([animationName length] == 0) {
        return nil;
    }
    
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    for (unsigned int i = 0; i < numberOfFrames; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%@-%u", animationName, i];
        SKTexture *texture;
        
        if (atlas) {
            texture = [atlas textureNamed:textureName];
        } else {
            texture = [SKTexture textureWithImageNamed:textureName];
        }
        
        if (texture) {
            [textures addObject:texture];
        } else {
            NSLog(@"SKSpriteNode+SSKAnimation: The texture named \"%@\" cannot be found!", textureName);
        }
    }
    
    return textures;
}


@implementation SKSpriteNode (SSKAnimation)

- (void)ssk_animateWithTextures:(NSArray *)textures duration:(NSTimeInterval)duration repeat:(BOOL)repeat resize:(BOOL)resize onComplete:(SSKAnimationCompletionBlock)onComplete
{
    [self removeActionForKey:SSKAnimationActionKey];
    
    if ([textures count] < 2) {
        self.texture = [textures firstObject];
        self.size = self.texture.size;
        
        return;
    }
    
    NSTimeInterval timePerFrame = duration / (NSTimeInterval)[textures count];
    
    SKAction *animationAction = [SKAction animateWithTextures:textures
                                                 timePerFrame:timePerFrame
                                                       resize:resize
                                                      restore:NO];
    
    if (!repeat) {
        [self runAction:animationAction completion:onComplete];
        
        return;
    }
    
    [self runActionForever:animationAction withKey:SSKAnimationActionKey];
}

@end

