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
    
    UITapGestureRecognizer * tapper;
}

@end

@implementation ViewController

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self != nil)
    {
        [[WikiInterface sharedInterface] addObserver:self forKeyPath:NSStringFromSelector(@selector(allWikiPagesEverFetched)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNewImage:) name:kWikiPageNewImageLoaded object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [[WikiInterface sharedInterface] removeObserver:self forKeyPath:NSStringFromSelector(@selector(allWikiPagesEverFetched))];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    tableTitles = [[NSMutableArray alloc] init];
    
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tapped: (UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    
    if (!CGRectContainsPoint(self.searchBar.frame, location))
    {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - Updates
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(allWikiPagesEverFetched))])
    {
        int changeKind = [change[NSKeyValueChangeKindKey] intValue];
        NSIndexSet * changedIndexes = change[NSKeyValueChangeIndexesKey];
        
        if (changeKind == NSKeyValueChangeInsertion)
        {
            [self.tableView beginUpdates];
            
            [changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            }];
            
            [self.tableView endUpdates];
        } else if (changeKind == NSKeyValueChangeRemoval)
        {
            [self.tableView beginUpdates];
            
            [changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            }];
            
            [self.tableView endUpdates];
        } else if (changeKind == NSKeyValueChangeSetting
                   )
        {
            [self.tableView reloadData];
        } else {
            NSLog(@"Unrecognized KVO type.  Reloading table.");
            [self.tableView reloadData];
        }
        
    }
}

- (void) notifyNewImage: (NSNotification *)notification
{
    WikiPage * updatePage = notification.object;
    
    NSUInteger index = [[[WikiInterface sharedInterface] allWikiPagesEverFetched] indexOfObject:updatePage];
    
    if (index != NSNotFound)
    {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Searching
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
    [self clearResults];

    if (([self.searchBar.text length] > 0) && (![primaryTopic isEqualToString:self.searchBar.text]))
    {
        primaryTopic = self.searchBar.text;
        [[WikiInterface sharedInterface] fetchPageForTopic:primaryTopic];
        [[WikiInterface sharedInterface] fetchAllPagesLinkedFromTopic:primaryTopic];
    }
}

- (void) clearResults
{
    primaryTopic = nil;
    tableTitles = [[NSMutableArray alloc] init];
    [[WikiInterface sharedInterface] clearAllPreviousResults];
}

#pragma mark - Table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[WikiInterface sharedInterface] allWikiPagesEverFetched] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WikiInterface * wiki = [WikiInterface sharedInterface];
    NSString * cellID = @"wikiCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row >= [wiki.allWikiPagesEverFetched count])
    {
        cell.imageView.image = nil;
        cell.textLabel.text = nil;
    } else {
        WikiPage * page = wiki.allWikiPagesEverFetched[indexPath.row];
        cell.textLabel.text = page.title;
        cell.imageView.image = page.randomImage;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WikiInterface * wiki = [WikiInterface sharedInterface];
    
    if (indexPath.row < [wiki.allWikiPagesEverFetched count])
    {
        WikiPage * selectedPage = wiki.allWikiPagesEverFetched[indexPath.row];
        
        [self clearResults];
        primaryTopic = selectedPage.title;
        self.searchBar.text = primaryTopic;
        [wiki fetchPageForTopic:primaryTopic];
        [wiki fetchAllPagesLinkedFromTopic:primaryTopic];
    }
}




@end
