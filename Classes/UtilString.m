//
//  UtilString.m
//  JavaEye
//
//  Created by ieliwb on 10-6-8.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import "UtilString.h"

@implementation NSMutableString (HtmlEntities)

- (NSMutableString *)htmlSimpleUnescape
{
    [self replaceOccurrencesOfString:@"&amp;"  withString:@"&"  options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&#x27;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&#x39;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&#x92;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&#x96;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&gt;"   withString:@">"  options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&lt;"   withString:@"<"  options:NSLiteralSearch range:NSMakeRange(0, [self length])];
	
    return self;
}

- (NSMutableString *)htmlSimpleEscape
{
    [self replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [self length])];
	
    return self;
}

@end


@implementation NSString (UtilString)

- (NSString *)thumb
{
	NSInteger len = self.length;
	
	NSString *ext = [self substringFromIndex:(len -4)];	
	if ([ext isEqualToString:@".jpg"] || [ext isEqualToString:@".png"]) {
		return [NSString stringWithFormat:@"http://www.javaeye.com%@-thumb%@",[self substringToIndex:(len-4)],ext];
	}
	return nil;
}

- (NSString *)shortDate
{
	//  2010/06/28 13:50:34 +0800
	if (self.length > 16) {
		return [self substringToIndex:16];
	}
	return self;
}


- (NSString *)htmlSimpleUnescapeString
{
    NSMutableString *unescapeStr = [NSMutableString stringWithString:self];
    return [unescapeStr htmlSimpleUnescape];
}

- (NSString *)htmlSimpleEscapeString
{
    NSMutableString *escapeStr = [NSMutableString stringWithString:self];
    return [escapeStr htmlSimpleEscape];
}

@end
