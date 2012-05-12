//
//  JavaEyeAppDelegate.h
//  JavaEye
//
//  Created by ieliwb on 10-5-27.
//  Copyright ieliwb.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginController;

@interface JavaEyeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	LoginController *loginController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) LoginController *loginController;

@end