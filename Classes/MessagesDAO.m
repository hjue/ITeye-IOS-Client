//
//  MessagesDAO.m
//  JavaEye
//
//  Created by ieliwb on 10-6-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "MessagesDAO.h"

@implementation MessagesDAO

- (void)add: (id)messages
{
	NSMutableDictionary *theMessages = (NSMutableDictionary*)messages;
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	
	NSString *sql = @"INSERT INTO messages\
					 (id,title,plain_body,created_at,system_notice,has_read,attach,sender_name,sender_logo,sender_domain)\
					 VALUES (%d,%s,%s,%s,%d,%d,%d,%s,%s,%s) ";
	[sqlitedb stmt_execute:sql,
					 [[theMessages objectForKey:@"id"] intValue],
					 [theMessages objectForKey:@"title"],
					 [theMessages objectForKey:@"plain_body"],
					 [theMessages objectForKey:@"created_at"],
					 [[theMessages objectForKey:@"system_notice"] intValue],
					 [[theMessages objectForKey:@"has_read"] intValue],
					 [[theMessages objectForKey:@"attach"] intValue],
					 [[theMessages objectForKey:@"sender"] objectForKey:@"name"],
					 [[theMessages objectForKey:@"sender"] objectForKey:@"logo"],
					 [[theMessages objectForKey:@"sender"] objectForKey:@"domain"]
	 ];
	 
	[sqlitedb release];
}

- (void) delete : (int) messages_id
{
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM messages WHERE id = %d ",messages_id];
	//NSLog(@"sql:%@",sql);
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	[sqlitedb execute:sql];
	[sqlitedb release];
}

- (NSMutableArray *) getAll
{
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM messages ORDER BY id DESC"];
	
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	NSMutableArray *result = [sqlitedb query:sql];
	[sqlitedb release];
	
	return result;
}

@end
