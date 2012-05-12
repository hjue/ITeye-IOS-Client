//
//  EditLinksController.h
//  JavaEye
//
//  Created by ieliwb on 10-6-2.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditLinksController : UIViewController<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UIActionSheetDelegate> {
	UITableView *table;
	NSMutableDictionary *links;
	NSArray *fieldLabels;
	int    editMode;
	
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSMutableDictionary *links;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, assign) int editMode;

- (id)initWithLinks:(NSMutableDictionary *)theLinks editMode:(int) mode;
- (void)cancel:(id)sender;
- (void)save:(id)sender;

- (NSString*)getTextByRow:(NSNumber *)row;

@end