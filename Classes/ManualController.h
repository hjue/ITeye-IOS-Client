//
//  ManualController.h
//  iTool
//
//  Created by ieliwb on 10-5-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ManualController : UIViewController<UIWebViewDelegate,MBProgressHUDDelegate> {
	UIWebView *webView;
	MBProgressHUD *HUD;	
}

@end
