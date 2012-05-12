//
//  AboutController.m
//  iTool
//
//  Created by ieliwb on 10-5-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "AboutController.h"
#import "Common.h"

@implementation AboutController
@synthesize resultArray,table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.navigationController.navigationBarHidden = NO;
		self.navigationItem.title=NSLocalizedString(@"about",nil);
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = CGSizeMake(320.0, 380.0);
		} else {
			
		}
		
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSArray *tempArray = [[NSArray alloc] initWithObjects:
						  [NSArray arrayWithObjects:
						   [NSArray arrayWithObjects:NSLocalizedString(@"about_name",nil),NSLocalizedString(@"JavaEye",nil),nil],
						   [NSArray arrayWithObjects:NSLocalizedString(@"about_version",nil),@"V1.0.0 Build 201006",nil],
						   nil],
						  nil];
	self.resultArray = tempArray;
	[tempArray release];
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,0.0f,320.0f,380.0f) style: UITableViewStyleGrouped];
	table.tag = TABLE_VIEW_TAG;
	[table setDelegate:self];
	[table setDataSource:self];
	[self.view addSubview:table];
		
}

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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];
		
		CGRect keyRect = CGRectMake(20,10, 200, 20);
		UILabel *keyLable = [[UILabel alloc] initWithFrame:keyRect];
		keyLable.textAlignment = UITextAlignmentLeft;
		keyLable.tag = KEY_LABEL_TAG;
		keyLable.backgroundColor = [UIColor clearColor];
		keyLable.font = [UIFont fontWithName:@"Courier" size:11.0];
		[cell.textLabel setNumberOfLines:0];
		[cell.contentView addSubview:keyLable];
		[keyLable release];
		
		CGRect valueRect = CGRectMake(110,10, 160, 20);
		UILabel *valueLable = [[UILabel alloc] initWithFrame:valueRect];
		valueLable.textAlignment = UITextAlignmentRight;
		valueLable.backgroundColor = [UIColor clearColor];
		valueLable.tag = VALUE_LABEL_TAG;
		valueLable.font = [UIFont boldSystemFontOfSize:11];
		[cell.textLabel setNumberOfLines:0];
		[cell.contentView addSubview:valueLable];
		[valueLable release];
		
	}
	
	if (indexPath.section != 0) {
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; 
	}
	
	UILabel *key = (UILabel *)[cell.contentView viewWithTag:KEY_LABEL_TAG];
	key.text = [[[resultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:0];
	
	UILabel *value = (UILabel *)[cell.contentView viewWithTag:VALUE_LABEL_TAG];
	value.text = [[[resultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:1];
	
    return cell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
	return 40;	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.section == 1) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://ieliwb@gmail.com"]];
	}
	else if (indexPath.section == 2) {
		switch (indexPath.row){
			case 0:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ieliwb.com/index.php"]];
				break;
			case 1:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/ieliwb/"]];
				break;
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[resultArray release];
	[table release];
    [super dealloc];
}

@end
