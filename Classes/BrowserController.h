//
//  BrowserController.h
//  JavaEye
//
//  Created by ieliwb on 10-6-6.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MBProgressHUD.h"

@interface BrowserController : UIViewController <UIWebViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate,UIPopoverControllerDelegate>{
	UIWebView *webView;
	NSString  *url;
	
	MBProgressHUD *HUD;	
}

@property (nonatomic, retain) NSString *url;

- (id)initWithUrl:(NSString *)theUrl;

@end