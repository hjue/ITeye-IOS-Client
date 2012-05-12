//
//  XmlParser.h
//  JavaEye
//
//  Created by ieliwb on 10-6-8.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XmlParser : NSObject {

}

+ (NSMutableArray *) parseNews: (NSString*)xmlString;
+ (NSMutableArray *) xml2array: (NSString *)Url;


@end
