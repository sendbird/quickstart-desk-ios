//
//  SBDSKOutgoingUserMessageTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 4/24/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "SBDSKOutgoingUserMessageTableViewCell.h"
#import "SBDSKUtils.h"

@interface SBDSKOutgoingUserMessageTableViewCell()

// Views
@property (weak, nonatomic) IBOutlet UILabel *dateDividerLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *messageStatusLabel;

// Layout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewWidth;

@property (atomic) CGFloat cellHeight;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (strong, nonatomic) SBDBaseMessage *message;

@end

@implementation SBDSKOutgoingUserMessageTableViewCell

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
    self.messageContainerView.layer.borderColor = [UIColor colorNamed:@"color_outgoing_user_message_border"].CGColor;
    self.messageContainerView.layer.borderWidth = 1;
    
    self.messageTextView.textContainerInset = UIEdgeInsetsZero;
    self.messageTextView.textContainer.lineFragmentPadding = 0;
    self.messageTextView.delegate = self;
    
    self.resendButton.hidden = YES;
    self.deleteButton.hidden = YES;
    self.messageStatusLabel.hidden = YES;
    
    self.messageStatusLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Sending" attributes:@{
                                                                                                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:14],
                                                                                                                NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#808080"],
                                                                                                                }];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)clickResendFailedUserMessage {
    if (self.delegate != nil) {
        [self.delegate clickResendFailedMessage:self message:self.message];
    }
}

- (void)clickDeleteFiledUserMessage {
    if (self.delegate != nil) {
        [self.delegate clickDeleteFailedMessage:self message:self.message];
    }
}

- (void)setModel:(SBDUserMessage *)model {
    self.cellHeight = 0;
    self.message = model;
    NSAttributedString *attributedMessage = [self buildMessage:model.message];
    
    self.messageTextView.attributedText = attributedMessage;
    self.messageTextView.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorNamed:@"color_outgoing_user_message_link"],
                                                NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
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
    self.messageDateLabelHeight.constant = 14;
    
    // Default
    self.dateDividerLabel.hidden = NO;
    self.dateDividerLabelTopMargin.constant = 16;
    self.dateDividerLabelHeight.constant = 15;
    self.messageContainerViewTopMargin.constant = 14;
    
    [self.resendButton addTarget:self action:@selector(clickResendFailedUserMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(clickDeleteFiledUserMessage) forControlEvents:UIControlEventTouchUpInside];
    
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
    CGFloat extraHeight = self.dateDividerLabelTopMargin.constant + self.dateDividerLabelHeight.constant + self.messageContainerViewTopMargin.constant + self.messageTextViewTopMargin.constant + self.messageDateLabelTopMargin.constant + self.messageDateLabelHeight.constant + self.messageDateLabelBottomMargin.constant;
    CGFloat messageTextViewMaxWidth = (self.frame.size.width - (self.messageTextViewLeftMargin.constant + self.messageTextViewRightMargin.constant + self.messageContainerViewRightMargin.constant)) * 0.7;
    CGRect attributedMessageRect = [attributedMessage boundingRectWithSize:CGSizeMake((messageTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    CGRect attributedMessageDateRect = [attributedMessageDate boundingRectWithSize:CGSizeMake((messageTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    if (attributedMessageRect.size.width < messageTextViewMaxWidth) {
        CGFloat messageTextViewWidth = 0;
        if (attributedMessageDateRect.size.width > attributedMessageRect.size.width) {
            messageTextViewWidth = attributedMessageDateRect.size.width;
        }
        else {
            messageTextViewWidth = attributedMessageRect.size.width + 1;
        }

        self.messageTextViewWidth.constant = messageTextViewWidth;
    }
    else {
        self.messageTextViewWidth.constant = messageTextViewMaxWidth;
    }

    [self updateConstraints];

    self.cellHeight = attributedMessageRect.size.height + extraHeight;
}

- (NSAttributedString *)buildMessage:(NSString *)message {
    NSDictionary *messageAttributes = @{
                                        NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16],
                                        NSForegroundColorAttributeName: [UIColor colorNamed:@"color_outgoing_user_message_text"],
                                        };
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
    [attributedMessage addAttributes:messageAttributes range:NSMakeRange(0, attributedMessage.length)];
    
    return attributedMessage;
}

- (NSAttributedString *)buildMessageDate:(NSString *)plainDate {
    NSDictionary *messageDateAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14],
                                            NSForegroundColorAttributeName: [UIColor colorNamed:@"color_outgoing_user_message_date"],
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

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (self.delegate != nil) {
        [self.delegate clickUrlInMessage:self message:self.message url:URL];
    }
    
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(nonnull NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if (self.delegate != nil) {
        [self.delegate clickUrlInMessage:self message:self.message url:URL];
    }

    return NO;
}

@end
