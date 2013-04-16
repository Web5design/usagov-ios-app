//
//  SearchSettingsViewController.h
//  GSA
//
//  Created by Mobomo LLC on 9/8/10.
//  Copyright 2010 Mobomo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SearchSettingsViewController  : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate> {
	
	IBOutlet UIBarButtonItem *settingsDoneBarButton;
	IBOutlet UIButton *callButton, *mailButton, *visitBlog, *visitSite;
}

- (IBAction) finishSettings; 
- (IBAction) settingsAction:(id)sender;

@property(retain,nonatomic)	IBOutlet UIBarButtonItem *settingsDoneBarButton;
@property(retain,nonatomic) IBOutlet UIButton *callButton;
@property(retain,nonatomic) IBOutlet UIButton *mailButton;
@property(retain,nonatomic) IBOutlet UIButton *visitBlog;
@property(retain,nonatomic) IBOutlet UIButton *visitSite;

@end
