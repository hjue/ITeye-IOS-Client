//
//  BaseAuthenicationHttpClient.h
//  JavaEye
//
//  Created by ieliwb on 10-6-7.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaseAuthenicationHttpClient : NSObject {

}
+ (NSString *)doRequest:(NSString *)theUrl u:(NSString *)username p:(NSString *)password params:(NSMutableDictionary *)theParams;

@end
