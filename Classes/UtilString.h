//
//  UtilString.h
//  JavaEye
//
//  Created by ieliwb on 10-6-8.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString(HtmlEntities)

- (NSMutableString *)htmlSimpleUnescape;
- (NSMutableString *)htmlSimpleEscape;

@end


@interface NSString(UtilString)

- (NSString *)thumb;
- (NSString *)shortDate;
- (NSString *)htmlSimpleUnescapeString;
- (NSString *)htmlSimpleEscapeString;

@end
