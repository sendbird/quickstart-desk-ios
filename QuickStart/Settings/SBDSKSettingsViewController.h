//
//  SBDSKSettingsViewController.h
//  QuickStart
//
//  Created by SendBird on 4/27/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>
#import "DeskViewControllerDelegate.h"

@interface SBDSKSettingsViewController : UIViewController

@property (weak, nonatomic) id<DeskViewControllerDelegate> delegate;

- (void)openChatWithChannelUrl:(NSString *)channelUrl;

@end
