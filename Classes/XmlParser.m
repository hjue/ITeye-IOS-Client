//
//  XmlParser.m
//  JavaEye
//
//  Created by ieliwb on 10-6-8.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "XmlParser.h"
#import "TouchXML.h"

@implementation XmlParser


#pragma mark -
#pragma mark parseNews methods
+ (NSMutableArray*) parseNews: (NSString*)xmlString
{
	if(0 == [xmlString length])
		return nil;

	NSMutableArray *res = [[[NSMutableArray alloc] init] autorelease];
	CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString: xmlString options: 0 error: nil];
	NSArray *nodes = NULL;

	nodes = [doc nodesForXPath:@"//item" error:nil];
	
	for (CXMLElement *node in nodes) {
		NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
		int counter;
		for(counter = 0; counter < [node childCount]; counter++) {
			[item setObject:[[node childAtIndex:counter] stringValue] forKey:[[node childAtIndex:counter] name]];
		}
		[res addObject:item];
		[item release];
	}
	
	//NSLog(@"%@", res);
	
	[doc release];
	return res;
}

#pragma mark -
+ (NSMutableArray *)xml2array:(NSString *)Url
{
	NSError *error;
	NSURLResponse *response;
	NSData *dataReply;
	NSString *stringReply;
	
	NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:Url]];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"Mozilla/5.0" forHTTPHeaderField:@"User-Agent"];
	
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

	if(dataReply==nil&&error!=nil)
	{
		return nil;
	}
	else
	{
		NSMutableArray *result = [NSMutableArray arrayWithCapacity:10];
		stringReply = [[NSString alloc]initWithData:dataReply encoding:NSUTF8StringEncoding];
		[result addObjectsFromArray:[XmlParser parseNews:stringReply]];
		[stringReply release];		
		return result;
	}
	
}

@end
