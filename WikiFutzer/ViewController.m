//
//  ViewController.m
//  WikiFutzer
//
//  Created by Jason Neel on 8/24/14.
//
//

#import "ViewController.h"
#import "WikiInterface.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[WikiInterface sharedInterface] fetchPageForTopic:@"Albert Einstein"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

}

@end
