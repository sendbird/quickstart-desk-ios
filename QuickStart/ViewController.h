//
//  ViewController.h
//  QuickStart
//
//  Created by SendBird on 3/19/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

#import "InboxViewController.h"

@interface ViewController : UIViewController

- (void)openChatWithChannelUrl:(NSString *)channelUrl;

@end

