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
//  WebPageViewController.m
//  General Services Administration
//

#import "WebPageViewController.h"
#import "Utility.h"

@implementation WebPageViewController
@synthesize urlString;
@synthesize activityIndicator;
@synthesize resultsWebView;
@synthesize firstVC, pagePath;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self enableNavButtonsForWebview:resultsWebView];
	[self.resultsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
	self.title = @"Web";
    [activityIndicator startAnimating];
}

- (IBAction)homePage {
	[firstVC updateCurrentPosition:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Webview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    

	
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self enableNavButtonsForWebview:webView];
	[self.activityIndicator stopAnimating];
    toastView.hidden = YES;
}


//delegate method to track the link clicks from UIWebview
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        // for tracking
        
    }
        return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self enableNavButtonsForWebview:webView];
    [self.activityIndicator stopAnimating];
    toastView.hidden = YES;
}




- (void)enableNavButtonsForWebview:(UIWebView *)webView {
	prevBtn.enabled = YES;
	if(webView.canGoBack) {
		[prevBtn removeTarget:self action:@selector(homePage) forControlEvents:UIControlEventTouchUpInside];
		[prevBtn addTarget:self action:@selector(previousWebPage) forControlEvents:UIControlEventTouchUpInside];
	}
	else {
		[prevBtn removeTarget:self action:@selector(previousWebPage) forControlEvents:UIControlEventTouchUpInside];
		[prevBtn addTarget:self action:@selector(homePage) forControlEvents:UIControlEventTouchUpInside];
	}
	
	if (webView.canGoForward) {
		nxtBtn.enabled = YES;
	}
	else {
		nxtBtn.enabled = NO;
	}
	
}

- (void)previousWebPage {
	[self.resultsWebView goBack];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	//NSLog(@"viewDidUnload");

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[self.resultsWebView stopLoading];
	self.resultsWebView = nil;
	[self.activityIndicator release];
    [super dealloc];
}


@end
