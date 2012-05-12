//
//  AboutController.h
//  iTool
//
//  Created by ieliwb on 10-5-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	UITableView *table;
	NSArray *resultArray;
}

@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSArray *resultArray;

@end
