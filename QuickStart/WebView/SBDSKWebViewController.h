//
//  SBDSKWebViewController.h
//  QuickStart
//
//  Created by SendBird on 6/14/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

@interface SBDSKWebViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) SBDBaseMessage *message;

+ (UINib *)nib;

- (void)openChatWithChannelUrl:(NSString *)channelUrl;

@end
