//
//  SBDSKOutgoingUrlPreviewTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 7/18/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

#import "SBDSKMessageCellDelegate.h"

@interface SBDSKOutgoingUrlPreviewTableViewCell : UITableViewCell<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *urlPreviewThumbnailImageView;

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic) id<SBDSKMessageCellDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setModel:(SBDBaseMessage *)model;
- (void)showSendingStatus;
- (void)setSentMessage;
- (void)showMessageControlButton;

@end
