//
//  LogonController.h
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsController;
@class ChatController;
@class MessagesController;
@class LinksController;
@class MoreController;

@interface LogonController : UIViewController<UITextFieldDelegate> {
	UITabBarController *javaEyeTabBarController;
}
@property (nonatomic, retain) UITabBarController *javaEyeTabBarController;

@end
