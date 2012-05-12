//
//  LinksController.h
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditLinksController;
@class EGORefreshTableHeaderView;

@interface LinksController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIPopoverControllerDelegate> {
	UITableView *table;
	NSMutableArray *resultArray;
	
	EditLinksController *editLinksController;
	
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
	
	int _footerStatus;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSMutableArray *resultArray;

@property (nonatomic, retain) EditLinksController *editLinksController;

@property(assign,getter=isReloading) BOOL reloading;
@property (nonatomic, assign) int _footerStatus;

- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle ;
- (void)addLinks:(id)sender;

- (void) loadThread:(id)sender;
- (void) finshLoad;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

@interface LinksController (Private)
- (void)dataSourceDidFinishLoadingNewData;
@end