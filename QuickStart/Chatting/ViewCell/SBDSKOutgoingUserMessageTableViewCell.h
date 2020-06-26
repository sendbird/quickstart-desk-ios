//
//  SBDSKOutgoingUserMessageTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 4/24/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

#import "SBDSKMessageCellDelegate.h"

@interface SBDSKOutgoingUserMessageTableViewCell : UITableViewCell<UITextViewDelegate>

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic) id<SBDSKMessageCellDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setModel:(SBDUserMessage *)model;
- (void)showSendingStatus;
- (void)setSentMessage;
- (void)showMessageControlButton;

@end
