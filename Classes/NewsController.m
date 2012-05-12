//
//  NewsController.m
//  JavaEye
//
//  Created by ieliwb on 10-6-4.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "NewsController.h"
#import "Common.h"
#import "NewsListController.h"

#import "NewsDAO.h"
#import "XmlParser.h"

@implementation NewsController
@synthesize resultArray,table;
@synthesize newsListController;

- (id)initWithTitle:(NSString *)title withNavigationTitle:(NSString *)navTitle {
	
	if (self=[super init]) {
		
		self.title = title;
		self.navigationItem.title = navTitle;
		
		if(self.tabBarItem){
            self.tabBarItem.title = title;
            self.tabBarItem.image = [UIImage imageNamed:@"item_news.png"];
        }
		
		UIBarButtonItem *loadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																					 target:self
																					 action:@selector(loadAction:)];
		self.navigationItem.rightBarButtonItem = loadButton;
		[loadButton release];
		 
	}
	
	return self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
    [super dealloc];
	[resultArray release];	
	[table release];
	[newsListController release];
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

#pragma mark -
#pragma mark refresh all rss methods
- (void)loadAction:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:NSLocalizedString(@"load_all_title",nil)
								  delegate:self 
								  cancelButtonTitle:NSLocalizedString(@"cancel",nil)
								  destructiveButtonTitle:NSLocalizedString(@"load_all_ok",nil)
								  otherButtonTitles:nil
								  ];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 0) 
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;

		HUD = [[MBProgressHUD alloc] initWithView:self.view];
		[self.view addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = NSLocalizedString(@"connecting",nil);
		[HUD showWhileExecuting:@selector(loadAllRssThread) onTarget:self withObject:nil animated:YES];
	}
}

- (void)loadAllRssThread {

    // Switch to determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = NSLocalizedString(@"load_all_start",nil);
	
    float progress = 0.01f;
	HUD.progress = progress;
	
	NewsDAO *newsDao = [[NewsDAO alloc] init];
	for (NSArray *cat in self.resultArray) {
		for (NSArray *one in cat) {
			NSMutableArray *result = [XmlParser xml2array:[one objectAtIndex:1]];
			[newsDao empty:[[one objectAtIndex:2] intValue]];
			for (NSDictionary *new in result) {
				[newsDao add:new cat:[[one objectAtIndex:2] intValue]];
			}
			
			progress += 0.048f;
			HUD.progress = progress;
			HUD.labelText = NSLocalizedString(@"load_all_status",nil);
			HUD.detailsLabelText = [one objectAtIndex:0];
		}
	}
	[newsDao release];
	
    // Back to indeterminate mode
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = NSLocalizedString(@"load_all_end",nil);
	HUD.detailsLabelText = NSLocalizedString(@"load_all_clean",nil);

    //sleep(2);
	
	self.navigationItem.rightBarButtonItem.enabled = YES;

}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden {
    [HUD removeFromSuperview];
    [HUD release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//NSLog(@"u:%@",[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"]);
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithObjects:
									
									[NSArray arrayWithObjects:
										[NSArray arrayWithObjects:@"ITeye最新新闻",@"http://www.iteye.com/rss/news",[NSNumber numberWithInt:2],nil],
										nil
									 ],
									[NSArray arrayWithObjects:
										[NSArray arrayWithObjects:@"ITeye博客",@"http://www.iteye.com/rss/blogs",[NSNumber numberWithInt:3],nil],
										[NSArray arrayWithObjects:@"ITeye圈子",@"http://www.iteye.com/rss/groups",[NSNumber numberWithInt:4],nil],
										nil
									],
									[NSArray arrayWithObjects:								 
                                     
									 [NSArray arrayWithObjects:@"论坛精彩帖子",@"http://www.iteye.com/rss/topic",[NSNumber numberWithInt:5],nil], 
									 [NSArray arrayWithObjects:@"论坛最新帖子",@"http://www.iteye.com/rss/forum" ,[NSNumber numberWithInt:6],nil], 
                                     
									 [NSArray arrayWithObjects:@"Java版",@"http://www.iteye.com/rss/board/Java",[NSNumber numberWithInt:7],nil], 
									 [NSArray arrayWithObjects:@"Web版",@"http://www.iteye.com/rss/board/web",[NSNumber numberWithInt:8],nil], 
									 [NSArray arrayWithObjects:@"移动编程版",@"http://www.iteye.com/rss/board/mobile",[NSNumber numberWithInt:9],nil], 
                                     
									 [NSArray arrayWithObjects:@"Ruby版",@"http://www.iteye.com/rss/tag/Ruby",[NSNumber numberWithInt:10],nil], 
									 [NSArray arrayWithObjects:@"Python版",@"http://www.iteye.com/rss/tag/Python",[NSNumber numberWithInt:11],nil], 
									 [NSArray arrayWithObjects:@"PHP版",@"http://www.iteye.com/rss/tag/PHP",[NSNumber numberWithInt:12],nil], 
									 [NSArray arrayWithObjects:@"Flash版",@"http://www.iteye.com/rss/tag/Flash",[NSNumber numberWithInt:13],nil], 
									 [NSArray arrayWithObjects:@"dotnet版",@"http://www.iteye.com/rss/tag/dotnet",[NSNumber numberWithInt:14],nil], 
									 [NSArray arrayWithObjects:@"综合技术版",@"http://www.iteye.com/rss/board/Tech",[NSNumber numberWithInt:15],nil], 
									 [NSArray arrayWithObjects:@"入门技术版",@"http://www.iteye.com/rss/board/New",[NSNumber numberWithInt:16],nil],                             
									 [NSArray arrayWithObjects:@"招聘求职版",@"http://www.iteye.com/rss/board/Job",[NSNumber numberWithInt:17],nil], 
									 [NSArray arrayWithObjects:@"海阔天空版",@"http://www.iteye.com/rss/board/Life",[NSNumber numberWithInt:18],nil], 									 
										nil
									 ],																		
									nil
								 ];
	self.resultArray = tempArray;
	[tempArray release];
	
	if ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"]) {
		[self.resultArray insertObject:[NSArray arrayWithObjects:
										[NSArray arrayWithObjects:@"我的Blog文章",[NSString stringWithFormat:@"http://%@.javaeye.com/rss",[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"] objectForKey:@"domain"]],[NSNumber numberWithInt:1],nil],
										nil
										]
							   atIndex:0];
	}
	
	table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,self.view.frame.size.height-([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"] ? 90.0f : 50.0f)) 
										 style: UITableViewStyleGrouped];
	table.backgroundColor = [UIColor clearColor];
	table.tag = TABLE_VIEW_TAG;
	[table setDelegate:self];
	[table setDataSource:self];
	[self.view addSubview:table];
}


#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [resultArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[resultArray objectAtIndex:section] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10,10, 300, 20)];
		titleLable.textAlignment = UITextAlignmentLeft;
		titleLable.tag = KEY_LABEL_TAG;
		titleLable.font = [UIFont boldSystemFontOfSize:12];
		[titleLable setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:titleLable];
		[titleLable release];
		
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; 
		
    }
	
	UILabel *title = (UILabel *)[cell.contentView viewWithTag:KEY_LABEL_TAG];
	title.text = [[[self.resultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:0];
		
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return ([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"] ? [NSString stringWithFormat:@"Hi,%@.Welcome!",[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"javaeye_userinfo"] objectForKey:@"name"]] : @"");
			break;
		case 1:
			return @"ITeye新闻频道";
			break;
		case 2:
			return @"ITeye圈子频道";
			break;
		case 3:
			return @"ITeye论坛频道";
			break;
		default:
			return @"";
			break;
	}	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	newsListController = [[NewsListController alloc] init];
	[newsListController initWithTitle:NSLocalizedString(@"news_title",nil) withNavigationTitle:[[[self.resultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:0] withRssUrl:[[[self.resultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:1] withCategory:[[[[self.resultArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectAtIndex:2] intValue]];
	[self.navigationController pushViewController:newsListController animated:YES];	
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section 
{
    if(section ==3)
        return 50.0f;
    else
        return 16.0f;	
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if(section == 3)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 50, 50, 44)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        label.textAlignment = UITextAlignmentCenter;
        label.lineBreakMode = UILineBreakModeWordWrap; 
		label.font = [UIFont boldSystemFontOfSize:10];
		label.numberOfLines = 0;
        label.text = @"Powered by iteye.com\nCopyright 2012. All rights reserved.";
        return [label autorelease];
    }
    return nil;
}


@end
