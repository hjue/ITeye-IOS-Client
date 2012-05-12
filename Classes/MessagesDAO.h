//
//  MessagesDAO.h
//  JavaEye
//
//  Created by ieliwb on 10-6-3.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"
#import "SQLiteDB.h"

@interface MessagesDAO : NSObject {
	
}

- (void) add :    (id) messages;
- (void) delete : (int) messages_id;
- (NSMutableArray *) getAll;

@end