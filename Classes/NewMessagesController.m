//
//  NewMessagesController.m
//  JavaEye
//
//  Created by ieliwb on 10-6-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "NewMessagesController.h"

#import "Common.h"
#import "MessagesDAO.h"

#import "JavaEyeApiClient.h"

@implementation NewMessagesController

@synthesize msg;
@synthesize	sendMode;
@synthesize fieldLabels;
@synthesize table;

- (id)initWithMsg:(NSMutableDictionary *)theMsg sendMode:(int) theMode
{
	if(self=[super init])
	{
	    self.msg = theMsg;	
		self.sendMode = theMode;
		
		switch (theMode) {
			case 1:
				self.title = NSLocalizedString(@"msg_reply",nil);
				break;
			case 2:
				self.title = NSLocalizedString(@"msg_forward",nil);
				break;
			default:
				self.title = NSLocalizedString(@"msg_new",nil);
				break;
		}
		
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
									   initWithTitle:NSLocalizedString(@"send",nil)
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
	
	NSArray *fields=[[NSArray alloc] initWithObjects:NSLocalizedString(@"msg_receiver",nil),NSLocalizedString(@"msg_subject",nil),NSLocalizedString(@"msg_body",nil),nil];
	self.fieldLabels = fields;
	[fields release];
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 440) style: UITableViewStylePlain];
	table.backgroundColor = [UIColor whiteColor];
	table.tag = TABLE_VIEW_TAG;
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
	[msg release];
	[fieldLabels release];
    [super dealloc];
}

#pragma mark -
#pragma mark set field methods
- (NSString*)getTextByRow:(NSNumber *)row
{
	if (self.msg == nil) {
		return @"";
	}
	
	switch ([row integerValue])
	{
		case 0:
			return [self.msg objectForKey:@"receiver_name"];
			break;
		case 1:
			return [self.msg objectForKey:@"title"];
			break;
		case 2:
			return [self.msg objectForKey:@"body"];
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
	UITextField *rField = (UITextField *)([self.view viewWithTag:1]);
	UITextField *tField = (UITextField *)([self.view viewWithTag:2]);
	UITextView *bField = (UITextView *)([self.view viewWithTag:3]);

	if([rField.text isEqualToString:@""] && [tField.text isEqualToString:@""] && [bField.text isEqualToString:@""])
	{	
		[[self navigationController] popViewControllerAnimated:YES];	
	}
	else 
	{
		UIActionSheet *actionSheet = [[UIActionSheet alloc] 
									  initWithTitle:NSLocalizedString(@"msg_exit_confirm",nil)
									  delegate:self 
									  cancelButtonTitle:nil 
									  destructiveButtonTitle:nil
									  otherButtonTitles:NSLocalizedString(@"msg_edit_continue",nil),NSLocalizedString(@"msg_save",nil),NSLocalizedString(@"msg_exit_ok",nil),nil
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
	UITextField *rField = (UITextField *)([self.view viewWithTag:1]);
	UITextField *tField = (UITextField *)([self.view viewWithTag:2]);
	UITextView *bField = (UITextView *)([self.view viewWithTag:3]);
	
	if([rField.text isEqualToString:@""] || [tField.text isEqualToString:@""] || [bField.text isEqualToString:@""])
	{	
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_save_error_title",nil)
														message:NSLocalizedString(@"msg_save_error_msg",nil)
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"ok",nil)
											  otherButtonTitles:nil];
		[alert show];
		[alert release];		
		return;
	}
	
	NSMutableDictionary *tempMsg = [[NSMutableDictionary alloc] initWithCapacity:5];
	
	[tempMsg setObject:rField.text forKey:@"receiver_name"];
    [tempMsg setObject:tField.text forKey:@"title"];
	[tempMsg setObject:bField.text forKey:@"body"];

		
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	[javaEyeClient createMessage:tempMsg];
	[javaEyeClient release];
	
	[tempMsg release];
	
	rField.text = @"";
	tField.text = @"";
	bField.text = @"";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
													message:@"Message send success!"
												   delegate:nil 
										  cancelButtonTitle:NSLocalizedString(@"ok",nil)
										  otherButtonTitles:nil];
	[alert show];
	[alert release];	
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//[self.parentViewController dismissPopoverAnimated:YES];
		
	} else {
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
	
	
	if (row < 2) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 85, 25)];
		label.textAlignment = UITextAlignmentLeft;
		label.tag = KEY_LABEL_TAG;
		label.textColor = [UIColor blackColor];
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
		
	}else {
		UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 240)];
		textView.textColor = [UIColor blackColor];
		textView.font = [UIFont systemFontOfSize:15.0];
		textView.backgroundColor = [UIColor whiteColor];
		textView.alpha = 1.0;
		textView.clipsToBounds = YES;
		textView.tag = row+1;
		textView.text = [self getTextByRow:[NSNumber numberWithInt:row]];
		textView.textAlignment = UITextAlignmentLeft;
		textView.editable = YES;	
		textView.scrollEnabled = YES;
		[textView becomeFirstResponder];
		[cell.contentView addSubview: textView];
		[textView release];
		
		[textView becomeFirstResponder];
	}
	
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end