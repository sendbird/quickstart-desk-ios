//
//  SBDSKIncomingGeneralFileMessageTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 5/24/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "SBDSKIncomingGeneralFileMessageTableViewCell.h"
#import "SBDSKUtils.h"

@interface SBDSKIncomingGeneralFileMessageTableViewCell()

// Views
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateDividerLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIView *seperatorLineView;
@property (weak, nonatomic) IBOutlet UIProgressView *fileDownloadProgressView;


// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconImageViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconImageViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorLineViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileNameLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileIconImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorLineViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelHeight;

@property (atomic) CGFloat cellHeight;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (strong, nonatomic) SBDBaseMessage *nextMessage;
@property (strong, nonatomic) SBDFileMessage *message;

@end

@implementation SBDSKIncomingGeneralFileMessageTableViewCell

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.messageContainerView.layer.cornerRadius = 12;
    
    self.profileImageView.layer.cornerRadius = 17.0;
    self.profileImageView.clipsToBounds = YES;
    
    self.seperatorLineViewHeight.constant = 0.5;
    
    self.viewButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    [self.viewButton setTitleColor:[UIColor colorNamed:@"color_incoming_file_message_access_status"] forState:UIControlStateNormal];
    
    self.fileDownloadProgressView.tintColor = [UIColor colorNamed:@"color_incoming_file_message_access_status"];
    
    self.fileDownloadProgressView.hidden = YES;
    [self.fileDownloadProgressView setProgress:0];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)clickViewFileMessage {
    if (self.delegate != nil) {
        [self.delegate clickViewMessage:self message:self.message];
    }
}

- (void)setModel:(SBDFileMessage *)model {
    self.cellHeight = 0;
    self.message = model;
    NSAttributedString *attributedFileName = [self buildMessage:model.name];
    
    self.fileNameLabel.attributedText = attributedFileName;
    self.fileSizeLabel.attributedText = [[NSAttributedString alloc] initWithString:[SBDSKUtils fileSizeFromByteSize:model.size] attributes:@{
                                                                                                                                             NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12],
                                                                                                                                             NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_file_message_access_status"],
                                                                                                                                             }];

    self.nicknameLabel.attributedText = [self buildNickname:model.sender.nickname];

    if ([model.type hasPrefix:@"video"] || [model.type hasPrefix:@"audio"]) {
        [self.viewButton setTitle:@"OPEN" forState:UIControlStateNormal];
    }
    else {
        [self.viewButton setTitle:@"DOWNLOAD" forState:UIControlStateNormal];
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
    
    // Default
    self.nicknameLabel.hidden = NO;
    self.dateDividerLabel.hidden = NO;
    self.dateDividerLabelTopMargin.constant = 16;
    self.dateDividerLabelHeight.constant = 15;
    self.nicknameLabelTopMargin.constant = 14;
    self.nicknameLabelHeight.constant = 17;
    self.messageContainerViewTopMargin.constant = 14;
    self.profileImageView.hidden = NO;
    self.messageDateLabelHeight.constant = 14;
    
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
            self.nicknameLabelTopMargin.constant = 14;
            self.nicknameLabelHeight.constant = 17;
            self.messageContainerViewTopMargin.constant = 7;
        }
        else {
            // Hide date seperator.
            self.dateDividerLabel.hidden = YES;
            self.dateDividerLabelTopMargin.constant = 0;
            self.dateDividerLabelHeight.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.nicknameLabel.hidden = NO;
                self.nicknameLabelTopMargin.constant = 14;
                self.nicknameLabelHeight.constant = 17;
                self.messageContainerViewTopMargin.constant = 7;
                
                SBDUser *currMessageSender = nil;
                SBDUser *nextMessageSender = nil;
                
                if (self.nextMessage != nil) {
                    if ([self.nextMessage isKindOfClass:[SBDUserMessage class]]) {
                        nextMessageSender = [(SBDUserMessage *)self.nextMessage sender];
                    }
                    else if ([self.nextMessage isKindOfClass:[SBDFileMessage class]]) {
                        nextMessageSender = [(SBDFileMessage *)self.nextMessage sender];
                    }
                }
                
                currMessageSender = [model sender];
                
                if (nextMessageSender != nil && currMessageSender != nil) {
                    if ([nextMessageSender.userId isEqualToString:currMessageSender.userId]) {
                        // Hide profile image
                        self.profileImageView.hidden = YES;
                    }
                }
            }
            else {
                SBDUser *prevMessageSender = nil;
                SBDUser *currMessageSender = nil;
                SBDUser *nextMessageSender = nil;
                
                if (self.prevMessage != nil) {
                    if ([self.prevMessage isKindOfClass:[SBDUserMessage class]]) {
                        SBDUserMessage *prevUserMessage = (SBDUserMessage *)self.prevMessage;
                        NSDictionary *customData = nil;
                        NSError *jsonError = nil;
                        @autoreleasepool {
                            customData = [NSJSONSerialization JSONObjectWithData:[prevUserMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
                        }
                        
                        if (customData != nil || jsonError == nil) {
                            NSString *cannedType = customData[@"type"];
                            if (cannedType != nil && ([cannedType isEqualToString:@"SENDBIRD_DESK_INQUIRE_CLOSE_TICKET"] || [cannedType isEqualToString:@"SENDBIRD_DESK_INQUIRE_TICKET_CLOSURE"])) {
                                prevMessageSender = nil;
                            }
                            else {
                                prevMessageSender = [prevUserMessage sender];
                            }
                        }
                        else {
                            prevMessageSender = [prevUserMessage sender];
                        }
                    }
                    else if ([self.prevMessage isKindOfClass:[SBDFileMessage class]]) {
                        prevMessageSender = [(SBDFileMessage *)self.prevMessage sender];
                    }
                }
                
                if (self.nextMessage != nil) {
                    if ([self.nextMessage isKindOfClass:[SBDUserMessage class]]) {
                        SBDUserMessage *nextUserMessage = (SBDUserMessage *)self.nextMessage;
                        NSDictionary *customData = nil;
                        NSError *jsonError = nil;
                        @autoreleasepool {
                            customData = [NSJSONSerialization JSONObjectWithData:[nextUserMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
                        }
                        
                        if (customData != nil || jsonError == nil) {
                            NSString *cannedType = customData[@"type"];
                            if (cannedType != nil && ([cannedType isEqualToString:@"SENDBIRD_DESK_INQUIRE_CLOSE_TICKET"] || [cannedType isEqualToString:@"SENDBIRD_DESK_INQUIRE_TICKET_CLOSURE"])) {
                                nextMessageSender = nil;
                            }
                            else {
                                nextMessageSender = [nextUserMessage sender];
                            }
                        }
                        else {
                            nextMessageSender = [nextUserMessage sender];
                        }
                    }
                    else if ([self.nextMessage isKindOfClass:[SBDFileMessage class]]) {
                        nextMessageSender = [(SBDFileMessage *)self.nextMessage sender];
                    }
                }
                
                currMessageSender = [model sender];
                
                if (prevMessageSender != nil && currMessageSender != nil) {
                    if ([prevMessageSender.userId isEqualToString:currMessageSender.userId]) {
                        // Reduce margin
                        self.nicknameLabel.hidden = YES;
                        self.nicknameLabelTopMargin.constant = 0;
                        self.nicknameLabelHeight.constant = 0;
                        self.messageContainerViewTopMargin.constant = 3;
                    }
                    else {
                        // Set default margin.
                        self.messageContainerViewTopMargin.constant = 7;
                    }
                }
                else {
                    // Set default margin.
                    self.messageContainerViewTopMargin.constant = 7;
                }
                
                if (nextMessageSender != nil && currMessageSender != nil) {
                    if ([nextMessageSender.userId isEqualToString:currMessageSender.userId]) {
                        // Hide profile image
                        self.profileImageView.hidden = YES;
                    }
                }
            }
        }
    }
    
    // Calculate height
    CGFloat extraHeight = self.dateDividerLabelTopMargin.constant + self.dateDividerLabelHeight.constant + self.nicknameLabelTopMargin.constant + self.nicknameLabelHeight.constant + self.messageContainerViewTopMargin.constant + self.fileIconImageViewTopMargin.constant + self.fileIconImageViewHeight.constant + self.messageDateLabelTopMargin.constant + self.messageDateLabelHeight.constant + self.seperatorLineViewTopMargin.constant + self.seperatorLineViewHeight.constant + self.fileInfoContainerViewHeight.constant;
    self.fileNameLabelWidth.constant = 180;
    
    [self updateConstraints];
    
    self.cellHeight = extraHeight;
}

- (NSAttributedString *)buildNickname:(NSString *)nickname {
    NSDictionary *nicknameAttributes = @{
                                         NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14],
                                         NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_file_message_nickname"],
                                         };
    NSMutableAttributedString *attributedNickname = [[NSMutableAttributedString alloc] initWithString:nickname];
    [attributedNickname addAttributes:nicknameAttributes range:NSMakeRange(0, attributedNickname.length)];
    
    return attributedNickname;
}

- (NSAttributedString *)buildMessage:(NSString *)message {
    NSDictionary *messageAttributes = @{
                                        NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16],
                                        NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_file_message_filename"],
                                        };
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
    [attributedMessage addAttributes:messageAttributes range:NSMakeRange(0, attributedMessage.length)];
    
    return attributedMessage;
}

- (NSAttributedString *)buildMessageDate:(NSString *)plainDate {
    NSDictionary *messageDateAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12],
                                            NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_file_message_date"],
                                            };
    NSMutableAttributedString *attributedMessageDate = [[NSMutableAttributedString alloc] initWithString:plainDate];
    [attributedMessageDate addAttributes:messageDateAttributes range:NSMakeRange(0, attributedMessageDate.length)];
    
    return attributedMessageDate;
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (void)setNextMessage:(SBDBaseMessage *)aNextMessage {
    _nextMessage = aNextMessage;
}

- (void)setFileDownloadingStatus:(int)downloadingStatus {
    if (!([self.message.type hasPrefix:@"video"] || [self.message.type hasPrefix:@"audio"])) {
        if (downloadingStatus == 0) {
            self.fileDownloadProgressView.hidden = YES;
            [self.viewButton setTitle:@"DOWNLOAD" forState:UIControlStateNormal];
            self.viewButton.hidden = NO;
        }
        else if (downloadingStatus == 1) {
            self.viewButton.hidden = YES;
            self.fileDownloadProgressView.hidden = NO;
        }
        else if (downloadingStatus == 2) {
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
