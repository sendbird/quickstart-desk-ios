//
//  SBDSKOutgoingVideoFileMessageTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 7/10/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

#import "SBDSKMessageCellDelegate.h"

@interface SBDSKOutgoingVideoFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic, nullable) IBOutlet UIImageView *fileImageView;

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic, nullable) id<SBDSKMessageCellDelegate> delegate;

+ (nullable UINib *)nib;
+ (nullable NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage * _Nullable)aPrevMessage;
- (void)setModel:(SBDFileMessage * _Nonnull)model;
- (void)showSendingStatus;
- (void)setSentMessage;
- (void)showMessageControlButton;

@end
