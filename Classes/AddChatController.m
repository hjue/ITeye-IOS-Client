//
//  AddChatController.m
//  JavaEye
//
//  Created by ieliwb on 10-6-6.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "AddChatController.h"
#import <QuartzCore/QuartzCore.h>

#import "Common.h"

#import "JavaEyeApiClient.h"

@implementation AddChatController
@synthesize chatBody,locmanager;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
	[chatBody release];
	[self.locmanager release];
    [super dealloc];
}

- (id)initWithChatBody:(NSString *)theChatBody{
	if (self = [super init]) {
		self.title = NSLocalizedString(@"chat_new",nil);
		self.chatBody = theChatBody;
		
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = CGSizeMake(320.0, 200.0);
		} else {
			UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
										   initWithTitle:NSLocalizedString(@"back",nil)
										   style:UIBarButtonItemStyleBordered
										   target:self
										   action:@selector(backAction:)];
			self.navigationItem.leftBarButtonItem = backButton;
			[backButton release];
		}
				
		UIBarButtonItem *sendButton = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"send",nil)
									   style:UIBarButtonItemStyleBordered
									   target:self
									   action:@selector(sendAction:)];
		self.navigationItem.rightBarButtonItem = sendButton;
		[sendButton release];
		
		self.hidesBottomBarWhenPushed=YES;//隐藏UITabBar
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 140)];
	textView.textColor = [UIColor blueColor];
	textView.font = [UIFont systemFontOfSize:15.0];
	textView.backgroundColor = [UIColor whiteColor];
	textView.opaque = YES;
	textView.alpha = 1.0;
	textView.delegate = self;
	textView.tag = VALUE_LABEL_TAG;
	textView.layer.cornerRadius = 8;
	textView.clipsToBounds = YES;
	textView.text = self.chatBody;
	textView.textAlignment = UITextAlignmentLeft;
	textView.editable = YES;	
	textView.scrollEnabled = YES;
	[textView becomeFirstResponder];
	[self.view addSubview: textView];
	[textView release];
	
	
	//Creat ToolBar
	UIToolbar *toolbar = [UIToolbar new];
	toolbar.barStyle = UIBarStyleBlackOpaque;
	[toolbar sizeToFit];
	CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 158.0f,
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	
	UIBarButtonItemStyle style = UIBarButtonSystemItemFlexibleSpace;
	UIBarButtonItem *locationItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"chat_location",nil)
																style:style
															   target:self
															   action:@selector(addLocationAction:)];
	
	UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"chat_empty",nil)
																	 style:style
																	target:self
																	action:@selector(clearAction:)];
	
	
	
	NSArray *items = [NSArray arrayWithObjects: locationItem,clearItem, nil];
	[toolbar setItems:items animated:NO];
	[self.view addSubview:toolbar];
	[locationItem release];
	[clearItem release];
	
	
	UITextView *textview = (UITextView *)[self.view viewWithTag:VALUE_LABEL_TAG];
	
	UILabel *sizeLabel = [[UILabel alloc] init];
	sizeLabel.frame = CGRectMake(150, 10, 150, 25);
	sizeLabel.textAlignment = UITextAlignmentRight;
	sizeLabel.text = [NSString stringWithFormat:@"%d",(140 - [textview.text length])];
	sizeLabel.tag = STATUS_LABEL_TAG;
	sizeLabel.textColor = [UIColor whiteColor];
	sizeLabel.font = [UIFont boldSystemFontOfSize:14];
	sizeLabel.backgroundColor = [UIColor clearColor];
	[toolbar addSubview:sizeLabel];
	[sizeLabel release];
	
	[toolbar release];
}

- (void)textViewDidChange:(UITextView *)textView{
	UITextView *textview = (UITextView *)[self.view viewWithTag:VALUE_LABEL_TAG];
	UILabel *sizelabel = (UILabel *)[self.view viewWithTag:STATUS_LABEL_TAG];
	sizelabel.text = [NSString stringWithFormat:@"%d",(140 - [textview.text length])];
}


#pragma mark -
#pragma mark navigationController Item button methods
- (void)backAction:(id)sender
{
	UITextView *textview = (UITextView *)[self.view viewWithTag:VALUE_LABEL_TAG];
	if ([textview.text length] > 0 && ![self.chatBody isEqualToString:textview.text]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] 
									  initWithTitle:NSLocalizedString(@"chat_exit_confirm",nil)
									  delegate:self 
									  cancelButtonTitle:nil 
									  destructiveButtonTitle:nil
									  otherButtonTitles:NSLocalizedString(@"chat_edit_continue",nil),NSLocalizedString(@"chat_save",nil),NSLocalizedString(@"chat_exit_ok",nil),nil
									  ];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		actionSheet.destructiveButtonIndex = 1;
		[actionSheet showInView:self.view];
		[actionSheet release];
	}else {
		[[self navigationController] popViewControllerAnimated:YES];
	}
	
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

	if (buttonIndex == 0) {
		//do nothing
	}else if (buttonIndex == 1) {
		[self sendAction:nil];
	}else {
		[[self navigationController] popViewControllerAnimated:YES];
	}
	
}

- (void)sendAction:(id)sender
{
	
	UITextView *textview = (UITextView *)[self.view viewWithTag:VALUE_LABEL_TAG];
	NSInteger size = [textview.text length];
	if (size < 1) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chat_save_error_title",nil) message:NSLocalizedString(@"chat_save_error_empty_msg",nil)
													   delegate:self cancelButtonTitle:NSLocalizedString(@"ok",nil) otherButtonTitles: nil];
		[alert show];	
		[alert release];
		return ;
	}
	if (size > 140) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chat_save_error_title",nil) message:NSLocalizedString(@"chat_save_error_full_msg",nil)
													   delegate:self cancelButtonTitle:NSLocalizedString(@"ok",nil) otherButtonTitles: nil];
		[alert show];	
		[alert release];
		return ;
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	[javaEyeClient createTwitter:[NSDictionary dictionaryWithObject:textview.text forKey:@"body"]];
	[javaEyeClient release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		UILabel *sizelabel = (UILabel *)[self.view viewWithTag:STATUS_LABEL_TAG];
		sizelabel.text = @"Send Success!";

		[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChat" object:self];		
	} else {
		textview.text = @"";

		[self.parentViewController viewDidAppear:YES];
		[[self navigationController] popViewControllerAnimated:YES];

	}

}

-(void)clearAction:(id)sender
{
	UITextView *textview = (UITextView *)[self.view viewWithTag:VALUE_LABEL_TAG];
	textview.text = @"";	
}

-(void)addLocationAction:(id)sender
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	self.locmanager = [[CLLocationManager alloc] init]; 
	[self.locmanager setDelegate:self]; 
	[self.locmanager setDesiredAccuracy:kCLLocationAccuracyBest];	
	[self.locmanager startUpdatingLocation];
		
	UILabel *sizelabel = (UILabel *)[self.view viewWithTag:STATUS_LABEL_TAG];
	sizelabel.text = NSLocalizedString(@"chat_search_location",nil);
}

-(void)setReplyChatBody:(NSString *)cc
{
	self.chatBody = cc;
	UITextView *textview = (UITextView *)[self.view viewWithTag:VALUE_LABEL_TAG];
	textview.text = cc;
}

#pragma mark -
#pragma mark locationManager methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{ 
	CLLocationCoordinate2D loc = [newLocation coordinate];

	UITextView *textview = (UITextView *)[self.view viewWithTag:VALUE_LABEL_TAG];
	textview.text = [NSString stringWithFormat:NSLocalizedString(@"chat_location_tpl",nil), textview.text,loc.latitude, loc.longitude];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	

}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{ 
	UILabel *sizelabel = (UILabel *)[self.view viewWithTag:STATUS_LABEL_TAG];
	sizelabel.text = NSLocalizedString(@"chat_search_location_error",nil);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}


@end
