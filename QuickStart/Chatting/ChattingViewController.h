//
//  ChattingViewController.h
//  QuickStart
//
//  Created by SendBird on 3/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TOCropViewController/TOCropViewController.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>
#import <Photos/Photos.h>
#import <UserNotifications/UserNotifications.h>
#import <HTMLKit/HTMLKit.h>
#import <AFNetworking/AFNetworking.h>
#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import <SendBirdDesk/SendBirdDesk.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "DeskViewControllerDelegate.h"
#import "SBDSKMessageCellDelegate.h"

@interface ChattingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, SBDConnectionDelegate, SBDChannelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SBDSKMessageCellDelegate, DeskViewControllerDelegate, TOCropViewControllerDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic) UIViewController *previousViewController;

@property (weak, nonatomic) id<DeskViewControllerDelegate> delegate;

@property (strong, nonatomic) SBDSKTicket *ticket;

- (void)openChatWithChannelUrl:(NSString *)channelUrl;

@end
