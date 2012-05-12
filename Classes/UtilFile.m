//
//  UtilFile.m
//  JavaEye
//
//  Created by ieliwb on 10-6-24.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "UtilFile.h"
#import "Common.h"

@implementation UtilFile


#pragma mark -
#pragma mark delete user db
+(void)deleteUserDB
{
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:JAVAEYE_DB_NAME];
	if ([fileManager fileExistsAtPath:writableDBPath]) {
		[fileManager removeItemAtPath:writableDBPath error:&error];
	}
}


@end
