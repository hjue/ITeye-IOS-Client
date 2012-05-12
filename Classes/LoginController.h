//
//  LoginController.h
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@class LogonController;

@interface LoginController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate,MBProgressHUDDelegate> {
	LogonController *logonController;
	MBProgressHUD *HUD;
}
@property (retain, nonatomic) LogonController *logonController;

-(void)loginAction:(id)sender;

@end