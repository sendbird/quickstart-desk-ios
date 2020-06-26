//
//  SBDSKOutgoingImageFileMessageTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 4/25/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

#import "SBDSKMessageCellDelegate.h"
#import "FLAnimatedImageView+ImageCache.h"

@interface SBDSKOutgoingImageFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic, nullable) IBOutlet FLAnimatedImageView *fileImageView;
@property (weak, nonatomic, nullable) IBOutlet UIActivityIndicatorView *imageLoadingActivityIndicator;

@property (atomic, readonly) CGFloat cellHeight;
@property (weak, nonatomic, nullable) id<SBDSKMessageCellDelegate> delegate;
@property (atomic) BOOL hasImageCacheData;

+ (nullable UINib *)nib;
+ (nullable NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage * _Nullable)aPrevMessage;
- (void)setModel:(SBDFileMessage * _Nonnull)model;
- (void)showSendingStatus;
- (void)setSentMessage;
- (void)showMessageControlButton;
- (void)setImageData:(NSData * _Nonnull)imageData type:(NSString * _Nullable)type;

@end
