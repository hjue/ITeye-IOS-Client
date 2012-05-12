//
//  NewsDAO.m
//  JavaEye
//
//  Created by ieliwb on 10-6-5.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "NewsDAO.h"
#import "UtilString.h"

@implementation NewsDAO

- (void) add :(id) news cat:(int)category
{
	NSMutableDictionary *theNews = (NSMutableDictionary*)news;
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	
	NSString *sql = @"INSERT INTO news\
					 (title,description,link,pubDate,is_read,category)\
					 VALUES (%s,%s,%s,%s,0,%d) ";
	[sqlitedb stmt_execute:sql,
					 [[theNews objectForKey:@"title"] htmlSimpleEscapeString],
					 [[theNews objectForKey:@"description"] htmlSimpleEscapeString],
					 [theNews objectForKey:@"link"],
					 [theNews objectForKey:@"pubDate"],
					 category
	 ];
	[sqlitedb release];
}

- (void) update : (id) news
{
	NSMutableDictionary *theNews = (NSMutableDictionary*)news;
	NSString *sql = [NSString stringWithFormat:
					 @"UPDATE news SET \
					 is_read = %d \
					 WHERE news_id = %d ",
					 [theNews objectForKey:@"is_read"],
					 [theNews objectForKey:@"news_id"]
					 ];
	
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	[sqlitedb execute:sql];
	[sqlitedb release];	
}

- (void) empty:(int)category
{
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM news WHERE category=%d ",category];
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	[sqlitedb execute:sql];
	[sqlitedb release];	
}

- (NSMutableString *)getOne: (int)news_id
{
	NSString *sql = [NSString stringWithFormat:@"SELECT description FROM news WHERE news_id=%d ",news_id];
	
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	NSMutableArray *result = [sqlitedb query:sql];
	
	//NSLog(@"sql:%@\nrr:%@",sql,result);
	[sqlitedb release];
	
	if ([result count] > 0) {
		return [[result objectAtIndex:0] objectForKey:@"description"];
	}
	return nil;
	
}

- (NSMutableArray *) getAll : (int)category
{
	NSString *sql = [NSString stringWithFormat:@"SELECT news_id,title,pubDate,link FROM news WHERE category=%d ORDER BY news_id ASC",category];
	
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	NSMutableArray *result = [sqlitedb query:sql];
	[sqlitedb release];
	
	return result;
}

@end
