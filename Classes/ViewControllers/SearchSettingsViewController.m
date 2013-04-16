//
//  SearchSettingsViewController.m
//  GSA
//
//  Created by Mobomo LLC on 9/8/10.
//  Copyright 2010 Mobomo LLC. All rights reserved.
//

#import "SearchSettingsViewController.h"

enum {
	call = 1,
	message,
	visitBlogTag,
	visitSiteTag
	
};


@implementation SearchSettingsViewController

@synthesize settingsDoneBarButton, callButton, mailButton, visitBlog, visitSite;

- (IBAction) finishSettings {
	[self dismissModalViewControllerAnimated:YES];	
}

- (IBAction) settingsAction:(id)sender {
	
	NSLog(@"button tag = %d",[sender tag]);

	switch ([sender tag]) {
		case message:
			[self sendEmail:@"" :@""];
			break;
			
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
		case visitSiteTag:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://search.usa.gov/"]];
			break;
			
		case visitBlogTag:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://blog.usa.gov/"]];
			break;
	}
			
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	if(buttonIndex == 1) {
		NSString *phoneStr = [NSString stringWithFormat:@"tel://+1-800-333-4636"];
		NSURL *url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@",phoneStr]];
		[[UIApplication sharedApplication] openURL:url];
	 }
}


#pragma mark - sendEmail

//For launching the mail app
- (void)sendEmail:(NSString *)emailSubject:(NSString *)emailBody {
	
	NSMutableArray *emailRecipients = [[NSMutableArray alloc] init];
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
	if (mailClass != nil){
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail]) {
            [self displayComposerSheet:emailRecipients:emailSubject:emailBody];
        }
        else {
            [self launchMailAppOnDevice:emailRecipients:emailSubject:emailBody];
        }
    }
    else {
        [self launchMailAppOnDevice:emailRecipients:emailSubject:emailBody];
    }
}

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void)displayComposerSheet:(NSArray *)emailRecipients:(NSString *)emailSubject:(NSString *)emailBody {
    MFMailComposeViewController *composeView = [[MFMailComposeViewController alloc] init];
    composeView.mailComposeDelegate = self;
    [composeView setSubject:emailSubject];
	[composeView setToRecipients:emailRecipients];
    [composeView setMessageBody:emailBody isHTML:YES];
	[self presentModalViewController:composeView animated:YES];
    [composeView release];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {   
    [self dismissModalViewControllerAnimated:YES];	
}

#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
- (void)launchMailAppOnDevice:(NSArray *)emailRecipients:(NSString *)emailSubject:(NSString *)emailBody {
	
	NSString *text = @"";
    int i;
    int recipientCount = [emailRecipients count];
    for(i=0; i<recipientCount; i++) {
        text = [text stringByAppendingString:[NSString stringWithFormat:@"%@,",[emailRecipients objectAtIndex:i]]];
    }
	
	NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@", text, emailSubject, emailBody];
	mailString = [mailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
	
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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


@end
