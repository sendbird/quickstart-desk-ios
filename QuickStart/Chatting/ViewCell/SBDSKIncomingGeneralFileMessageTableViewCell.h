//
//  SBDSKIncomingGeneralFileMessageTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 5/24/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

#import "SBDSKMessageCellDelegate.h"

@interface SBDSKIncomingGeneralFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic) id<SBDSKMessageCellDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setNextMessage:(SBDBaseMessage *)aNextMessage;
- (void)setModel:(SBDFileMessage *)model;
- (void)setFileDownloadingStatus:(int)downloadingStatus;
- (void)setDownloadingProgress:(float)progress;

@end
