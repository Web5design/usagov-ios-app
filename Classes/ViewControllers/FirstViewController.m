/*
 * This project constitutes a work of the United States Government and is
 * not subject to domestic copyright protection under 17 USC § 105.
 *
 * However, because the project utilizes code licensed from contributors
 * and other third parties, it therefore is licensed under the MIT
 * License. http://opensource.org/licenses/mit-license.php. Under that
 * license, permission is granted free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the conditions that any appropriate copyright notices and this
 * permission notice are included in all copies or substantial portions
 * of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

//
//  FirstViewController.m
//  General Services Administration
//


#import "FirstViewController.h"
#import "MBMNetworkActivity.h"
#import "Constants.h"
#import "SuggestionsOperation.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchWebservice.h"
#import "WebPageViewController.h"
#import "NSObject+YAJL.h"
#import "ImageLoadOperation.h"
#import "RecallsViewController.h"
#import "SearchSettingsViewController.h"
#import "RecallWebservice.h"
#import "Reachability.h"

@implementation FirstViewController

@synthesize imageAnimationView;
@synthesize searchWebView;
@synthesize searchHistory;
@synthesize baseImageName;
@synthesize filteredSearches;
@synthesize searchTableView;
@synthesize searchKeyword;
@synthesize viewHistory;
@synthesize currentPosition;
@synthesize searchResults;

#pragma mark -
#pragma mark Initial loading Methods

- (void)viewDidLoad {
	[super viewDidLoad];
    
    
	isSearchInProgress = YES;
    isRelatedSearchInProgress = NO;
	self.title = @"";
	recallLabelHeight =0;
	webSearchLabelHeight = 0;
	self.viewHistory = [[NSMutableArray alloc] init];
	currentPosition = 0;
	
	prevBtn.enabled = NO;
	nxtBtn.enabled = NO;
	
	searchBoxView.frame = CGRectMake(0, -72, 320, 72);
	searchTypePop.frame = CGRectMake(0, searchBarBgImage.frame.size.height, searchTypePop.frame.size.width, 0);
	appLogoWidth = 43;
	searchTypeMode = modeWebSearch;
	searchTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	searchTypeButton.frame = CGRectMake(10, 7, 40, 30);
	searchTypeButton.tag = modeWebSearch;
	searchTypeButton.backgroundColor = [UIColor clearColor];
	[searchTypeButton addTarget:self action:@selector(showOrHideSearchOptions) forControlEvents:UIControlEventTouchUpInside];
    [searchTypeButton setBackgroundImage:[UIImage imageNamed:@"web_Arrow.png"] forState:UIControlStateNormal];
	[searchTypeButton setBackgroundImage:[UIImage imageNamed:@"web_Arrow.png"] forState:UIControlStateHighlighted];
	[self.view bringSubviewToFront:appLogoView];
	[self.view sendSubviewToBack:searchTypeView];
	[self.view sendSubviewToBack:searchTypeView];
	[self.view sendSubviewToBack:multitouchLargeView];
	[self.view sendSubviewToBack:detailedImageView];
	opQueue = [NSOperationQueue new];
	recallForNoResult = NO;
	
	contactUsView.frame = CGRectMake(0, 460 + 200 , 320, 200);
	
	width = self.view.frame.size.width;
	height = self.view.frame.size.height;
	//setting picture counts
	totalImageCount = [[Utility appDelegate].gsa_image_data count]-1;
	
	NSDate *date = [NSDate date];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"EEEE"];
    NSString *weekday = [formatter stringFromDate:date];
	currentImageCount = [Utility getCurrentImageCountWithWeekDay:weekday];
	
	xOffset = 90;
	yOffset = 130;
	
	imageViewInitialWidth = 150;
	imageViewInitialHeight = 150;
	imageViewFinalWidth = 250;
	imageViewFinalHeight = 250;
	
	isScrollViewVisible = NO;
	
	self.searchTableView.backgroundColor = [UIColor whiteColor];
	
	//initializing the width and height of scrollview when tapping on results in image result page
	scrollViewPageWidth = 320;
	scrollViewPageHeight = 324;
	
	wordsPerLine = 45;
	
    
	// load the content controller object for Phone-based devices
	clearHistoryFrame = CGRectMake(0, 0, 320, 21);
    baseImageName = @"name_iPhone";
	imageWidth = 500;
	imageHeight = 718;
	imagesPerCell = 3;
    
	
	//initializing frames for different zommlevels
	lPanNormal = CGRectMake(0, -yOffset, imageWidth, imageHeight);
    lPanZoom = CGRectMake(-xOffset, -yOffset, imageWidth - xOffset, imageHeight-yOffset);
    rPanNormal = CGRectMake(-(2 * xOffset), -yOffset, imageWidth, imageHeight);
    rPanZoom = CGRectMake(0, -yOffset, imageWidth - xOffset, imageHeight-yOffset);
    
	searchBarCancelButton.hidden = YES;
	int nextImageCount = 0;
	if(currentImageCount == totalImageCount || currentImageCount < 0) {
		nextImageCount = 0;
	} else {
		nextImageCount = currentImageCount + 1;
	}
	[bgImageView1 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [[[Utility appDelegate].gsa_image_data objectAtIndex:nextImageCount] objectForKey:baseImageName ]]]]; 
	[bgImageView2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [[[Utility appDelegate].gsa_image_data objectAtIndex:currentImageCount] objectForKey:baseImageName ]]]]; 
	bgImageView2.tag = currentImageCount + 1;
	bgImageView1.tag = nextImageCount + 1;
    
	[bgImageView1 setFrame:[Utility getFrameFromDict:[[Utility appDelegate].gsa_image_data objectAtIndex:(bgImageView1.tag -1)] forPosition:1]];
	[bgImageView2 setFrame:[Utility getFrameFromDict:[[Utility appDelegate].gsa_image_data objectAtIndex:(bgImageView2.tag - 1)] forPosition:1]];
}

- (void)viewDidAppear:(BOOL)animated {
	[self showSearchBarWithAnimation];
	[self updateNavButtons];
	
	//setting animation status 
	isSwipeRight = YES;
	isAnimating = NO;
	
	//zoom status 1= zoom out state; 2= zoom in state; 3= image swipe state;
	zoomStatus = 1;
	
	//start animating on loading the page
	[self startAnimating];
	
	//settings for showing previous search history
	historyTableView.hidden = YES;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.searchHistory = [NSMutableArray arrayWithArray:[defaults objectForKey:@"favoriteSearches"]];
	self.filteredSearches = [[NSArray alloc] initWithArray:self.searchHistory];
	
}

- (void)showSearchBarWithAnimation {
	
    isAnimating = YES;
    [self.view bringSubviewToFront:searchBoxView];
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    searchBoxView.frame = CGRectMake(0, 0, 320, 96);
	bottomToolBarView.frame = CGRectMake(0, height-44, width, 44);
	[UIView commitAnimations];
}

// called when the home button in the tool bar is tapped. 
// Removes the search webview and displays the image view with animation.
- (void)loadHomePage {
	
    
	[self.searchResults removeAllObjects];
	[viewHistory removeAllObjects];
	currentPosition = 0;
	searchTextField.text = @"";
	searchBarCancelButton.hidden = YES;
	[self changeSearchTypeWithMode:modeWebSearch isHistoryOperation:0];
	
	[self homeScreenUI];
	self.filteredSearches = [NSMutableArray arrayWithArray:self.searchHistory];
	prevBtn.enabled = NO;
	nxtBtn.enabled = NO;
	searchBarCancelButton.hidden = YES;
	
}

- (void)homeScreenUI {
	
	[self emptyScrollView];
	[self.view sendSubviewToBack:self.searchTableView];
	searchTypeView.hidden = YES;
	[self.view sendSubviewToBack:searchTypePop];
	[self.view sendSubviewToBack:detailedImageView];
	bottomToolBar.image = [UIImage imageNamed:@"bottom_toolbar_bar_bg.png"];
	
	searchBarBgImage.image = [UIImage imageNamed:@"search_bar_bg_with_box.png"];
	searchBarBgImage.frame = CGRectMake(0, 0, 320, 96);
	logoButton.frame = CGRectMake(10, 5, 100, 20);
	searchTextField.frame = CGRectMake(46, 30, 232, 31);
	searchSelectedTypeButton.frame = CGRectMake(16, 30, 30, 31);
	searchBarCancelButton.frame = CGRectMake(280, 32, 25, 25);
	searchViewWebButton.frame = CGRectMake(134, 70, 50, 21);
	searchViewImageButton.frame = CGRectMake(184, 70, 50, 21);
	searchViewRecallButton.frame = CGRectMake(239, 70, 55, 21);
	self.searchTableView.frame = CGRectMake(0, 96, 320, self.searchTableView.frame.size.height);
}

// called after each animation session to check for looping
- (void)checkAnimation {
	if(isAnimating) {
		[self startAnimating];
	}
}

// to start/continue the animation based on the current state.
// This function is iterative based on the animation setting.
- (void)startAnimating {
	[bgImageView1.layer removeAllAnimations];
	[bgImageView2.layer removeAllAnimations];
	isAnimating = YES;
	[UIImageView beginAnimations:nil context:NULL];
	[UIImageView setAnimationDelegate:self];
	if(zoomStatus == 1 ) {
		//current state is zoomed out, so start zooming in and let panning.
		zoomStatus = 2;
		[UIImageView setAnimationDuration:10];
		[UIImageView setAnimationDidStopSelector:@selector(checkAnimation)];
		int nextImageCount = 0;
		if(currentImageCount == totalImageCount || currentImageCount < 0) {
			nextImageCount = 0;
		} else {
			nextImageCount = currentImageCount + 1;
		}
		if(bgImageView1.alpha == 0.0) {
			bgImageView2.frame = [Utility getFrameFromDict:[[Utility appDelegate].gsa_image_data objectAtIndex:(bgImageView2.tag - 1)] forPosition:2];
			bgImageView1.frame = [Utility getFrameFromDict:[[Utility appDelegate].gsa_image_data objectAtIndex:nextImageCount] forPosition:1];
		}else {
			bgImageView1.frame = [Utility getFrameFromDict:[[Utility appDelegate].gsa_image_data objectAtIndex:(bgImageView1.tag - 1)] forPosition:2];
			bgImageView2.frame = [Utility getFrameFromDict:[[Utility appDelegate].gsa_image_data objectAtIndex:nextImageCount] forPosition:1];
		}
        
        
	} else if(zoomStatus == 2 ){
		//	current state is zoomed in, so change the picture in the other frame. 
		//	Make the current frame hidden and display the other frame.
		zoomStatus = 1; 
		[UIImageView setAnimationDuration:3];
		[UIImageView setAnimationDidStopSelector:@selector(checkAnimation)];
		
		if(currentImageCount == totalImageCount || currentImageCount < 0) {
			currentImageCount = 0;
		} else {
			currentImageCount += 1;
		}
		if(bgImageView1.alpha == 0.0) {
			[bgImageView1 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [[[Utility appDelegate].gsa_image_data objectAtIndex:currentImageCount] objectForKey:baseImageName]]]];
			bgImageView1.tag = currentImageCount +1;
			bgImageView1.alpha = 1.0;
			bgImageView2.alpha = 0;
		}else {
			[bgImageView2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [[[Utility appDelegate].gsa_image_data objectAtIndex:currentImageCount] objectForKey:baseImageName]]]];
			bgImageView2.tag = currentImageCount + 1;
			bgImageView2.alpha = 1.0;
			bgImageView1.alpha = 0;
		}
		
	} 
	[UIImageView commitAnimations];
}

//To save the search keyword to history
- (void)addToHistory:(NSString *)keyword {
	BOOL isDuplicate = NO;
	for (int i = 0; i < [self.searchHistory count]; i++) {
		if ([[self.searchHistory objectAtIndex:i] isEqual:keyword]) {
			isDuplicate = YES;		
		}
	}
	if ((!isDuplicate) && (keyword != nil)) {
		[self.searchHistory addObject:keyword];
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.searchHistory forKey:@"favoriteSearches"];
	[defaults synchronize];
}

- (IBAction)showOrHideSearchOptions {
	searchWebButton.alpha = 0.0;
	searchImageButton.alpha = 0.0;
	searchRecallButton.alpha = 0.0;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	
	if(searchTypePop.frame.size.height == 0 )    { //check the current visibility status of popup view
		searchTypePop.alpha = 1.0;
		searchTypePop.frame = CGRectMake(0, searchBarBgImage.frame.size.height, searchTypePop.frame.size.width, 128);
		[self.view bringSubviewToFront:searchTypePop];
		[UIView setAnimationDidStopSelector:@selector(showSearchOptionButtons)];
    } else {
		searchTypePop.frame = CGRectMake(0, searchBarBgImage.frame.size.height, searchTypePop.frame.size.width, 0);
		[UIView setAnimationDidStopSelector:@selector(hideSearchOptionView)];
    }
	[UIView commitAnimations];
}

- (void)hideSearchOptions {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	searchWebButton.alpha = 0.0;
	searchImageButton.alpha = 0.0;
	searchRecallButton.alpha = 0.0;
	searchTypePop.frame = CGRectMake(0, searchBarBgImage.frame.size.height, searchTypePop.frame.size.width, 0);
	[UIView setAnimationDidStopSelector:@selector(hideSearchOptionView)];
	[UIView commitAnimations];
}

- (void)showSearchOptionButtons {
	searchWebButton.alpha = 1.0;
	searchImageButton.alpha = 1.0;
	searchRecallButton.alpha = 1.0;
}

- (void)hideSearchOptionView {
	[self hideContactUs];
	searchTypePop.alpha = 0.0;
	[self.view sendSubviewToBack:searchTypePop];
}

- (IBAction)goForward {
    
	if(currentPosition < [self.viewHistory count] && currentPosition > 0) {
        
		NSMutableDictionary *nxtDict = [self.viewHistory objectAtIndex:currentPosition];
		NSMutableDictionary *currentDict = [self.viewHistory objectAtIndex:currentPosition - 1];
		
		if([[nxtDict objectForKey:@"mode"] intValue] == [[currentDict objectForKey:@"mode"] intValue]) {//same mode
			if([[nxtDict objectForKey:@"layer"] intValue] == [[currentDict objectForKey:@"layer"] intValue]) {// same layer
				if([[nxtDict objectForKey:@"layer"] intValue] == 1 && searchTypeMode == [[currentDict objectForKey:@"mode"] intValue]) {//we don't have to consider different layers, as two modes wont come close after layer one.
					currentPage = [[nxtDict objectForKey:@"pageNumber"] intValue];
					[self performSearchWithQuery:[nxtDict objectForKey:@"keyword"] mode:1];
					searchTextField.text = [nxtDict objectForKey:@"keyword"];
				} 
			} else if([[nxtDict objectForKey:@"layer"] intValue] > [[currentDict objectForKey:@"layer"] intValue]){// next layer is higher
				if([[nxtDict objectForKey:@"layer"] intValue] == 2) { // next layer is layer 2
					if([[nxtDict objectForKey:@"mode"] intValue] == modeWebSearch) {//websearch so open in web view
						WebPageViewController *webPageVC = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
						webPageVC.firstVC = self;
						webPageVC.urlString = [nxtDict objectForKey:@"keyword"];
                        webPageVC.pagePath = @"/Home/WebSearchDetails/LinkClick";
                        NSMutableDictionary *histDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",2], @"layer", [NSString stringWithFormat:@"%d",searchTypeMode], @"mode", [nxtDict objectForKey:@"keyword"], @"keyword", [NSString stringWithFormat:@"%d",currentPage], @"pageNumber", nil];
						[self updateViewHistoryWithDict:histDict mode:1];
						[self updateCurrentPosition:YES];
						[self.navigationController pushViewController:webPageVC animated:YES];
						[webPageVC release];
					} else if([[nxtDict objectForKey:@"mode"] intValue] == modeImageSearch){// image search so load scroll view
						[self emptyScrollView];	
						[self loadImages:[self.searchResults objectForKey:@"results"] selectedPosition:[[nxtDict objectForKey:@"keyword"] intValue] mode:1];
					} else if([[nxtDict objectForKey:@"mode"] intValue] == modeRecallSearch){// recall search so open recall details
                        WebPageViewController *webPageVC = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
						webPageVC.firstVC = self;
						webPageVC.urlString = [nxtDict objectForKey:@"keyword"];
						webPageVC.pagePath = @"/Home/RecallDetails/LinkClick";
                        NSMutableDictionary *histDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",2], @"layer", [NSString stringWithFormat:@"%d",searchTypeMode], @"mode", [nxtDict objectForKey:@"keyword"], @"keyword", [NSString stringWithFormat:@"%d",currentPage], @"pageNumber", nil];
						[self updateViewHistoryWithDict:histDict mode:1];
						[self updateCurrentPosition:YES];
						[self.navigationController pushViewController:webPageVC animated:YES];
						[webPageVC release];
						
					}
				} 
			}
		} else {
			if([[nxtDict objectForKey:@"layer"] intValue] == 1) {
				[self changeSearchTypeWithMode:[[nxtDict objectForKey:@"mode"] intValue] isHistoryOperation:1];
				currentPage = [[nxtDict objectForKey:@"pageNumber"] intValue];
				[self performSearchWithQuery:[nxtDict objectForKey:@"keyword"] mode:1];
				searchTextField.text = [nxtDict objectForKey:@"keyword"];
			}
		}
	} else if(currentPosition == 0){
		NSMutableDictionary *nxtDict = [self.viewHistory objectAtIndex:currentPosition];
		[self changeSearchTypeWithMode:[[nxtDict objectForKey:@"mode"] intValue] isHistoryOperation:1];
		currentPage = [[nxtDict objectForKey:@"pageNumber"] intValue];
		[self performSearchWithQuery:[nxtDict objectForKey:@"keyword"] mode:1];
		searchTextField.text = [nxtDict objectForKey:@"keyword"];
	}
	[self updateNavButtons];
}

- (IBAction)goBackward {
    
	if(currentPosition == 1) {
		[self updateCurrentPosition:NO];
		
		bottomToolBar.image = [UIImage imageNamed:@"bottom_toolbar_bar_bg.png"];
        
		searchTextField.text = @"";
		searchBarBgImage.image = [UIImage imageNamed:@"search_bar_bg_with_box.png"];
		searchBarBgImage.frame = CGRectMake(0, 0, 320, 96);
		logoButton.frame = CGRectMake(10, 5, 100, 20);
		searchTextField.frame = CGRectMake(46, 30, 232, 31);
		searchSelectedTypeButton.frame = CGRectMake(16, 30, 30, 31);
		searchBarCancelButton.frame = CGRectMake(280, 32, 25, 25);
		searchViewWebButton.frame = CGRectMake(134, 70, 50, 21);
		searchViewImageButton.frame = CGRectMake(184, 70, 50, 21);
		searchViewRecallButton.frame = CGRectMake(239, 70, 55, 21);
		self.searchTableView.frame = CGRectMake(0, 96, 320, self.searchTableView.frame.size.height);
		
		searchBarCancelButton.hidden = YES;
		[self emptyScrollView];
		[self.view sendSubviewToBack:self.searchTableView];
		searchTypeView.hidden = YES;
		[self.view sendSubviewToBack:searchTypePop];
		[self.view sendSubviewToBack:detailedImageView];
		[self updateNavButtons];
	} else {
		
		NSMutableDictionary *currentDict = [self.viewHistory objectAtIndex:currentPosition - 1];
		NSMutableDictionary *prevDict = [self.viewHistory objectAtIndex:currentPosition - 2];
		
		if([[prevDict objectForKey:@"mode"] intValue] == [[currentDict objectForKey:@"mode"] intValue]){
			if([[prevDict objectForKey:@"layer"] intValue] == 1) { 
				currentPage = [[prevDict objectForKey:@"pageNumber"] intValue];
				[self performSearchWithQuery:[prevDict objectForKey:@"keyword"] mode:2];
				searchTextField.text = [prevDict objectForKey:@"keyword"];
			} else {
				currentPage = [[prevDict objectForKey:@"pageNumber"] intValue];
				[self performSearchWithQuery:[prevDict objectForKey:@"keyword"] mode:2];
				searchTextField.text = [prevDict objectForKey:@"keyword"];
			}
		} else {
			if([[prevDict objectForKey:@"layer"] intValue] == 1) {
				[self changeSearchTypeWithMode:[[prevDict objectForKey:@"mode"] intValue] isHistoryOperation:2];
				currentPage = [[prevDict objectForKey:@"pageNumber"] intValue];
				
				recallForNoResult = NO;
				[self performSearchWithQuery:[prevDict objectForKey:@"keyword"] mode:2];
				searchTextField.text = [prevDict objectForKey:@"keyword"];
			}
            
		}
	}
	[self updateNavButtons];
}

- (void)removeLastViewFromHistorywithPosition {
	[self.viewHistory removeLastObject];
	[self updateCurrentPosition:NO];
}

- (void)updateCurrentPosition:(BOOL)input {
	if(input) {
		currentPosition ++;
    } else {
		currentPosition --;
	}
	
}

- (void)updateNavButtons {
	if ([self.viewHistory count] > 0) {
		if(currentPosition < [self.viewHistory count]) {
			nxtBtn.enabled = YES;
		} else {
			nxtBtn.enabled = NO;
		}
		if(currentPosition == 0) {
			prevBtn.enabled = NO;
		}else {
			prevBtn.enabled = YES;
		}
	} else {
		prevBtn.enabled = NO;
		nxtBtn.enabled = NO;
	}
}

- (IBAction)hideMultitouchView {
	[self.view sendSubviewToBack:multitouchLargeView];
}

- (IBAction)changeSearchType:(id)sender {
	int mode = [sender tag];
    isSearchInProgress = YES;
	if ([[searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
		[self addToHistory:searchTextField.text];		
	}
	[self changeSearchTypeWithMode:mode isHistoryOperation:0];
}

- (IBAction)changeSearchTypeWithMode:(int)mode isHistoryOperation:(int)operationMode {
	
	self.searchTableView.backgroundColor = [UIColor whiteColor];
	[self hideSearchOptions];
	
	searchTypeMode = mode;
	currentPage = 0;
	[self.searchResults removeAllObjects];
	[self.view sendSubviewToBack:detailedImageView];
	
	if ([searchTextField.text length] > 0 || searchTypeMode == modeRecallSearch) {
		[self.view sendSubviewToBack:historyTableView];
		[searchTextField resignFirstResponder];
	}
	
	[searchWebButton setSelected:NO];
	[searchImageButton setSelected:NO];
	[searchRecallButton setSelected:NO];
    
	[searchViewWebButton setSelected:NO];
	[searchViewImageButton setSelected:NO];
	[searchViewRecallButton setSelected:NO];
    
	if (searchTypeMode == modeWebSearch)
	{
        [searchWebButton setSelected:YES];
		[searchViewWebButton setSelected:YES];
		[searchSelectedTypeButton setImage:[UIImage imageNamed:@"web_Arrow.png"] forState:UIControlStateNormal];
		[searchSelectedTypeButton setImage:[UIImage imageNamed:@"web_Arrow.png"] forState:UIControlStateHighlighted];
	}
	else if (searchTypeMode == modeImageSearch){
        [searchImageButton setSelected:YES];
		[searchViewImageButton setSelected:YES];
		self.searchTableView.backgroundColor = [UIColor blackColor];
		[searchSelectedTypeButton setImage:[UIImage imageNamed:@"images_Arrow.png"] forState:UIControlStateNormal];
		[searchSelectedTypeButton setImage:[UIImage imageNamed:@"images_Arrow.png"] forState:UIControlStateHighlighted];
	}else if (searchTypeMode == modeRecallSearch){
        [searchRecallButton setSelected:YES];
		[searchViewRecallButton setSelected:YES];
		[searchSelectedTypeButton setImage:[UIImage imageNamed:@"recall_arrow.png"] forState:UIControlStateNormal];
		[searchSelectedTypeButton setImage:[UIImage imageNamed:@"recall_arrow.png"] forState:UIControlStateHighlighted];
	} 
	[self.searchResults removeAllObjects];
    [self.searchTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	if(operationMode == 0 ) {
		if ([searchTextField.text length] > 0) {
			nxtBtn.enabled = NO;
			prevBtn.enabled = NO;
			[self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:searchTextField.text];
		} else if (searchTypeMode == modeRecallSearch){
			recallForNoResult = NO;
			searchBarCancelButton.hidden = YES;
			nxtBtn.enabled = NO;
			prevBtn.enabled = NO;
			[self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:searchTextField.text];
        } else {
			[self homeScreenUI];
		}
	}
}

//To open deep links in a separate web page
- (void)openDeepLinks:(id)sender {
	UIButton *button = (UIButton *)sender;
	WebPageViewController *webPageVC = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
	webPageVC.urlString = button.titleLabel.text;
	[self.navigationController pushViewController:webPageVC animated:YES];
	[webPageVC release];
}

//To fetch the related search
- (void)openRelated:(id)sender {
    if(!isRelatedSearchInProgress) {
        
        
        UIButton *selected = (UIButton *)sender;
        [selected setTitleColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.11 alpha:1.0] forState:UIControlStateNormal];
        [selected setBackgroundImage:[UIImage imageNamed:@"bottom_toolbar_bar_bg_results.png"] forState:UIControlStateNormal];
        currentPage = 0;
        [self.searchResults removeAllObjects];
        recallForNoResult = NO;
        nxtBtn.enabled = NO;
        prevBtn.enabled = NO;
        
        [self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:selected.titleLabel.text];
        searchTextField.text = selected.titleLabel.text;
        [self addToHistory:selected.titleLabel.text];
    }
    isRelatedSearchInProgress = YES;
	
}

- (void)showResultImage:(id)sender {
    UIButton *selected = (UIButton *)sender;
	if ([selected.titleLabel.text length] > 0) {
        [opQueue cancelAllOperations];
        [self.view bringSubviewToFront:detailedImageView];
        isScrollViewVisible = YES;
		int arrayPosition = ([selected.titleLabel.text intValue] * imagesPerCell) + selected.tag;
		[self emptyScrollView];
		[self loadImages:[self.searchResults objectForKey:@"results"] selectedPosition:arrayPosition mode:0];
	}
}

//To remove all subviews from the scrollview
- (void)emptyScrollView {
	NSArray *viewArray = [imageScrollView subviews];
	for(UIView *v in viewArray) {
		[v removeFromSuperview];
	}
}

//To populate the scrollview
- (void)loadImages:(NSArray *)imageArray selectedPosition:(int)position mode:(int)mode{
	[self hideContactUs];
	NSMutableDictionary *histDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",2], @"layer", [NSString stringWithFormat:@"%d",searchTypeMode], @"mode", [NSString stringWithFormat:@"%d",position], @"keyword", [NSString stringWithFormat:@"%d",currentPage], @"pageNumber", nil];
	[self updateViewHistoryWithDict:histDict];
	if(mode == 0) {
		[self updateCurrentPosition:YES];
	} else if(mode == 1) {
		[self updateCurrentPosition:YES];
	} else if(mode == 1) {
		[self updateCurrentPosition:NO];
	}
	
	[self updateNavButtons];
	[self.view bringSubviewToFront:detailedImageView];
	isScrollViewVisible = YES;
	detailedImageView.backgroundColor = [UIColor blackColor];
	
	int startX = 0, xSeparator = 0;
	float scrollViewThumbImageWidth = 150, scrollViewThumbImageHeight = 150.0;
	int wordCount = [imageArray count];
	for (int i = 0; i < [imageArray count]; i++) {
		NSDictionary *thumbnailDetails = [[[self.searchResults objectForKey:@"results"] objectAtIndex:i] objectForKey:@"Thumbnail"];
		
		UIView	*thumbImageView = [[UIView alloc] initWithFrame:CGRectMake((startX+(i*(width+xSeparator))) , 0, scrollViewPageWidth, scrollViewPageHeight)];
		thumbImageView.tag = i+1; 
		UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
		imageButton.showsTouchWhenHighlighted = YES;
		imageButton.backgroundColor = [UIColor whiteColor];
        
		UIButton *urlButton = [UIButton buttonWithType:UIButtonTypeCustom];
		urlButton.frame = CGRectMake(35 , scrollViewPageHeight - 56, 250, 56);
		urlButton.showsTouchWhenHighlighted = YES;
		urlButton.opaque = NO;
		urlButton.tag = i+1+10001;
		[urlButton setBackgroundImage:[UIImage imageNamed:@"image_details_button_bg.png"] forState:UIControlStateNormal];
		[urlButton addTarget:self action:@selector(openImageDetail:) forControlEvents:UIControlEventTouchUpInside];
        
		UIImageView *largeImageView = [[UIImageView  alloc] initWithFrame:CGRectZero];
		largeImageView.hidden = YES;
		largeImageView.tag = i+1+10002;
		largeImageView.contentMode = UIViewContentModeScaleAspectFit;
		largeImageView.frame = CGRectMake(0, 0, scrollViewPageWidth, scrollViewPageHeight);
		
		UILabel *imageDetail = [[UILabel alloc] initWithFrame:CGRectZero];
		imageDetail.frame = CGRectMake(35 , scrollViewPageHeight - 56, 230, 56);
		imageDetail.numberOfLines = 0;
		imageDetail.tag = i+1+10003;
		imageDetail.lineBreakMode = UILineBreakModeWordWrap;
		imageDetail.textAlignment = UITextAlignmentCenter;
		imageDetail.font = [UIFont systemFontOfSize:13];
		imageDetail.backgroundColor = [UIColor clearColor];
		imageDetail.textColor = [UIColor whiteColor];
		imageDetail.text = [[[self.searchResults objectForKey:@"results"] objectAtIndex:i] objectForKey:@"title"];
		
		UILabel *imageSize = [[UILabel alloc] initWithFrame:CGRectZero];
		imageSize.frame = CGRectMake(scrollViewPageWidth - 110 , scrollViewPageHeight -45, 100, 27);
		imageSize.textAlignment = UITextAlignmentRight;
		imageSize.font = [UIFont systemFontOfSize:12];
		imageSize.backgroundColor = [UIColor clearColor];
		imageSize.textColor = [UIColor whiteColor];
		imageSize.text = [NSString stringWithFormat:@"%@ x %@", [[[self.searchResults objectForKey:@"results"] objectAtIndex:i] objectForKey:@"Width"], [[[self.searchResults objectForKey:@"results"] objectAtIndex:i] objectForKey:@"Height"]];
		
		
		float originalThumbnailWidth = [[thumbnailDetails objectForKey:@"Width"] floatValue];
		float originalThumbnailHeight = [[thumbnailDetails objectForKey:@"Height"]floatValue];
		float x = (scrollViewPageWidth - scrollViewThumbImageWidth)/2;
		float y = (scrollViewPageHeight - scrollViewThumbImageHeight)/2;
        if(originalThumbnailWidth != originalThumbnailWidth) {
            originalThumbnailWidth = 0;
        }
        if(originalThumbnailHeight != originalThumbnailHeight) {
            originalThumbnailHeight = 0;
        }
        if(0 != originalThumbnailHeight && 0 != originalThumbnailWidth) {
            if (originalThumbnailWidth > originalThumbnailHeight) {
                originalThumbnailHeight = originalThumbnailHeight * scrollViewThumbImageWidth/originalThumbnailWidth;
                originalThumbnailWidth = scrollViewThumbImageWidth;
                y = (scrollViewPageHeight - originalThumbnailHeight)/2;
            }
            else {
                originalThumbnailWidth = originalThumbnailWidth * scrollViewThumbImageHeight/originalThumbnailHeight;
                originalThumbnailHeight = scrollViewThumbImageHeight;
                x = (scrollViewPageWidth - originalThumbnailWidth)/2;
            }
        }
        
		imageButton.tag = i+1+10000;
		imageButton.frame = CGRectMake(x , y, originalThumbnailWidth, originalThumbnailHeight);
		if([[[self.searchResults objectForKey:@"results"] objectAtIndex:i] objectForKey:@"imageData"]) {
			[imageButton setBackgroundImage:[UIImage imageWithData:[[[self.searchResults objectForKey:@"results"] objectAtIndex:i] objectForKey:@"imageData"]] forState:UIControlStateNormal];
		} else {
			ImageLoadOperation *imgLoadOp = [[ImageLoadOperation alloc] initWithDelegate:self indexPath:nil	imageTag:i url:[thumbnailDetails objectForKey:@"Url"] mode:2];
			[opQueue addOperation:imgLoadOp];
			[imgLoadOp release];
		}
		
		[thumbImageView addSubview:largeImageView];
		[thumbImageView addSubview:imageButton];
		[thumbImageView addSubview:urlButton];
		[thumbImageView addSubview:imageDetail];
		[imageScrollView addSubview:thumbImageView];
		
		[largeImageView release];
		[imageSize release];
		[thumbImageView release];
		[imageDetail release];
	}
	imageScrollView.contentSize = CGSizeMake((wordCount*(scrollViewPageWidth + xSeparator) + xSeparator), scrollViewPageHeight);
	[imageScrollView setContentOffset:CGPointMake(scrollViewPageWidth * (position - 1), 0)];
	[self loadImageOperationForlargeImageWithPosition:position-1];
}

- (void)openImageDetail:(id)sender {
	UIButton *image = (UIButton *)sender;
	int index = image.tag - 10002;
    WebPageViewController *webPageVC = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
	webPageVC.urlString = [[[self.searchResults objectForKey:@"results"] objectAtIndex:index] objectForKey:@"Url"];
    webPageVC.pagePath = @"/Home/ImageSearchDetails/LinkClick";
	[self.navigationController pushViewController:webPageVC animated:YES];
	[webPageVC release];
	
}

- (IBAction)showSettings {
    [self.view bringSubviewToFront:contactUsView];
	contactUsView.frame = CGRectMake(10,475,320,200);
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:contactUsView cache:NO];
    contactUsView.frame = CGRectMake(10,235,320,235);
	[UIView commitAnimations];
}


- (IBAction)contactUsAction:(id)sender {
	
	WebPageViewController *webPageVC;
	switch ([sender tag]) {
		case message: {
            
			[Utility sendEmail:@"" :@"" :self];
			break;
        }
		case call:
		{
			UIAlertView *callOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Contact Us - Call" message:@"Call 1800 FED INFO"
																	  delegate:self cancelButtonTitle:@"Cancel" 
															 otherButtonTitles:@"Call", nil];
			[callOptionsAlert show];
			UIButton *popupbtn1 = (UIButton *)[[callOptionsAlert valueForKey:@"_buttons"] objectAtIndex:0];
			popupbtn1.frame = CGRectMake(150, popupbtn1.frame.origin.y, 120, popupbtn1.frame.size.height);
			UIButton *popupbtn2 = (UIButton *)[[callOptionsAlert valueForKey:@"_buttons"] objectAtIndex:1];
			popupbtn2.frame = CGRectMake(20, popupbtn2.frame.origin.y, 120, popupbtn2.frame.size.height);
			
			[callOptionsAlert release];
		}
			break;
		case visitSiteTag: {
            webPageVC = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
			webPageVC.firstVC = self;
            webPageVC.pagePath = @"/Home/SiteVisit/LinkClick";
			webPageVC.urlString = WEBSITE_LINK;
			[self.navigationController pushViewController:webPageVC animated:YES];
			[webPageVC release];
			break;
        }
		case visitBlogTag:{
            webPageVC = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
			webPageVC.firstVC = self;
			webPageVC.urlString =  BLOG_LINK;
            webPageVC.pagePath = @"/Home/BlogVisit/LinkClick";
			[self.navigationController pushViewController:webPageVC animated:YES];
			[webPageVC release];
			break;
        }
	}
	[self hideContactUs];
}

- (void)hideContactUs {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:contactUsView cache:NO];
	contactUsView.frame = CGRectMake(10,self.view.frame.size.height+50,320,200);
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    if(buttonIndex == 1) {
        NSString *phoneStr = [NSString stringWithFormat:PHONE_NUM];
        NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@",phoneStr]];
        [[UIApplication sharedApplication] openURL:url];
	}
}
#pragma mark -
#pragma mark Searchbar delegate Methods

- (IBAction)searchBarCancelButtonPressed {
	[opQueue cancelAllOperations];
	if ([searchTextField.text length] > 0) {
		searchTextField.text = @"";
		self.filteredSearches = nil;
		self.filteredSearches = self.searchHistory;
		[historyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
		[searchTextField becomeFirstResponder];
	}
	else {
		searchBarCancelButton.hidden = YES;
		[self.view sendSubviewToBack:historyTableView];
		[searchTextField resignFirstResponder];
	}
	
}

- (IBAction)searchBarSearchButtonClicked {
    historyTableView.hidden = YES;
	currentPage = 0;
	[self.searchResults removeAllObjects];
	self.searchKeyword = searchTextField.text;
	nxtBtn.enabled = NO;
	prevBtn.enabled = NO;
	
	if ([[searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
		[self addToHistory:searchTextField.text];
		[self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:self.searchKeyword];
		
	} else if (searchTypeMode == modeRecallSearch) {
		recallForNoResult = NO;
		[self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:self.searchKeyword];
	} else {
        [self.searchTableView reloadData];
    }
}

- (void)searchBarTextDidBeginEditing {
	appLogoView.frame = CGRectMake(0, 0, appLogoWidth, 44);
	[self.view bringSubviewToFront:historyTableView];
	historyTableView.hidden = NO;
}

#pragma mark -
#pragma mark Webview delegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[MBMNetworkActivity pushNetworkActivity];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if (webView == searchWebView) {
		[self.view bringSubviewToFront:self.searchTableView];
	}
	webView.hidden = NO;
	[MBMNetworkActivity popNetworkActivity];
	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if (webView == searchWebView) {
		[self.view bringSubviewToFront:self.searchTableView];
	}
	[MBMNetworkActivity popNetworkActivity];
}

- (void)enableNavButtonsForWebview:(UIWebView *)webView {
	if(webView.canGoBack) {
		prevBtn.enabled = YES;
	}
	else {
		prevBtn.enabled = NO;
	}
	
	if (webView.canGoForward) {
		nxtBtn.enabled = YES;
	}
	else {
		nxtBtn.enabled = NO;
	}
}

#pragma mark -
#pragma mark TextField Delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	searchBarCancelButton.hidden = NO;
	return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self.view bringSubviewToFront:historyTableView];
	historyTableView.hidden = NO;
	self.filteredSearches = nil;
	if ([searchTextField.text length] == 0) {
		self.filteredSearches = self.searchHistory;
	}
	[historyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	searchBarBgImage.image = [UIImage imageNamed:@"search_bar_bg_with_box.png"];
	searchBarBgImage.frame = CGRectMake(0, 0, 320, 96);
	logoButton.frame = CGRectMake(10, 5, 100, 20);
	searchTextField.frame = CGRectMake(46, 30, 232, 31);
	searchSelectedTypeButton.frame = CGRectMake(16, 30, 30, 31);
	searchBarCancelButton.frame = CGRectMake(280, 32, 25, 25);
	searchViewWebButton.frame = CGRectMake(134, 70, 50, 21);
	searchViewImageButton.frame = CGRectMake(184, 70, 50, 21);
	searchViewRecallButton.frame = CGRectMake(239, 70, 55, 21);
	self.searchTableView.frame = CGRectMake(0, 96, 320, self.searchTableView.frame.size.height);
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
	[self searchBarSearchButtonClicked];
	if ([searchTextField.text length] == 0) {
		searchBarCancelButton.hidden = YES;
	}
	return TRUE;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[self.view bringSubviewToFront:historyTableView];
	historyTableView.hidden = NO;
	
	NSMutableString *searchString = [[NSMutableString alloc] init];
	[searchString appendString:searchTextField.text];
	if ([string length] > 0) {
		[searchString appendString:string];
	}
	else {
		[searchString deleteCharactersInRange:NSMakeRange(([searchString length] - 1), 1)];
	}
	searchString = [NSMutableString stringWithString:[searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
	self.filteredSearches = nil;
	[opQueue cancelAllOperations];
	if([searchString length] <= 0) {
		searchTextField.text = @"";
		self.filteredSearches = [self.searchHistory copy];
		
	}else {
		SuggestionsOperation *suggestionsOperation = [[SuggestionsOperation alloc] initWithDelegate:self keyword:searchString];
		[opQueue addOperation:suggestionsOperation];
		[suggestionsOperation release];
	}
	
	[historyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	return TRUE;
}

#pragma mark -
#pragma mark scrollview delegate methods

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	if (scrollView == imageScrollView) {
		float x = scrollView.contentOffset.x;
		int pageNumber = x / scrollViewPageWidth;
		UIView *tempImageView = (UIView *)[imageScrollView viewWithTag:pageNumber];
		for (UIView *view in [tempImageView subviews]) {
			if(view.tag == pageNumber+1+10002  && [view isKindOfClass:[UIImageView class]]) {
				if ([view isHidden]) {
					[self loadImageOperationForlargeImageWithPosition:pageNumber];
				}
			}
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView == imageScrollView) {
		float x = scrollView.contentOffset.x;
		int pageNumber = x / scrollViewPageWidth;
		
		UIView *tempImageView = (UIView *)[imageScrollView viewWithTag:pageNumber+1];
		for (UIView *view in [tempImageView subviews]) {
			if(view.tag == pageNumber+1+10002  && [view isKindOfClass:[UIImageView class]]) {
				if (view.hidden == YES) {
					[self loadImageOperationForlargeImageWithPosition:pageNumber];
				}
			}
		}
    }
}

#pragma mark -
- (void)loadImageOperationForlargeImageWithPosition:(int)pos {
	UIView *tempImageView = (UIView *)[imageScrollView viewWithTag:pos + 1];
	UIButton *tempImageButton = (UIButton *)[tempImageView viewWithTag:pos+1+10000];
	if(tempImageButton && tempImageButton.frame.size.width == imageViewFinalWidth) {
	} else {
        if (self.searchResults && [self.searchResults objectForKey:@"results"] && [[self.searchResults objectForKey:@"results"] count] > pos) {
            ImageLoadOperation *imgLoadOp = [[ImageLoadOperation alloc] initWithDelegate:self indexPath:nil	imageTag:pos url:[[[self.searchResults objectForKey:@"results"] objectAtIndex:pos] objectForKey:@"MediaUrl"] mode:3];
            [opQueue addOperation:imgLoadOp];
            [imgLoadOp release];
        }		
	}	
}

- (void)calculateLabelSizeForRecalls:(NSString *)content {
	CGSize maximumLabelSize = CGSizeMake(300,50);
	CGSize expectedLabelSize = [content sizeWithFont:[[Utility contentLabel] font] constrainedToSize:maximumLabelSize	lineBreakMode:[Utility contentLabel].lineBreakMode]; 
	recallLabelHeight = expectedLabelSize.height;
}

- (void)calculateLabelSizeForWebsearch:(NSString *)content {
	
	CGSize maximumLabelSize = CGSizeMake(300,54);
	UIFont *contentlabelFont = [[Utility contentLabel] font];
	int contentLabelLineBreakMode = [Utility contentLabel].lineBreakMode;
	
	CGSize expectedLabelSize = [content sizeWithFont:contentlabelFont
								   constrainedToSize:maximumLabelSize 
									   lineBreakMode:contentLabelLineBreakMode]; 
	webSearchLabelHeight = expectedLabelSize.height;
	
}

#pragma mark TableView Methods
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int result = 1;
    if (tableView == self.searchTableView) {
		if(searchTypeMode == modeWebSearch) { 
			if ([[self.searchResults objectForKey:@"results"] count] > 0 && [[self.searchResults objectForKey:@"related"] count] > 0) {
				result = 2;
			}
		}
    }
    return result;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.searchTableView) {
		if (searchTypeMode == modeRecallSearch) {
            if ([[self.searchResults allKeys] containsObject:@"success"]) {
                if([[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] > 0) {
                    if([[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] < [[[self.searchResults objectForKey:@"success"] objectForKey:@"total"] intValue]) {
                        return [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] + 1;
                    }else {
                        return [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count];
                    }
                } else {
                    return 0;
                }
            } else {
                return 0;
            }
            
        }else if ([[self.searchResults allKeys] containsObject:@"results"]) {
			if(section == 0) {
				int result = [[self.searchResults objectForKey:@"results"] count];
                if (searchTypeMode == modeImageSearch) {
					if (result > 2) {
						result = result/imagesPerCell;
					}
                    else if (result > 0){
						result = 1;
					}
                    
                }
                if([[self.searchResults objectForKey:@"total"] intValue] != 0 && [[self.searchResults objectForKey:@"total"] intValue] != [[self.searchResults objectForKey:@"endrecord"] intValue]) {
                    result ++;
                }
                return result;
			} else if(section == 1) {
				if([[self.searchResults objectForKey:@"total"] intValue] != 0 && [[self.searchResults objectForKey:@"related"] count] > 0) {
                    return [[self.searchResults objectForKey:@"related"] count];
                }
				
			} else {
				return 0;
			}
		} else {
			return 0;
		}
		
	} else {
		if ([searchTextField.text length] > 0) {
            return [self.filteredSearches count];
		}
		else {
			if([self.filteredSearches count] > 0) {
				return [self.filteredSearches count] + 1;
			} else {
				return 0;
			}
		}
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchTableView) {
        if(indexPath.section == resultsSection) {
            if(searchTypeMode == modeRecallSearch) {
                if([[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] > 0 && [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] == indexPath.row) {
                    return 60;
                } else if([self.searchResults objectForKey:@"success"]) {
					NSDictionary *result = [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] objectAtIndex:indexPath.row];
					NSString *content;
					if ([[result objectForKey:@"organization"] isEqualToString:@"NHTSA"]) {
						content = [result objectForKey:@"defect_summary"];
					} else if ([[result objectForKey:@"organization"] isEqualToString:@"CPSC"]) {
						content = [[result objectForKey:@"descriptions"] objectAtIndex:0];
					} else if ([[result objectForKey:@"organization"] isEqualToString:@"CDC"]) {
						content = [result objectForKey:@"description"];
					}
					
					if([content length] > 0) {
                        
						[self performSelectorOnMainThread:@selector(calculateLabelSizeForRecalls:) withObject:content waitUntilDone:YES];
						float height1 = recallLabelHeight + 45;
						height1 = ( height1 < 80 ) ? 80 : height1;
						return height1;
						
					} else {
						return 80;
					}
					
                } else {
                    return 120.0;
                }
				
            } else if(searchTypeMode == modeImageSearch) {
                if([[self.searchResults objectForKey:@"total"] intValue] != 0 && [[self.searchResults objectForKey:@"total"] intValue] != [[self.searchResults objectForKey:@"endrecord"] intValue] && [[self.searchResults objectForKey:@"endrecord"] intValue] == indexPath.row  ) {
                    return 105.0;
                }
				
                else if([[[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"deepLinks"] isEqual:[NSNull null]]){
					
                    return 105.0;
					
                } else {
                    int height1 = 105;
                    
                    return height1;               
                }
            } else if(searchTypeMode == modeWebSearch){
                
                if([[self.searchResults objectForKey:@"total"] intValue] != 0 && [[self.searchResults objectForKey:@"total"] intValue] != [[self.searchResults objectForKey:@"endrecord"] intValue] && [[self.searchResults objectForKey:@"endrecord"] intValue] == indexPath.row  ) {
                    return 50.0;
                }
                else if([[self.searchResults objectForKey:@"related"] count] > 0 && [[self.searchResults objectForKey:@"endrecord"] intValue] + 1 == indexPath.row  ) {
                    int height2 = 40;
                    int relatedCount = [[self.searchResults objectForKey:@"related"] count];
                    height2 = height2 + (relatedCount * 40);
                    return height2 + 10;
                } else {
                    int height1 = 55;// 8+15+7+10+15
					
                    int contentLength = [[[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"content"] length];
					
                    if(contentLength > 0) {
                        
						NSString *content = [[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"content"];
						[self performSelectorOnMainThread:@selector(calculateLabelSizeForWebsearch:) withObject:content waitUntilDone:YES];
						height1 = height1 + webSearchLabelHeight;
						
					}else {
                        height1 = 55;
                    }
					
                    if([[[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"deepLinks"] isEqual:[NSNull null]]){
						
                        return height1;
						
                    } else {
                        
                        if([[[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"deepLinks"] isEqual:[NSNull null]]) {
                            return height1;
                        }else {
                            if (indexPath.row == 0 && searchTypeMode == modeWebSearch ) {
                                int deepLinkCount = [[[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"deepLinks"] count];
                                height1 = height1 + (((deepLinkCount/2) + 1) * 16);
                            }                   
                            return height1;
                        }
					}
                }
			}
        }
		return 44.0;//height for row at related search section
		
    }else { 
		if ([searchTextField.text length] == 0 && indexPath.row == 0) {
			return 21;
		}
        return 44.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {	
	if(section == 0) { //results header
		if (searchTypeMode == modeRecallSearch && recallForNoResult) {
			return 44;
		}
		return 20;
	} else { //related header
		return 20;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { 
	if (tableView == self.searchTableView) {
		
		UIView *customView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 325, 44)] autorelease];
        customView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_header_bg.png"]];
        UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 300, 20)] autorelease];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor colorWithRed:0.93 green:0.75 blue:0.023 alpha:1];
        headerLabel.highlightedTextColor = [UIColor whiteColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:12];
        [customView addSubview:headerLabel];
		
		UIImageView *noRecall = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 24)] autorelease];
		noRecall.image = [UIImage imageNamed:@"no_recalls_message.png"];
		if(section == 1 ){
			headerLabel.text = [NSString stringWithFormat:@"Searches related to '%@'",searchTextField.text ];
		}
		else {
			if(searchTypeMode == modeWebSearch && [[self.searchResults objectForKey:@"results"] count] > 0) {
				headerLabel.text = @"Web Results";
			} else if(searchTypeMode == modeImageSearch && [[self.searchResults objectForKey:@"results"] count] > 0){
				headerLabel.text = @"Image Results";
			} else if (searchTypeMode == modeRecallSearch && [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] > 0) {
				headerLabel.text = @"Recalls by Date";
				if ([searchTextField.text length] == 0) {
					headerLabel.text = @"Recent Recalls";
				}
				if (recallForNoResult) {
					headerLabel.text = @"Recent Recalls";
					[customView addSubview:noRecall];
				}
			} else {
                if(isSearchInProgress) {
                    headerLabel.text = @"Loading...";
                } else {
                    headerLabel.text = @"No results found.";
                }
				
			}
		}
		return customView;
		
	}else {
		return nil;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (tableView == self.searchTableView && ((searchTypeMode == modeWebSearch) ||(searchTypeMode ==  modeImageSearch))) {
		UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 19)];
		customView.backgroundColor = [UIColor clearColor];
		
		
		if ([[self.searchResults allKeys] containsObject:@"results"]) {
			int result = [[self.searchResults objectForKey:@"results"] count];
			if(result > 1) {
				UIImageView *footerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 19)];
				if (searchTypeMode == modeWebSearch) {
					footerImage.image = [UIImage imageNamed:@"results_bing_logo.png"];
				}
				else {
					footerImage.image = [UIImage imageNamed:@"results_bing_logo_images.png"];
				}
				UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 120, 19)];
				versionLabel.textColor = [UIColor lightGrayColor];
				versionLabel. font = [UIFont boldSystemFontOfSize:9];
				versionLabel.backgroundColor = [UIColor clearColor];
				versionLabel.text = @"Ver 1.1 - 0607";
				[customView addSubview:footerImage];
				[customView addSubview:versionLabel];
				[versionLabel release];
				if ([self numberOfSectionsInTableView:self.searchTableView] == 2) {
					if (section == 1) {
						return customView;
					}
				}
				else {
					return customView;
				}
			} else {
				return customView;
			}
            
		} else {
			return customView;
        }   
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	static NSString *CellIdentifier1 = @"Cell1";
	static NSString *CellIdentifier2 = @"Cell2";
	static NSString *CellIdentifier3 = @"Cell3";
	static NSString *CellIdentifier4 = @"Cell4";
	UITableViewCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
    if (loadingCell == nil) {
        loadingCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3] autorelease];
		loadingCell.backgroundColor = [UIColor whiteColor];
		loadingCell.textLabel.textAlignment = UITextAlignmentCenter;
		loadingCell.textLabel.text = @"Load more";
	}
	UITableViewCell *searchCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    if (!searchCell) {
		searchCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1] autorelease];
		searchCell.backgroundColor = [UIColor clearColor];
		[searchCell.contentView addSubview:[Utility titleLabel]];
		[searchCell.contentView addSubview:[Utility contentLabel]];
		[searchCell.contentView addSubview:[Utility urlLabel]];
		searchCell.backgroundColor = [UIColor whiteColor];
	}
	UITableViewCell *imageCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4];
    if (!imageCell) {
		imageCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier4] autorelease];
		imageCell.backgroundColor = [UIColor whiteColor];
		
		for (int i=1; i <= imagesPerCell; i++) {
			[imageCell.contentView addSubview:[Utility imageFrameWithTag:i+1000]];
			[imageCell.contentView addSubview:[Utility searchImageWithTag:i]];
		}
	}
	UITableViewCell *relatedCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (relatedCell == nil) {
        relatedCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
		relatedCell.backgroundColor = [UIColor whiteColor];
		relatedCell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundColor = [UIColor whiteColor];
		
		[cell.contentView addSubview:[Utility clearHistoryButton]];
		[cell.contentView addSubview:[Utility searchHistorynSuggestionText]];
		[cell.contentView addSubview:[Utility searchHistorynSuggestionImage]];
		[cell.contentView addSubview:[Utility searchHistoryAccessoryImage]];
	}
	UITableViewCell *recallCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (recallCell == nil) {
        recallCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		recallCell.backgroundColor = [UIColor whiteColor];
		[recallCell.contentView addSubview:[Utility recallType]];
		[recallCell.contentView addSubview:[Utility recallName]];
		[recallCell.contentView addSubview:[Utility companyName]];
		[recallCell.contentView addSubview:[Utility unitCountLabel]];
		[recallCell.contentView addSubview:[Utility datelabel]];
		[recallCell.contentView addSubview:[Utility recallTypeName]];
	}
	
	if (tableView == self.searchTableView) {//search results table view
		
		//this table has one sections and this section has three parts- results, loadmore and related
		if (indexPath.section == resultsSection) {
			
			if (searchTypeMode == modeWebSearch) { //web results section
				self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
				loadingCell.textLabel.textColor = [UIColor blackColor];
				
				if ([[self.searchResults objectForKey:@"total"] intValue] != 0 && [[self.searchResults objectForKey:@"total"] intValue] > [[self.searchResults objectForKey:@"endrecord"] intValue] && [[self.searchResults objectForKey:@"endrecord"] intValue] == indexPath.row ) {
					
					// condition for showing "Load more" row
					// when row count is equal to end record and totalrecord > endrecord
					loadingCell.textLabel.text = @"Load more";
                    loadingCell.textLabel.textAlignment = UITextAlignmentCenter;
                    loadingCell.userInteractionEnabled = YES;
                    return loadingCell;
				} else if([[self.searchResults objectForKey:@"related"] count] > 0 && [[self.searchResults objectForKey:@"endrecord"] intValue] + 1 == indexPath.row) {
					// condition for showing Relatedsearches row
					// when (end record +1) is equal to row count and "related search count" greater than zero
					return [self createRelatedCellforIndexpath:indexPath withCell:relatedCell];
					
				} else {
					//search results section
					return [self createWebResultsCellforIndexpath:indexPath withCell:searchCell];
					
				}
			} else if(searchTypeMode == modeImageSearch) {
				//image results section
				self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
				loadingCell.textLabel.textColor = [UIColor whiteColor];
				if ([[self.searchResults objectForKey:@"total"] intValue] != 0 && [[self.searchResults objectForKey:@"total"] intValue] > [[self.searchResults objectForKey:@"endrecord"] intValue] && ([[self.searchResults objectForKey:@"endrecord"] intValue])/imagesPerCell == indexPath.row ) {
					// condition for showing "Load more" row
					// when row count is equal to end record and totalrecord > endrecord
					loadingCell.textLabel.text = @"Load more";
                    loadingCell.textLabel.textAlignment = UITextAlignmentCenter;
					//To automatically call next set of results - removed from 0.9 release
					nxtBtn.enabled = NO;
					prevBtn.enabled = NO;
					currentPage = currentPage +1;
					recallForNoResult = NO;
                    loadingCell.userInteractionEnabled = YES;
					[self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:self.searchKeyword];
					return loadingCell;
					
				} else if([[self.searchResults objectForKey:@"related"] count] > 0 && ([[self.searchResults objectForKey:@"endrecord"] intValue])/imagesPerCell + 1 == indexPath.row) {
					// condition for showing Relatedsearches row
					// when (end record +1) is equal to row count and "related search count" greater than zero
					return [self createRelatedCellforIndexpath:indexPath withCell:relatedCell];
					
				} else {
					return [self createImageResultsCellforIndexpath:indexPath withCell:imageCell];
				}
			} else if(searchTypeMode == modeRecallSearch) {
				self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
				loadingCell.textLabel.textColor = [UIColor blackColor];
				if([[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] > 0 && [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] == indexPath.row) {
					nxtBtn.enabled = NO;
					prevBtn.enabled = NO;
					currentPage = currentPage +1;
                    loadingCell.userInteractionEnabled = YES;
                    NSLog(@"loading cell shown for recall");
					if (!recallForNoResult) {
						[self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:self.searchKeyword];
					}
					else {
						[self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:@""];
					}
					
					return loadingCell;
					
				}
                if(self.searchResults && [self.searchResults objectForKey:@"success"] && [[self.searchResults objectForKey:@"success"] objectForKey:@"results"] && [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] > indexPath.row) {
                    
                    NSDictionary *result = [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] objectAtIndex:indexPath.row];
                    if ([@"NHTSA" isEqualToString:[result objectForKey:@"organization"]]) {
                        [self configureFirstCell:recallCell withData:result];
                    }
                    
                    else if ([@"CPSC" isEqualToString:[result objectForKey:@"organization"]]) {
                        [self configureSecondCell:recallCell withData:result];
                    }
                    
                    else if ([@"CDC" isEqualToString:[result objectForKey:@"organization"]]) {
                        [self configureThirdCell:recallCell withData:result];
                    }
                }
				
				
				return recallCell;
			}
			
		} else {
			if (searchTypeMode == modeWebSearch) {
				// condition for showing Relatedsearches row
				// when (end record +1) is equal to row count and "related search count" greater than zero
				return [self createRelatedCellforIndexpath:indexPath withCell:relatedCell];
			}
		}
		
	} else {
		return [self createClearHistoryCellforIndexpath:indexPath withCell:cell];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self hideContactUs];
	if (tableView == self.searchTableView) {
        if(indexPath.section == 0) {
            if (searchTypeMode == modeRecallSearch) {
                if([[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] > 0 && [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] == indexPath.row) {
                    //
                } else {
                    WebPageViewController *webPageVC = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
                    webPageVC.firstVC = self;
                    webPageVC.urlString = [[[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"recall_url"];
                    webPageVC.pagePath = @"/Home/RecallDetails/LinkClick";
                    NSMutableDictionary *histDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",2], @"layer", [NSString stringWithFormat:@"%d",searchTypeMode], @"mode", [[[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"recall_url"], @"keyword", [NSString stringWithFormat:@"%d",currentPage], @"pageNumber", nil];
                    [self updateViewHistoryWithDict:histDict];
                    [self updateCurrentPosition:YES];
                    
                    [self.navigationController pushViewController:webPageVC animated:YES];
                    [self.searchTableView deselectRowAtIndexPath:indexPath animated:NO];
                    [webPageVC release];
                    
                }
            } else {
                historyTableView.hidden = YES;
                if([[self.searchResults objectForKey:@"total"] intValue] != 0 && [[self.searchResults objectForKey:@"total"] intValue] > [[self.searchResults objectForKey:@"endrecord"] intValue] && [[self.searchResults objectForKey:@"endrecord"] intValue]  == indexPath.row ) {
                    //load more section tapped
                    nxtBtn.enabled = NO;
                    prevBtn.enabled = NO;
                    if (searchTypeMode == modeWebSearch) {
                        currentPage++;
                        recallForNoResult = NO;
                        UITableViewCell *cc = [tableView cellForRowAtIndexPath:indexPath];
                        cc.userInteractionEnabled = NO;
                        [self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:self.searchKeyword];
                    }
                    
                    
                }else if([[self.searchResults objectForKey:@"related"] count] > 0 && [[self.searchResults objectForKey:@"endrecord"] intValue] + 1 == indexPath.row) {
                    //Related section no action required
                    NSLog(@"tapped on commnetd area");
                    
                }else if (indexPath.section == resultsSection){
                    if (searchTypeMode == modeWebSearch) {
                        //results section, results tapped
                        WebPageViewController *webPageVC = [[WebPageViewController alloc] initWithNibName:@"WebPageViewController" bundle:nil];
                        webPageVC.firstVC = self;
                        if (searchTypeMode == modeWebSearch) {
                            webPageVC.urlString = [[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"unescapedUrl"];
                            webPageVC.pagePath = @"/Home/WebSearchDetails/LinkClick";
                            NSMutableDictionary *histDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",2], @"layer", [NSString stringWithFormat:@"%d",searchTypeMode], @"mode", [[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"unescapedUrl"], @"keyword", [NSString stringWithFormat:@"%d",currentPage], @"pageNumber", nil];
                            [self updateViewHistoryWithDict:histDict];
                            [self updateCurrentPosition:YES];
                        }
                        else {
                            webPageVC.urlString = [[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"DisplayUrl"];
                            NSMutableDictionary *histDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",3], @"layer", [NSString stringWithFormat:@"%d",searchTypeMode], @"mode", [[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"DisplayUrl"], @"keyword", [NSString stringWithFormat:@"%d",currentPage], @"pageNumber", nil];
                            [self updateViewHistoryWithDict:histDict];
                            [self updateCurrentPosition:YES];
                        }
                        
                        if(webPageVC.urlString && [webPageVC.urlString length] > 0 ) {
                            [self.navigationController pushViewController:webPageVC animated:YES];
                        }
                        
                        [self.searchTableView deselectRowAtIndexPath:indexPath animated:NO];
                        [webPageVC release];
                    }
                    else {
                        if ([[self.searchResults objectForKey:@"total"] intValue] != 0 && [[self.searchResults objectForKey:@"total"] intValue] > [[self.searchResults objectForKey:@"endrecord"] intValue] && ([[self.searchResults objectForKey:@"endrecord"] intValue])/imagesPerCell == indexPath.row ) {
                            //[self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:self.searchKeyword];
                            
                        }
                    }
                    
                }
            }
        } else {
            //Related search section. No need to check cell tap here as we are using buttons
        }
	} else {
        
        
        
        if (indexPath.row == 0 && [searchTextField.text length] == 0) {
            //clear history button tapped
            [self.searchHistory removeAllObjects];
            self.filteredSearches = self.searchHistory;
            [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.searchHistory forKey:@"favoriteSearches"];
            [defaults synchronize];
        }
        else {
            //tapped from suggestions/search history
            
            historyTableView.hidden = YES;
            [searchTextField resignFirstResponder];
            
            currentPage = 0;
            [self.searchResults removeAllObjects];
            
            if ([searchTextField.text length] > 0) {
                self.searchKeyword = [self.filteredSearches objectAtIndex:indexPath.row];
            }
            else {
                self.searchKeyword = [self.filteredSearches objectAtIndex:[self.filteredSearches count] - indexPath.row];
            }
            recallForNoResult = NO;
			nxtBtn.enabled = NO;
			prevBtn.enabled = NO;
            [self performSelectorInBackground:@selector(performSearchWithQuery:) withObject:self.searchKeyword];
            searchTextField.text = self.searchKeyword;
            [self addToHistory:self.searchKeyword];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (UITableViewCell *)createClearHistoryCellforIndexpath:(NSIndexPath *)indexPath withCell:(UITableViewCell *)cell {
	[cell.contentView viewWithTag:clearHistoryButtonTag].alpha = 0.0;
	cell.textLabel.text = @"";
	UILabel *textlabel = (UILabel *)[cell.contentView viewWithTag:searchHistoryLabelTag];
	UIImageView *typeImage = (UIImageView *)[cell.contentView viewWithTag:searchHistoryImageTag];
	UIImageView *accessoryImage = (UIImageView *)[cell.contentView viewWithTag:searchHistoryAccessoryImageTag];
	UIButton *clearButton = (UIButton *)[cell.contentView viewWithTag:clearHistoryButtonTag];
	clearButton.alpha = 0.0;
	textlabel.text = @"";
	typeImage.image = nil;
	accessoryImage.image = nil;
	if (indexPath.row == 0 && ([searchTextField.text length] == 0)) {
		[cell.contentView viewWithTag:clearHistoryButtonTag].alpha = 1.0;
		[cell.contentView viewWithTag:clearHistoryButtonTag].frame = clearHistoryFrame;
		
	}
	else if ([self.filteredSearches count] != 0)  {
		
		if ([searchTextField.text length] > 0) {
			typeImage.image = nil;
			textlabel.text = [self.filteredSearches objectAtIndex:indexPath.row];
		}
		else {
			typeImage.image = [UIImage imageNamed:@"history.png"];
			textlabel.text = [self.filteredSearches objectAtIndex:[self.filteredSearches count] - indexPath.row];
		}
        
	}
	
	return cell;
}

- (UITableViewCell *)createImageResultsCellforIndexpath:(NSIndexPath *)indexPath withCell:(UITableViewCell *)imageCell {
	imageCell.selectionStyle = UITableViewCellSelectionStyleNone;
	for (int i=1; i <= imagesPerCell; i++) {
		if ([[self.searchResults objectForKey:@"results"] count] > (indexPath.row*imagesPerCell)+i-1) {
			int xPading = 2.5, yPadding = 2.5, thumbnailWidth = 100, thumbnailHeight = 100;
			UILabel *imageFrame = (UILabel *)[[imageCell contentView] viewWithTag:i+1000];
			imageFrame.frame = CGRectMake(0 + ((thumbnailWidth + (2* xPading)) * (i-1)), 0, thumbnailWidth + (2* xPading), thumbnailHeight + (2* yPadding));
 			imageFrame.layer.borderColor = [UIColor grayColor].CGColor;
			imageFrame.layer.borderWidth = 1.0f;
			
			NSDictionary *thumbnailDetails = [[[self.searchResults objectForKey:@"results"] objectAtIndex:(indexPath.row*imagesPerCell)+i-1] objectForKey:@"Thumbnail"];
			UIButton *searchImage2 = (UIButton *)[[imageCell contentView] viewWithTag:i];
			searchImage2.titleLabel.text = @"";
			[searchImage2 addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
			searchImage2.userInteractionEnabled = YES;
			
			float thumbnailOriginalWidth = [[thumbnailDetails objectForKey:@"Width"] floatValue];
			float thumbnailOriginalHeight = [[thumbnailDetails objectForKey:@"Height"]floatValue];
			float x = 2.5;
			float y = 2.5;
			if(thumbnailOriginalWidth != thumbnailOriginalWidth) {
				thumbnailOriginalWidth = 0;
			}
			if(thumbnailOriginalHeight != thumbnailOriginalHeight) {
				thumbnailOriginalHeight = 0;
			}
			if(0 != thumbnailOriginalHeight && 0 != thumbnailOriginalWidth) {
				if (thumbnailOriginalWidth > thumbnailOriginalHeight) {
					thumbnailOriginalHeight = thumbnailOriginalHeight * thumbnailWidth/thumbnailOriginalWidth;
					thumbnailOriginalWidth = thumbnailWidth;
					y = ((thumbnailHeight + (2* yPadding)) - thumbnailOriginalHeight)/2;
				}
				else {
					thumbnailOriginalWidth = thumbnailOriginalWidth * thumbnailHeight/thumbnailOriginalHeight;
					thumbnailOriginalHeight = thumbnailHeight;
					x = ((thumbnailWidth + (2* xPading)) - thumbnailOriginalWidth)/2;
				}
			}
			NSString *imageUrl2 = [thumbnailDetails objectForKey:@"Url"];
			searchImage2.frame = CGRectMake(x + ((thumbnailWidth + (2* xPading))  * (i-1)), y, thumbnailOriginalWidth, thumbnailOriginalHeight);
			[searchImage2 setBackgroundImage:nil forState:UIControlStateNormal];
			if([[[self.searchResults objectForKey:@"results"] objectAtIndex:(indexPath.row*imagesPerCell)+i-1] objectForKey:@"imageData"]) {
				[searchImage2 setBackgroundImage:[UIImage imageWithData:[[[self.searchResults objectForKey:@"results"] objectAtIndex:(indexPath.row*imagesPerCell)+i-1] objectForKey:@"imageData"]] forState:UIControlStateNormal];
				searchImage2.titleLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
				[searchImage2 addTarget:self action:@selector(showResultImage:) forControlEvents:UIControlEventTouchUpInside];
			} else {
				ImageLoadOperation *imgLoadOp = [[ImageLoadOperation alloc] initWithDelegate:self indexPath:indexPath imageTag:i url:imageUrl2 mode:1];
				[opQueue addOperation:imgLoadOp];
				[imgLoadOp release];
			}
		}
		else {
			UIButton *searchImage2 = (UIButton *)[[imageCell contentView] viewWithTag:i];
			[searchImage2 setBackgroundImage:nil forState:UIControlStateNormal];
			searchImage2.userInteractionEnabled = NO;
			
			UILabel *imageFrame = (UILabel *)[[imageCell contentView] viewWithTag:i+1000];
			imageFrame.layer.borderColor = [UIColor blackColor].CGColor;
			imageFrame.layer.borderWidth = 1.0f;
		}
        
	}
	
	return imageCell;
}

- (UITableViewCell *)createWebResultsCellforIndexpath:(NSIndexPath *)indexPath withCell:(UITableViewCell *)searchCell {
    UIView *prevView = (UIView *)[[searchCell contentView] viewWithTag:deeplinkTag];
    if(prevView)
        [prevView removeFromSuperview];
	
    UILabel *titleLabel = (UILabel *)[[searchCell contentView] viewWithTag:titleTag];
    UILabel *contentLabel = (UILabel *)[[searchCell contentView] viewWithTag:contentTag];
    UILabel *urlLabel = (UILabel *)[[searchCell contentView] viewWithTag:urlTag];
    
    
	[self performSelectorOnMainThread:@selector(calculateLabelSizeForWebsearch:) withObject:[[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"content"] waitUntilDone:YES];
	//adjust the label the the new height.
	CGRect newFrame = contentLabel.frame;
	newFrame.size.height = webSearchLabelHeight;
	contentLabel.frame = newFrame;
	
	
    titleLabel.text = [[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"title"] ;
    contentLabel.text = [[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"content"];
    urlLabel.text = [[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"unescapedUrl"];
    urlLabel.frame = CGRectMake(urlLabel.frame.origin.x, (contentLabel.frame.size.height + contentLabel.frame.origin.y + 2), urlLabel.frame.size.width, urlLabel.frame.size.height);
	
	
    if ([[[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"deepLinks"] isEqual:[NSNull null]]) {
        //No deep links
    } else {
        if(indexPath.row == 0) {
            int width1 = 300;
            int yPadding = urlLabel.frame.size.height + urlLabel.frame.origin.y;
            NSArray *deepLinksArray = [[[self.searchResults objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"deepLinks"];
            int height1 = [deepLinksArray count] * 50;
            UIView *deepLinkView = [[UIView alloc] initWithFrame:CGRectMake(0, yPadding, width1, height1)];
            deepLinkView.tag = deeplinkTag;
            int count = 0;
            int initialY = 5;
			
            for (NSMutableDictionary *link in deepLinksArray) {
				
                UIButton *button = [Utility deepLinksButton];
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 300, 15)];
                titleLabel.text = [link objectForKey:@"Title"];
                titleLabel.textColor = [UIColor colorWithRed:0.19921875 green:0.19921875 blue:0.597656 alpha:1];
                titleLabel.font = [UIFont systemFontOfSize:11];
				
                int y = initialY + (count/2)*15;
                count++;
                int x = 30;
                if(count %2 == 0  && count != 1) {
                    x = 168;
                    
                }
                
                button.frame = CGRectMake(x, y+2, 135, 15);
                titleLabel.frame = CGRectMake(0, 0, 135, 15);
                [button addSubview:titleLabel];
                [titleLabel release];
                [button addTarget:self action:@selector(openDeepLinks:) forControlEvents:UIControlEventTouchUpInside];
                button.titleLabel.text = [link objectForKey:@"Url"];
				
                [deepLinkView addSubview:button];
            }
            [searchCell.contentView addSubview:deepLinkView];
            [deepLinkView release];
        } else {
            //No deep links needed
        }
	}
    return searchCell;
	
}

- (UITableViewCell *)createRelatedCellforIndexpath:(NSIndexPath *)indexPath withCell:(UITableViewCell *)relatedCell {
	int width1 = 325;
    for (UIView *aView in [relatedCell.contentView subviews]) {
        if ([aView isKindOfClass:[UIButton class]]) {
            [aView removeFromSuperview];
        }
    }
    NSArray *relatedArray = [self.searchResults objectForKey:@"related"];
    int height1 = 40;
	
    if(indexPath.row < [relatedArray count]) {
		
        UIButton *button = [Utility deepLinksButton];
		button.frame = CGRectMake(0, 0, width1, height1);
		[button setTitle: [relatedArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
		[button setTitleColor:[UIColor colorWithRed:0.23 green:0.36 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
        
		[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[button setTitleEdgeInsets:UIEdgeInsetsMake(3, 10, 2, 4)];
        [button addTarget:self action:@selector(openRelated:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.text = [relatedArray objectAtIndex:indexPath.row];
		button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[relatedCell.contentView addSubview:button];
		
    }
	
    return relatedCell;
}

- (void)configureFirstCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails {
	
    UILabel *companyNameLabel = (UILabel *)[[cell contentView] viewWithTag:recallCompanyLabelTag];
    companyNameLabel.text = @"";
	companyNameLabel.frame = CGRectMake(70, 3, 240, 15);
	UILabel *nameLabel = (UILabel *)[[cell contentView] viewWithTag:recallNameLabelTag];
    nameLabel.text = @"";
	UILabel *unitLabel = (UILabel *)[[cell contentView] viewWithTag:recallUnitLabelTag];
    unitLabel.text = @"";
	UILabel *dateLabel = (UILabel *)[[cell contentView] viewWithTag:recallDateLabelTag];
    dateLabel.text = @"";
	
    UIImageView *recallImage = (UIImageView *)[[cell contentView] viewWithTag:recallImageTag];
    recallImage.image = nil;
    recallImage.image = [UIImage imageNamed:@"recall_type_auto.png"];
	recallImage.frame = CGRectMake(5, 0, 60, 60);
	
    UILabel *recallTypeLabel = (UILabel *)[[cell contentView] viewWithTag:recallTypeLabelTag];
    recallTypeLabel.text = @"";
    recallTypeLabel.text = @"Auto";
	recallTypeLabel.frame = CGRectMake(0, recallImage.frame.origin.y + 60, 70, 20);
    
    if ([resultDetails isKindOfClass:[NSDictionary class]]) {
        companyNameLabel.text = [[resultDetails objectForKey:@"recall_subject"] uppercaseString];
        unitLabel.text = [NSString stringWithFormat:@"By : %@",[resultDetails objectForKey:@"manufacturer"]];//[formatter stringFromNumber:number];
        dateLabel.text = [resultDetails objectForKey:@"recall_date"] ? [NSString stringWithFormat:@"%@",[resultDetails objectForKey:@"recall_date"]] : @"";
        nameLabel.text = [resultDetails objectForKey:@"defect_summary"];
        [self performSelectorOnMainThread:@selector(calculateLabelSizeForRecalls:) withObject:[resultDetails objectForKey:@"defect_summary"] waitUntilDone:YES];
    }
    
    nameLabel.frame = CGRectMake(70,companyNameLabel.frame.size.height + companyNameLabel.frame.origin.y + 5, 240, recallLabelHeight);
    unitLabel.frame = CGRectMake(150, nameLabel.frame.size.height + nameLabel.frame.origin.y + 5, 160, 15);
    dateLabel.frame = CGRectMake(70, nameLabel.frame.size.height + nameLabel.frame.origin.y + 5, 75, 15);
}

- (void)configureSecondCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails {
	
    
    UILabel *companyNameLabel = (UILabel *)[[cell contentView] viewWithTag:recallCompanyLabelTag];
    companyNameLabel.text = @"";
    companyNameLabel.frame = CGRectMake(70, 3, 240, 15);
    companyNameLabel.backgroundColor = [UIColor clearColor];
    companyNameLabel.numberOfLines = 1;
    
	
    UILabel *nameLabel = (UILabel *)[[cell contentView] viewWithTag:recallNameLabelTag];
    nameLabel.text = @"";
	float namelblheight;
	UILabel *unitLabel = (UILabel *)[[cell contentView] viewWithTag:recallUnitLabelTag];
    unitLabel.font = [UIFont systemFontOfSize:11];
	UILabel *dateLabel = (UILabel *)[[cell contentView] viewWithTag:recallDateLabelTag];
	dateLabel.text = @"";
    
	
    UIImageView *recallImage = (UIImageView *)[[cell contentView] viewWithTag:recallImageTag];
	recallImage.frame = CGRectMake(5, 0, 60, 60);
	recallImage.image = nil;
	recallImage.image = [UIImage imageNamed:@"recall_type_product.png"];
	
	
    UILabel *recallTypeLabel = (UILabel *)[[cell contentView] viewWithTag:recallTypeLabelTag];
	recallTypeLabel.frame = CGRectMake(0, recallImage.frame.origin.y + 60, 70, 20);
    recallTypeLabel.text = @"";
    recallTypeLabel.text = @"Product";	
    
    if ([resultDetails isKindOfClass:[NSDictionary class]]) {
        if ([[resultDetails objectForKey:@"product_types"] count] > 0) {
            companyNameLabel.text = [[[resultDetails objectForKey:@"product_types"] objectAtIndex:0] uppercaseString];
        }
        if ([[resultDetails objectForKey:@"descriptions"] count] > 0) {
            nameLabel.text = [[resultDetails objectForKey:@"descriptions"] objectAtIndex:0];
            [self performSelectorOnMainThread:@selector(calculateLabelSizeForRecalls:) withObject:[[resultDetails objectForKey:@"descriptions"] objectAtIndex:0] waitUntilDone:YES];
            nameLabel.frame = CGRectMake(70,companyNameLabel.frame.size.height + companyNameLabel.frame.origin.y + 5, 240, recallLabelHeight);
        } else {
            namelblheight = 20;
            nameLabel.frame = CGRectMake(70,companyNameLabel.frame.size.height + companyNameLabel.frame.origin.y + 5, 240, namelblheight);
        }
        NSString *manufacturersString = [[resultDetails objectForKey:@"manufacturers"] componentsJoinedByString:@" "];
        unitLabel.text = [NSString stringWithFormat:@"By: %@",manufacturersString];
        dateLabel.text = [resultDetails objectForKey:@"recall_date"] ? [NSString stringWithFormat:@"%@",[resultDetails objectForKey:@"recall_date"]] :@"";
    }
    dateLabel.frame = CGRectMake(70, nameLabel.frame.size.height + nameLabel.frame.origin.y + 5, 160, 15);
    unitLabel.frame = CGRectMake(150, nameLabel.frame.size.height + nameLabel.frame.origin.y + 5, 160, 15);
}

- (void)configureThirdCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails {
	
    
    UILabel *companyNameLabel = (UILabel *)[[cell contentView] viewWithTag:recallCompanyLabelTag];
    companyNameLabel.text = @"";
    
    companyNameLabel.numberOfLines = 1;
	companyNameLabel.frame = CGRectMake(70, 3, 240, 15);
	
    UILabel *nameLabel = (UILabel *)[[cell contentView] viewWithTag:recallNameLabelTag];
	nameLabel.lineBreakMode = UILineBreakModeWordWrap;
    nameLabel.text = @"";
    
    nameLabel.numberOfLines = 3;
    nameLabel.backgroundColor = [UIColor clearColor];
	
    UILabel *unitLabel = (UILabel *)[[cell contentView] viewWithTag:recallUnitLabelTag];
    unitLabel.text = @"";
	
    UILabel *dateLabel = (UILabel *)[[cell contentView] viewWithTag:recallDateLabelTag];
	dateLabel.frame = CGRectMake(70, 74, 75, 30);
    dateLabel.text = @"";
    
	
    UIImageView *recallImage = (UIImageView *)[[cell contentView] viewWithTag:recallImageTag];
    recallImage.image = nil;
    recallImage.image = [UIImage imageNamed:@"recall_type_food.png"];
	recallImage.frame = CGRectMake(5, 0, 60, 60);
	
    UILabel *recallTypeLabel = (UILabel *)[[cell contentView] viewWithTag:recallTypeLabelTag];
    recallTypeLabel.text = @"";
    recallTypeLabel.text = @"Food";
	recallTypeLabel.frame = CGRectMake(0, recallImage.frame.origin.y + 60, 70, 20);
    
    if ([resultDetails isKindOfClass:[NSDictionary class]]) {
        companyNameLabel.text = [[resultDetails objectForKey:@"summary"] uppercaseString];
        nameLabel.text = [resultDetails objectForKey:@"description"];
        dateLabel.text = [resultDetails objectForKey:@"recall_date"] ? [NSString stringWithFormat:@"%@",[resultDetails objectForKey:@"recall_date"]]: @"";
        [self performSelectorOnMainThread:@selector(calculateLabelSizeForRecalls:) withObject:[resultDetails objectForKey:@"description"] waitUntilDone:YES];
        
        nameLabel.frame = CGRectMake(70, 25, 210, recallLabelHeight);
    }
    
}

#pragma mark -
#pragma mark Touch and swipe detection methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	if(mystartTouchPosition.x != newTouchPosition.x || mystartTouchPosition.y != newTouchPosition.y) {
		isProcessingListMove = NO;
	}
	mystartTouchPosition = [touch locationInView:self.view];
    
	//check if touched outside the popup frame, then move the popup out of the visible frame
	if (!CGRectContainsPoint(contactUsView.frame, newTouchPosition)) { 
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:contactUsView cache:NO];
		contactUsView.frame = CGRectMake(10,475,320,200);
		[UIView commitAnimations];
		[self.view sendSubviewToBack:contactUsView];
	} 
	[self hideContactUs];
	[self hideSearchOptions];
	[super touchesBegan:touches withEvent:event];
}

#pragma mark -
#pragma mark Suggestions Operation delegate methods
- (void)suggestionOperationDidFinish:(NSArray *)suggestions {
	if(!historyTableView.hidden) {
		self.filteredSearches = nil;
		self.filteredSearches = suggestions; 
		[historyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	}
}

#pragma mark Search API and UI methods
- (void)performSearchWithQuery: (NSString *)searchString {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	if ([Utility connectionSuccess]) {
		[self performSearchWithQuery:searchString mode:0];
    }
	else {
		[Utility showAlertWithTitle:@"Warning!" message:@"Unable to connect to server. Please try again later." delegate:nil];
	}
    
	[pool release];
}

- (void)performSearchWithQuery: (NSString *)searchString mode:(int)mode {
    
	[searchViewWebButton setSelected:NO];
	[searchViewImageButton setSelected:NO];
	[searchViewRecallButton setSelected:NO];
    
	
	[opQueue cancelAllOperations];
	NSString *searchString1 = [[searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	int currentSearchMode = modeWebSearch; 
	NSData *responseData;
	if (searchTypeMode == modeWebSearch) {
		[searchViewWebButton setSelected:YES];
        if([searchString length] > 0 ) {
            responseData = [SearchWebservice performSearchWithkeyword:searchString1 page:currentPage+1];
        }        
		
	} else if (searchTypeMode == modeImageSearch) {
		currentSearchMode = modeImageSearch; 
		[searchViewImageButton setSelected:YES];
        if([searchString length] > 0 ) {
            responseData = [SearchWebservice performImageSearchForWebviewWithkeyword:searchString1 page:currentPage+1];
        } else {
            responseData = [[NSData alloc] init]; 
        }
	} else if (searchTypeMode == modeRecallSearch) {
		currentSearchMode = modeRecallSearch; 
		[searchViewRecallButton setSelected:YES];
		if([searchString length] > 0 ) {
			responseData = [SearchWebservice performRecallSearchWithQueryString:searchString1 page:currentPage+1];
		} else {
			responseData = [RecallWebservice recentRecallwithPage:currentPage +1];
		}
    }
    isSearchInProgress = NO;
    isRelatedSearchInProgress = NO;
	if(mode == 0) {
        NSMutableDictionary *histDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",1], @"layer", [NSString stringWithFormat:@"%d",searchTypeMode], @"mode", searchString, @"keyword", [NSString stringWithFormat:@"%d",currentPage], @"pageNumber", nil];
        [self updateViewHistoryWithDict:histDict];
        [self updateCurrentPosition:YES];
	} else if(mode == 1) {
		[self updateCurrentPosition:YES];
	} else if(mode == 2) {
		[self updateCurrentPosition:NO];
	}
	
	if (![searchTextField isFirstResponder]) {
		[self updateViewWithData:responseData type:1 currentSearchMode:currentSearchMode];
		[self updateNavButtons];
	}
}

- (void)updateViewHistoryWithDict:(NSMutableDictionary *)histDict mode:(int)mode{
	if(currentPosition < [viewHistory count]) {//if a new explicit action is performed by user, remove all forward pages from history
		if(mode == 0) {
			int tCount = [viewHistory count];
			for (int i= tCount; i > currentPosition; i--) {
				[viewHistory removeLastObject];
			}
			currentPosition = [viewHistory count];
			
		} else {
			return;
		}
    }
	
	
	if([self.viewHistory count] > 1) {
		NSMutableDictionary *lastDict = [self.viewHistory lastObject];
		
		if([[lastDict objectForKey:@"mode"] intValue] != [[histDict objectForKey:@"mode"] intValue]) {
			while ([[lastDict objectForKey:@"pageNumber"] intValue] > 0) {
				if([[lastDict objectForKey:@"layer"] intValue] == 1) {
					[viewHistory removeLastObject];
					lastDict = [self.viewHistory lastObject];
					
				} else {
					break;
				}
			}
			currentPosition = [viewHistory count];
		}
		
		
		if([[lastDict objectForKey:@"mode"] intValue] ==  modeWebSearch && [[lastDict objectForKey:@"layer"] intValue] ==  2) {
			[self.viewHistory removeLastObject];
			if(mode == 0) {
				currentPosition = [viewHistory count];
			}
			
		} else if([[lastDict objectForKey:@"mode"] intValue] ==  modeRecallSearch && [[lastDict objectForKey:@"layer"] intValue] ==  2) {
			[self.viewHistory removeLastObject];
			if(mode == 0) {
				currentPosition = [viewHistory count];
			}
			
		} else if ([[lastDict objectForKey:@"mode"] intValue] ==  modeImageSearch && [[lastDict objectForKey:@"layer"] intValue] ==  3) {
			[self.viewHistory removeLastObject];
			if(mode == 0) {
				currentPosition = [viewHistory count];
			}
		} else {
			if([[lastDict objectForKey:@"layer"] intValue] > [[histDict objectForKey:@"layer"] intValue]) {
				[self.viewHistory removeLastObject];
				if(mode == 0) {
					currentPosition = [viewHistory count];
				}
			}
		}
	}
	[self.viewHistory addObject:histDict];
	
	
}

- (void)updateViewHistoryWithDict:(NSMutableDictionary *)histDict {
	[self updateViewHistoryWithDict:histDict mode:0];
}

- (void)updateViewWithData:(NSData *)data type:(int)mode currentSearchMode:(int)currentSearchMode {
    searchBarBgImage.image = [UIImage imageNamed:@"search_bar_bg_with_box_for_results.png"];
	searchBarBgImage.frame = CGRectMake(0, 0, 320, 72);
	logoButton.frame = CGRectMake(5, 48, 100, 20);
	searchTextField.frame = CGRectMake(46, 12, 232, 31);
	searchSelectedTypeButton.frame = CGRectMake(16, 11, 30, 31);
	searchBarCancelButton.frame = CGRectMake(280, 14, 25, 25);
	searchViewWebButton.frame = CGRectMake(134, 46, 50, 21);
	searchViewImageButton.frame = CGRectMake(184, 46, 50, 21);
	searchViewRecallButton.frame = CGRectMake(239, 46, 55, 21);
	self.searchTableView.frame = CGRectMake(0, 72, 320, self.searchTableView.frame.size.height);
	
	bottomToolBar.image = [UIImage imageNamed:@"bottom_toolbar_bar_bg_results.png"];
	int currentResultsCount = [[self.searchResults objectForKey:@"results"] count];
	if (searchTypeMode == modeRecallSearch) {
		currentResultsCount = [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count];
	}
	
	if(currentPage == 0) {
		if(currentSearchMode == searchTypeMode) {
			if(searchTypeMode == modeRecallSearch) {
				[self.searchResults removeAllObjects];
				self.searchResults = [[data yajl_JSON] retain];
			} else {
				
				NSMutableDictionary *tempsearchResults = [[data yajl_JSON] retain];
                int startCount = 0;
                if ([tempsearchResults objectForKey:@"startrecord"] != [NSNull null]) {
                    startCount = [[tempsearchResults objectForKey:@"startrecord"] intValue];
                }
				if(1 == startCount) {
					[self.searchResults removeAllObjects];
					self.searchResults = [[data yajl_JSON] retain];
				}
				[tempsearchResults release];	
			}
		}
	} else {
		
		if(searchTypeMode == modeRecallSearch) {
			NSMutableArray *resultsArray = [NSMutableArray arrayWithArray:[[self.searchResults objectForKey:@"success"] objectForKey:@"results"]];
			if([resultsArray count] > (currentPage * 10)) {
				while ([resultsArray count] > (currentPage * 10)) {
					[resultsArray removeLastObject];
				}
			}
			self.searchResults = [[data yajl_JSON] retain];
			NSArray *newResultsArray = [resultsArray arrayByAddingObjectsFromArray:[[self.searchResults objectForKey:@"success"] objectForKey:@"results"]];
			[[self.searchResults objectForKey:@"success"] setObject:newResultsArray forKey:@"results"];
		} else {
			NSMutableArray *resultsArray = [NSMutableArray arrayWithArray:[self.searchResults objectForKey:@"results"]];
			int perPageCount = 10;
			if(searchTypeMode == modeImageSearch) {
				perPageCount = 30;
			}
			if([resultsArray count] > (currentPage * perPageCount)) {
				while ([resultsArray count] > (currentPage * perPageCount)) {
					[resultsArray removeLastObject];
				}
			}
			self.searchResults = [[data yajl_JSON] retain];
			NSArray *newResultsArray = [resultsArray arrayByAddingObjectsFromArray:[self.searchResults objectForKey:@"results"] ];
			[self.searchResults setObject:newResultsArray forKey:@"results"];
		}
	}
	[self.view bringSubviewToFront:self.searchTableView];
	[self.view bringSubviewToFront:bottomToolBarView];
	historyTableView.hidden = YES;
	if (searchTypeMode == modeRecallSearch && [[[self.searchResults objectForKey:@"success"] objectForKey:@"results"] count] == 0) {
		recallForNoResult = YES;
		currentPage = 0;
		[self performSearchWithQuery:@"" mode:3];
	}
	else {
		[self.searchTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	}
	if (currentPage > 0) {
		[self performSelectorOnMainThread:@selector(scrollTableView) withObject:nil waitUntilDone:NO];
	}
}

- (void)scrollTableView {
    int numOfActiveRows = [self.searchTableView numberOfRowsInSection:0];
    if(numOfActiveRows > 10) {
        numOfActiveRows = numOfActiveRows - 10;
    }
    NSLog(@"scrol to index - %d",numOfActiveRows);
    if (numOfActiveRows > 0) {
        [self.searchTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numOfActiveRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } 
}

#pragma mark --
#pragma mark ImageLoadOperation delegate methods
- (void)imageLoadOperationDidFinishWithImage:(NSMutableArray *)params {
	[self performSelectorOnMainThread:@selector(updateImages:) withObject:params waitUntilDone:NO];
}

- (void)imageLoadOperationForScrollViewDidFinishWithImage:(NSMutableArray *)params {
	[self performSelectorOnMainThread:@selector(updateImagesInScrollView:) withObject:params waitUntilDone:NO];
}

- (void)imageLoadOperationForLargeImageInScrollViewDidFinishWithImage:(NSMutableArray *)params {
	[self performSelectorOnMainThread:@selector(updateLargeImagesInScrollView:) withObject:params waitUntilDone:NO];
}

- (void)updateImagesInScrollView:(NSArray *)params {
	if(searchTypeMode == modeImageSearch) {
		int tag = [[params objectAtIndex:2] intValue];
		UIView *tempImageView = (UIView *)[imageScrollView viewWithTag:tag + 1];
		
		for (UIView *view in [tempImageView subviews]) {
			if(view.tag == tag+1+10000  && [view isKindOfClass:[UIButton class]]) {
				UIButton *tempImageButton = (UIButton *)[tempImageView viewWithTag:tag+1+10000];
				[tempImageButton setBackgroundImage:[UIImage imageWithData:[params objectAtIndex:0]] forState:UIControlStateNormal];
			}
		}
	}
}

- (void)updateLargeImagesInScrollView:(NSArray *)params {
	if(searchTypeMode == modeImageSearch) {
		int tag = [[params objectAtIndex:2] intValue];
        
		UIView *tempImageView = (UIView *)[imageScrollView viewWithTag:tag + 1];
		for (UIView *view in [tempImageView subviews]) {
			
			if(view.tag == tag+1+10002  && [view isKindOfClass:[UIImageView class]]) {
				UIImageView *tempImageDetail = (UIImageView *)[tempImageView viewWithTag:tag+1+10002];
				[tempImageView bringSubviewToFront:tempImageDetail];
				tempImageDetail.image = [UIImage imageWithData:(NSData *)[params objectAtIndex:0]];
				tempImageDetail.hidden = NO;
            }
		}
		
		for (UIView *view in [tempImageView subviews]) {
			
			if(view.tag == tag+1+10001  && [view isKindOfClass:[UIButton class]]) {
				[tempImageView bringSubviewToFront:view];
            }
		}
		
		for (UIView *view in [tempImageView subviews]) {
			
			if(view.tag == tag+1+10003  && [view isKindOfClass:[UILabel class]]) {
				[tempImageView bringSubviewToFront:view];
            }
		}
        
	}
}

- (void)updateImages:(NSArray *)params {
	if(searchTypeMode == modeImageSearch) {
		NSIndexPath *tempIndexPath = (NSIndexPath *)[params objectAtIndex:1];
		UITableViewCell *tempCell = [self.searchTableView cellForRowAtIndexPath:tempIndexPath];
		UIButton *tempImageView = (UIButton *)[[tempCell contentView] viewWithTag:[[params objectAtIndex:2] intValue]];
        [tempImageView setBackgroundImage:[UIImage imageWithData:[params objectAtIndex:0]] forState:UIControlStateNormal];
		tempImageView.titleLabel.text = [NSString stringWithFormat:@"%d", tempIndexPath.row];
		[tempImageView addTarget:self action:@selector(showResultImage:) forControlEvents:UIControlEventTouchUpInside];
	}
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {   
    [self dismissModalViewControllerAnimated:YES];	
}

#pragma mark --
- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarningdidReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[opQueue cancelAllOperations];
	[bgImageView1.layer removeAllAnimations];
	[bgImageView2.layer removeAllAnimations];
	isAnimating = NO;
}

- (void)dealloc {
    [super dealloc];
}

- (IBAction)getCurrentPositions {
	NSLog(@"getCurrentPositionsgetCurrentPositions currentPage = %d current position - %d, count = %d viewHistory -%@",currentPage ,currentPosition, [self.viewHistory count], self.viewHistory);
}

@end
