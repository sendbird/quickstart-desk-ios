//
//  SBDSKIncomingInquireCloseTicketMessageTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 5/24/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>
#import "SBDSKMessageCellDelegate.h"

@interface SBDSKIncomingInquireCloseTicketMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) id<SBDSKMessageCellDelegate> delegate;

@property (atomic, readonly) CGFloat cellHeight;
@property (strong) NSString *inquireStatus;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setModel:(SBDUserMessage *)model;
- (void)setInquireStatus:(NSString *)status;

@end
