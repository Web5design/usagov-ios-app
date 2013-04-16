    //
//  RecallsViewController.m
//  GSA
//
//  Created by Mobomo LLC on 16/08/10.
//  Copyright 2010 Mobomo LLC. All rights reserved.
//

#import "RecallsViewController.h"

#import "SearchDetailsViewController.h"
#import "RecallWebservice.h"
#import "NSObject+YAJL.h"
#import "Utility.h"

enum  {
	recallCompanyLabelTag = 1,
	recallImageTag,
	recallNameLabelTag,
	recallTypeLabelTag,
	recallUnitLabelTag,
	recallDateLabelTag
};

@implementation RecallsViewController
@synthesize searchKeyword;
@synthesize activityIndicator;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.view.backgroundColor = [UIColor whiteColor];
	[recallTableView setBackgroundColor:[UIColor clearColor]];
	//recallTableView.separatorColor = [Utility tableSeparatorColor];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[recallTableView setBackgroundView:nil];
	}
	currentPage = 1;
	[self doRecentSearch];
}

- (void)viewDidAppear:(BOOL)animated {
	self.title = @"Recalls";
	
}

+ (UILabel *)defaultLabel {
	
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		label.frame = CGRectMake(10, 2, 200, 36);
	}else {
		label.frame = CGRectMake(10, 2, 200, 36);
	}
    label.adjustsFontSizeToFitWidth = NO;
    label.textColor = [UIColor blackColor];
	label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UILabel *)companyName {
	UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		label.frame = CGRectMake(115, 5, 500, 30);
		label.font = [UIFont boldSystemFontOfSize:16];
	}else {
		label.frame = CGRectMake(70, 5, 200, 30);
		label.font = [UIFont boldSystemFontOfSize:12];
	}
	label.textAlignment= UITextAlignmentLeft;
	label.numberOfLines = 0;
    label.tag = recallCompanyLabelTag;
    label.textColor = [Utility appTextColor]; // [UIColor blueColor];
    label.backgroundColor = [UIColor clearColor];
    return label;
	
}

+ (UIImageView *)recallType {
	UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		imageView.frame = CGRectMake(5, 5, 80, 80);
	}else {
		imageView.frame = CGRectMake(5, 5, 60, 60);
	}
	imageView.tag = recallImageTag;
	return imageView;
}

+ (UILabel *)recallName {
	UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
 	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		label.frame = CGRectMake(115, 30, 525, 50);
		label.font = [UIFont boldSystemFontOfSize:16];
	}else {
		label.frame = CGRectMake(70, 30, 200, 50);
		label.font = [UIFont boldSystemFontOfSize:12];
	}
	label.textAlignment= UITextAlignmentLeft;
    label.tag = recallNameLabelTag;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UILabel *)recallTypeName {
	UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
 	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		label.frame = CGRectMake(10, 75, 70, 20);
		label.font = [UIFont boldSystemFontOfSize:16];
	}else {
		label.frame = CGRectMake(0, 60, 70, 20);
		label.font = [UIFont boldSystemFontOfSize:12];
	}
	label.textAlignment= UITextAlignmentCenter;
    label.tag = recallTypeLabelTag;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UILabel *)unitCountLabel {
	UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		label.frame = CGRectMake(115, 90, 300, 30);
		label.font = [UIFont boldSystemFontOfSize:14];
	}else {
		label.frame = CGRectMake(70, 90, 300, 30);
		label.font = [UIFont boldSystemFontOfSize:10];
	}
	label.textAlignment= UITextAlignmentLeft;
	label.numberOfLines = 0;
    label.tag = recallUnitLabelTag;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

+ (UILabel *)datelabel {
	UILabel *label = [[self class] defaultLabel];
    label.adjustsFontSizeToFitWidth = NO;
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		label.frame = CGRectMake(115, 65, 300, 30);
		label.font = [UIFont boldSystemFontOfSize:14];
	}else {
		label.frame = CGRectMake(70, 65, 200, 30);
		label.font = [UIFont boldSystemFontOfSize:10];
	}
	label.textAlignment= UITextAlignmentLeft;
	label.numberOfLines = 0;
    label.tag = recallDateLabelTag;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (IBAction)doRecentSearch {
	
	//Search for recalls in the last 2 weeks
	[self performSelectorInBackground:@selector(performRecallSearch) withObject:nil];
	
	activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityIndicator setFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 50, 50)];
	//[activityIndicator setFrame:CGRectMake(130, 200, 50, 50)];
	[activityIndicator setHidesWhenStopped:YES];
	[activityIndicator startAnimating];
	[self.view addSubview:activityIndicator];
}

- (void)performRecallSearch {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSData *responseData = [RecallWebservice recentRecallwithPage:currentPage];
	[self updateViewWithData:responseData];
	[pool release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)updateViewWithData:(NSData *)data {
	if(currentPage == 1) {
		searchResults = [[data yajl_JSON] retain];
		//NSLog(@"search results==%@",searchResults);
	} else {
		NSArray *resultsArray = [[searchResults objectForKey:@"success"] objectForKey:@"results"];
		searchResults = [[data yajl_JSON] retain];
		NSArray *newResultsArray = [resultsArray arrayByAddingObjectsFromArray:[[searchResults objectForKey:@"success"] objectForKey:@"results"]];
		[[searchResults objectForKey:@"success"] setObject:newResultsArray forKey:@"results"];
		
	}
	
	for (NSString *key in searchResults)
		//NSLog(@"%@ key value %@", key, [searchResults objectForKey: key] );
		
		if ([[searchResults allKeys] containsObject:@"results"]) {
			
			//NSNumber *totalNumber = [searchResults objectForKey:@"total"];
			//[self.resultsCountLabel performSelectorOnMainThread:@selector(setText:) withObject:[totalNumber stringValue] waitUntilDone:NO];
		}
		
	[recallTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	[activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
	[activityIndicator release];
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (tableView == recallTableView) {
		if ([[searchResults allKeys] containsObject:@"success"]) {
			if([[[searchResults objectForKey:@"success"] objectForKey:@"results"] count] > 0) {
				return [[[searchResults objectForKey:@"success"] objectForKey:@"results"] count] + 1;
			}
			return [[[searchResults objectForKey:@"success"] objectForKey:@"results"] count];
		}
		
	} 
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == recallTableView) {
		if([[[searchResults objectForKey:@"success"] objectForKey:@"results"] count] > 0 && [[[searchResults objectForKey:@"success"] objectForKey:@"results"] count] == indexPath.row) {
			return 60;
			
		} else if([searchResults objectForKey:@"success"]) {
			NSDictionary *result = [[[searchResults objectForKey:@"success"] objectForKey:@"results"] objectAtIndex:indexPath.row];
			if ([[result objectForKey:@"organization"] isEqualToString:@"NHTSA"]) {
				return 120.0;
			} else {
				return 100;
			}
		} else {
			return 120.0;
		}
		


		
	} 
	return 44.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	static NSString *CellIdentifier2 = @"Cell2";
	static NSString *CellIdentifier3 = @"Cell3";
	   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier2] autorelease];
		cell.backgroundColor = [UIColor whiteColor];
		[cell.contentView addSubview:[[self class] defaultLabel]];
	}
	UITableViewCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
    if (loadingCell == nil) {
        loadingCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier3] autorelease];
		loadingCell.textLabel.textColor = [UIColor blueColor];
		loadingCell.textLabel.textAlignment = UITextAlignmentRight;
		loadingCell.textLabel.text = @"More...";
	}

	UITableViewCell *recallCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (recallCell == nil) {
        recallCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		recallCell.backgroundColor = [UIColor whiteColor];
		[recallCell.contentView addSubview:[[self class] recallType]];
		[recallCell.contentView addSubview:[[self class] recallName]];
		[recallCell.contentView addSubview:[[self class] companyName]];
		[recallCell.contentView addSubview:[[self class] unitCountLabel]];
		[recallCell.contentView addSubview:[[self class] datelabel]];
		[recallCell.contentView addSubview:[[self class] recallTypeName]];
		
		recallCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	if (tableView == recallTableView) {
		
		if([[[searchResults objectForKey:@"success"] objectForKey:@"results"] count] > 0 && [[[searchResults objectForKey:@"success"] objectForKey:@"results"] count] == indexPath.row) {
			return loadingCell;
			
		}
		NSDictionary *result = [[[searchResults objectForKey:@"success"] objectForKey:@"results"] objectAtIndex:indexPath.row];
		if ([[result objectForKey:@"organization"] isEqualToString:@"NHTSA"]) {
			[self configureFirstCell:recallCell withData:result];
		}
		
		else if ([[result objectForKey:@"organization"] isEqualToString:@"CPSC"]) {
			[self configureSecondCell:recallCell withData:result];
		}
		
		else if ([[result objectForKey:@"organization"] isEqualToString:@"CDC"]) {
			[self configureThirdCell:recallCell withData:result];
		}
		
		/*
		recallCell.textLabel.text = nil;
		recallCell.detailTextLabel.text = nil;
		if ([[searchResults allKeys] containsObject:@"success"]) {
			if (indexPath.row == 0) {
				recallCell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
				recallCell.textLabel.numberOfLines = 0;
				recallCell.textLabel.text = [[[[searchResults objectForKey:@"success"] objectForKey:@"results"] objectAtIndex:indexPath.section] objectForKey:@"component_description"];
				recallCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			if (indexPath.row == 1) {
				recallCell.textLabel.text = @"Potential Units Affected";
				NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
				[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
				[formatter setCurrencySymbol:@""];
				[formatter setMaximumFractionDigits:0];
				NSNumber *number = [NSNumber numberWithInt:[[[[[searchResults objectForKey:@"success"] objectForKey:@"results"] objectAtIndex:indexPath.section] objectForKey:@"potential_units_affected"]intValue]];
				recallCell.detailTextLabel.text = [formatter stringFromNumber:number];
				[formatter release];
				recallCell.accessoryType = UITableViewCellAccessoryNone;
			}
			else if (indexPath.row == 2) {
				recallCell.textLabel.text = @"Recall Date";
				recallCell.detailTextLabel.text = [[[[searchResults objectForKey:@"success"] objectForKey:@"results"] objectAtIndex:indexPath.section] objectForKey:@"recall_date"];
				recallCell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
		recallCell.selectionStyle = UITableViewCellSelectionStyleNone;
		 */
		
	}

	else {
		recallCell.textLabel.text = [filteredSearches objectAtIndex:indexPath.row];
	}
	
	return recallCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (tableView == recallTableView) {
		if([[[searchResults objectForKey:@"success"] objectForKey:@"results"] count] > 0 && [[[searchResults objectForKey:@"success"] objectForKey:@"results"] count] == indexPath.row) {
			currentPage = currentPage +1;
			[self doRecentSearch];
			//NSData *responseData = [RecallWebservice recentRecallwithPage:currentPage];
			//[self updateViewWithData:responseData type:0];
		} else {
			SearchDetailsViewController *detailsViewController = [[SearchDetailsViewController alloc] initWithNibName:@"SearchDetailsViewController" bundle:nil];
			detailsViewController.searchResults = searchResults;
			detailsViewController.section = indexPath.row;
			[self.navigationController pushViewController:detailsViewController animated:YES];
			[detailsViewController release];
			
		}
		
	}
}


- (void)configureFirstCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails {
	UILabel *companyNameLabel = (UILabel *)[[cell contentView] viewWithTag:recallCompanyLabelTag];
	companyNameLabel.text = @"";
	companyNameLabel.text = [[resultDetails objectForKey:@"manufacturer"] uppercaseString];
	
	UILabel *nameLabel = (UILabel *)[[cell contentView] viewWithTag:recallNameLabelTag];
	nameLabel.text = @"";
	nameLabel.text = [resultDetails objectForKey:@"component_description"];
	
	UILabel *unitLabel = (UILabel *)[[cell contentView] viewWithTag:recallUnitLabelTag];
	unitLabel.text = @"";
	/*NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
	 [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	 [formatter setCurrencySymbol:@""];
	 [formatter setMaximumFractionDigits:0];
	 NSNumber *number = [NSNumber numberWithInt:[[resultDetails objectForKey:@"potential_units_affected"] intValue]];*/
	unitLabel.text = [NSString stringWithFormat:@"Potential Units Affected : %d",[[resultDetails objectForKey:@"potential_units_affected"] intValue]];//[formatter stringFromNumber:number];
	//[formatter release];
	
	UILabel *dateLabel = (UILabel *)[[cell contentView] viewWithTag:recallDateLabelTag];
	dateLabel.text = @"";
	dateLabel.text = [NSString stringWithFormat:@"Recall Date : %@", [resultDetails objectForKey:@"recall_date"]];
	
	UIImageView *recallImage = (UIImageView *)[[cell contentView] viewWithTag:recallImageTag];
	recallImage.image = nil;
	recallImage.image = [UIImage imageNamed:@"recall_type_image.png"];
	
	UILabel *recallTypeLabel = (UILabel *)[[cell contentView] viewWithTag:recallTypeLabelTag];
	recallTypeLabel.text = @"";
	recallTypeLabel.text = @"Auto";
}

- (void)configureSecondCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails {
	UILabel *companyNameLabel = (UILabel *)[[cell contentView] viewWithTag:recallCompanyLabelTag];
	companyNameLabel.text = @"";
	companyNameLabel.text = [[[resultDetails objectForKey:@"manufacturers"] objectAtIndex:0] uppercaseString];
	
	UILabel *nameLabel = (UILabel *)[[cell contentView] viewWithTag:recallNameLabelTag];
	nameLabel.numberOfLines = 0;
	nameLabel.text = @"";
	nameLabel.text = [[resultDetails objectForKey:@"descriptions"] objectAtIndex:0];
	
	UILabel *unitLabel = (UILabel *)[[cell contentView] viewWithTag:recallUnitLabelTag];
	unitLabel.text = @"";
	
	UILabel *dateLabel = (UILabel *)[[cell contentView] viewWithTag:recallDateLabelTag];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		dateLabel.frame = CGRectMake(115, 75, 300, 30);
	}else {
		dateLabel.frame = CGRectMake(70, 75, 300, 30);
	}
	dateLabel.text = @"";
	dateLabel.text = [resultDetails objectForKey:@"recall_date"];
	
	UIImageView *recallImage = (UIImageView *)[[cell contentView] viewWithTag:recallImageTag];
	recallImage.image = nil;
	recallImage.image = [UIImage imageNamed:@"recall_type_image2.png"];
	
	UILabel *recallTypeLabel = (UILabel *)[[cell contentView] viewWithTag:recallTypeLabelTag];
	recallTypeLabel.text = @"";
	recallTypeLabel.text = @"Product";
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		recallTypeLabel.frame = CGRectMake(10, 75, 70, 20);
		
	}else {
		recallTypeLabel.frame = CGRectMake(0, 60, 70, 20);
		
	}
	
}

- (void)configureThirdCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails {
	UILabel *companyNameLabel = (UILabel *)[[cell contentView] viewWithTag:recallCompanyLabelTag];
	companyNameLabel.text = @"";
	companyNameLabel.text = [[resultDetails objectForKey:@"description"] uppercaseString];
	
	UILabel *nameLabel = (UILabel *)[[cell contentView] viewWithTag:recallNameLabelTag];
	nameLabel.numberOfLines = 0;
	nameLabel.lineBreakMode = UILineBreakModeWordWrap;
	nameLabel.text = @"";
	nameLabel.text = [resultDetails objectForKey:@"summary"];
	
	UILabel *unitLabel = (UILabel *)[[cell contentView] viewWithTag:recallUnitLabelTag];
	unitLabel.text = @"";
	
	UILabel *dateLabel = (UILabel *)[[cell contentView] viewWithTag:recallDateLabelTag];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		dateLabel.frame = CGRectMake(115, 75, 300, 30);
	}else {
		dateLabel.frame = CGRectMake(70, 75, 300, 30);
	}
	dateLabel.text = @"";
	dateLabel.text = [resultDetails objectForKey:@"recall_date"];
	
	UIImageView *recallImage = (UIImageView *)[[cell contentView] viewWithTag:recallImageTag];
	recallImage.image = nil;
	recallImage.image = [UIImage imageNamed:@"recall_type_image3.png"];
	
	UILabel *recallTypeLabel = (UILabel *)[[cell contentView] viewWithTag:recallTypeLabelTag];
	recallTypeLabel.text = @"";
	recallTypeLabel.text = @"Food";
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		recallTypeLabel.frame = CGRectMake(10, 75, 70, 20);
		
	}else {
		recallTypeLabel.frame = CGRectMake(0, 60, 70, 20);
		
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)performSearchWithQuery {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSData *responseData = [RecallWebservice recentRecallwithPage:currentPage];
	[self updateViewWithData:responseData type:0];
	[pool release];
}
- (void)updateViewWithData:(NSData *)data type:(int)mode {
	
	if(currentPage == 1) {
		searchResults = [[data yajl_JSON] retain];
	} else {
		NSArray *resultsArray = [[searchResults objectForKey:@"success"] objectForKey:@"results"];
		searchResults = [[data yajl_JSON] retain];
		NSArray *newResultsArray = [resultsArray arrayByAddingObjectsFromArray:[[searchResults objectForKey:@"success"] objectForKey:@"results"]];
		[[searchResults objectForKey:@"success"] setObject:newResultsArray forKey:@"results"];
	}
	[self.activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
	[activityIndicator release];
	[recallTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
}

- (IBAction)homePage {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)prevPage {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
