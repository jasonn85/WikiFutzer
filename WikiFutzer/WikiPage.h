//
//  WikiPage.h
//  WikiFutzer
//
//  Created by Jason Neel on 8/24/14.
//
//

#import <Foundation/Foundation.h>

@interface WikiPage : NSObject

- (instancetype) initWithResponseDictionary: (NSDictionary *)jsonDictionary;

@property (nonatomic, retain) NSDictionary * rawResponse;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * pageText;
@property (nonatomic, strong) UIImage * firstImage;

@end
