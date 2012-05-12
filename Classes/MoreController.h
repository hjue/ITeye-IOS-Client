//
//  MoreController.h
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface MoreController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,UIPopoverControllerDelegate> {
	UITableView *table;
	NSMutableArray *resultArray;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSMutableArray *resultArray;

- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle ;

@end
