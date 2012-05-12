//
//  NewsListController.m
//  JavaEye
//
//  Created by ieliwb on 10-6-4.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "NewsListController.h"
#import "Common.h"
#import "NewsDAO.h"
#import "NewsDetailController.h"

#import "JavaEyeApiClient.h"
#import "EGORefreshTableHeaderView.h"

#import "XmlParser.h"
#import "UtilString.h"

@implementation NewsListController

@synthesize resultArray,table;
@synthesize url;
@synthesize reloading=_reloading;
@synthesize _category;
@synthesize _footerStatus;

-(id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle withRssUrl:(NSString *)theUrl withCategory:(int)theCategory
{	
	if (self=[super init]) {

		self.title = title;
		self.navigationItem.title = navTitle;

		UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
									  initWithTitle:NSLocalizedString(@"back",nil)
									  style:UIBarButtonItemStyleBordered
									  target:self
									  action:@selector(backAction:)];
		self.navigationItem.leftBarButtonItem = backButton;
		[backButton release];
		
		self.url = theUrl;
		self._category = theCategory;
	}
	
	return self;
}


- (void)backAction:(id)sender
{
	[[self navigationController] popViewControllerAnimated:YES];
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLE_VIEW_TAG];
	[tableView setFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,self.view.frame.size.height-([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"] ? 90.0f : 50.0f))];
	[tableView reloadData];
}
 */

- (void)viewDidLoad {
    [super viewDidLoad];

	_footerStatus = 0;

	resultArray = [[NSMutableArray alloc] initWithCapacity:0];
	
	[self loadThread:nil];
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,self.view.frame.size.height-([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"] ? 90.0f : 50.0f)) style:UITableViewStylePlain];
	//table.backgroundColor = [UIColor colorWithRed:219.0f/255.0f green:225.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
	table.backgroundColor = [UIColor whiteColor];
	table.tag = TABLE_VIEW_TAG;
	[table setSeparatorColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1]];
	[table setDelegate:self];
	[table setDataSource:self];
	[self.view addSubview:table];
		
	
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.table.bounds.size.height, self.view.frame.size.width, self.table.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.table addSubview:refreshHeaderView];
		self.table.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	refreshHeaderView=nil;
	
}
- (void)dealloc {
	[resultArray release];	
	[table release];
 	refreshHeaderView=nil;
   [super dealloc];
}


- (void) loadThread:(id)sender {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NewsDAO *newsDao = [[NewsDAO alloc] init];
	
	self.resultArray = [newsDao getAll:_category];
	
	[newsDao release];
		
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
		
	_footerStatus = 1;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSMutableArray *result = [XmlParser xml2array:url];
	
	NewsDAO *newsDao = [[NewsDAO alloc] init];
	[newsDao empty:_category];
	for (NSDictionary *new in result) {
		[newsDao add:new cat:_category];
	}
	[newsDao release];

	//NSLog(@"xml:%@",result);
	
	/*
	 for(NSDictionary *chat in result){  
	 
	 [chatDao add:chat t:_type];
	 
	 }
	 */
	
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
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];
		
		UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10,5, self.view.frame.size.width - 20, 20)];
		titleLable.textAlignment = UITextAlignmentLeft;
		titleLable.tag = KEY_LABEL_TAG;
		titleLable.font = [UIFont boldSystemFontOfSize:12];
		[titleLable setBackgroundColor:[UIColor clearColor]];
		[cell.textLabel setNumberOfLines:0];
		[cell.contentView addSubview:titleLable];
		[titleLable release];
		
		UILabel *timeLable = [[UILabel alloc] initWithFrame:CGRectMake(10,25, self.view.frame.size.width - 20, 20)];
		timeLable.textAlignment = UITextAlignmentLeft;
		timeLable.textColor = [UIColor darkGrayColor];
		timeLable.tag = TIME_LABEL_TAG;
		timeLable.font = [UIFont fontWithName:@"Courier" size:11.0];
		[timeLable setBackgroundColor:[UIColor clearColor]];
		[cell.textLabel setNumberOfLines:0];
		[cell.contentView addSubview:timeLable];
		[timeLable release];
		
		cell.accessoryType =    UITableViewCellAccessoryDisclosureIndicator; 
    }
	
	UILabel *title = (UILabel *)[cell.contentView viewWithTag:KEY_LABEL_TAG];
	title.text = [[[self.resultArray objectAtIndex:indexPath.row] objectForKey:@"title"] htmlSimpleUnescapeString];
	
	UILabel *time = (UILabel *)[cell.contentView viewWithTag:TIME_LABEL_TAG];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];// 
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	[formatter setDateFormat: @"ccc, d MMM yyyy H:m:s zzzz"];
	NSDate* pubDate = [formatter dateFromString:[[self.resultArray objectAtIndex:indexPath.row] objectForKey:@"pubDate"]];
	[formatter setTimeZone:[NSTimeZone defaultTimeZone]];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
	time.text = [formatter stringFromDate:pubDate];
	
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NewsDetailController *newsDetailController = [[NewsDetailController alloc] initWithDictionary:[self.resultArray objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:newsDetailController animated:YES];	
	[newsDetailController release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section 
{
	if ([resultArray count] < 1) {
        return self.view.frame.size.height;
    }
	return 0;	
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if([resultArray count] < 1 ) {
        if(_footerStatus == 0)
        {
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
            UIView *footerView  = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)] autorelease];
            [footerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [footerView setContentMode:UIViewContentModeTopLeft];
            UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10,5, self.view.frame.size.width - 20, 20)];
            titleLable.textAlignment = UITextAlignmentCenter;
            titleLable.tag = KEY_LABEL_TAG;
            titleLable.font = [UIFont boldSystemFontOfSize:18];
            [titleLable setBackgroundColor:[UIColor clearColor]];
            [titleLable setText:@"No data found."];
            [footerView addSubview:titleLable];
            [titleLable release];            
            /*
            UIImageView *footer = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"footer_gradient.png"]] autorelease];
            [footerView addSubview:footer];
            footerView.frame = CGRectMake(0, 0, 320, 40);
            
            UIView *footerView  = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
             */
            return footerView;
        }
	}else {
		return nil;
	}
	
}


@end