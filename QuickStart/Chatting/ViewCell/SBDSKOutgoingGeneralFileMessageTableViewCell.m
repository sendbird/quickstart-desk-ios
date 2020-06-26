//
//  SBDSKOutgoingGeneralFileMessageTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 5/23/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "SBDSKOutgoingGeneralFileMessageTableViewCell.h"
#import "SBDSKUtils.h"

@interface SBDSKOutgoingGeneralFileMessageTableViewCell()

// Views
@property (weak, nonatomic) IBOutlet UILabel *dateDividerLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *messageStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIView *seperatorLineView;
@property (weak, nonatomic) IBOutlet UIProgressView *fileDownloadProgressView;

// Layout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconImageViewlTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconImageViewlLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameLabelLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameLabelRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorLineViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorLineViewHeight;

@property (atomic) CGFloat cellHeight;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (strong, nonatomic) SBDFileMessage *message;

@end

@implementation SBDSKOutgoingGeneralFileMessageTableViewCell

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.messageContainerView.layer.borderWidth = 1;
    self.messageContainerView.layer.cornerRadius = 12;
    self.messageContainerView.layer.borderColor = [UIColor colorNamed:@"color_outgoing_file_message_border"].CGColor;
    
    self.resendButton.hidden = YES;
    self.deleteButton.hidden = YES;
    self.messageStatusLabel.hidden = YES;
    
    self.messageStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Sending" attributes:@{
                                                                                                                                                              NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:14],
                                                                                                                                                              NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#808080"],
                                                                                                                                                              }];
    
    self.seperatorLineViewHeight.constant = 0.5;
    self.seperatorLineView.backgroundColor = [SBDSKUtils colorWithHex:@"#D0BEFF"];
    
    self.fileDownloadProgressView.tintColor = [UIColor colorNamed:@"color_outgoing_file_message_access_status"];
    
    self.viewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    [self.viewButton setTitleColor:[UIColor colorNamed:@"color_outgoing_file_message_access_status"] forState:UIControlStateNormal];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

- (void)clickViewFileMessage {
    if (self.delegate != nil) {
        [self.delegate clickViewMessage:self message:self.message];
    }
}

- (void)setModel:(SBDFileMessage *)model {
    self.cellHeight = 0;
    self.message = model;
    NSAttributedString *attributedFileName = [self buildFileName:model.name];
    
    self.fileNameLabel.attributedText = attributedFileName;
    self.fileSizeLabel.attributedText = [[NSAttributedString alloc] initWithString:[SBDSKUtils fileSizeFromByteSize:model.size] attributes:@{
                                                                                                                                             NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13],
                                                                                                                                             NSForegroundColorAttributeName: [UIColor colorNamed:@"color_outgoing_file_message_access_status"],
                                                                                                                                             }];
    
    if (![model.type hasPrefix:@"video"]) {
        [self.viewButton setTitle:@"DOWNLOAD" forState:UIControlStateNormal];
    }
    else {
        [self.viewButton setTitle:@"OPEN" forState:UIControlStateNormal];
    }
    
    // Date
    NSTimeInterval messageTimestamp = (double)model.createdAt / 1000.0;
    NSDate *messageCreatedDate = [NSDate dateWithTimeIntervalSince1970:messageTimestamp];
    
    // Date divider
    NSDateFormatter *seperatorDateFormatter = [[NSDateFormatter alloc] init];
    [seperatorDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSAttributedString *dateDividerAttrString = [[NSAttributedString alloc] initWithString:[seperatorDateFormatter stringFromDate:messageCreatedDate] attributes:@{
                                                                                                                                                                   NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:13],
                                                                                                                                                                   NSForegroundColorAttributeName: [UIColor colorNamed:@"color_message_date_divider"],
                                                                                                                                                                   }];
    self.dateDividerLabel.attributedText = dateDividerAttrString;
    
    // Message Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *messageDateString = [dateFormatter stringFromDate:messageCreatedDate];
    NSAttributedString *attributedMessageDate = [self buildMessageDate:messageDateString];
    self.messageDateLabel.attributedText = attributedMessageDate;
    self.messageDateLabelHeight.constant = 12;
    
    // Default
    self.dateDividerLabel.hidden = NO;
    self.dateDividerLabelTopMargin.constant = 16;
    self.dateDividerLabelHeight.constant = 15;
    self.messageContainerViewTopMargin.constant = 14;
    
    [self.resendButton addTarget:self action:@selector(clickResendFailedFileMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(clickDeleteFiledFileMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewButton addTarget:self action:@selector(clickViewFileMessage) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    // Calculate height.
    CGFloat extraHeight = self.dateDividerLabelTopMargin.constant + self.dateDividerLabelHeight.constant + self.messageContainerViewTopMargin.constant + self.fileIconImageViewlTopMargin.constant + self.fileIconImageViewHeight.constant + self.messageDateLabelTopMargin.constant + self.messageDateLabelHeight.constant + self.seperatorLineViewTopMargin.constant + self.seperatorLineViewHeight.constant + self.fileInfoContainerViewHeight.constant;
    self.fileNameLabelWidth.constant = 180;
    
    [self updateConstraints];
    
    self.cellHeight = extraHeight;
}

- (NSAttributedString *)buildFileName:(NSString *)fileName {
    NSDictionary *fileNameAttributes = @{
                                         NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16],
                                         NSForegroundColorAttributeName: [UIColor colorNamed:@"color_outgoing_file_message_filename"],
                                         };
    NSMutableAttributedString *attributedFileName = [[NSMutableAttributedString alloc] initWithString:fileName];
    [attributedFileName addAttributes:fileNameAttributes range:NSMakeRange(0, attributedFileName.length)];
    
    return attributedFileName;
}

- (NSAttributedString *)buildMessageDate:(NSString *)plainDate {
    NSDictionary *messageDateAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12],
                                            NSForegroundColorAttributeName: [UIColor colorNamed:@"color_outgoing_file_message_date"],
                                            };
    NSMutableAttributedString *attributedMessageDate = [[NSMutableAttributedString alloc] initWithString:plainDate];
    [attributedMessageDate addAttributes:messageDateAttributes range:NSMakeRange(0, attributedMessageDate.length)];
    
    return attributedMessageDate;
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

- (void)setFileDownloadingStatus:(int)downloadingStatus {
    if (!([self.message.type hasPrefix:@"video"] || [self.message.type hasPrefix:@"audio"])) {
        if (downloadingStatus == 0) { // ready to download
            self.fileDownloadProgressView.hidden = YES;
            [self.viewButton setTitle:@"DOWNLOAD" forState:UIControlStateNormal];
            self.viewButton.hidden = NO;
        }
        else if (downloadingStatus == 1) { // downloading
            self.viewButton.hidden = YES;
            self.fileDownloadProgressView.hidden = NO;
        }
        else if (downloadingStatus == 2) { // did download
            self.fileDownloadProgressView.hidden = YES;
            [self.viewButton setTitle:@"OPEN" forState:UIControlStateNormal];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                self.viewButton.hidden = NO;
            });
        }
    }
}

- (void)setDownloadingProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fileDownloadProgressView setProgress:progress];
    });
}

@end
