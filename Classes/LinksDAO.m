//
//  LinksDAO.m
//  JavaEye
//
//  Created by ieliwb on 10-6-2.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "LinksDAO.h"

@implementation LinksDAO

- (void) add :    (id) links
{
	NSMutableDictionary *theLinks = (NSMutableDictionary*)links;
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];

	NSString* sql = @"INSERT INTO links\
			(id,url,title,description,cached_tag_list,public,created_at)\
			VALUES (%d, %s, %s, %s, %s, %d, %s) ";
	[sqlitedb stmt_execute:sql, 
			[[theLinks objectForKey:@"id"] intValue],
			[theLinks objectForKey:@"url"],
			[theLinks objectForKey:@"title"],
			[theLinks objectForKey:@"description"],
			[theLinks objectForKey:@"cached_tag_list"],
			[[theLinks objectForKey:@"public"] intValue],
			[theLinks objectForKey:@"created_at"]
	 ];
	[sqlitedb release];
}

- (void) update : (id) links
{
	NSMutableDictionary *theLinks = (NSMutableDictionary*)links;
	NSString *sql = @"UPDATE links SET \
						url = %s ,\
						title = %s,\
						description = %s,\
						cached_tag_list = %s,\
						public = %d ,\
						created_at = %s,\
					 WHERE id = %d ";
	
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	[sqlitedb stmt_execute:sql,
					 [theLinks objectForKey:@"url"],
					 [theLinks objectForKey:@"title"],
					 [theLinks objectForKey:@"description"],
					 [theLinks objectForKey:@"cached_tag_list"],
					 [[theLinks objectForKey:@"public"] intValue],
					 [theLinks objectForKey:@"created_at"],
					 [[theLinks objectForKey:@"id"] intValue]
	 ];
	[sqlitedb release];	
}

- (void) delete : (int) links_id
{
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM links WHERE id = %d ",links_id];
	
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	[sqlitedb execute:sql];
	[sqlitedb release];
}

- (void) empty
{
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM links"];
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	[sqlitedb execute:sql];
	[sqlitedb release];	
}

- (NSMutableArray *) getAll
{
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM links ORDER BY id DESC"];
	
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	NSMutableArray *result = [sqlitedb query:sql];
	[sqlitedb release];
	
	return result;
}


@end
