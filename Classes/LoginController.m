//
//  LoginController.m
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "LoginController.h"
#import "Common.h"
#import "UtilFile.h"
#import "LogonController.h"
#import "SFHFKeychainUtils.h"
#import "JavaEyeApiClient.h"
#import "NewsController.h"

@implementation LoginController
@synthesize logonController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.navigationItem.hidesBackButton = YES;		
		self.hidesBottomBarWhenPushed=YES;//隐藏UITabBar
		self.title = NSLocalizedString(@"login_title",nil);
		
		UIBarButtonItem *registerButton = [[UIBarButtonItem alloc]
										   initWithTitle:NSLocalizedString(@"register",nil)
										   style:UIBarButtonItemStyleBordered
										   target:self
										   action:@selector(registerAction:)];
		self.navigationItem.leftBarButtonItem = registerButton;
		[registerButton release];
		
		UIBarButtonItem *guestButton = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"guest",nil)
									   style:UIBarButtonItemStyleBordered
									   target:self
									   action:@selector(guestAction:)];
		self.navigationItem.rightBarButtonItem = guestButton;
		[guestButton release];	
		
	}
	return self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
	[logonController release];
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
/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	UIImageView *logoView = (UIImageView *)[self.view viewWithTag:LOGO_VIEW_TAG];
	logoView.frame = CGRectMake((self.view.frame.size.width-200)/2, 50, 200, 90);
	
	UITextField *u_textFieldView = (UITextField *)[self.view viewWithTag:KEY_LABEL_TAG];
	u_textFieldView.frame = CGRectMake((self.view.frame.size.width-240)/2, 150, 240, 40);
	
	UITextField *p_textFieldView = (UITextField *)[self.view viewWithTag:VALUE_LABEL_TAG];
	p_textFieldView.frame = CGRectMake((self.view.frame.size.width-240)/2, 200, 240, 40);
	
	UIButton *btnView = (UIButton *)[self.view viewWithTag:BTN_VIEW_TAG];
	btnView.frame = CGRectMake((self.view.frame.size.width-128)/2, 260, 128, 39);
}
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *save_username;
	NSString *save_password;
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"javaeye_username"]) {
		save_username = [[NSUserDefaults standardUserDefaults] objectForKey:@"javaeye_username"];
		NSError *error;
		save_password = [SFHFKeychainUtils getPasswordForUsername:save_username andServiceName:@"javaeye" error:&error];
	}else {
		save_username = @"";
		save_password = @"";
	}

	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 50, 200, 90)];
	logo.tag = LOGO_VIEW_TAG;
    [logo setImage:[UIImage imageNamed:@"logo.png"]];
	[self.view addSubview: logo];
    [logo release];
	
	UITextField *usernameField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-240)/2, 150, 240, 40)];
	usernameField.tag = KEY_LABEL_TAG;
	usernameField.textColor = [UIColor blackColor];
	usernameField.font = [UIFont systemFontOfSize:15.0];
	usernameField.placeholder = NSLocalizedString(@"username_input",nil);
	usernameField.text = save_username;
	usernameField.backgroundColor = [UIColor clearColor];
	usernameField.keyboardType = UIKeyboardTypeURL;
	usernameField.returnKeyType = UIReturnKeyDone;
	usernameField.clipsToBounds = YES;
	usernameField.delegate =self;
	usernameField.borderStyle = UITextBorderStyleRoundedRect;
	usernameField.keyboardAppearance = UIKeyboardAppearanceAlert;
	usernameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
	usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	usernameField.textAlignment = UITextAlignmentLeft;
	usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
	[self.view addSubview: usernameField];
	[usernameField release];

	
	UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-240)/2, 200, 240, 40)];
	passwordField.tag = VALUE_LABEL_TAG;
	passwordField.textColor = [UIColor blackColor];
	passwordField.font = [UIFont systemFontOfSize:15.0];
	passwordField.placeholder = NSLocalizedString(@"password_input",nil);
	passwordField.text = save_password;
	passwordField.backgroundColor = [UIColor clearColor];
	passwordField.keyboardType = UIKeyboardTypeURL;
	passwordField.returnKeyType = UIReturnKeyDone;
	passwordField.clipsToBounds = YES;
	passwordField.delegate =self;
	passwordField.borderStyle = UITextBorderStyleRoundedRect;
	passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
	passwordField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
	passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	passwordField.textAlignment = UITextAlignmentLeft;
	passwordField.secureTextEntry = YES;
	passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;	
	[self.view addSubview: passwordField];
	[passwordField release];
	
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.tag = BTN_VIEW_TAG;
	button.frame = CGRectMake((self.view.frame.size.width-128)/2, 260, 128, 39);
	[button setTitle:NSLocalizedString(@"login",nil) forState:UIControlStateNormal];
	[button addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	if (![save_username isEqualToString:@""] && ![save_password isEqualToString:@""] && [[NSUserDefaults standardUserDefaults] objectForKey:@"auto_login"]) {
		[self loginAction:nil];
	}
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && textField.tag == VALUE_LABEL_TAG)
	{
		self.view.frame = CGRectMake (0,-100,self.view.frame.size.width, self.view.frame.size.height);
	}
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && textField.tag == VALUE_LABEL_TAG)
	{
		self.view.frame = CGRectMake (0,0,self.view.frame.size.width, self.view.frame.size.height);
	}
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

-(void)loginAction:(id)sender{
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.delegate = self;
	HUD.minShowTime = 1.0;
	[HUD show:YES];
	HUD.labelText = NSLocalizedString(@"logining",nil);

	
	UITextField* username_field =  (UITextField *) [self.view viewWithTag: KEY_LABEL_TAG];
	if ([username_field.text isEqualToString:@""]) {
		HUD.labelText = NSLocalizedString(@"username_empty",nil);
		[HUD hide:YES];
		return ;
	}
	
	UITextField* password_field =  (UITextField *) [self.view viewWithTag: VALUE_LABEL_TAG];
	if ([password_field.text isEqualToString:@""]) {
		HUD.labelText = NSLocalizedString(@"password_empty",nil);
		[HUD hide:YES];
		return ;
	}
	
	HUD.labelText = NSLocalizedString(@"logining",nil);

	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	NSMutableDictionary *result = [javaEyeClient verify:username_field.text p:password_field.text];
	[javaEyeClient release];
	
	//NSLog(@"logoin:%@",result);
	
	if ([result objectForKey:@"error"]) {
		HUD.labelText = [result objectForKey:@"error"];
		[HUD hide:YES];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Fail!" 
														message:[result objectForKey:@"error"]
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"ok",nil) 
											  otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
		return ;
	}else if (![result objectForKey:@"name"]) {
		HUD.labelText = NSLocalizedString(@"login_fail",nil);
		[HUD hide:YES];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Fail!" 
														message:NSLocalizedString(@"login_fail",nil)
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"ok",nil) 
											  otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
		return ;		
	}
	else {
		[HUD hide:YES];
		
		//删除登录不同用户的数据库,防止不同帐号登录后缓存数据显示错乱
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"javaeye_username"] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"javaeye_username"] isEqualToString:username_field.text]) {
			[UtilFile deleteUserDB];
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:username_field.text forKey:@"javaeye_username"];
		[[NSUserDefaults standardUserDefaults] setObject:result forKey:@"javaeye_userinfo"];
		
		NSError *error;
		[SFHFKeychainUtils storeUsername:username_field.text andPassword:password_field.text forServiceName:@"javaeye" updateExisting:NO error:&error];

		if(self.logonController == nil){
			self.navigationController.navigationBarHidden=YES;
			LogonController *logonViewController = [[LogonController alloc] init];
			self.logonController = logonViewController;
			[logonViewController release];
		}
		
		[UIView beginAnimations:@"View Flip" context:nil];
		[UIView setAnimationDuration:0.7f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationRepeatAutoreverses:NO];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		self.view = self.logonController.view;
		[UIView commitAnimations];
		return ;
	}	
	
}

-(void)guestAction:(id)sender
{
	self.navigationController.navigationBarHidden=NO;
	NewsController *newsController = [[NewsController alloc] initWithTitle:NSLocalizedString(@"news_title",nil) withNavigationTitle:NSLocalizedString(@"news_nav_title",nil)];
	[self.navigationController pushViewController:newsController animated:YES];
	[newsController release];	
}

-(void)registerAction:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:NSLocalizedString(@"register_remind",nil)
								  delegate:self 
								  cancelButtonTitle:NSLocalizedString(@"cancel",nil)
								  destructiveButtonTitle:NSLocalizedString(@"register",nil)
								  otherButtonTitles:nil
								  ];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) 
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.javaeye.com/signup"]];
	}
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden {
    [HUD removeFromSuperview];
    [HUD release];
}


@end
