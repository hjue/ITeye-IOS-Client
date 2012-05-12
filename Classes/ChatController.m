//
//  ChatController.m
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "ChatController.h"
#import "Common.h"
#import "ChatDAO.h"
#import "UtilString.h"

#import "AddChatController.h"

#import "JavaEyeApiClient.h"
#import "EGORefreshTableHeaderView.h"

#import "AsyncImageView.h"

#define TYPE_LIST [NSArray arrayWithObjects:@"list",@"my",@"replies",@"all",nil]

@implementation ChatController
@synthesize chatArray,table;
@synthesize addChatController;
@synthesize reloading=_reloading;
@synthesize _type;
@synthesize _footerStatus;

- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle {
	
	if (self=[super init]) {
				
		self.title = title;
		self.navigationItem.title = navTitle;
		
		if(self.tabBarItem){
            self.tabBarItem.title = title;
            self.tabBarItem.image = [UIImage imageNamed:@"item_chat.png"];
        }
		
		NSArray *buttonNames = [NSArray arrayWithObjects:NSLocalizedString(@"chat_list",nil),NSLocalizedString(@"chat_my",nil),NSLocalizedString(@"chat_replies",nil),NSLocalizedString(@"chat_all",nil), nil];
		UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar; 
		segmentedControl.selectedSegmentIndex = 0;
		[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		self.navigationItem.titleView = segmentedControl;
		[segmentedControl release];
		
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																				   target:self 
																				   action:@selector(addChat:)];
		self.navigationItem.rightBarButtonItem = addButton;
		[addButton release];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reloadChat:)
													 name:@"reloadChat" object:nil];
		
		
	}
	
	return self;
}

-(void)addChat:(id) sender{
	// add a new chat message, reply to nobody
	// this will set the chat message input box to empty
	[self replyChat:@""];
	
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.navigationItem.rightBarButtonItem.enabled = YES;
	[popoverController release];
}

-(void)replyChat:(NSString *)reply
{
	if(addChatController==nil)
	{
		addChatController = [[AddChatController alloc] initWithChatBody:reply];
	}else {
		[addChatController setReplyChatBody:reply];
	}
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
		
		UINavigationController *chat_navigationController = [[UINavigationController alloc] initWithRootViewController:addChatController];
		
		Class popoverClass = NSClassFromString(@"UIPopoverController");
		if (popoverClass) {
			UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:chat_navigationController];
			popover.delegate = self;
			[popover presentPopoverFromRect:self.navigationItem.titleView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		[chat_navigationController release];
	}
	else
	{
		[self.navigationController pushViewController:addChatController animated:YES];
	}
	
}

-(void)segmentAction:(id) sender
{
	NSInteger index = [sender selectedSegmentIndex];
	[chatArray removeAllObjects];
	_type = index;
	_footerStatus = 0;

	//NSLog(@"index:%d",index);
	[self loadThread:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	chatArray = [[NSMutableArray alloc] initWithCapacity:0];
	_type = 0;
	_footerStatus = 0;
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,self.view.frame.size.height-90.0f) style: UITableViewStylePlain];
	table.tag = TABLE_VIEW_TAG;
	table.backgroundColor=[UIColor colorWithRed:219.0f/255.0f green:225.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
	[table setDelegate:self];
	[table setDataSource:self];
	[table setSeparatorColor:[UIColor grayColor]];
	[self.view addSubview:table];
	
	[self loadThread:nil];

	
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
	[addChatController release];
	[chatArray release];	
	[table release];
	refreshHeaderView = nil;

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
	[self reloadTableViewDataSource];
}

-(void)reloadChat:(id)sender
{
	//[self dismissPopoverAnimated:YES];
	[self reloadTableViewDataSource];
}

#pragma mark -
#pragma mark loadThread methods
- (void) loadThread:(id)sender {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	ChatDAO *chatDao = [[ChatDAO alloc] init];
	
	self.chatArray = [chatDao getAll:_type];
	
	[chatDao release];
	
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
#pragma mark loadMore methods
-(void)loadMore:(id)sender{

	NSInteger now_page = floor((float)[chatArray count] / 30) + 1;
	//NSLog(@"page:%d",now_page);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	NSMutableArray *result = [javaEyeClient twitters:[TYPE_LIST objectAtIndex:_type] last_id:(NSInteger)1 page:(NSInteger)now_page];
	[javaEyeClient release];
	
	if ([result count] < 30) {
		_footerStatus = 2;
	}
	
	for(NSDictionary *theChat in result){  
		[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   [theChat objectForKey:@"id"],@"id",
								   [theChat objectForKey:@"created_at"],@"created_at",
								   [theChat objectForKey:@"body"],@"body",
								   [[theChat objectForKey:@"user"] objectForKey:@"name"],@"user_name",
								   (NSString *)[[theChat objectForKey:@"user"] objectForKey:@"logo"],@"user_logo",
								   [[theChat objectForKey:@"user"] objectForKey:@"domain"],@"user_domain",
								   [[theChat objectForKey:@"receiver"] objectForKey:@"name"],@"receiver_name",
								   (NSString *)[[theChat objectForKey:@"receiver"] objectForKey:@"logo"],@"receiver_logo",
								   [[theChat objectForKey:@"receiver"] objectForKey:@"domain"],@"receiver_domain",
								   [theChat objectForKey:@"reply_to_id"],@"reply_to_id",
								   [theChat objectForKey:@"via"],@"via",
								   nil
								   ]];		
	}
	
	
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLE_VIEW_TAG];
	[tableView reloadData];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}

#pragma mark -
#pragma mark refresh tableView 
- (void)reloadTableViewDataSource{
	//  should be calling your tableviews model to reload	
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}
- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	
	NSInteger max = [chatArray count] > 0 ? [[[chatArray objectAtIndex:0] objectForKey:@"id"] intValue]: (NSInteger)0;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	NSMutableArray *result = [javaEyeClient twitters:[TYPE_LIST objectAtIndex:_type] last_id:max page:(NSInteger)0];
	[javaEyeClient release];
	
	_footerStatus = 1;
	
	ChatDAO *chatDao = [[ChatDAO alloc] init];
	
	for(NSDictionary *chat in result){  
		
		[chatDao add:chat t:_type];
		
	}
	//删除冗余数据,保留最新的30条
	[chatDao empty:_type];
	[chatDao release];
	
	[chatArray removeAllObjects];

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
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 1) {
		return 0;
	}
    return [chatArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UIFont *font = [UIFont systemFontOfSize:15];
	CGSize size = [[[chatArray objectAtIndex:[indexPath row]] objectForKey:@"body"] sizeWithFont:font constrainedToSize:CGSizeMake(self.view.frame.size.width - 80.0f, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
	return size.height + 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		
		cell.backgroundColor = [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else {

		while (cell.contentView.subviews.count) {
			UIView* child = cell.contentView.subviews.lastObject;
			[child removeFromSuperview];
		}
		
    }
	
	NSDictionary *chat = [chatArray objectAtIndex:[indexPath row]];
	BOOL isReply = [chat objectForKey:@"reply_to_id"]!=[NSNull null] && [[chat objectForKey:@"reply_to_id"] intValue] != 0;
	
	UIFont *font = [UIFont systemFontOfSize:15];
	CGSize size = [[chat objectForKey:@"body"] sizeWithFont:font constrainedToSize:CGSizeMake(self.view.frame.size.width - 80.0f, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
	//UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:([[chat objectForKey:@"body"] length] > 50 ? @"bubbleSelf" : @"bubble") ofType:@"png"]];
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(isReply ?  @"bubbleReply" : @"bubble" ) ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:21 topCapHeight:14]];
	bubbleImageView.frame = CGRectMake(60.0f, 25.0f, self.view.frame.size.width - 70.0f, size.height+15.0f);
	[cell.contentView addSubview:bubbleImageView];
	[bubbleImageView release];
	
	UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, 25.0f, size.width, size.height+10)];
	if( isReply ){
		bubbleText.frame = CGRectMake(70.0f, 25.0f, size.width, size.height+10);
	}
	bubbleText.backgroundColor = [UIColor clearColor];
	bubbleText.font = font;
	bubbleText.numberOfLines = 0;
	bubbleText.lineBreakMode = UILineBreakModeCharacterWrap;
	bubbleText.text = [[chat objectForKey:@"body"] htmlSimpleUnescapeString];
	[cell.contentView addSubview:bubbleText];
	[bubbleText release];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 4.0f, 200, 20)];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.font = [UIFont boldSystemFontOfSize:14];
	usernameLabel.text = [chat objectForKey:@"user_name"];
	[cell.contentView addSubview:usernameLabel];
	[usernameLabel release];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 220.0f, 4.0f, 200, 20)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.font = [UIFont systemFontOfSize:12];
	timeLabel.textColor = [UIColor grayColor];
	timeLabel.textAlignment = UITextAlignmentRight;
	timeLabel.text = [[chat objectForKey:@"created_at"] shortDate];
	[cell.contentView addSubview:timeLabel];
	[timeLabel release];
	
	if ([chat objectForKey:@"user_logo"] != [NSNull null] &&  [[chat objectForKey:@"user_logo"] thumb] != nil) {
		//NSLog(@"img:%@",[[chat objectForKey:@"user_logo"] thumb]);
		AsyncImageView* logoView = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 48, 48)];
		[logoView loadImageFromURL:[NSURL URLWithString:[[chat objectForKey:@"user_logo"] thumb]]];
		[cell.contentView addSubview:logoView];
		[logoView release];
	}else {
		UIImageView *noLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-logo-no-icon.png"]];
		noLogoView.frame = CGRectMake(10, 10, 48, 48);
		[cell.contentView addSubview:noLogoView];
		[noLogoView release];
	}
		
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[self replyChat:[NSString stringWithFormat:@"@%@ \n",[[chatArray objectAtIndex:indexPath.row] objectForKey:@"user_name"]]];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section 
{
    return 0;
	if ([chatArray count] > 0) {
		return 50;
	}
	return 370;	
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	
	if (section == 1) {
		if ([chatArray count] > 0 && _footerStatus != 2) {
			CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
			UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 44.0)];
			footerView.tag = 211;
			footerView.autoresizesSubviews = YES;
			footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			footerView.userInteractionEnabled = YES;
			footerView.hidden = NO;
			footerView.multipleTouchEnabled = NO;
			footerView.opaque = NO;
			footerView.contentMode = UIViewContentModeScaleToFill;
			
			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];        
			btn.frame = CGRectMake((self.view.frame.size.width - 100)/2, 10, 100, 30);
			[btn setTitle:@"更多..." forState:UIControlStateNormal];
			[btn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
			btn.backgroundColor = [UIColor clearColor];
			[btn addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
			[footerView addSubview:btn];		
			
			// Return the footerView
			return [footerView autorelease];
		}else if([chatArray count] == 0 && _footerStatus == 0) {
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
	else return nil;
	 
}

@end
