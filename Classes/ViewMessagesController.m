//
//  ViewMessagesController.m
//  JavaEye
//
//  Created by ieliwb on 10-6-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "ViewMessagesController.h"
#import "UtilString.h"
#import "NewMessagesController.h"

#import "JavaEyeApiClient.h"
#import "MessagesDAO.h"

@implementation ViewMessagesController
@synthesize detailDictionary;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
	[detailDictionary release];
    [super dealloc];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	
	if (self = [super init]) {
		self.title = NSLocalizedString(@"msg_view_title",nil);
		self.detailDictionary = dict;
		
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"back",nil)
									   style:UIBarButtonItemStyleBordered
									   target:self
									   action:@selector(backAction:)];
		self.navigationItem.leftBarButtonItem = backButton;
		[backButton release];
		
		UIBarButtonItem *backIndexItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_index.png"]
																		  style:UIBarButtonSystemItemFlexibleSpace
																		 target:self
																		 action:@selector(backIndexAction:)];
		self.navigationItem.rightBarButtonItem = backIndexItem;
		[backIndexItem release];
		
		self.hidesBottomBarWhenPushed=YES;//隐藏UITabBar
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIToolbar *toolbar = [UIToolbar new];
	toolbar.barStyle = self.navigationController.navigationBar.barStyle;
	[toolbar sizeToFit];
	CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	
	
	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																			   target:self
																			   action:@selector(refreshAction:)];
	
	UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
																				 target:self
																				 action:@selector(deleteAction:)];

	UIBarButtonItem *replyItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
																				target:self
																				action:@selector(replyAction:)];
	
	UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				target:self
																				action:@selector(forwardAction:)];
	
	UIBarButtonItem *addNewItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																				target:self
																				action:@selector(addNewAction:)];
	
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	NSArray *items = [NSArray arrayWithObjects: refreshItem, spaceItem, replyItem, spaceItem,addNewItem , spaceItem, forwardItem, spaceItem, deleteItem, nil];
	[toolbar setItems:items animated:YES];
	[self.view addSubview:toolbar];
	[refreshItem release];
	[deleteItem release];
	[replyItem release];
	[forwardItem release];
	[addNewItem release];
	[spaceItem release];
	[toolbar release];
		
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 35)];
	CGSize fitSize = CGSizeMake(self.view.frame.size.width, 400);
	CGRect titleRect = titleLabel.frame;
	fitSize = [[detailDictionary valueForKey:@"title"] sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:fitSize lineBreakMode:UILineBreakModeWordWrap];
	titleRect.size.height = fitSize.height;
	
	[titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
	[titleLabel setTextColor:[UIColor blueColor]];
	[titleLabel setText:[detailDictionary valueForKey:@"title"]];
	[titleLabel setNumberOfLines:5];
	[titleLabel setTextAlignment:UITextAlignmentCenter];
	[titleLabel setFrame:titleRect];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:titleLabel];
	[titleLabel release];

	
	UILabel *statusLable = [[UILabel alloc] initWithFrame:CGRectMake(4,titleLabel.frame.size.height + 20,self.view.frame.size.width, 20)];
	statusLable.textAlignment = UITextAlignmentCenter;
	statusLable.textColor = [UIColor darkGrayColor];
	statusLable.text = [NSString stringWithFormat:NSLocalizedString(@"msg_status",nil),[detailDictionary objectForKey:@"sender_name"],[detailDictionary objectForKey:@"created_at"]];
	statusLable.font = [UIFont boldSystemFontOfSize:12];
	[statusLable setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:statusLable];
	[statusLable release];
	
	/*
	NewsDAO *newsDao = [[NewsDAO alloc] init];
	NSMutableString *body = [newsDao getOne:[[detailDictionary objectForKey:@"news_id"] intValue]];
	[newsDao release];
	 */

	webView = [[UIWebView alloc] initWithFrame:CGRectMake(4, titleLabel.frame.size.height + 60, self.view.frame.size.width, self.view.frame.size.height - (titleLabel.frame.size.height + 130))];
	
	[webView setUserInteractionEnabled:YES];
	[webView setBackgroundColor:[UIColor clearColor]];
	[webView setDelegate:self];
	[webView setOpaque:NO];
	[webView loadHTMLString:[NSString stringWithFormat:
							 @"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"> \
							 <html xmlns=\"http://www.w3.org/1999/xhtml\"> \
							 <head>\
							 <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\
							 <meta id=\"viewport\" name=\"viewport\" content=\"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\" />\
							 <font face=\"Helvetica\">%@</font>\
							 <br/><br/>\
							 </body> \
							 </html> \
							 ",
							 [[detailDictionary objectForKey:@"plain_body"] htmlSimpleUnescapeString]]
					baseURL:[NSURL URLWithString:@"file:///"]];
	[self.view addSubview:webView];
	[webView release];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = NSLocalizedString(@"loading",nil);
	[HUD show:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[HUD hide:YES];
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden {
    [HUD removeFromSuperview];
    [HUD release];
}

#pragma mark -
#pragma mark buttonAction methods
- (void)backAction:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)backIndexAction:(id)sender{
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

- (void)refreshAction:(id)sender {
	//[webView reload];
}

- (void)deleteAction:(id)sender {
	
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	BOOL result = [javaEyeClient deleteMessage:[[detailDictionary objectForKey:@"id"] intValue]];
	[javaEyeClient release];
	
	if (result) {
		MessagesDAO *messagesDao = [[MessagesDAO alloc] init];
		[messagesDao delete:[[detailDictionary objectForKey:@"id"] intValue]];	
		[messagesDao release];
		
		[self.parentViewController viewDidAppear:YES];
		[[self navigationController] popViewControllerAnimated:YES];

	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_delete_error",nil) message:NSLocalizedString(@"web_connect_error",nil)
													   delegate:self cancelButtonTitle:NSLocalizedString(@"ok",nil) otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
	
}

- (void)replyAction:(id)sender {
	NewMessagesController *newMessagesController = [[NewMessagesController alloc] 
													initWithMsg:[NSMutableDictionary dictionaryWithObjectsAndKeys:
																 [NSString stringWithFormat:@"Re: %@", [detailDictionary objectForKey:@"title"]],
																 @"title",
																 [detailDictionary objectForKey:@"sender_name"],
																 @"receiver_name",
																 nil
																 ] 
													sendMode:1];
	
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{		
		UINavigationController *newMsg_navigationController = [[UINavigationController alloc] initWithRootViewController:newMessagesController];
		
		Class popoverClass = NSClassFromString(@"UIPopoverController");
		if (popoverClass) {
			UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:newMsg_navigationController];
			popover.delegate = self;
			[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		[newMsg_navigationController release];
	}
	else
	{
		[self.navigationController pushViewController:newMessagesController animated:YES];
	}
	
	[newMessagesController release];
}

- (void)forwardAction:(id)sender {
	NewMessagesController *newMessagesController = [[NewMessagesController alloc] 
													initWithMsg:[NSMutableDictionary dictionaryWithObjectsAndKeys:
																 [NSString stringWithFormat:@"Fwd: %@", [detailDictionary objectForKey:@"title"]],
																 @"title",
																 [NSString stringWithFormat:@"\n\n\n---------- Forwarded message ----------  \nFrom: %@\nSubject: %@\n%@\n", [detailDictionary objectForKey:@"sender_name"],[detailDictionary objectForKey:@"title"],[detailDictionary objectForKey:@"plain_body"]],
																 @"body",
																 nil
																 ] 
													sendMode:2];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{		
		UINavigationController *newMsg_navigationController = [[UINavigationController alloc] initWithRootViewController:newMessagesController];
		
		Class popoverClass = NSClassFromString(@"UIPopoverController");
		if (popoverClass) {
			UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:newMsg_navigationController];
			popover.delegate = self;
			[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		[newMsg_navigationController release];
	}
	else
	{
		[self.navigationController pushViewController:newMessagesController animated:YES];
	}
		
	[newMessagesController release];
}

- (void)addNewAction:(id)sender {
	NewMessagesController *newMessagesController = [[NewMessagesController alloc] initWithMsg:nil sendMode:0];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		
		UINavigationController *msg_navigationController = [[UINavigationController alloc] initWithRootViewController:newMessagesController];
		
		Class popoverClass = NSClassFromString(@"UIPopoverController");
		if (popoverClass) {
			UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:msg_navigationController];
			popover.delegate = self;
			[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		[msg_navigationController release];
	}
	else
	{
		[self.navigationController pushViewController:newMessagesController animated:YES];
	}

	[newMessagesController release];
}



#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[popoverController release];
}



@end