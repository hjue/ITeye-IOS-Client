//
//  NewsDetailController.h
//  JavaEye
//
//  Created by ieliwb on 10-6-4.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
	
@interface NewsDetailController : UIViewController<UIWebViewDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate,UIPopoverControllerDelegate> {
	UIWebView *webView;
	NSDictionary *detailDictionary;
	MBProgressHUD *HUD;	
}

@property (nonatomic, retain) NSDictionary *detailDictionary;

- (id)initWithDictionary:(NSDictionary *)dict;

@end