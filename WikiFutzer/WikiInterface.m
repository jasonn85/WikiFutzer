//
//  WikiInterface.m
//  WikiFutzer
//
//  Created by Jason Neel on 8/24/14.
//
//

#import "WikiInterface.h"

@implementation WikiInterface

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        self.allWikiPagesEverFetched = [[NSOrderedSet alloc] init];
    }
    
    return self;
}

+ (instancetype) sharedInterface
{
    static id singleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
}

- (NSString *) wikipediaAPIURLString
{
    return @"http://en.wikipedia.org/w/api.php";
}

- (NSURL *) fetchURLForTopic: (NSString *)topic
{
    NSString * escapedTopic = [topic stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * urlString = [NSString stringWithFormat:@"%@?format=json&action=query&titles=%@&prop=revisions&rvprop=content",
                            [self wikipediaAPIURLString],
                            escapedTopic];
    return [NSURL URLWithString:urlString];
}

- (NSURL *) imageListURLForTopic: (NSString *)topic
{
    NSString * escapedTopic = [topic stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * urlString = [NSString stringWithFormat:@"%@?format=json&action=query&titles=%@&prop=images",
                            [self wikipediaAPIURLString],
                            escapedTopic];
    return [NSURL URLWithString:urlString];
}

- (NSURL *) imageURLFetchURLForImageTitled: (NSString *)title
{
    NSString * filename = [title stringByReplacingOccurrencesOfString:@"File:" withString:@""];
    NSString * escapedTitle = [filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * urlString = [NSString stringWithFormat:@"%@?format=json&action=query&titles=Image:%@&prop=imageinfo&iiprop=url",
                            [self wikipediaAPIURLString],
                            escapedTitle];
    return [NSURL URLWithString:urlString];
}

- (NSURL *) linksURLForTopic: (NSString *)topic
{
    NSString * escapedTopic = [topic stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * urlString = [NSString stringWithFormat:@"%@?format=json&action=query&titles=%@&prop=links&pllimit=500",
                            [self wikipediaAPIURLString],
                            escapedTopic];
    return [NSURL URLWithString:urlString];
}

- (NSDictionary *) fetchJSONForRequest: (NSURL *) requestURL
{
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:requestURL];
    NSData * result = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if ([result length] == 0)
    {
        return nil;
    }
    
    return [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
}

- (NSURL *) urlForImageWithTitle: (NSString *)title
{
    NSURL * fetchURL = [self imageURLFetchURLForImageTitled:title];
    NSDictionary * result = [self fetchJSONForRequest:fetchURL];
    
    NSString * urlString = [[[result[@"query"][@"pages"] allValues] firstObject][@"imageinfo"] firstObject][@"url"];
    
    if ([urlString length] > 0)
    {
        return [NSURL URLWithString:urlString];
    }
    
    return nil;
}

- (NSArray *) titlesLinkedFromTopic:(NSString *)topic
{
    NSURL * fetchLinksURL = [self linksURLForTopic:topic];
    NSDictionary * result = [self fetchJSONForRequest:fetchLinksURL];
    NSArray * links = [[result[@"query"][@"pages"] allValues] firstObject][@"links"];
    
    NSMutableArray * linkTitles = [[NSMutableArray alloc] initWithCapacity:[links count]];
    
    for (NSDictionary * linkDict in links)
    {
        NSString * title = linkDict[@"title"];
        if (title != nil)
        {
            [linkTitles addObject:title];
        }
    }
    
    return linkTitles;
}

- (WikiPage *) fetchPageForTopic:(NSString *)topic
{
    NSURL * url = [self fetchURLForTopic:topic];
    NSDictionary * responseDict = [self fetchJSONForRequest:url];
    WikiPage * page = [[WikiPage alloc] initWithResponseDictionary:responseDict];
    
    if (![self.allWikiPagesEverFetched containsObject:page])
    {
        [[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(allWikiPagesEverFetched))] addObject:page];
    }
    
    return page;
}

- (NSURL *) urlOfRandomImageInTopic:(NSString *)topic
{
    NSURL * url = [self imageListURLForTopic:topic];
    NSDictionary * responseDict = [self fetchJSONForRequest:url];
    NSArray * images = [[responseDict[@"query"][@"pages"] allValues] firstObject][@"images"];
    
    if ([images count] == 0)
    {
        NSLog(@"Unable to find any images for %@", topic);
        return nil;
    }
    
    NSUInteger imageIndex = arc4random() % [images count];
    NSDictionary * imageInfo = images[imageIndex];
    NSString * imageTitle = imageInfo[@"title"];
    
    return [self urlForImageWithTitle:imageTitle];
}

@end
