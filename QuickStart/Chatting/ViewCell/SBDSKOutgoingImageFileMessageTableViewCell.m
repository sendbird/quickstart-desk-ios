//
//  SBDSKOutgoingImageFileMessageTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 4/25/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "SBDSKOutgoingImageFileMessageTableViewCell.h"
#import "SBDSKUtils.h"

@interface SBDSKOutgoingImageFileMessageTableViewCell()

// Views
@property (weak, nonatomic) IBOutlet UILabel *dateDividerLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *messageStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *messageDateContainerView;


//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileImageViewHeight;

@property (atomic) CGFloat cellHeight;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (strong, nonatomic) SBDBaseMessage *message;

@end

@implementation SBDSKOutgoingImageFileMessageTableViewCell

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.messageContainerView.layer.cornerRadius = 6;
    self.messageContainerView.layer.masksToBounds = NO;
    
    self.messageStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Sending" attributes:
                                              @{
                                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:14],
                                                NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#808080"],
                                                }];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)clickFileMessage {
    if (self.delegate != nil) {
        [self.delegate clickMessage:self message:self.message];
    }
}

- (void)clickResendFailedFileMessage {
    if (self.delegate != nil) {
        [self.delegate clickResendFailedMessage:self message:self.message];
    }
}

- (void)clickDeleteFiledFileMessage {
    if (self.delegate != nil) {
        [self.delegate clickDeleteFailedMessage:self message:self.message];
    }
}

- (void)setModel:(SBDFileMessage *)model {
    self.message = model;
    self.cellHeight = 0;
    
    if (self.hasImageCacheData == NO) {
        self.imageLoadingActivityIndicator.hidden = NO;
        [self.imageLoadingActivityIndicator startAnimating];
    }
    else {
        self.imageLoadingActivityIndicator.hidden = YES;
        [self.imageLoadingActivityIndicator stopAnimating];
    }

    UITapGestureRecognizer *messageContainerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFileMessage)];
    self.fileImageView.userInteractionEnabled = YES;
    [self.fileImageView addGestureRecognizer:messageContainerTapRecognizer];
    
    [self.resendButton addTarget:self action:@selector(clickResendFailedFileMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(clickDeleteFiledFileMessage) forControlEvents:UIControlEventTouchUpInside];
    
    // Date
    NSTimeInterval messageTimestamp = (double)model.createdAt / 1000.0;
    NSDate *messageCreatedDate = [NSDate dateWithTimeIntervalSince1970:messageTimestamp];
    
    // Date divider
    NSDateFormatter *seperatorDateFormatter = [[NSDateFormatter alloc] init];
    [seperatorDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSAttributedString *dateDividerAttrString = [[NSAttributedString alloc] initWithString:[seperatorDateFormatter stringFromDate:messageCreatedDate] attributes:@{
                                                                                                                                                                   NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:13],
                                                                                                                                                                   NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#8A93A6"],
                                                                                                                                                                   }];
    self.dateDividerLabel.attributedText = dateDividerAttrString;
    
    // Message Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSAttributedString *messageDateAttrString = [[NSAttributedString alloc] initWithString:[dateFormatter stringFromDate:messageCreatedDate] attributes:@{
                                                                                                                                                          NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:11],
                                                                                                                                                          NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#FFFFFF"],
                                                                                                                                                          }];
    self.messageDateLabel.attributedText = messageDateAttrString;
    
    // Default
    self.dateDividerLabel.hidden = NO;
    self.dateDividerLabelTopMargin.constant = 16;
    self.dateDividerLabelHeight.constant = 15;
    self.messageContainerViewTopMargin.constant = 14;
    
    if (self.prevMessage != nil) {
        // Day Changed
        NSDate *prevMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.prevMessage.createdAt / 1000.0];
        NSDate *currMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)model.createdAt / 1000.0];
        NSDateComponents *prevMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:prevMessageDate];
        NSDateComponents *currMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currMessageDate];

        if (prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day) {
            // Show date seperator.
            self.dateDividerLabel.hidden = NO;
            self.dateDividerLabelTopMargin.constant = 16;
            self.dateDividerLabelHeight.constant = 15;
            self.messageContainerViewTopMargin.constant = 14;
        }
        else {
            // Hide date seperator.
            self.dateDividerLabel.hidden = YES;
            self.dateDividerLabelTopMargin.constant = 0;
            self.dateDividerLabelHeight.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.messageContainerViewTopMargin.constant = 12;
            }
            else {
                SBDUser *prevMessageSender = nil;
                SBDUser *currMessageSender = nil;
                
                if ([self.prevMessage isKindOfClass:[SBDUserMessage class]]) {
                    prevMessageSender = [(SBDUserMessage *)self.prevMessage sender];
                }
                else if ([self.prevMessage isKindOfClass:[SBDFileMessage class]]) {
                    prevMessageSender = [(SBDFileMessage *)self.prevMessage sender];
                }
                
                currMessageSender = [model sender];
                
                if (prevMessageSender != nil && currMessageSender != nil) {
                    if ([prevMessageSender.userId isEqualToString:currMessageSender.userId]) {
                        // Reduce margin
                        self.messageContainerViewTopMargin.constant = 3;
                    }
                    else {
                        // Set default margin.
                        self.messageContainerViewTopMargin.constant = 14;
                    }
                }
                else {
                    // Set default margin.
                    self.messageContainerViewTopMargin.constant = 14;
                }
            }
        }
    }
    
    // Calculate height
    CGFloat extraHeight = self.dateDividerLabelTopMargin.constant + self.dateDividerLabelHeight.constant + self.messageContainerViewTopMargin.constant;
    CGFloat imageWidth = self.frame.size.width * 0.6;
    CGFloat imageHeight = imageWidth * (2.0/3.0);
    
    self.fileImageViewWidth.constant = imageWidth;
    self.fileImageViewHeight.constant = imageHeight;
    
    self.cellHeight = imageHeight + extraHeight;
    
    [self updateConstraints];
}

- (void)showSendingStatus {
    self.messageStatusLabel.hidden = NO;
    self.resendButton.hidden = YES;
    self.deleteButton.hidden = YES;
}

- (void)setSentMessage {
    self.messageStatusLabel.hidden = YES;
    self.resendButton.hidden = YES;
    self.deleteButton.hidden = YES;
}

- (void)showMessageControlButton {
    self.messageStatusLabel.hidden = YES;
    self.resendButton.hidden = NO;
    self.deleteButton.hidden = NO;
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (void)setImageData:(NSData * _Nonnull)imageData type:(NSString * _Nullable)type {
    if (self.hasImageCacheData == YES) {
        self.imageLoadingActivityIndicator.hidden = YES;
        [self.imageLoadingActivityIndicator stopAnimating];
    }
    
    [self.fileImageView setImage:[UIImage imageWithData:imageData]];
}

@end
