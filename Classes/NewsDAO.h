//
//  NewsDAO.h
//  JavaEye
//
//  Created by ieliwb on 10-6-5.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"
#import "SQLiteDB.h"

@interface NewsDAO : NSObject {
	
}

- (void) add :(id) news cat:(int)category;
- (void) update : (id) news;
- (void) empty:(int)category;
- (NSMutableArray *) getAll : (int)category;
- (NSMutableString *)getOne: (int)news_id;

@end
