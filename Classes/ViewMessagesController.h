//
//  ViewMessagesController.h
//  JavaEye
//
//  Created by ieliwb on 10-6-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ViewMessagesController : UIViewController<UIWebViewDelegate,MBProgressHUDDelegate,UIPopoverControllerDelegate> {
	NSDictionary *detailDictionary;
	UIWebView *webView;
	MBProgressHUD *HUD;	
}

@property (nonatomic, retain) NSDictionary *detailDictionary;

- (id)initWithDictionary:(NSDictionary *)dict;

@end