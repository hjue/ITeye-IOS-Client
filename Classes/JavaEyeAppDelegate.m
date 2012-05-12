//
//  JavaEyeAppDelegate.m
//  JavaEye
//
//  Created by ieliwb on 10-5-27.
//  Copyright ieliwb.com 2010. All rights reserved.
//

#import "JavaEyeAppDelegate.h"
#import "LoginController.h"

@implementation JavaEyeAppDelegate

@synthesize window;
@synthesize loginController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"javaeye_userinfo"];//防止意外退出

	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	loginController = [[LoginController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *showNavigationController = [[UINavigationController alloc] initWithRootViewController:loginController];

	window.rootViewController = showNavigationController;
    //[window addSubview:showNavigationController.view];
    [window makeKeyAndVisible];
	[window setBackgroundColor:[UIColor groupTableViewBackgroundColor]];

	return YES;
}

-(void)applicationWillTerminate:(UIApplication *)app {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"javaeye_userinfo"];
}

- (void)dealloc {
	[loginController release];
    [window release];
    [super dealloc];
}


@end
