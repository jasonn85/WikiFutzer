//
//  WikiInterface.h
//  WikiFutzer
//
//  Created by Jason Neel on 8/24/14.
//
//

#import <Foundation/Foundation.h>
#import "WikiPage.h"

@interface WikiInterface : NSObject

+ (instancetype) sharedInterface;
- (dispatch_queue_t) imageFetchingQueue;

// Synchronously fetches the page specified
- (WikiPage *) fetchPageForTopic:(NSString *)topic;
- (void) fetchAllPagesLinkedFromTopic:(NSString *)topic;

- (NSURL *) urlOfRandomImageInTopic:(NSString *)topic;

- (void) clearAllPreviousResults;


@property (nonatomic, retain) NSOrderedSet * allWikiPagesEverFetched;

@end
