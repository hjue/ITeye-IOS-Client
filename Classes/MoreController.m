//
//  MoreController.m
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "MoreController.h"
#import "Common.h"
#import "UtilFile.h"
#import "AboutController.h"
#import "BrowserController.h"
#import "ManualController.h"
#import "LoginController.h"
#import "SFHFKeychainUtils.h"

@implementation MoreController
@synthesize resultArray,table;


- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle {
	
	if (self=[super init]) {
		
		self.title = title;
		self.navigationItem.title = navTitle;
		
		if(self.tabBarItem){
            self.tabBarItem.title = title;
            self.tabBarItem.image = [UIImage imageNamed:@"item_more.png"];
        }
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"logout",nil)
									   style:UIBarButtonItemStyleBordered
									   target:self
									   action:@selector(logout:)];
		self.navigationItem.rightBarButtonItem = editButton;
		[editButton release];
	}
	
	return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
	[resultArray release];	
	[table release];
	[super dealloc];
}

- (void)viewDidLoad {
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithObjects:
								 [NSArray arrayWithObjects:
								  [NSArray arrayWithObjects:NSLocalizedString(@"system_setting",nil),@"",nil],
								  nil
								  ],
								 [NSArray arrayWithObjects:
								  [NSArray arrayWithObjects:NSLocalizedString(@"soft_manual",nil),@"",nil],
								  //[NSArray arrayWithObjects:NSLocalizedString(@"soft_about",nil),@"",nil],
								  [NSArray arrayWithObjects:NSLocalizedString(@"soft_feedback",nil),@"",nil],
								  nil
								  ],
								 nil
								 ];
	self.resultArray = tempArray;
	[tempArray release];
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,self.view.frame.size.height-50) style: UITableViewStyleGrouped];
	table.backgroundColor = [UIColor clearColor];
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
	if (indexPath.section==0) {
		static NSString *logoutCellIdentifier = @"logoutCell";
		UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:logoutCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		UILabel *keyLable = [[UILabel alloc] initWithFrame:CGRectMake(10,10, 300, 20)];
		keyLable.textAlignment = UITextAlignmentLeft;
		keyLable.backgroundColor = [UIColor clearColor];
		keyLable.font = [UIFont boldSystemFontOfSize:12];
		keyLable.text = NSLocalizedString(@"auto_login",nil);
		[cell.contentView addSubview:keyLable];
		[keyLable release];
		
		UISwitch* autologinSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, 5, 80.0, 45.0)];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			autologinSwitch.frame = CGRectMake(570, 5, 80.0, 45.0);
		}
		[autologinSwitch addTarget:self action:@selector(switchValueDidChange:) forControlEvents:UIControlEventValueChanged];
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"auto_login"]) {
			[autologinSwitch setOn:YES animated:YES];
		}
		[cell.contentView addSubview: autologinSwitch];
		[autologinSwitch release];
		return cell;
	}else {
		static NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			
			UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10,10, 300, 20)];
			titleLable.textAlignment = UITextAlignmentLeft;
			titleLable.tag = KEY_LABEL_TAG;
			titleLable.font = [UIFont boldSystemFontOfSize:12];
			[titleLable setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:titleLable];
			[titleLable release];
			
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; 
			
		}
		
		UILabel *title = (UILabel *)[cell.contentView viewWithTag:KEY_LABEL_TAG];
		title.text = [[[self.resultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:0];
		return cell;
	}
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
		case 10:
		{
			ManualController *manualController = [[ManualController alloc] initWithNibName:nil bundle:nil];
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			{		
				UINavigationController *manual_navigationController = [[UINavigationController alloc] initWithRootViewController:manualController];
				
				Class popoverClass = NSClassFromString(@"UIPopoverController");
				if (popoverClass) {
					UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:manual_navigationController];
					popover.delegate = self;
					[popover presentPopoverFromRect:tableView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				}
				[manual_navigationController release];
			}
			else
			{
				[self.navigationController pushViewController:manualController animated:YES];
			}
			[manualController release];
		}
			break;
		case 111:
		{
			AboutController *aboutController = [[AboutController alloc] initWithNibName:nil bundle:nil];
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			{		
				UINavigationController *about_navigationController = [[UINavigationController alloc] initWithRootViewController:aboutController];
				
				Class popoverClass = NSClassFromString(@"UIPopoverController");
				if (popoverClass) {
					UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:about_navigationController];
					popover.delegate = self;
					[popover presentPopoverFromRect:tableView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				}
				[about_navigationController release];
			}
			else
			{
				[self.navigationController pushViewController:aboutController animated:YES];
			}			
			[aboutController release];
		}
			break;
		case 11:
		{
			MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
			mail.mailComposeDelegate = self;
			if ([MFMailComposeViewController canSendMail]) {
				
				[mail setToRecipients:[NSArray arrayWithObjects:@"webmaster@iteye.com",nil]];
				[mail setSubject:NSLocalizedString(@"feedback_title_tpl",nil)];
				[mail setMessageBody:@"" isHTML:NO];
				
				[self presentModalViewController:mail animated:YES];				
			}
			[mail release];
		}
			break;
		default:
			break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section 
{
	return 50;	
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	
    if(section == 2)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 50, 50, 44)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        label.textAlignment = UITextAlignmentCenter;
        label.lineBreakMode = UILineBreakModeWordWrap; 
		label.font = [UIFont boldSystemFontOfSize:10];
		label.numberOfLines = 0;
        label.text = @"Powered by iteye.com\nCopyright 2012. All rights reserved.";
        return [label autorelease];
    }
	
    return nil;
}

#pragma mark -
#pragma mark MessagesUI delegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if (result == MFMailComposeResultFailed) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed!" message:@"Your email has failed to send" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[popoverController release];
}

#pragma mark auto_login switch action method
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


- (void)logout: (id) sender{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"javaeye_username"]) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"javaeye_username"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"javaeye_userinfo"];
		[NSUserDefaults resetStandardUserDefaults];
		NSError *error;
		[SFHFKeychainUtils deleteItemForUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"javaeye_username"] andServiceName:@"javaeye" error:&error];
		//删除数据库
		[UtilFile deleteUserDB];
	}
	LoginController *loginController = [[LoginController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:loginController animated:YES];	
	[loginController release];
}


@end
