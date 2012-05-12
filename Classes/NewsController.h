//
//  NewsController.h
//  JavaEye
//
//  Created by ieliwb on 10-6-4.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class NewsListController;

@interface NewsController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MBProgressHUDDelegate> {
	UITableView *table;
	NSMutableArray *resultArray;
	
	NewsListController *newsListController;
	
	MBProgressHUD *HUD;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSMutableArray *resultArray;
@property (nonatomic, retain) NewsListController *newsListController;

- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle ;

@end
