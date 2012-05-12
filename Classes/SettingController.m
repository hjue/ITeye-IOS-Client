//
//  SettingController.m
//  JavaEye
//
//  Created by ieliwb on 10-6-10.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "SettingController.h"
#import "Common.h"

@implementation SettingController
@synthesize resultArray,table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.title = NSLocalizedString(@"system_setting",nil);
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = CGSizeMake(320.0, 380.0);
		} else {
			
		}
		
    }
    return self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
- (void)dealloc {
	[resultArray release];	
	[table release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithObjects:
								 [NSArray arrayWithObjects:
								  [NSArray arrayWithObjects:NSLocalizedString(@"auto_login",nil),@"",nil],
								  nil
								  ],
								 nil
								 ];
	self.resultArray = tempArray;
	[tempArray release];
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,0.0f,320.0f,380.0f) style: UITableViewStyleGrouped];
	table.backgroundColor = [UIColor clearColor];
	table.scrollEnabled = NO;
	table.tag = TABLE_VIEW_TAG;
	[table setDelegate:self];
	[table setDataSource:self];
	[self.view addSubview:table];
	
}


#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [resultArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[resultArray objectAtIndex:section] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.accessoryType = UITableViewCellAccessoryNone; 
    }
		
	UILabel *keyLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 100.0, 25.0)];
	keyLable.textAlignment = UITextAlignmentLeft;
	keyLable.backgroundColor = [UIColor clearColor];
	keyLable.font = [UIFont fontWithName:@"Courier" size:15.0];
	keyLable.text = [[[self.resultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:0];
	[cell.contentView addSubview:keyLable];
	[keyLable release];
	
	UISwitch* autologinSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(150.0, 5, 80.0, 45.0)];
	[autologinSwitch addTarget:self action:@selector(switchValueDidChange:) forControlEvents:UIControlEventValueChanged];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"auto_login"]) {
		[autologinSwitch setOn:YES animated:YES];
	}
	[cell.contentView addSubview: autologinSwitch];
	[autologinSwitch release];
	
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger index = indexPath.section * 10 + indexPath.row;
	switch (index) {
			
		case 0:
			
			break;

	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Target/Action method
- (void)switchValueDidChange:(UISwitch *)sender {
    if(sender.on){
        [sender setOn:YES animated:YES];
		[[NSUserDefaults standardUserDefaults] setObject:@"ON" forKey:@"auto_login"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"auto_login"];
		[NSUserDefaults resetStandardUserDefaults];
	}

}


@end