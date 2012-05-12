//
//  News.h
//  JavaEye
//
//  Created by ieliwb on 10-6-5.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject {
	
	NSInteger news_id;
	NSString  *title;
	NSString  *description;
	NSString  *link;
	NSString  *pubDate;
	BOOL      is_read;
	NSInteger category;

}

@property(nonatomic,assign) NSInteger news_id;
@property(nonatomic,assign) NSString  *title;
@property(nonatomic,assign) NSString  *description;
@property(nonatomic,assign) NSString  *link;
@property(nonatomic,assign) NSString  *pubDate;
@property(nonatomic,assign) BOOL      is_read;
@property(nonatomic,assign) NSInteger category;

@end