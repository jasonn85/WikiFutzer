//
//  WikiPage.h
//  WikiFutzer
//
//  Created by Jason Neel on 8/24/14.
//
//

#import <Foundation/Foundation.h>

#define kWikiPageNewImageLoaded     @"kWikiPageNewImageLoaded"

@interface WikiPage : NSObject

- (instancetype) initWithResponseDictionary: (NSDictionary *)jsonDictionary;

// Only used for comparison
+ (instancetype) wikiPageWithTitle: (NSString *)title;

@property (nonatomic, retain) NSDictionary * rawResponse;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * pageText;
@property (nonatomic, strong) UIImage * randomImage;

@end
