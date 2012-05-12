//
//  BaseAuthenicationHttpClient.m
//  JavaEye
//
//  Created by ieliwb on 10-6-7.
//  http://stackoverflow.com/questions/471898/google-app-engine-with-clientlogin-interface-for-objective-c
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "BaseAuthenicationHttpClient.h"
#import "GTMBase64.h"

@implementation BaseAuthenicationHttpClient

+ (NSString *)doRequest:(NSString *)theUrl u:(NSString *)username p:(NSString *)password params:(NSMutableDictionary *)theParams{
	
	NSString *loginString = [NSString stringWithFormat:@"%@:%@", username, password];
	NSString *authHeader = [NSString stringWithFormat:@"Basic %@", [GTMBase64 stringByEncodingData:[NSData dataWithBytes:[loginString UTF8String] length:strlen([loginString UTF8String]) ]]];

	//NSLog(@"login:%@ header:%@",loginString,authHeader);
	//authHeader = @"6Iqx5aSq6aaZ6b2QOmIwMDVmNzM5";
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:theUrl]];
	[request setTimeoutInterval:3.0];
	[request setHTTPMethod:@"POST"];
	[request setValue:authHeader forHTTPHeaderField:@"Authorization"];  
	[request setValue:@"Mozilla/5.0" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];

	if (theParams != nil) {
		NSMutableString *post_fields = [NSMutableString stringWithCapacity:40];
		
		NSArray *keyArr=[theParams allKeys]; 

		for(NSString *kk in keyArr){  
			[post_fields appendFormat:@"&%@=%@",kk,[theParams objectForKey:kk]];  
		}
		NSLog(@"post:%@\n",post_fields);

		[request setHTTPBody:[post_fields dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
	}
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];    
	NSString *result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	[request release];

	return result;
}

@end
