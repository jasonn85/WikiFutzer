//
//  ViewController.m
//  WikiFutzer
//
//  Created by Jason Neel on 8/24/14.
//
//

#import "ViewController.h"
#import "WikiInterface.h"

#define kSearchBarDelay     1.0

@interface ViewController ()
{
    NSTimer * searchTimer;
    
    NSString * primaryTopic;
    NSMutableArray * tableTitles;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    tableTitles = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [searchTimer invalidate];
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:kSearchBarDelay target:self selector:@selector(performSearch:) userInfo:nil repeats:NO];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchTimer invalidate];
    [self performSearch:nil];
}

- (void) performSearch: (NSTimer *)timer
{
    if ([self.searchBar.text length] == 0)
    {
        [self clearResults];
    } else if (![primaryTopic isEqualToString:self.searchBar.text])
    {
        primaryTopic = self.searchBar.text;
        [[WikiInterface sharedInterface] fetchPageForTopic:primaryTopic];
    }
}

- (void) clearResults
{
    primaryTopic = nil;
    tableTitles = [[NSMutableArray alloc] init];
    [[WikiInterface sharedInterface] clearAllPreviousResults];
    
    // TODO: Clear table
}


@end
