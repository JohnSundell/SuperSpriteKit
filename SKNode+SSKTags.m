#import "SKNode+SSKTags.h"

static NSString * const SSKTagStorageKey = @"SuperSpriteKit_Tag";

@implementation SKNode (SSKTags)

#pragma mark - Public

- (NSUInteger)ssk_tag
{
    return [[self.userData objectForKey:SSKTagStorageKey] unsignedIntegerValue];
}

- (void)ssk_setTag:(NSUInteger)tag
{
    if (!self.userData) {
        self.userData = [NSMutableDictionary new];
    }
    
    [self.userData setObject:@(tag) forKey:SSKTagStorageKey];
}

- (SKNode *)ssk_childNodeWithTag:(NSUInteger)tag
{
    return [self ssk_childNodeWithTag:tag recursive:NO];
}

- (SKNode *)ssk_childNodeWithTag:(NSUInteger)tag recursive:(BOOL)recursive
{
    NSArray *matches = [self ssk_childNodesWithTag:tag
                                         recursive:recursive
                                returnOnFirstMatch:YES];
    
    return [matches firstObject];
}

- (NSArray *)ssk_childNodesWithTag:(NSUInteger)tag
{
    return [self ssk_childNodesWithTag:tag recursive:NO];
}

- (NSArray *)ssk_childNodesWithTag:(NSUInteger)tag recursive:(BOOL)recursive
{
    return [self ssk_childNodesWithTag:tag
                             recursive:recursive
                    returnOnFirstMatch:NO];
}

- (NSArray *)ssk_nodesAtPoint:(CGPoint)point withTag:(NSUInteger)tag
{
    NSArray *nodesAtPoint = [self nodesAtPoint:point];
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"ssk_tag == %u", (unsigned long)tag];
    
    return [nodesAtPoint filteredArrayUsingPredicate:tagPredicate];
}

#pragma mark - Private

- (NSArray *)ssk_childNodesWithTag:(NSUInteger)tag recursive:(BOOL)recursive returnOnFirstMatch:(BOOL)returnOnFirstMatch
{
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"ssk_tag == %u", (unsigned long)tag];
    NSArray *directChildMatches = [self.children filteredArrayUsingPredicate:tagPredicate];
    
    if (!recursive) {
        return directChildMatches;
    }
    
    if (returnOnFirstMatch && [directChildMatches count] > 0) {
        return directChildMatches;
    }
    
    NSMutableArray *foundNodes = [directChildMatches mutableCopy];
    
    for (SKNode *child in self.children) {
        NSArray *childMatches = [child ssk_childNodesWithTag:tag
                                                   recursive:YES
                                          returnOnFirstMatch:returnOnFirstMatch];
        
        if (returnOnFirstMatch && [childMatches count] > 0) {
            return childMatches;
        }
        
        [foundNodes addObjectsFromArray:childMatches];
    }
    
    return [foundNodes copy];
}

@end
