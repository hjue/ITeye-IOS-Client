//
//  SQLiteDB.m
//  fit_mbcreater
//
//  Created by Feng Huajun on 07-9-19.
//  Edit By ieliwb on 10-06-02
//  Copyright 2007 Feng Huajun. All rights reserved.
//

#import "SQLiteDB.h"
#import <stdlib.h>
#import "Common.h"
#ifdef IPHONE
#import <openssl/md5.h>
#endif

@implementation SQLiteDB

-(id) initWithPath: (NSString*)path
{
	[self createEditableCopyOfDatabaseIfNeeded:path];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *_path = [documentsDirectory stringByAppendingPathComponent:path];
    // Open the database. The database was prepared outside the application.
	
	self = [super init];
	if (self != nil) {
		int err = sqlite3_open([_path UTF8String], &db);
		if (err) {
			NSLog(@"can not open database:%@",_path);
			exit(1);
		}
	}
	return self;
}

- (void)createEditableCopyOfDatabaseIfNeeded:(NSString*)path {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:path];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

-(NSString* ) md5:(NSString *) str
{
#ifdef IPHONE
	return str;
#else
	/*
	NSData *toHash = [str dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char* digest = MD5([toHash bytes], [toHash length], NULL);
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0], digest[1], 
				   digest[2], digest[3],
				   digest[4], digest[5],
				   digest[6], digest[7],
				   digest[8], digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
	return s;
	 */
	return str;
#endif
}

-(void) enableQueryCache
{
	if(!queryCache){
		queryCacheRowNum = 1000;
		queryCache = [[NSMutableDictionary alloc] init];
	}
}

-(NSMutableArray*) query: (NSString *)sql
{
	NSString* key = nil;
	if(queryCache){
		key = [self md5:sql];
		NSMutableArray* cacheRows = [queryCache objectForKey:key];
		if(cacheRows) {
			//NSLog(@"cache hitted");
			return cacheRows;
		}
	}
	//NSLog(@"query: %@",sql);
	char* errMsg;
	char **result;
	int nrow,ncol;
	int err = sqlite3_get_table(db,[sql UTF8String],&result,&nrow,&ncol,&errMsg);
	if( err != SQLITE_OK ){
		NSLog(@"query sql error! sql:%@ message:%s", sql, errMsg);
		exit(1);		
	}
	
	NSMutableArray* rows = [[NSMutableArray alloc] initWithCapacity:nrow];
	[rows autorelease];
	
	
	
	if(nrow != 0) {
		
		NSMutableArray* colNames = [[NSMutableArray alloc] initWithCapacity: ncol];
		
		int idx = 0;
		int i,j;
		
		for(i = 0; i < ncol; i++){
			NSString* s = [[NSString alloc] initWithUTF8String:result[i]];
			[colNames addObject:s];
			[s release];
		}
		
		for(i = 0; i < nrow; i++ ) {
			NSMutableDictionary* cols = [[NSMutableDictionary alloc] initWithCapacity: ncol];
			for(j=0;j<ncol;j++){
				idx = (i+1)*ncol + j;
				//printf("s=%s\n",result[idx]);
				if(result[idx]){
					NSString* s = [[NSString alloc] initWithUTF8String:result[idx]];
					[cols setObject:s forKey:[colNames objectAtIndex:j]];
					[s release];
				}else{
					[cols setObject:@"" forKey:[colNames objectAtIndex:j]];
				}
			}
			[rows addObject:cols];
			[cols release];
		}
		[colNames release];
	}
	
	sqlite3_free_table(result);
	
	if(queryCache){
		if([queryCache count] > queryCacheRowNum){
			[queryCache release];
			queryCache = [[NSMutableDictionary alloc] init];
		}
		[queryCache setObject:rows forKey:key];
	}
	
	return rows;
}

-(void) execute: (NSString *)sql
{
	char* errMsg;
	int err = sqlite3_exec(db,[sql UTF8String], NULL, 0, &errMsg);
	if(err!=SQLITE_OK){
        NSLog(@"excute sql error! sql:%@ message:%s", sql, errMsg);
        exit(1);
	}
}

// execute a sql query by stmt way
-(void) stmt_execute: (NSString *)sql, ...
{
	NSMutableArray* argTypes = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray* argValues = [NSMutableArray arrayWithCapacity:10];
	NSInteger argCount = 0;
	va_list args;
	va_start(args, sql);
	
	// to support %d, %s in the sql
	NSMutableString* _sql = [NSMutableString stringWithCapacity:80];
	[_sql appendString:sql];
	NSInteger cursor = 0;
	while (true) {
		NSRange searchRange = NSMakeRange(cursor, [_sql length]-cursor);
		NSInteger index = [_sql rangeOfString:@"%" options:NSCaseInsensitiveSearch range:searchRange].location;
		if(index != NSNotFound){
			NSString* type = [_sql substringWithRange:NSMakeRange(index+1, 1)];// get the type of the stmt param, now d or s can be used
			if ([type isEqualToString:@"d"]) { // this param is an integer
				NSInteger arg = va_arg(args, NSInteger);
				[argTypes addObject:@"d"];
				[argValues addObject:[NSNumber numberWithInt:arg]];
			}else if ([type isEqualToString:@"s"]) { // this param is an integer
				id arg = va_arg(args, id);
				[argTypes addObject:@"s"];
				[argValues addObject:[NSString stringWithFormat:@"%@", arg]];
			}else {
				cursor ++;
				continue;
			}
			argCount ++;
			cursor = index;
			[_sql replaceCharactersInRange:NSMakeRange(index, 2) withString:@"?"]; // replace the %d, %s to the stmt ?
		}else{
			break;
		}
	}
	va_end(args);
	
	sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(db, [_sql UTF8String], -1, &stmt, nil) != SQLITE_OK){
		sqlite3_finalize(stmt);
		return;
	}else{
		for(NSInteger i=0; i<argCount; i++){
			NSString* type = [argTypes objectAtIndex:i];
			if ([type isEqualToString:@"d"]) {
				sqlite3_bind_int(stmt, i+1, [[argValues objectAtIndex:i] intValue]);
			}else if ([type isEqualToString:@"s"]) {
				sqlite3_bind_text(stmt, i+1, [[argValues objectAtIndex:i] UTF8String], -1, NULL);
			}
		}
		if(sqlite3_step(stmt) != SQLITE_DONE){
			NSLog(@"Error occured while executing sql");
			exit(1);
		}
		sqlite3_finalize(stmt);
	}
}


-(int) last_insert_id
{
	return sqlite3_last_insert_rowid(db);
}

- (void) dealloc
{
	if(queryCache) [queryCache release];
	sqlite3_close(db);
	[super dealloc];
}

-(void) beginTrans
{
	[self execute:@"BEGIN TRANSACTION;"];
}

-(void) endTrans
{
	[self execute:@"COMMIT;"];
}



@end