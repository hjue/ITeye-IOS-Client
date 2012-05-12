//
//  BrowserController.m
//  JavaEye
//
//  Created by ieliwb on 10-6-6.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "BrowserController.h"
#import "Common.h"
#import "AddChatController.h"
#import "EditLinksController.h"

@implementation BrowserController

@synthesize url;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
	[url release];
    [super dealloc];
}

- (id)initWithUrl:(NSString *)theUrl{
	if (self = [super init]) {
		self.title = theUrl;
		self.url = theUrl;
		
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

	webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-80.0f)];
	[webView setUserInteractionEnabled:YES];
	[webView setBackgroundColor:[UIColor clearColor]];
	[webView setDelegate:self];
	[webView setOpaque:NO];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
	[self.view addSubview:webView];
	[webView release];
	
	
	//Creat ToolBar
	
	UIToolbar *toolbar = [UIToolbar new];
	toolbar.barStyle = self.navigationController.navigationBar.barStyle;
	[toolbar sizeToFit];
	CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	
	
	UIBarButtonItemStyle style = UIBarButtonSystemItemFlexibleSpace;
	
	UIBarButtonItem *preItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"browser_pre",nil)
																style:style
																target:self
																action:@selector(preAction:)];
	
	UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"browser_reload",nil)
																   style:style
																  target:self
																  action:@selector(reloadAction:)];
	
	UIBarButtonItem *stopItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"browser_stop",nil)
																 style:style
																target:self
																action:@selector(stopAction:)];
	
	UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"browser_next",nil)
																 style:style
															    target:self
															    action:@selector(nextAction:)];
	
	UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_more.png"]
																style:style
															   target:self
															   action:@selector(moreAction:)];
	
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil];
	
	NSArray *items = [NSArray arrayWithObjects: preItem, reloadItem, stopItem, nextItem, spaceItem, moreItem, nil];
	[toolbar setItems:items animated:NO];

	
	/*
	UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[preBtn setFrame:CGRectMake(50, 15, 16, 16)];
	[preBtn setImage:[UIImage imageNamed:@"toolbar_pre.png"] forState:UIControlStateNormal];
	[preBtn addTarget:self action:@selector(preAction:) forControlEvents:UIControlEventTouchUpInside];
	[toolbar addSubview:preBtn];
	
	UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[nextBtn setFrame:CGRectMake(100, 15, 16, 16)];
	[nextBtn setImage:[UIImage imageNamed:@"toolbar_next.png"] forState:UIControlStateNormal];
	[nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
	[toolbar addSubview:nextBtn];
	
	UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[moreBtn setFrame:CGRectMake(150, 15, 16, 16)];
	[moreBtn setImage:[UIImage imageNamed:@"toolbar_bookmark.png"] forState:UIControlStateNormal];
	[moreBtn addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
	[toolbar addSubview:moreBtn];
	
	UIButton *email = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[email setFrame:CGRectMake(200, 15, 16, 16)];
	[email setImage:[UIImage imageNamed:@"toolbar_email.png"] forState:UIControlStateNormal];
	[email addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
	[toolbar addSubview:email];
	 */

	
	[self.view addSubview:toolbar];
	[preItem release];
	[reloadItem release];
	[stopItem release];
	[nextItem release];
	[spaceItem release];
	[moreItem release];
	[toolbar release];	
}

#pragma mark -
#pragma mark loadRequest
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	/*
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"Loading...";
	[HUD show:YES];
	 */
}
- (void)webViewDidFinishLoad:(UIWebView *)awebView {
	/*
	[HUD hide:YES];
	 */
	self.navigationItem.rightBarButtonItem.enabled = YES;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[awebView stringByEvaluatingJavaScriptFromString:@"{\
     var a = document.getElementsByTagName('a'); \
     for (var i=0; i<a.length; i++) \
     a[i].target = '_self';\
     }"];

}
#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [HUD removeFromSuperview];
    [HUD release];
}


#pragma mark -
#pragma mark TOOLBAR Methods
-(void)preAction:(id)sender{
	[webView goBack];
}
-(void)nextAction:(id)sender{
	[webView goForward];
}
-(void)reloadAction:(id)sender{
	[webView reload];
}
-(void)stopAction:(id)sender{
	[webView stopLoading];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}

-(void)backAction:(id)sender{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)backIndexAction:(id)sender{	
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

- (void)moreAction:(id)sender{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:NSLocalizedString(@"select_what_to_do",nil)
								  delegate:self 
								  cancelButtonTitle:NSLocalizedString(@"cancel",nil)
								  destructiveButtonTitle:nil
								  otherButtonTitles:NSLocalizedString(@"open_safair",nil),NSLocalizedString(@"push_chat",nil),NSLocalizedString(@"add_link",nil),NSLocalizedString(@"email_friends",nil),nil
								  ];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];
	[actionSheet release];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
		}
			break;
		case 1:
		{
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
			
			AddChatController *addChatController = [[AddChatController alloc] initWithChatBody:[NSString stringWithFormat:NSLocalizedString(@"push_chat_tpl",nil),self.url]];
			
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			{		
				UINavigationController *chat_navigationController = [[UINavigationController alloc] initWithRootViewController:addChatController];
				
				Class popoverClass = NSClassFromString(@"UIPopoverController");
				if (popoverClass) {
					UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:chat_navigationController];
					popover.delegate = self;
					[popover presentPopoverFromRect:self.tabBarController.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				}
				

				[chat_navigationController release];
			}
			else
			{
				[self.navigationController pushViewController:addChatController animated:YES];
			}
						
			[addChatController release];
		}
			break;
		case 2:
		{
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
			
			EditLinksController *editLinksController = [[EditLinksController alloc] initWithLinks:[NSMutableDictionary dictionaryWithObject:self.url forKey:@"url"] editMode:ADD];
			
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			{		
				UINavigationController *link_navigationController = [[UINavigationController alloc] initWithRootViewController:editLinksController];
				
				Class popoverClass = NSClassFromString(@"UIPopoverController");
				if (popoverClass) {
					UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:link_navigationController];
					popover.delegate = self;
					[popover presentPopoverFromRect:self.tabBarController.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				}
				[link_navigationController release];
			}
			else
			{
				[self.navigationController pushViewController:editLinksController animated:YES];
			}
			
			[editLinksController release];
		}
			break;
		case 3:
		{
			
			MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
			mail.mailComposeDelegate = self;
			if ([MFMailComposeViewController canSendMail]) {

				[mail setToRecipients:[NSArray arrayWithObjects:@"",nil]];
				[mail setSubject:NSLocalizedString(@"send_email_title_tpl",nil)];
				[mail setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"send_email_body_tpl",nil),self.url] isHTML:NO];

				[self presentModalViewController:mail animated:YES];
				
				/*
				UIImage *pic = [UIImage imageNamed:@"Funny.png"];
				NSData *exportData = UIImageJPEGRepresentation(pic ,1.0);
				[mail addAttachmentData:exportData mimeType:@"image/jpeg" fileName:@"Picture.jpeg"];
				 */
			}
			[mail release];
		}
			break;

		default:

			break;
	}
	
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
