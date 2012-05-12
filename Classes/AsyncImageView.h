//
//  AsyncImageView.h
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


//
// Code heavily lifted from here:
// http://www.markj.net/iphone-asynchronous-table-image/
//
/**
 @brief 异步图片下载并显示
 
 
 */

#import <UIKit/UIKit.h>


@interface AsyncImageView : UIView {
    NSURLConnection *connection;
    NSMutableData *data;
   //! key for image cache dictionary
	NSString *urlString; 
}

-(void)loadImageFromURL:(NSURL*)url;

@end
