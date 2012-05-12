//
//  SettingController.h
//  JavaEye
//
//  Created by ieliwb on 10-6-10.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	UITableView *table;
	NSMutableArray *resultArray;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSMutableArray *resultArray;

@end
