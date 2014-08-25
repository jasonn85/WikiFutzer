//
//  WikiPage.m
//  WikiFutzer
//
//  Created by Jason Neel on 8/24/14.
//
//

#import "WikiPage.h"
#import "WikiInterface.h"

@implementation WikiPage

- (BOOL) isEqual:(WikiPage *)object
{
    if ([object isKindOfClass:[WikiPage class]])
    {
        return ([self.title isEqualToString:object.title]);
    }
    
    return NO;
}

- (NSUInteger) hash
{
    return [self.title hash];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: %@", [self class], self.title];
}

+ (instancetype) wikiPageWithTitle: (NSString *)title
{
    WikiPage * page = [[WikiPage alloc] init];
    page.title = title;
    return page;
}

- (instancetype) initWithResponseDictionary: (NSDictionary *)jsonDictionary
{
    if (jsonDictionary == nil)
    {
        NSLog(@"Attempted to create WikiPage object with nil response.");
        return nil;
    }
    
    NSDictionary * firstPage = [[jsonDictionary[@"query"][@"pages"] allValues] firstObject];

    
    if (firstPage[@"missing"] != nil)
    {
        NSLog(@"No results found");
        return nil;
    }
    
    self = [self init];
    
    if (self != nil)
    {
        self.rawResponse = jsonDictionary;
        
        self.title = firstPage[@"title"];
        self.pageText = [firstPage[@"revisions"] firstObject];
        
        __weak WikiPage * weakSelf = self;
        
        dispatch_async([[WikiInterface sharedInterface] imageFetchingQueue], ^{
            [weakSelf retrieveImage];
        });
    }
    
    return self;
}

- (void) retrieveImage
{
    NSURL * imageUrl = [[WikiInterface sharedInterface] urlOfRandomImageInTopic:self.title];
    
    if (imageUrl != nil)
    {
        NSData * imageData = [NSData dataWithContentsOfURL:imageUrl];
        
        if ([imageData length] > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.randomImage = [UIImage imageWithData:imageData];
                [[NSNotificationCenter defaultCenter] postNotificationName:kWikiPageNewImageLoaded object:self];
            });
        }
    }
}


@end
