//
//  SBDSKIncomingUserMessageTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 4/24/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

#import "SBDSKMessageCellDelegate.h"

@interface SBDSKIncomingUserMessageTableViewCell : UITableViewCell<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic) id<SBDSKMessageCellDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setNextMessage:(SBDBaseMessage *)aNextMessage;
- (void)setModel:(SBDUserMessage *)model;

@end
