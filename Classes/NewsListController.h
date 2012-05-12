//
//  NewsListController.h
//  JavaEye
//
//  Created by ieliwb on 10-6-4.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGORefreshTableHeaderView;

@interface NewsListController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	NSString *url;
	
	UITableView *table;
	NSMutableArray *resultArray;
	
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
	
	int _category;
	
	int _footerStatus;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSMutableArray *resultArray;

@property(assign,getter=isReloading) BOOL reloading;

@property (nonatomic, assign) int _category;

@property (nonatomic, assign) int _footerStatus;

-(id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle withRssUrl:(NSString *)theUrl withCategory:(int)theCategory;
- (void)backAction:(id)sender;

- (void) loadThread:(id)sender;
- (void) finshLoad;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

@interface NewsListController (Private)
- (void)dataSourceDidFinishLoadingNewData;
@end