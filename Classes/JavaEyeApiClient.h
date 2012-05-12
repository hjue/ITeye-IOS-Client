//
//  JavaEyeApiClient.h
//  JavaEye
//
//  Created by ieliwb on 10-6-7.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JavaEyeApiClient : NSObject {
	NSString *username;
	NSString *password;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;


-(NSMutableDictionary *)verify:(NSString *)ck_username p:(NSString *)ck_password;

-(NSMutableArray *)twitters:(NSString *)type last_id:(NSInteger)t_id page:(NSInteger)t_page;
-(NSMutableDictionary *)createTwitter:(NSDictionary *)chat;
-(BOOL)deleteTwitter:(NSInteger)t_id;
-(NSMutableDictionary *)showTwitter:(NSString *)t_ids;

-(NSMutableArray *)favorites;
-(NSMutableDictionary *)createFavorite:(NSDictionary *)fav;
-(NSMutableDictionary *)updateFavorite:(NSDictionary *)fav;
-(BOOL)deleteFavorite:(NSInteger)fav_id;

-(NSMutableArray *)messages:(NSInteger)m_id page:(NSInteger)m_page;
-(NSMutableDictionary *)createMessage:(NSDictionary *)message;
-(NSMutableDictionary *)replyMessages:(NSInteger)r_id message:(NSDictionary *)r_message;
-(BOOL)deleteMessage:(NSInteger)m_id;

@end