//
//  Messages.h
//  JavaEye
//
//  Created by ieliwb on 10-6-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Messages : NSObject {
	
	NSInteger messages_id;
	NSString  *title;
	NSString  *plain_body;
	NSString  *created_at;
	BOOL	  system_notice;
	BOOL      has_read;
	BOOL      attach;
	NSString  *sender_name;
	NSString  *sender_logo;
	NSString  *sender_domain;
}

@property(nonatomic,assign) NSInteger messages_id;
@property(nonatomic,assign) NSString  *title;
@property(nonatomic,assign) NSString  *plain_body;
@property(nonatomic,assign) NSString  *created_at;
@property(nonatomic,assign) BOOL	  system_notice;
@property(nonatomic,assign) BOOL      has_read;
@property(nonatomic,assign) BOOL      attach;
@property(nonatomic,assign) NSString  *sender_name;
@property(nonatomic,assign) NSString  *sender_logo;
@property(nonatomic,assign) NSString  *sender_domain;

@end
