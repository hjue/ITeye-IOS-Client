//
//  ChatDAO.h
//  JavaEye
//
//  Created by ieliwb on 10-6-1.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"
#import "SQLiteDB.h"

@interface ChatDAO : NSObject {

}

- (void) add : (id) chat t:(int)type;
- (void) delete : (int) chat_id;
- (void) empty: (int)type;
- (NSMutableArray *) getAll:(int)type;

@end
