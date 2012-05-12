//
//  LogonController.m
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "LogonController.h"

#import "NewsController.h"
#import "ChatController.h"
#import "MessagesController.h"
#import "LinksController.h"
#import "MoreController.h"


@implementation LogonController
@synthesize javaEyeTabBarController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	NewsController *newsController = [[NewsController alloc] initWithTitle:NSLocalizedString(@"news_title",nil) withNavigationTitle:NSLocalizedString(@"news_nav_title",nil)];
	UINavigationController *newsNavigationController = [[UINavigationController alloc] initWithRootViewController:newsController];
	[newsController release];

	ChatController *chatController = [[ChatController alloc] initWithTitle:NSLocalizedString(@"chat_title",nil) withNavigationTitle:NSLocalizedString(@"chat_nav_title",nil)];
	UINavigationController *chatNavigationController = [[UINavigationController alloc] initWithRootViewController:chatController];
	[chatController release];
	
	MessagesController *messagesController = [[MessagesController alloc] initWithTitle:NSLocalizedString(@"msg_title",nil) withNavigationTitle:NSLocalizedString(@"msg_nav_title",nil)];
	UINavigationController *messagesNavigationController = [[UINavigationController alloc] initWithRootViewController:messagesController];
	[messagesController release];
	
	LinksController *linksController = [[LinksController alloc] initWithTitle:NSLocalizedString(@"link_title",nil) withNavigationTitle:NSLocalizedString(@"link_nav_title",nil)];
	UINavigationController *linksNavigationController = [[UINavigationController alloc] initWithRootViewController:linksController];
	[linksController release];
	
	MoreController *moreController = [[MoreController alloc] initWithTitle:NSLocalizedString(@"more_title",nil) withNavigationTitle:NSLocalizedString(@"more_nav_title",nil)];
	UINavigationController *moreNavigationController = [[UINavigationController alloc] initWithRootViewController:moreController];
	[moreController release];

	javaEyeTabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
	javaEyeTabBarController.viewControllers = [NSArray arrayWithObjects:newsNavigationController,chatNavigationController, messagesNavigationController, linksNavigationController, moreNavigationController, nil];
	javaEyeTabBarController.selectedIndex = 0;
	
	[newsNavigationController release];
	[chatNavigationController release];
	[messagesNavigationController release];
	[linksNavigationController release];
	[moreNavigationController release];
    

    [[[UIApplication sharedApplication] keyWindow] addSubview:javaEyeTabBarController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
- (void)dealloc {
	[javaEyeTabBarController release];
    [super dealloc];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return 
			(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) || 
			(interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	return NO;
}

@end
