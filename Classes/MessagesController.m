//
//  MessagesController.m
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "MessagesController.h"
#import "Common.h"
#import "MessagesDAO.h"
#import "NewMessagesController.h"
#import "ViewMessagesController.h"

#import "EGORefreshTableHeaderView.h"

#import "JavaEyeApiClient.h"
#import "UtilString.h"
#import "AsyncImageView.h"

@implementation MessagesController
@synthesize resultArray,table;
@synthesize newMessagesController;
@synthesize reloading=_reloading;
@synthesize _footerStatus;

- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle {
	
	if (self=[super init]) {
		
		selectedRow=-1;

		self.title = title;
		self.navigationItem.title = navTitle;
		
		if(self.tabBarItem){
            self.tabBarItem.title = title;
            self.tabBarItem.image = [UIImage imageNamed:@"item_messages.png"];
        }
		
		
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																				   target:self
																				   action:@selector(addMessages:)];
		self.navigationItem.leftBarButtonItem = addButton;
		[addButton release];
		
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"edit",nil)
									   style:UIBarButtonItemStyleBordered
									   target:self
									   action:@selector(toggleEdit:)];
		self.navigationItem.rightBarButtonItem = editButton;
		[editButton release];
	}
	
	return self;
}

#pragma mark 
#pragma mark navigationItem button methods
- (void)addMessages:(id)sender{

	if(newMessagesController==nil)
	{
		newMessagesController = [[NewMessagesController alloc] initWithMsg:nil sendMode:0];
	}
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		self.navigationItem.leftBarButtonItem.enabled = NO;
		
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
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.navigationItem.leftBarButtonItem.enabled = YES;
	[popoverController release];
}


-(void)toggleEdit:(id)sender {
	
	UITableView *tableView = [[self.view subviews] objectAtIndex:0];
    [tableView setEditing:!tableView.editing animated:YES];
    
	if (tableView.editing)
	{	
		self.navigationItem.leftBarButtonItem.enabled = NO;
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"done",nil)];
	}
    else
	{
		self.navigationItem.leftBarButtonItem.enabled = YES;
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"edit",nil)];
	}
}

- (void)deleteMessages:(id)sender {
	
}

- (void)viewMessages:(id)sender {
		
}



- (void)viewDidLoad {
    [super viewDidLoad];
	
	selectedRow=-1;
	_footerStatus = 0;
	
	
	self.resultArray = [[NSMutableArray alloc] initWithCapacity:0];
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,self.view.frame.size.height-90.0f) style: UITableViewStylePlain];
	table.tag = TABLE_VIEW_TAG;
	table.backgroundColor=[UIColor colorWithRed:219.0f/255.0f green:225.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
	[table setDelegate:self];
	[table setDataSource:self];
	[table setSeparatorColor:[UIColor grayColor]];
	[self.view addSubview:table];
	
	[self loadThread:nil];

	//tmpView	=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slidingmenu.png"]];
	[tmpView setFrame:CGRectMake(0, 0.0f, 320.0f, 86.0f)];
	
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.table.bounds.size.height, self.view.frame.size.width, self.table.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.table addSubview:refreshHeaderView];
		self.table.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
	refreshHeaderView=nil;
}
- (void)dealloc {
    [super dealloc];
	[resultArray release];	
	[table release];
	[tmpView release];
	[newMessagesController release];
	refreshHeaderView = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
	[self loadThread:nil];
}


#pragma mark -
#pragma mark load data methods
- (void) loadThread:(id)sender {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	MessagesDAO *messagesDao = [[MessagesDAO alloc] init];	
	self.resultArray = [messagesDao getAll];
	[messagesDao release];
	
	[self performSelectorOnMainThread:@selector(finshLoad) withObject:nil waitUntilDone:YES];
	[pool release];
}
- (void) finshLoad {
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLE_VIEW_TAG];
	[tableView reloadData];
	
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
}


#pragma mark -
#pragma mark refresh tableView 
- (void)reloadTableViewDataSource{
	//  should be calling your tableviews model to reload		
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}
- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSInteger max = [resultArray count] > 0 ? [[[resultArray objectAtIndex:0] objectForKey:@"id"] intValue] : (NSInteger)0;
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	NSMutableArray *result = [javaEyeClient messages:max page:(NSInteger)0];
	[javaEyeClient release];
	
	_footerStatus = 1;
	
	MessagesDAO *messagesDao = [[MessagesDAO alloc] init];
	
	for(NSDictionary *message in result){  
		[messagesDao add:message];
	}
	
	[messagesDao release];
	
	[self loadThread:nil];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	
	[self dataSourceDidFinishLoadingNewData];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.table.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}
- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.table setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}


#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [resultArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 76.0f;
	if (indexPath.row!=selectedRow)
		return 72.0f;
	else return 72.0f+86.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		UILabel *infoLable = [[UILabel alloc] initWithFrame:CGRectMake(70,5,self.view.frame.size.width-80.0f, 20)];
		infoLable.textAlignment = UITextAlignmentLeft;
		infoLable.tag = INFO_LABEL_TAG;
		infoLable.textColor = [UIColor blueColor];
		infoLable.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
		[infoLable setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:infoLable];
		[infoLable release];
		
		UILabel *keyLable = [[UILabel alloc] initWithFrame:CGRectMake(70,25,self.view.frame.size.width-80.0f, 20)];
		keyLable.textAlignment = UITextAlignmentLeft;
		keyLable.tag = KEY_LABEL_TAG;
		keyLable.textColor = [UIColor darkGrayColor];
		keyLable.font = [UIFont boldSystemFontOfSize:12];
		[keyLable setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:keyLable];
		[keyLable release];
		
		UILabel *valueLable = [[UILabel alloc] initWithFrame:CGRectMake(70,45, self.view.frame.size.width-80.0f, 20)];
		valueLable.textAlignment = UITextAlignmentLeft;
		valueLable.tag = VALUE_LABEL_TAG;
		valueLable.textColor = [UIColor grayColor];
		valueLable.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
		[valueLable setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:valueLable];
		[valueLable release];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 

    }else {
		UIView* oldImage = (UIView*)[cell.contentView viewWithTag:999];
		[oldImage removeFromSuperview];
    }
			
	if ([[[resultArray objectAtIndex:indexPath.row] objectForKey:@"sender_logo"] thumb] != nil) {
		AsyncImageView* asyncImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 48, 48)];
		asyncImage.tag = 999;
		[asyncImage loadImageFromURL:[NSURL URLWithString:[[[resultArray objectAtIndex:indexPath.row] objectForKey:@"sender_logo"] thumb]]];
		[cell.contentView addSubview:asyncImage];
		[asyncImage release];
	}else {
		UIImageView *noLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-logo-no-icon.png"]];
		noLogoView.frame = CGRectMake(10, 10, 48, 48);
		noLogoView.tag = 999;
		[cell.contentView addSubview:noLogoView];
		[noLogoView release];
	}


	UILabel *info = (UILabel *)[cell.contentView viewWithTag:INFO_LABEL_TAG];
	info.text = [NSString stringWithFormat:NSLocalizedString(@"msg_status",nil),[[resultArray objectAtIndex:indexPath.row] objectForKey:@"sender_name"],[[[resultArray objectAtIndex:indexPath.row] objectForKey:@"created_at"] shortDate]] ;
	
	UILabel *key = (UILabel *)[cell.contentView viewWithTag:KEY_LABEL_TAG];
	key.text = [[resultArray objectAtIndex:indexPath.row] objectForKey:@"title"];
	
	UILabel *value = (UILabel *)[cell.contentView viewWithTag:VALUE_LABEL_TAG];
	value.text = [[resultArray objectAtIndex:indexPath.row] objectForKey:@"plain_body"];
	
	cell.selectedBackgroundView=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 150.0f)] autorelease];	
	
	if (indexPath.row!=selectedRow){

	}
	else {
		[cell addSubview:tmpView];
		[tmpView setFrame:CGRectMake(320.0f, 0.0f, 320.0f, 86.0f)];
		[UIView beginAnimations:@"twee" context:nil];
		[tmpView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 86.0f)];
		[UIView commitAnimations];
	}
	return cell;
}
- (void)willTransitionToState:(UITableViewCellStateMask)state
{
}
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	selectedRow=indexPath.row;
	[table reloadData];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	/*
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
	 */
	
	NSUInteger row = [indexPath row];
	
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	BOOL result = [javaEyeClient deleteMessage:[[[self.resultArray objectAtIndex:row] objectForKey:@"id"] intValue]];
	[javaEyeClient release];
	
	if (result) {
		MessagesDAO *msgDao = [[MessagesDAO alloc] init];
		[msgDao delete:[[[self.resultArray objectAtIndex:row] objectForKey:@"id"] intValue]];	
		[msgDao release];
		
		[self.resultArray removeObjectAtIndex:row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"msg_delete_error",nil) message:NSLocalizedString(@"web_connect_error",nil)
													   delegate:self cancelButtonTitle:NSLocalizedString(@"ok",nil) otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[UIView beginAnimations:@"tweeback" context:nil];
	[tmpView setFrame:CGRectMake(340.0f, 0.0f, 320.0f, 86.0f)];
	[UIView commitAnimations];
	[self performSelector:@selector(hideMenu) withObject:nil afterDelay:0.2f];
	
	ViewMessagesController *viewMessagesController = [[ViewMessagesController alloc] initWithDictionary:[resultArray objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:viewMessagesController animated:YES];	
	[viewMessagesController release];
}
-(void) hideMenu{
	selectedRow=-1;
	[table reloadData];
	[tmpView removeFromSuperview];
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section 
{
	if ([resultArray count] < 1) {
		return 370;
	}
	return 0;	
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if([resultArray count] < 1 && _footerStatus == 0) {
		//画一个下拉刷新图
		NSString *refresh_img = nil;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			refresh_img = @"pull_down_refresh_ipad_1.png";
		}
		else				
		{
			refresh_img = @"pull_down_refresh_iphone_1.png";
		}
		
		UIImageView *pullDownView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:refresh_img]];
		pullDownView.frame = CGRectMake(0, 0, self.view.frame.size.width, 370);
		return [pullDownView autorelease];
	}else {
		return nil;
	}
	
}


@end
