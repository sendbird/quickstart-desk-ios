//
//  SBDSKIncomingVideoFileMessageTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 7/10/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "SBDSKIncomingVideoFileMessageTableViewCell.h"
#import "SBDSKUtils.h"

@interface SBDSKIncomingVideoFileMessageTableViewCell()

// Views
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateDividerLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIView *messageDateContainerView;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileImageViewWidth;

@property (atomic) CGFloat cellHeight;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (strong, nonatomic) SBDBaseMessage *nextMessage;
@property (strong, nonatomic) SBDBaseMessage *message;

@end

@implementation SBDSKIncomingVideoFileMessageTableViewCell

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // message container view
    self.messageContainerView.layer.cornerRadius = 12;
    
    // file image ivew
    self.fileImageView.layer.cornerRadius = self.messageContainerView.layer.cornerRadius;
    
    // profile image view
    self.profileImageView.layer.cornerRadius = 17.0;
    self.profileImageView.clipsToBounds = YES;
    
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

- (void)setModel:(SBDFileMessage *)model {
    self.cellHeight = 0;
    self.message = model;

    UITapGestureRecognizer *messageContainerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFileMessage)];
    self.fileImageView.userInteractionEnabled = YES;
    [self.fileImageView addGestureRecognizer:messageContainerTapRecognizer];
    
    self.nicknameLabel.attributedText = [self buildNickname:model.sender.nickname];
    
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
    self.nicknameLabelTopMargin.constant = 14;
    self.nicknameLabelHeight.constant = 17;
    self.messageContainerViewTopMargin.constant = 7;
    self.profileImageView.hidden = NO;
    
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
                        
                        //                        prevMessageSender = [(SBDUserMessage *)self.prevMessage sender];
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
                        
                        //                        nextMessageSender = [(SBDUserMessage *)self.nextMessage sender];
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
    CGFloat extraHeight = self.dateDividerLabelTopMargin.constant + self.dateDividerLabelHeight.constant + self.nicknameLabelTopMargin.constant + self.nicknameLabelHeight.constant + self.messageContainerViewTopMargin.constant;
    CGFloat imageWidth = self.frame.size.width * 0.6;
    CGFloat imageHeight = imageWidth * (2.0/3.0);
    
    self.fileImageViewWidth.constant = imageWidth;
    self.fileImageViewHeight.constant = imageHeight;
    
    self.cellHeight = imageHeight + extraHeight;
    
    [self updateConstraints];
}

- (NSAttributedString *)buildNickname:(NSString *)nickname {
    NSDictionary *nicknameAttributes = @{
                                         NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14],
                                         NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#8A93A6"],
                                         };
    NSMutableAttributedString *attributedNickname = [[NSMutableAttributedString alloc] initWithString:nickname];
    [attributedNickname addAttributes:nicknameAttributes range:NSMakeRange(0, attributedNickname.length)];
    
    return attributedNickname;
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (void)setNextMessage:(SBDBaseMessage *)aNextMessage {
    _nextMessage = aNextMessage;
}

@end
