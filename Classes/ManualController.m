//
//  ManualController.m
//  iTool
//
//  Created by ieliwb on 10-5-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "ManualController.h"

@implementation ManualController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.navigationController.navigationBarHidden = NO;
		self.navigationItem.title=NSLocalizedString(@"manual_title",nil);
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = CGSizeMake(320.0, 370.0);
		} else {
			
		}
		
		
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 370)];
	[webView setUserInteractionEnabled:YES];
	[webView setBackgroundColor:[UIColor clearColor]];
	[webView setDelegate:self];
	[webView setOpaque:NO];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Manual" ofType:@"htm"]]]];
	[self.view addSubview:webView];
	[webView release];
	
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = NSLocalizedString(@"loading",nil);
	[HUD show:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[HUD hide:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden {
    [HUD removeFromSuperview];
    [HUD release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}

@end