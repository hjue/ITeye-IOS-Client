//
//  ChatController.h
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddChatController;
@class EGORefreshTableHeaderView;

@interface ChatController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIPopoverControllerDelegate> {
	
	UITableView *table;	
	NSMutableArray *chatArray;

	AddChatController *addChatController;
	
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
	
	int _type;
	
	int _footerStatus;
}

@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSMutableArray *chatArray;
@property (nonatomic, retain) AddChatController *addChatController;

@property(assign,getter=isReloading) BOOL reloading;

@property (nonatomic, assign) int _type;
@property (nonatomic, assign) int _footerStatus;

- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle ;
-(void)segmentAction:(id) sender;
- (void) loadThread:(id)sender;
- (void) finshLoad;
-(void)addChat:(id) sender;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

@interface ChatController (Private)
- (void)dataSourceDidFinishLoadingNewData;
- (void) replyChat:(NSString *)reply;
@end