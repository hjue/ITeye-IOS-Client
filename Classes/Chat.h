//
//  Chat.h
//  JavaEye
//
//  Created by ieliwb on 10-6-1.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chat : NSObject {
	
	NSInteger chat_id;
	NSString  *created_at;
	NSString  *body;
	NSString  *user_name;
	NSString  *user_logo;
	NSString  *user_domain;
	NSString  *receiver_name;
	NSString  *receiver_logo;
	NSString  *receiver_domain;
	NSInteger reply_to_id;
	NSString  *via;
	
}

@property(nonatomic,assign) NSInteger chat_id;
@property(nonatomic,assign) NSString  *created_at;
@property(nonatomic,assign) NSString  *body;
@property(nonatomic,assign) NSString  *user_name;
@property(nonatomic,assign) NSString  *user_logo;
@property(nonatomic,assign) NSString  *user_domain;
@property(nonatomic,assign) NSString  *receiver_name;
@property(nonatomic,assign) NSString  *receiver_logo;
@property(nonatomic,assign) NSString  *receiver_domain;
@property(nonatomic,assign) NSInteger reply_to_id;
@property(nonatomic,assign) NSString  *via;


@end
