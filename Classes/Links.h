//
//  Links.h
//  JavaEye
//
//  Created by ieliwb on 10-6-2.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Links : NSObject {
	
	NSInteger links_id;
	NSString  *url;
	NSString  *title;
	NSString  *description;
	NSString  *cached_tag_list;
	BOOL      public;
	NSString  *created_at;

}

@property(nonatomic,assign) NSInteger links_id;
@property(nonatomic,assign) NSString  *url;
@property(nonatomic,assign) NSString  *title;
@property(nonatomic,assign) NSString  *description;
@property(nonatomic,assign) NSString  *cached_tag_list;
@property(nonatomic,assign) BOOL      public;
@property(nonatomic,assign) NSString  *created_at;

@end
