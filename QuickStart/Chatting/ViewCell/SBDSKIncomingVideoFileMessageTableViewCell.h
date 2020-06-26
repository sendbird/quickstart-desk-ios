//
//  SBDSKIncomingVideoFileMessageTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 7/10/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

#import "SBDSKMessageCellDelegate.h"

@interface SBDSKIncomingVideoFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic) id<SBDSKMessageCellDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setNextMessage:(SBDBaseMessage *)aNextMessage;
- (void)setModel:(SBDFileMessage *)model;

@end
