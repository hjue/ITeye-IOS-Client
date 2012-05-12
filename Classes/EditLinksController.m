//
//  EditLinksController.m
//  JavaEye
//
//  Created by ieliwb on 10-6-2.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "EditLinksController.h"

#import "Common.h"
#import "LinksDAO.h"

#import "JavaEyeApiClient.h"

@implementation EditLinksController

@synthesize links;
@synthesize	editMode;
@synthesize fieldLabels;
@synthesize table;

- (id)initWithLinks:(NSMutableDictionary *)theLinks editMode:(int) mode
{
	if(self=[super init])
	{
	    self.links = theLinks;	
		self.editMode = mode;
		self.title = (mode == ADD) ? NSLocalizedString(@"links_add",nil) : NSLocalizedString(@"links_edit",nil);
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = CGSizeMake(320.0, 400.0);
		} else {
			UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
										   initWithTitle:NSLocalizedString(@"cancel",nil)
										   style:UIBarButtonItemStyleBordered
										   target:self
										   action:@selector(cancel:)];
			self.navigationItem.leftBarButtonItem = backButton;
			[backButton release];
		}
				
		UIBarButtonItem *sendButton = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"save",nil)
									   style:UIBarButtonItemStyleBordered
									   target:self
									   action:@selector(save:)];
		self.navigationItem.rightBarButtonItem = sendButton;
		[sendButton release];
	
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSArray *fields=[[NSArray alloc] initWithObjects:NSLocalizedString(@"links_title",nil),NSLocalizedString(@"links_url",nil),NSLocalizedString(@"links_category",nil),NSLocalizedString(@"links_dec",nil),nil];
	self.fieldLabels = fields;
	[fields release];
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 440) style: UITableViewStylePlain];
	table.backgroundColor = [UIColor whiteColor];
	table.tag = TABLE_VIEW_TAG;
	table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	table.scrollEnabled = NO;
	[table setDelegate:self];
	[table setDataSource:self];
	[self.view addSubview:table];
	
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
	[table release];	
	[links release];
	[fieldLabels release];
    [super dealloc];
}

#pragma mark -
#pragma mark set field methods
- (NSString*)getTextByRow:(NSNumber *)row
{
	if (self.links == nil) {
		return @"";
	}
	
	switch ([row integerValue])
	{
		case 0:
			return [self.links objectForKey:@"title"];
			break;
		case 1:
			return [self.links objectForKey:@"url"];
			break;
		case 2:
			return [self.links objectForKey:@"description"];
			break;	
		case 3:
			return [self.links objectForKey:@"cached_tag_list"];
			break;	
		default:
			return @"";
			break;		
	}
	
	
}


#pragma mark -
#pragma mark navigationController Item button methods
- (void)cancel:(id)sender
{
	UITextField *tField = (UITextField *)([self.view viewWithTag:1]);
	UITextField *uField = (UITextField *)([self.view viewWithTag:2]);		
	if([tField.text isEqualToString:@""] && [uField.text isEqualToString:@""])
	{	
		[[self navigationController] popViewControllerAnimated:YES];	
	}
	else 
	{
		UIActionSheet *actionSheet = [[UIActionSheet alloc] 
									  initWithTitle:NSLocalizedString(@"links_exit_confirm",nil)
									  delegate:self 
									  cancelButtonTitle:nil 
									  destructiveButtonTitle:nil
									  otherButtonTitles:NSLocalizedString(@"links_edit_continue",nil),NSLocalizedString(@"links_save",nil),NSLocalizedString(@"links_exit_ok",nil),nil
									  ];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		actionSheet.destructiveButtonIndex = 1;
		[actionSheet showInView:self.view];
		[actionSheet release];		
	}
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		//do nothing
	}else if (buttonIndex == 1) {
		[self save:nil];
	}else {
		[[self navigationController] popViewControllerAnimated:YES];
	}

}

- (void)save:(id)sender
{		
	UITextField *tField = (UITextField *)([self.view viewWithTag:1]);
	UITextField *uField = (UITextField *)([self.view viewWithTag:2]);
	
	if([tField.text isEqualToString:@""] || [uField.text isEqualToString:@""])
	{	
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"links_save_error_title",nil)
														message:NSLocalizedString(@"links_save_error_msg",nil)
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"ok",nil)
											  otherButtonTitles:nil];
		[alert show];
		[alert release];		
		return;
	}

	NSMutableDictionary *tempLinks = [[NSMutableDictionary alloc] initWithCapacity:5];

	[tempLinks setObject:tField.text forKey:@"title"];
    [tempLinks setObject:uField.text forKey:@"url"];

	
	UITextField *dField = (UITextField *)([self.view viewWithTag:3]);
	if (dField.text != nil) {
		[tempLinks setObject:dField.text forKey:@"description"];
	}
	
	UITextField *cField = (UITextField *)([self.view viewWithTag:4]);
	if (cField.text != nil) {
		[tempLinks setObject:cField.text forKey:@"cached_tag_list"];
	}
	
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	[javaEyeClient createFavorite:tempLinks];
	[javaEyeClient release];
	
	[tempLinks release];
	
	tField.text = @"";
	uField.text = @"";
	dField.text = @"";
	cField.text = @"";
	
	/*
	LinksDAO *myLinks = [[LinksDAO alloc] init];
	if(self.editMode == UPDATE)
	{
		[myLinks update:links];
	}
	else
	{
		[myLinks add:links];
	}
	[myLinks release];
	 */
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//[self.parentViewController dismissPopoverAnimated:YES];
		
	} else {
		[self.parentViewController viewDidAppear:YES];
		[[self navigationController] popViewControllerAnimated:YES];
		
	}
}

#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [fieldLabels count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	NSUInteger row = [indexPath row];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
    }
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 85, 25)];
	label.textAlignment = UITextAlignmentLeft;
	label.tag = KEY_LABEL_TAG;
	label.textColor = [UIColor grayColor];
	label.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
	[cell.contentView addSubview:label];
	label.text = [fieldLabels objectAtIndex:row];
	[label release];
	
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(95, 12, 200, 25)];
	textField.clearsOnBeginEditing = NO;
	[textField setDelegate:self];
	textField.returnKeyType = UIReturnKeyDone;
	textField.clearButtonMode =UITextFieldViewModeWhileEditing;
	textField.tag = row+1;
	textField.text = [self getTextByRow:[NSNumber numberWithInt:row]];
	[cell.contentView addSubview:textField];
	[textField release];
	
	
	if (row == 0) {
		[textField becomeFirstResponder];
	}
	
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
