//
//  InboxViewController.h
//  QuickStart
//
//  Created by SendBird on 3/19/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>
#import "DeskViewControllerDelegate.h"

@interface InboxViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SBDConnectionDelegate, SBDChannelDelegate, DeskViewControllerDelegate>

@property (weak, nonatomic) id<DeskViewControllerDelegate> delegate;
@property (strong, nonatomic) UIViewController *previousViewController;
@property (strong) NSString *channelUrl;

- (void)openChatWithChannelUrl:(NSString *)channelUrl;

@end
