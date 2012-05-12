//
//  SQLiteDB.h
//  fit_mbcreater
//
//  Created by Feng Huajun on 07-9-19.
//  Edit By ieliwb on 10-06-02
//  Copyright 2007 Feng Huajun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#ifdef IPHONE
#import <openssl/md5.h>
#endif

@interface SQLiteDB : NSObject {
	
	sqlite3* db;
	NSMutableDictionary* queryCache;
	int queryCacheRowNum;
	
}

-(NSString* ) md5:(NSString *) str;
-(id) initWithPath: (NSString*)path;
- (void)createEditableCopyOfDatabaseIfNeeded:(NSString*)path;
-(void) enableQueryCache;
-(NSMutableArray*) query: (NSString *)sql;
-(void) execute: (NSString *)sql;
-(void) stmt_execute: (NSString *)sql, ...;
-(int) last_insert_id;
-(void) beginTrans;
-(void) endTrans;

@end