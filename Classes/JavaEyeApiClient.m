//
//  JavaEyeApiClient.m
//  JavaEye
//
//  Created by ieliwb on 10-6-7.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "JavaEyeApiClient.h"

#import "SFHFKeychainUtils.h"
#import "BaseAuthenicationHttpClient.h"
#import "JSON.h"

@implementation JavaEyeApiClient

@synthesize username;
@synthesize password;

-(id)init
{
	if (self=[super init]) {
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"javaeye_username"]) {
			self.username = [[NSUserDefaults standardUserDefaults] objectForKey:@"javaeye_username"];
			NSError *error;
			self.password = [SFHFKeychainUtils getPasswordForUsername:self.username andServiceName:@"javaeye" error:&error];
		} else {
			self.username = @"";
			self.password = @"";
		}
		
	}
	return self;
}
- (void)dealloc {
    [super dealloc];
	[username release];
	[password release];
}

#pragma mark -
#pragma mark verify methods
-(NSMutableDictionary *)verify:(NSString *)ck_username p:(NSString *)ck_password
{	
	NSMutableDictionary *temp=[NSMutableDictionary dictionaryWithCapacity:10];  

	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/auth/verify" 
															u:ck_username
															p:ck_password
													   params:nil];
	//NSLog(@"login:%@",result);
	if ([result isEqualToString:@"error.auth.fail"]) {
		[temp setObject:NSLocalizedString(@"error_auth_fail",nil) forKey:@"error"];  
	}else if ([result isEqualToString:@"error.auth.over.limit"]) {
		[temp setObject:NSLocalizedString(@"error_auth_over",nil) forKey:@"error"];
	}else if ([result isEqualToString:@"error.api.over.limit"]) {
		[temp setObject:NSLocalizedString(@"error_api_over",nil) forKey:@"error"];
	}else  if ([result hasPrefix:@"error"]) {
		[temp setObject:result forKey:@"error"];
	}else{
		temp = [result JSONValue];
	}
	
	return temp;
}


#pragma mark -
#pragma mark twitters methods
-(NSMutableArray *)twitters:(NSString *)type last_id:(NSInteger)t_id page:(NSInteger)t_page
{
	NSMutableArray *temp=[NSMutableArray arrayWithCapacity:10];  
	
	NSMutableDictionary *tempDic=[NSMutableDictionary dictionaryWithCapacity:2];  
	[tempDic setObject:[NSString stringWithFormat:@"%d",t_id] forKey:@"last_id"];
	[tempDic setObject:[NSString stringWithFormat:@"%d",t_page] forKey:@"page"];
			
	NSString *result = [BaseAuthenicationHttpClient doRequest:[NSString stringWithFormat:@"http://api.iteye.com/api/twitters/%@",type]
															u:username
															p:password
													   params:tempDic
						];
		
	if ([result hasPrefix:@"error"]) {
		return temp;
	}else {
		temp = [result JSONValue];
	}
	return temp;
}


-(NSMutableDictionary *)createTwitter:(NSDictionary *)chat
{	
	NSMutableDictionary *temp=[NSMutableDictionary dictionaryWithCapacity:10];  
	NSMutableDictionary *tempChat=[NSMutableDictionary dictionaryWithCapacity:10];  
	
	if ([chat objectForKey:@"body"] == nil) {
		[temp setObject:@"闲聊内容不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempChat setObject:[chat objectForKey:@"body"] forKey:@"body"];
	}
	
	if ([chat objectForKey:@"reply_to_id"] != nil) {
		[tempChat setObject:[chat objectForKey:@"reply_to_id"] forKey:@"reply_to_id"];
	}
	
	[tempChat setObject:@"iPhone Client" forKey:@"via"];

	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/twitters/create"
															u:username
															p:password
													   params:tempChat
						];
	
	if ([result hasPrefix:@"error"]) {
		[temp setObject:result forKey:@"error"];
	}else {
		temp = [result JSONValue];
	}
	//NSLog(@"result:%@",result);
	return temp;
}

-(BOOL)deleteTwitter:(NSInteger)t_id
{
	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/twitters/destroy"
																u:username
																p:password
														   params:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",t_id],@"id",nil]
							];
	
	return [result hasPrefix:@"error"] ? NO : YES;
}

-(NSMutableDictionary *)showTwitter:(NSString *)t_ids
{
	NSMutableDictionary *temp=[NSMutableDictionary dictionaryWithCapacity:10];  

	if ([t_ids isEqualToString:@""]) {
		[temp setObject:@"请指定要获取的id" forKey:@"error"];
	}else {
		NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/twitters/show"
																u:username
																p:password
														   params:[NSDictionary dictionaryWithObjectsAndKeys:t_ids,@"id",nil]
							];
		if ([result isEqualToString:@"error.record.not.found"]) {
			[temp setObject:@"找不到要获取的记录" forKey:@"error"];
		}else {
			temp = [result JSONValue];
		}
	}
	
	return temp;
}

#pragma mark -
#pragma mark favorites methods
-(NSMutableArray *)favorites
{
	NSMutableArray *temp=[NSMutableArray arrayWithCapacity:10];  

	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/user_favorites/list"
															u:username
															p:password
													   params:nil
						];
	
	if ([result hasPrefix:@"error"]) {
		return temp;
	}else {
		temp = [result JSONValue];
	}
	
	return temp;
}


-(NSMutableDictionary *)createFavorite:(NSMutableDictionary *)fav
{
	NSMutableDictionary *temp=[NSMutableDictionary dictionaryWithCapacity:10];  
	
	NSMutableDictionary *tempFav=[NSMutableDictionary dictionaryWithCapacity:10];  
	
	if ([fav objectForKey:@"url"] == nil) {
		[temp setObject:@"收藏的URL不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempFav setObject:[fav objectForKey:@"url"] forKey:@"url"];
	}
	
	if ([fav objectForKey:@"title"] == nil) {
		[temp setObject:@"收藏的title不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempFav setObject:[fav objectForKey:@"title"] forKey:@"title"];
	}
	
	if ([fav objectForKey:@"description"] != nil) {
		[tempFav setObject:[fav objectForKey:@"description"] forKey:@"description"];
	}
	
	if ([fav objectForKey:@"tag_list"] != nil) {
		[tempFav setObject:[fav objectForKey:@"tag_list"] forKey:@"tag_list"];
	}
			
	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/user_favorites/create"
															u:username
															p:password
													   params:tempFav
						];
	
	//NSLog(@"createfav:%@",result);
	
	if ([result hasPrefix:@"error"]) {
		[temp setObject:result forKey:@"error"];
	}else {
		temp = [result JSONValue];
	}
	return temp;
}


-(NSMutableDictionary *)updateFavorite:(NSDictionary *)fav
{
	
	NSMutableDictionary *temp=[NSMutableDictionary dictionaryWithCapacity:10];  
	
	NSMutableDictionary *tempFav=[NSMutableDictionary dictionaryWithCapacity:10];  
	
	
	if ([fav objectForKey:@"f_id"] == nil) {
		[temp setObject:@"更新收藏的id不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempFav setObject:[fav objectForKey:@"f_id"] forKey:@"id"];
	}

	
	if ([fav objectForKey:@"url"] == nil) {
		[temp setObject:@"收藏的URL不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempFav setObject:[fav objectForKey:@"url"] forKey:@"url"];
	}
	
	if ([fav objectForKey:@"title"] == nil) {
		[temp setObject:@"收藏的title不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempFav setObject:[fav objectForKey:@"title"] forKey:@"title"];
	}
	
	if ([fav objectForKey:@"description"] != nil) {
		[tempFav setObject:[fav objectForKey:@"description"] forKey:@"description"];
	}
	
	if ([fav objectForKey:@"tag_list"] != nil) {
		[tempFav setObject:[fav objectForKey:@"tag_list"] forKey:@"tag_list"];
	}

	
	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/user_favorites/update"
															u:username
															p:password
													   params:tempFav
						];
	
	
	if ([result hasPrefix:@"error"]) {
		[temp setObject:result forKey:@"error"];
	}else {
		temp = [result JSONValue];
	}
	return temp;
	
}

-(BOOL)deleteFavorite:(NSInteger)fav_id
{
	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/user_favorites/destroy"
															u:username
															p:password
													   params:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",fav_id],@"id",nil]
						];
	
	//NSLog(@"error:%@",result);
	return [result hasPrefix:@"error"] ? NO : YES;
}


#pragma mark -
#pragma mark Messages methods
-(NSMutableArray *)messages:(NSInteger)m_id page:(NSInteger)m_page
{
	
	NSMutableArray *temp=[NSMutableArray arrayWithCapacity:10];
	
	NSMutableDictionary *tempDic=[NSMutableDictionary dictionaryWithCapacity:2];  
	[tempDic setObject:[NSString stringWithFormat:@"%d",m_id] forKey:@"last_id"];
	[tempDic setObject:[NSString stringWithFormat:@"%d",m_page] forKey:@"page"];
	
	
	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/messages/inbox"
															u:username
															p:password
													   params:tempDic
						];
	
	//NSLog(@"m:%@",result);
	
	if ([result hasPrefix:@"error"]) {
		return temp;
	}else {
		temp = [result JSONValue];
	}
	return temp;
}

-(NSMutableDictionary *)createMessage:(NSDictionary *)message
{	
	NSMutableDictionary *temp=[NSMutableDictionary dictionaryWithCapacity:10];  
	NSMutableDictionary *tempMsg=[NSMutableDictionary dictionaryWithCapacity:10];  
	
	
	if ([message objectForKey:@"title"] == nil) {
		[temp setObject:@"标题不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempMsg setObject:[message objectForKey:@"title"] forKey:@"title"];
	}
	
	if ([message objectForKey:@"body"] == nil) {
		[temp setObject:@"内容不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempMsg setObject:[message objectForKey:@"body"] forKey:@"body"];
	}
	
	if ([message objectForKey:@"receiver_name"] == nil) {
		[temp setObject:@"收件人用户名不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempMsg setObject:[message objectForKey:@"receiver_name"] forKey:@"receiver_name"];
	}
	
	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/messages/create"
															u:username
															p:password
													   params:tempMsg
						];
	
	if ([result hasPrefix:@"error"]) {
		[temp setObject:result forKey:@"error"];
	}else {
		temp = [result JSONValue];
	}
	return temp;
}

-(NSMutableDictionary *)replyMessages:(NSInteger)r_id message:(NSDictionary *)r_message
{
	
	NSMutableDictionary *temp=[NSMutableDictionary dictionaryWithCapacity:10];  
	NSMutableDictionary *tempMsg=[NSMutableDictionary dictionaryWithCapacity:10];  
	
	
	if ([r_message objectForKey:@"title"] == nil) {
		[temp setObject:@"标题不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempMsg setObject:[r_message objectForKey:@"title"] forKey:@"title"];
	}
	
	if ([r_message objectForKey:@"body"] == nil) {
		[temp setObject:@"内容不能为空!" forKey:@"error"];
		return temp;
	}else {
		[tempMsg setObject:[r_message objectForKey:@"body"] forKey:@"body"];
	}
	[tempMsg setObject:[NSString stringWithFormat:@"%d",r_id] forKey:@"id"];

	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/messages/reply"
															u:username
															p:password
													   params:tempMsg
						];
	
	if ([result hasPrefix:@"error"]) {
		[temp setObject:result forKey:@"error"];
	}else {
		temp = [result JSONValue];
	}
	return temp;
	
}

-(BOOL)deleteMessage:(NSInteger)m_id
{
	
	NSString *result = [BaseAuthenicationHttpClient doRequest:@"http://api.iteye.com/api/messages/destroy"
															u:username
															p:password
													   params:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",m_id],@"id",nil]
						];
	
	
	return [result hasPrefix:@"error"] ? NO : YES;
}

@end
