//
//  NewMessagesController.h
//  JavaEye
//
//  Created by ieliwb on 10-6-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewMessagesController : UIViewController<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UIActionSheetDelegate> {
	UITableView *table;
	NSMutableDictionary *msg;
	NSArray *fieldLabels;
	int    sendMode;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSMutableDictionary *msg;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, assign) int sendMode;

- (id)initWithMsg:(NSMutableDictionary *)theMsg sendMode:(int) theMode;

- (void)cancel:(id)sender;
- (void)save:(id)sender;

- (NSString*)getTextByRow:(NSNumber *)row;

@end