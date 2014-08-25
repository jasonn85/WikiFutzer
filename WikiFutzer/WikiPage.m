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

- (instancetype) initWithResponseDictionary: (NSDictionary *)jsonDictionary
{
    if (jsonDictionary == nil)
    {
        NSLog(@"Attempted to create WikiPage object with nil response.");
        return nil;
    }
    
    self = [super init];
    
    if (self != nil)
    {
        self.rawResponse = jsonDictionary;
        
        NSDictionary * firstPage = [[jsonDictionary[@"query"][@"pages"] allValues] firstObject];
        self.title = firstPage[@"title"];
        self.pageText = [firstPage[@"revisions"] firstObject];
        
        [self retrieveImage];
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
            self.firstImage = [UIImage imageWithData:imageData];
        } else {
            self.firstImage = nil;
        }
    }
}


@end
