//
//  SBDSKOutgoingGeneralFileMessageTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 5/23/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

#import "SBDSKMessageCellDelegate.h"

@interface SBDSKOutgoingGeneralFileMessageTableViewCell : UITableViewCell

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic) id<SBDSKMessageCellDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setModel:(SBDFileMessage *)model;
- (void)showSendingStatus;
- (void)setSentMessage;
- (void)showMessageControlButton;
- (void)setFileDownloadingStatus:(int)downloadingStatus;
- (void)setDownloadingProgress:(float)progress;

@end
