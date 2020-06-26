//
//  SBDSKIncomingUrlPreviewTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 7/19/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

@protocol SBDSKMessageCellDelegate;

@interface SBDSKIncomingUrlPreviewTableViewCell : UITableViewCell<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *urlPreviewThumbnailImageView;

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic) id<SBDSKMessageCellDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setNextMessage:(SBDBaseMessage *)aNextMessage;
- (void)setModel:(SBDUserMessage *)model;

@end
