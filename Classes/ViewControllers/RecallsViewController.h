//
//  RecallsViewController.h
//  GSA
//
//  Created by Mobomo LLC on 16/08/10.
//  Copyright 2010 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SearchDetailsViewController.h"


@interface RecallsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *recallTableView;
	IBOutlet UIButton *relatedButton;
	NSMutableDictionary *searchResults;
	NSMutableArray *favoriteSearches, *filteredSearches;
	int currentPage;
	NSString *searchKeyword;
	UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, retain) NSString *searchKeyword;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

- (void)updateViewWithData:(NSData *)data type:(int)mode;
- (void)configureFirstCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails;
- (void)configureSecondCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails;
- (void)configureThirdCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails;

- (IBAction)doRecentSearch;
- (IBAction)homePage;
- (IBAction)prevPage;
@end
