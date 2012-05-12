//
//  ChatDAO.m
//  JavaEye
//
//  Created by ieliwb on 10-6-1.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "ChatDAO.h"
#import "UtilString.h"

@implementation ChatDAO

- (void) add: (id) chat t:(int)type
{
	NSMutableDictionary *theChat = (NSMutableDictionary*)chat;
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];

	NSString *sql = @"INSERT INTO chat\
					(id,created_at,body,user_name,user_logo,user_domain,receiver_name,receiver_logo,receiver_domain,reply_to_id,via,type)\
					VALUES (%d,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%d) ";
	[sqlitedb stmt_execute:sql,
					 [[theChat objectForKey:@"id"] intValue],
					 [theChat objectForKey:@"created_at"],
					 [[theChat objectForKey:@"body"] htmlSimpleEscapeString],
					 [[theChat objectForKey:@"user"] objectForKey:@"name"],
					 [[theChat objectForKey:@"user"] objectForKey:@"logo"],
					 [[theChat objectForKey:@"user"] objectForKey:@"domain"],
					 [[theChat objectForKey:@"receiver"] objectForKey:@"name"],
					 [[theChat objectForKey:@"receiver"] objectForKey:@"logo"],
					 [[theChat objectForKey:@"receiver"] objectForKey:@"domain"],
					 [theChat objectForKey:@"reply_to_id"],
					 [theChat objectForKey:@"via"],
					 type
	 ];
	[sqlitedb release];
}

- (void) delete : (int) chat_id
{
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM chat WHERE id = %d ",chat_id];
	
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	[sqlitedb execute:sql];
	[sqlitedb release];
}

//只保留最新的30条
- (void) empty: (int)type
{
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	NSMutableArray *result = [sqlitedb query:[NSString stringWithFormat:@"SELECT created_at FROM chat WHERE type=%d ORDER BY created_at DESC LIMIT 30,1",type]];
		
	if ([result count] > 0) {
		[sqlitedb execute:[NSString stringWithFormat:@"DELETE FROM chat WHERE type=%d AND created_at < '%@'",type,[[result objectAtIndex:0] objectForKey:@"created_at"] ]];
	}
	[sqlitedb release];	
}

- (NSMutableArray *) getAll: (int)type
{
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM chat WHERE type=%d ORDER BY created_at DESC LIMIT 30",type];
	
	SQLiteDB *sqlitedb = [[SQLiteDB alloc] initWithPath:JAVAEYE_DB_NAME];
	NSMutableArray *result = [sqlitedb query:sql];
	[sqlitedb release];
	
	return result;
}

@end
