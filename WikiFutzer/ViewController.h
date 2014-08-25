//
//  ViewController.h
//  WikiFutzer
//
//  Created by Jason Neel on 8/24/14.
//
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar * searchBar;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

@end
