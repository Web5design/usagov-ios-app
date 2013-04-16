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
//  FirstViewController.h
//  General Services Administration
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "SuggestionsOperationDelegate.h"
#import "ImageLoadOperationDelegate.h"


@interface FirstViewController : UIViewController<UISearchBarDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, SuggestionsOperationDelegate, UITableViewDelegate, UITableViewDataSource, ImageLoadOperationDelegate, UIScrollViewDelegate, UITextFieldDelegate > {
	
	IBOutlet UIImageView *bottomToolBar;
	IBOutlet UIWebView *searchWebView;
	IBOutlet UIButton *prevBtn, *nxtBtn;
	IBOutlet UITextField *searchTextField;
	IBOutlet UISearchBar *keywordSeachBar;
	IBOutlet UITableView *historyTableView;
	IBOutlet UIScrollView *imageScrollView, *multitouchScrolView ;
	IBOutlet UIView *imageAnimationView, *searchTypeView, *searchTypePop, *detailedImageView, *contactUsView, *searchBoxView, *bottomToolBarView;
	IBOutlet UIImageView *bgImageView1, *bgImageView2, *appLogoView, *searchBarBgImage, *multitouchImageView, *multitouchLargeView;
	IBOutlet UIButton *searchViewWebButton, *searchViewImageButton, *searchViewRecallButton, *searchWebButton, *searchImageButton, *searchRecallButton,*searchSelectedTypeButton, *searchBarCancelButton , *logoButton;
	
	UIButton *searchTypeButton;
	UITableView *searchTableView;
	
	NSString *searchKeyword;
	NSString *baseImageName;
	NSArray *filteredSearches;
	NSOperationQueue *opQueue;
	NSMutableDictionary *searchResults;
	NSMutableArray *searchHistory, *viewHistory; 
	
	CGPoint mystartTouchPosition;
	CGRect lPanNormal, lPanZoom, rPanNormal, rPanZoom, clearHistoryFrame;
	
	int zoomStatus;
	int	wordsPerLine;
	int searchTypeMode;
	int currentPosition;
	int	currentPage, imagesPerCell;
	int totalImageCount, currentImageCount;
	int recallLabelHeight, webSearchLabelHeight;
	
	float scrollViewPageWidth, scrollViewPageHeight;
	float width, height, imageWidth, imageHeight, xOffset, yOffset, appLogoWidth;//for animation
	float imageViewInitialWidth, imageViewInitialHeight, imageViewFinalWidth, imageViewFinalHeight;//for scrollview
		
	BOOL isScrollViewVisible, recallForNoResult;
	BOOL vsibilityStatus, isAnimating;
	BOOL isProcessingListMove, isSwipeRight;
    BOOL isSearchInProgress, isRelatedSearchInProgress;

}

@property (nonatomic, retain) IBOutlet UITableView *searchTableView;
@property (nonatomic, retain) IBOutlet UIView *imageAnimationView;
@property (nonatomic, retain) IBOutlet UIWebView *searchWebView;
@property (nonatomic, retain) NSMutableArray *searchHistory, *viewHistory;
@property (nonatomic, retain) NSString *baseImageName;
@property (nonatomic, retain) NSArray *filteredSearches;
@property (nonatomic, retain) NSString *searchKeyword;
@property (nonatomic, retain) NSMutableDictionary *searchResults;
@property int currentPosition;

- (void)hideContactUs;
- (void)homeScreenUI;
- (void)startAnimating;
- (void)scrollTableView;
- (void)emptyScrollView;
- (void)updateNavButtons;
- (void)showSearchBarWithAnimation;

- (void)openRelated:(id)sender;
- (void)openImageDetail:(id)sender;
- (void)addToHistory:(NSString *)keyword;
- (void)updateCurrentPosition:(BOOL)input; 
- (void)removeLastViewFromHistorywithPosition;
- (void)enableNavButtonsForWebview:(UIWebView *)webView;
- (void)performSearchWithQuery: (NSString *)searchString;
- (void)loadImageOperationForlargeImageWithPosition:(int)pos;
- (void)updateViewHistoryWithDict:(NSMutableDictionary *)histDict;
- (void)performSearchWithQuery: (NSString *)searchString mode:(int)mode;
- (void)updateViewHistoryWithDict:(NSMutableDictionary *)histDict mode:(int)mode;
- (void)loadImages:(NSArray *)imageArray selectedPosition:(int)position mode:(int)mode;
- (void)updateViewWithData:(NSData *)data type:(int)mode currentSearchMode:(int)currentSearchMode;



- (UITableViewCell *)createClearHistoryCellforIndexpath:(NSIndexPath *)indexPath withCell:(UITableViewCell *)cell;
- (UITableViewCell *)createRelatedCellforIndexpath:(NSIndexPath *)indexPath withCell:(UITableViewCell *)relatedCell;
- (UITableViewCell *)createWebResultsCellforIndexpath:(NSIndexPath *)indexPath withCell:(UITableViewCell *)searchCell;
- (UITableViewCell *)createImageResultsCellforIndexpath:(NSIndexPath *)indexPath withCell:(UITableViewCell *)imageCell;

- (void)configureFirstCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails;
- (void)configureSecondCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails;
- (void)configureThirdCell:(UITableViewCell *)cell withData:(NSDictionary *)resultDetails;

- (IBAction)goForward;
- (IBAction)goBackward;
- (IBAction)showSettings;
- (IBAction)loadHomePage;
- (IBAction)hideMultitouchView;
- (IBAction)getCurrentPositions;
- (IBAction)showOrHideSearchOptions;
- (IBAction)searchBarCancelButtonPressed;
- (IBAction)searchBarSearchButtonClicked;

- (IBAction)contactUsAction:(id)sender;
- (IBAction)changeSearchType:(id)sender;
- (IBAction)changeSearchTypeWithMode:(int)mode isHistoryOperation:(int)operationMode;

@end
