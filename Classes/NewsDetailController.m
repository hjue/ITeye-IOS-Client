//
//  NewsDetailController.m
//  JavaEye
//
//  Created by ieliwb on 10-6-4.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "NewsDetailController.h"

#import "BrowserController.h"
#import "AddChatController.h"
#import "EditLinksController.h"

#import "NewsDAO.h"
#import "UtilString.h"

@implementation NewsDetailController

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
		self.title = NSLocalizedString(@"news_detail",nil);
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
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	UIWebView *webViewTag = (UIWebView *)[self.view viewWithTag:WEB_VIEW_TAG];
	webViewTag.frame = CGRectMake(4, 45, self.view.frame.size.width, self.view.frame.size.height - 150.0f);

	UIToolbar *toolbarViewTag = (UIToolbar *)[self.view viewWithTag:TOOLBAR_VIEW_TAG];
	toolbarViewTag.barStyle = self.navigationController.navigationBar.barStyle;
	[toolbarViewTag sizeToFit];
	CGFloat toolbarHeight = [toolbarViewTag frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[toolbarViewTag setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	
}
*/
- (void)viewDidLoad {
    [super viewDidLoad];

	UIToolbar *toolbar = [UIToolbar new];
	toolbar.tag = TOOLBAR_VIEW_TAG;
	toolbar.barStyle = self.navigationController.navigationBar.barStyle;
	[toolbar sizeToFit];
	CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	
	
	UIBarButtonItemStyle style = UIBarButtonSystemItemFlexibleSpace;
	
	UIBarButtonItem *webkitItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_webkit.png"]
																 style:style
																target:self
																action:@selector(openWebKit:)];
	
	UIBarButtonItem *tochatItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_tochat.png"]
																 style:style
																target:self
																action:@selector(addToChat:)];
	
	UIBarButtonItem *bookmarkItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_bookmark.png"]
																 style:style
																target:self
																action:@selector(addBookMark:)];
	
	
	UIBarButtonItem *emailItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_email.png"]
																 style:style
																target:self
																action:@selector(sendToFriend:)];
	
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:nil action:nil];
	
	NSArray *items = [NSArray arrayWithObjects: spaceItem, webkitItem, spaceItem, tochatItem, spaceItem, bookmarkItem, spaceItem, emailItem, spaceItem,spaceItem, nil];
	[toolbar setItems:items animated:YES];
	[self.view addSubview:toolbar];
	[webkitItem release];
	[tochatItem release];
	[bookmarkItem release];
	[emailItem release];
	[spaceItem release];
	[toolbar release];
	
	
	NewsDAO *newsDao = [[NewsDAO alloc] init];
	NSMutableString *body = [newsDao getOne:[[detailDictionary objectForKey:@"news_id"] intValue]];
	[newsDao release];
	
	webView = [[UIWebView alloc] initWithFrame:CGRectMake(4, 0, self.view.frame.size.width, self.view.frame.size.height - 85)];
	webView.tag = WEB_VIEW_TAG;
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
							 <style>img{max-width:300px}</style>\
							 </head><body>\
							 <h1 style='margin:10px 0;padding-bottom:10px;font-size:20px;color:#069;font-family: Arial, sans-serif, Helvetica, Tahoma;border-bottom:1px gray solid'>%@</h1>\
							 <font face=\"Helvetica\" style='word-wrap:break-word;'>%@</font>\
							 </body> \
							 </html> \
							 ",
							 [detailDictionary valueForKey:@"title"],
							 [body htmlSimpleUnescapeString]]
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
- (void)webViewDidFinishLoad:(UIWebView *)awebView{
	[HUD hide:YES];
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	[awebView stringByEvaluatingJavaScriptFromString:@"{\
     var a = document.getElementsByTagName('a'); \
     for (var i=0; i<a.length; i++){ \
     a[i].href = '#';\
	 a[i].onclick = 'alert(\"Please click the eye to open this link in webkit.\");';\
     }}"];
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
- (void)openWebKit:(id)sender {
	BrowserController *browserController = [[BrowserController alloc] initWithUrl:[detailDictionary objectForKey:@"link"]];
	[self.navigationController pushViewController:browserController animated:YES];	
	[browserController release];
}

- (void)addToChat:(id)sender {
	
	if (![[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"]) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"not login , no chat" 
														message:nil
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"ok",nil) 
											  otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
		return ;
	}
	
	AddChatController *addChatController = [[AddChatController alloc] initWithChatBody:[NSString stringWithFormat:NSLocalizedString(@"news_push_chat_tpl",nil),[detailDictionary objectForKey:@"title"],[detailDictionary objectForKey:@"link"]]];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{		
		UINavigationController *chat_navigationController = [[UINavigationController alloc] initWithRootViewController:addChatController];
		
		Class popoverClass = NSClassFromString(@"UIPopoverController");
		if (popoverClass) {
			UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:chat_navigationController];
			popover.delegate = self;
			[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		[chat_navigationController release];
	}
	else
	{
		[self.navigationController pushViewController:addChatController animated:YES];
	}
	
	[addChatController release];	
}

- (void)addBookMark:(id)sender {
	
	if (![[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"]) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"not login , no bookmark" 
														message:nil
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"ok",nil) 
											  otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
		return ;
	}
	
	
	EditLinksController *editLinksController = [[EditLinksController alloc] initWithLinks:[NSMutableDictionary dictionaryWithObjectsAndKeys:[detailDictionary objectForKey:@"link"],@"url",[detailDictionary objectForKey:@"title"],@"title",nil] editMode:ADD];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{		
		UINavigationController *link_navigationController = [[UINavigationController alloc] initWithRootViewController:editLinksController];
		
		Class popoverClass = NSClassFromString(@"UIPopoverController");
		if (popoverClass) {
			UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:link_navigationController];
			popover.delegate = self;
			[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		[link_navigationController release];
	}
	else
	{
		[self.navigationController pushViewController:editLinksController animated:YES];
	}
	
	[editLinksController release];
}

- (void)sendToFriend:(id)sender {
	MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
	mail.mailComposeDelegate = self;
	if ([MFMailComposeViewController canSendMail]) {
		
		[mail setToRecipients:[NSArray arrayWithObjects:@"",nil]];
		[mail setSubject:NSLocalizedString(@"news_send_email_title_tpl",nil)];
		[mail setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"news_send_email_body_tpl",nil),[detailDictionary objectForKey:@"title"],[detailDictionary objectForKey:@"link"]] isHTML:NO];
		
		[self presentModalViewController:mail animated:YES];
	}
	[mail release];
}



#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[popoverController release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if (result == MFMailComposeResultFailed) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed!" message:@"Your email has failed to send" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	[self dismissModalViewControllerAnimated:YES];
}


@end
