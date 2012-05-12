//
//  LinksController.m
//  JavaEye
//
//  Created by ieliwb on 10-5-31.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "LinksController.h"
#import "Common.h"
#import "LinksDAO.h"

#import "EditLinksController.h"
#import "BrowserController.h"

#import "EGORefreshTableHeaderView.h"

#import "JavaEyeApiClient.h"

@implementation LinksController

@synthesize resultArray,table;
@synthesize editLinksController;

@synthesize reloading=_reloading;
@synthesize _footerStatus;


- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle {
	
	if (self=[super init]) {
		
		self.title = title;
		self.navigationItem.title = navTitle;
		
		if(self.tabBarItem){
            self.tabBarItem.title = title;
            self.tabBarItem.image = [UIImage imageNamed:@"item_links.png"];
        }
		
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																				   target:self
																				   action:@selector(addLinks:)];
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
- (void)addLinks:(id)sender{
	if(editLinksController==nil)
	{
		editLinksController = [[EditLinksController alloc] initWithLinks:nil editMode:ADD];
	}
	
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		self.navigationItem.leftBarButtonItem.enabled = NO;
		
		UINavigationController *links_navigationController = [[UINavigationController alloc] initWithRootViewController:editLinksController];
		
		Class popoverClass = NSClassFromString(@"UIPopoverController");
		if (popoverClass) {
			UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:links_navigationController];
			popover.delegate = self;
			[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		[links_navigationController release];
	}
	else
	{
		[self.navigationController pushViewController:editLinksController animated:YES];
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
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"done",nil)];
		self.navigationItem.leftBarButtonItem.enabled = NO;
	}
    else
	{
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"edit",nil)];
		self.navigationItem.leftBarButtonItem.enabled = YES;
	}
}


- (void)viewDidLoad {
    [super viewDidLoad];
	_footerStatus = 0;

	self.resultArray = [[NSMutableArray alloc] initWithCapacity:0];
	[self loadThread:nil];
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,self.view.frame.size.height-90.0f) style: UITableViewStylePlain];
	table.backgroundColor = [UIColor colorWithRed:219.0f/255.0f green:225.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
	table.tag = TABLE_VIEW_TAG;
	[table setSeparatorColor:[UIColor grayColor]];
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
	
	[editLinksController release];
	
	refreshHeaderView = nil;

    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
	[self reloadTableViewDataSource];
}


#pragma mark -
#pragma mark load data methods
- (void) loadThread:(id)sender {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	LinksDAO *linksdao = [[LinksDAO alloc] init];
	NSMutableArray *links = [linksdao getAll];	
	[linksdao release];
	
	self.resultArray = links;
		
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
	
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	NSMutableArray *result = [javaEyeClient favorites];
	[javaEyeClient release];
	
	_footerStatus = 1;
	
	LinksDAO *linksDao = [[LinksDAO alloc] init];
	[linksDao empty];
	
	for(NSDictionary *link in result){  
		
		[linksDao add:link];
		
	}
	
	[linksDao release];
	
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
		
		UILabel *urlLable = [[UILabel alloc] initWithFrame:CGRectMake(10,25, self.view.frame.size.width - 20, 20)];
		urlLable.textAlignment = UITextAlignmentLeft;
		urlLable.textColor = [UIColor darkGrayColor];
		urlLable.tag = URL_LABEL_TAG;
		urlLable.font = [UIFont fontWithName:@"Courier" size:11.0];
		[urlLable setBackgroundColor:[UIColor clearColor]];
		[cell.textLabel setNumberOfLines:0];
		[cell.contentView addSubview:urlLable];
		[urlLable release];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 

    }
	
	UILabel *title = (UILabel *)[cell.contentView viewWithTag:KEY_LABEL_TAG];
	title.text = [[self.resultArray objectAtIndex:indexPath.row] objectForKey:@"title"];
	
	UILabel *url = (UILabel *)[cell.contentView viewWithTag:URL_LABEL_TAG];
	url.text = [[self.resultArray objectAtIndex:indexPath.row] objectForKey:@"url"];
	
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSInteger count = [resultArray count];
	if (count > 0) {
		return [NSString stringWithFormat:NSLocalizedString(@"links_table_title",nil),count];
	}
	return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	BrowserController *browserController = [[BrowserController alloc] initWithUrl:[[self.resultArray objectAtIndex:indexPath.row] objectForKey:@"url"]];
	[self.navigationController pushViewController:browserController animated:YES];	
	[browserController release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger row = [indexPath row];
	
	JavaEyeApiClient *javaEyeClient = [[JavaEyeApiClient alloc] init];
	BOOL result = [javaEyeClient deleteFavorite: [[[self.resultArray objectAtIndex:row] objectForKey:@"id"] intValue]];
	[javaEyeClient release];
	
	if (result) {
		LinksDAO *linksDao = [[LinksDAO alloc] init];
		[linksDao delete:[[[self.resultArray objectAtIndex:row] objectForKey:@"id"] intValue]];	
		[linksDao release];
		
		[self.resultArray removeObjectAtIndex:row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"links_delete_error",nil) message:NSLocalizedString(@"web_connect_error",nil)
													   delegate:self cancelButtonTitle:NSLocalizedString(@"ok",nil) otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}

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
