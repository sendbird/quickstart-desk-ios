//
//  SBDSKIncomingImageFileMessageTableViewCell.h
//  QuickStart
//
//  Created by Jebeom Gyeong on 24/04/2017.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

#import "SBDSKMessageCellDelegate.h"

@interface SBDSKIncomingImageFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingActivityIndicator;

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic) id<SBDSKMessageCellDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setNextMessage:(SBDBaseMessage *)aNextMessage;
- (void)setModel:(SBDFileMessage *)model;

@end
