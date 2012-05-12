//
//  MessagesController.h
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGORefreshTableHeaderView;
@class NewMessagesController;

@interface MessagesController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIPopoverControllerDelegate> {
	int selectedRow;
	UIImageView *tmpView;
	
	UITableView *table;
	NSMutableArray *resultArray;
	
	NewMessagesController *newMessagesController;
	
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
	
	int _footerStatus;
}

@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSMutableArray *resultArray;
@property (nonatomic, retain) NewMessagesController *newMessagesController;

@property(assign,getter=isReloading) BOOL reloading;
@property (nonatomic, assign) int _footerStatus;


- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle ;
- (void) loadThread:(id)sender;
- (void) finshLoad;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

@interface MessagesController (Private)
- (void)dataSourceDidFinishLoadingNewData;
@end