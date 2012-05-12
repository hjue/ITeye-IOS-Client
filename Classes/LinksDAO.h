//
//  LinksDAO.h
//  JavaEye
//
//  Created by ieliwb on 10-6-2.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"
#import "SQLiteDB.h"

@interface LinksDAO : NSObject {
	
}

- (void) add :    (id) links;
- (void) update : (id) links;
- (void) delete : (int) links_id;
- (void) empty;
- (NSMutableArray *) getAll;

@end
