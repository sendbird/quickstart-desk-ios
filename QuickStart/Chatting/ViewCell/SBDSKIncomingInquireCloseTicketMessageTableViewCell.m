//
//  SBDSKIncomingInquireCloseTicketMessageTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 5/24/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "SBDSKIncomingInquireCloseTicketMessageTableViewCell.h"
#import "SBDSKUtils.h"
#import "UIButton+SBDSKButton.h"

@interface SBDSKIncomingInquireCloseTicketMessageTableViewCell()

// Views
@property (weak, nonatomic) IBOutlet UILabel *dateDividerLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *yesButtonIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *noButtonIndicator;

// Layout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerViewBottomMargin;

@property (atomic) CGFloat cellHeight;
@property (strong, nonatomic) SBDBaseMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;

@end

@implementation SBDSKIncomingInquireCloseTicketMessageTableViewCell

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
    
    self.yesButton.layer.cornerRadius = 3;
    self.yesButton.layer.masksToBounds = YES;
    self.yesButton.layer.borderWidth = 0;
    self.yesButton.layer.borderColor = [SBDSKUtils colorWithHex:@"#51CF66"].CGColor;
    self.yesButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [self.yesButton setTitleColor:[SBDSKUtils colorWithHex:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.yesButton setTitle:@"YES" forState:UIControlStateNormal];
    [self.yesButton setBackgroundColor:[SBDSKUtils colorWithHex:@"#51CF66"] forState:UIControlStateNormal];
    [self.yesButton setBackgroundColor:[SBDSKUtils colorWithHex:@"#51CF6680"] forState:UIControlStateDisabled];
    
    self.noButton.layer.cornerRadius = 3;
    self.noButton.layer.masksToBounds = YES;
    self.noButton.layer.borderWidth = 0;
    self.noButton.layer.borderColor = [SBDSKUtils colorWithHex:@"#FF6B6B"].CGColor;
    self.noButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [self.noButton setTitleColor:[SBDSKUtils colorWithHex:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.noButton setTitle:@"NO" forState:UIControlStateNormal];
    [self.noButton setBackgroundColor:[SBDSKUtils colorWithHex:@"#FF6B6B"] forState:UIControlStateNormal];
    [self.noButton setBackgroundColor:[SBDSKUtils colorWithHex:@"#FF6B6B80"] forState:UIControlStateDisabled];
    
    self.messageTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, -1);
    self.messageTextView.textContainer.lineFragmentPadding = 0;
    self.messageTextView.textAlignment = NSTextAlignmentCenter;

    self.yesButton.hidden = YES;
    self.noButton.hidden = YES;
    self.yesButtonIndicator.hidden = YES;
    self.noButtonIndicator.hidden = YES;
    
    self.buttonContainerView.hidden = YES;
    self.buttonContainerViewHeight.constant = 0;
    self.buttonContainerViewTopMargin.constant = 11;
    self.buttonContainerViewBottomMargin.constant = 0;
    
    [self updateConstraints];
    
    self.inquireStatus = @"";
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)clickYesButton {
    if (self.delegate != nil) {
        [self.delegate clickInquireCloseMessageYes:self message:self.message];
    }
}

- (void)clickNoButton {
    if (self.delegate != nil) {
        [self.delegate clickInquireCloseMessageNo:self message:self.message];
    }
}

- (void)setModel:(SBDUserMessage *)model {
    self.message = model;
    self.cellHeight = 0;
    NSString *inquireMessage = @"";
    NSDictionary *customData = nil;
    NSError *jsonError = nil;
    @autoreleasepool {
        customData = [NSJSONSerialization JSONObjectWithData:[model.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
    }
    
    if (customData != nil || jsonError == nil) {
        NSString *cannedType = customData[@"type"];
        if (cannedType != nil && ([cannedType isEqualToString:@"SENDBIRD_DESK_INQUIRE_CLOSE_TICKET"] || [cannedType isEqualToString:@"SENDBIRD_DESK_INQUIRE_TICKET_CLOSURE"])) {
            NSDictionary *cannedBody = customData[@"body"];
            NSString *state = cannedBody[@"state"];
            if ([state isEqualToString:@"CONFIRMED"]) {
                self.yesButtonIndicator.hidden = YES;
                self.noButtonIndicator.hidden = YES;
                self.yesButton.hidden = YES;
                self.noButton.hidden = YES;
                
                self.buttonContainerView.hidden = YES;
                self.buttonContainerViewHeight.constant = 0;
                self.buttonContainerViewTopMargin.constant = 11;
                self.buttonContainerViewBottomMargin.constant = 0;
                
                inquireMessage = model.message;
            }
            else if ([state isEqualToString:@"DECLINED"]) {
                self.yesButtonIndicator.hidden = YES;
                self.noButtonIndicator.hidden = YES;
                self.yesButton.hidden = YES;
                self.noButton.hidden = YES;
                
                self.buttonContainerView.hidden = YES;
                self.buttonContainerViewHeight.constant = 0;
                self.buttonContainerViewTopMargin.constant = 11;
                self.buttonContainerViewBottomMargin.constant = 0;
                
                inquireMessage = model.message;
            }
            else if ([state isEqualToString:@"WAITING"]) {
                self.buttonContainerView.hidden = NO;
                self.buttonContainerViewHeight.constant = 32;
                self.buttonContainerViewTopMargin.constant = 14;
                self.buttonContainerViewBottomMargin.constant = 11;
                inquireMessage = [NSString stringWithFormat:@"%@", model.message];

                if ([self.inquireStatus isEqualToString:@"YES_IN_PROGRESS"]) {
                    self.yesButton.enabled = NO;
                    self.noButton.enabled = NO;
                    self.yesButton.hidden = NO;
                    self.noButton.hidden = NO;
                    self.yesButtonIndicator.hidden = NO;
                    [self.yesButtonIndicator startAnimating];
                    self.noButtonIndicator.hidden = YES;
                }
                else if ([self.inquireStatus isEqualToString:@"NO_IN_PROGRESS"]) {
                    self.yesButton.enabled = NO;
                    self.noButton.enabled = NO;
                    self.yesButton.hidden = NO;
                    self.noButton.hidden = NO;
                    self.yesButtonIndicator.hidden = YES;
                    self.noButtonIndicator.hidden = NO;
                    [self.noButtonIndicator startAnimating];
                }
                else if ([self.inquireStatus isEqualToString:@"FAILED"]) {
                    self.buttonContainerView.hidden = NO;
                    self.yesButton.hidden = NO;
                    self.noButton.hidden = NO;
                    self.yesButton.enabled = YES;
                    self.noButton.enabled = YES;
                    self.yesButtonIndicator.hidden = YES;
                    self.noButtonIndicator.hidden = YES;
                }
                else {
                    self.yesButton.hidden = NO;
                    self.noButton.hidden = NO;
                    self.yesButton.enabled = YES;
                    self.noButton.enabled = YES;
                    self.yesButtonIndicator.hidden = YES;
                    self.noButtonIndicator.hidden = YES;
                }
            }
        }
    }
    
    [self updateConstraints];
    [self layoutIfNeeded];
    
    NSAttributedString *attributedMessage = [self buildMessage:inquireMessage];
    self.messageTextView.attributedText = attributedMessage;
    
    [self.yesButton addTarget:self action:@selector(clickYesButton) forControlEvents:UIControlEventTouchUpInside];
    [self.noButton addTarget:self action:@selector(clickNoButton) forControlEvents:UIControlEventTouchUpInside];
    
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
            self.dateDividerLabel.hidden = YES;
            self.dateDividerLabelTopMargin.constant = 0;
            self.dateDividerLabelHeight.constant = 0;

            self.messageContainerViewTopMargin.constant = 14;
        }
    }
    
    // Calcuate height
    CGFloat messageTextViewMaxWidth = self.frame.size.width - (self.messageTextViewLeftMargin.constant + self.messageTextViewRightMargin.constant + self.messageContainerViewRightMargin.constant);
    CGRect attributedMessageRect = [attributedMessage boundingRectWithSize:CGSizeMake((messageTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    CGFloat extraHeight = self.dateDividerLabelTopMargin.constant + self.dateDividerLabelHeight.constant + self.messageContainerViewTopMargin.constant + self.messageTextViewTopMargin.constant + self.buttonContainerViewTopMargin.constant + self.buttonContainerViewHeight.constant + self.buttonContainerViewBottomMargin.constant;
    
    self.cellHeight = attributedMessageRect.size.height + extraHeight;
}

- (NSAttributedString *)buildMessage:(NSString *)message {
    NSMutableDictionary *messageAttributes = [[NSMutableDictionary alloc] initWithDictionary:@{
                                               NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16],
                                               NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#424756"],
                                               }];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    messageAttributes[NSParagraphStyleAttributeName] = paragraph;
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
    [attributedMessage addAttributes:messageAttributes range:NSMakeRange(0, attributedMessage.length)];
    
    return attributedMessage;
}

- (NSAttributedString *)buildMessageDate:(NSString *)plainDate {
    NSDictionary *messageDateAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12],
                                            NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#ABB4C4"],
                                            };
    NSMutableAttributedString *attributedMessageDate = [[NSMutableAttributedString alloc] initWithString:plainDate];
    [attributedMessageDate addAttributes:messageDateAttributes range:NSMakeRange(0, attributedMessageDate.length)];
    
    return attributedMessageDate;
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    _prevMessage = aPrevMessage;
}

@end
