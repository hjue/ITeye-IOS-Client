//
//  AddChatController.h
//  JavaEye
//
//  Created by ieliwb on 10-6-6.
//  Copyright 2010 ieliwb.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h> 
#import <CoreLocation/CLLocationManagerDelegate.h> 

@interface AddChatController : UIViewController<UITextViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate> {
	NSString *chatBody;
	CLLocationManager *locmanager;
}

@property (nonatomic, retain) NSString *chatBody;
@property (nonatomic, retain) CLLocationManager *locmanager;



- (id)initWithChatBody:(NSString *)theChatBody;

- (void)sendAction:(id)sender;

-(void)setReplyChatBody:(NSString *)cc;

@end
