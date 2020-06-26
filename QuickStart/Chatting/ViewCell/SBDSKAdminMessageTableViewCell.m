//
//  SBDSKAdminMessageTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 4/24/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "SBDSKAdminMessageTableViewCell.h"
#import "SBDSKUtils.h"

@interface SBDSKAdminMessageTableViewCell()

// Views
@property (weak, nonatomic) IBOutlet UILabel *dateDividerLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;

// Layout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelHeight;

@property (atomic) CGFloat cellHeight;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;

@end

@implementation SBDSKAdminMessageTableViewCell

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

    self.messageTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, -1);
    self.messageTextView.textContainer.lineFragmentPadding = 0;
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(SBDAdminMessage *)model {
    self.cellHeight = 0;
    NSAttributedString *attributedMessage = [self buildMessage:model.message];
    self.messageTextView.attributedText = attributedMessage;
    
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
    NSString *messageDateString = [dateFormatter stringFromDate:messageCreatedDate];
    NSAttributedString *attributedMessageDate = [self buildMessageDate:messageDateString];
    self.messageDateLabel.attributedText = attributedMessageDate;
    
    // Default
    self.dateDividerLabel.hidden = NO;
    self.dateDividerLabelTopMargin.constant = 16;
    self.dateDividerLabelHeight.constant = 15;
    self.messageContainerViewTopMargin.constant = 14;
    self.messageDateLabelHeight.constant = 14;
    
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
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.messageContainerViewTopMargin.constant = 3;
            }
            else {
                self.messageContainerViewTopMargin.constant = 14;
            }
        }
    }
    
    // Calcuate height
    CGFloat messageTextViewMaxWidth = self.frame.size.width - (self.messageTextViewLeftMargin.constant + self.messageTextViewRightMargin.constant + self.messageContainerViewRightMargin.constant);
    CGRect attributedMessageRect = [attributedMessage boundingRectWithSize:CGSizeMake((messageTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    CGFloat extraHeight = self.dateDividerLabelTopMargin.constant + self.dateDividerLabelHeight.constant + self.messageContainerViewTopMargin.constant + self.messageTextViewTopMargin.constant + self.messageDateLabelTopMargin.constant + self.messageDateLabelHeight.constant + self.messageDateLabelBottomMargin.constant;
    
    self.cellHeight = attributedMessageRect.size.height + extraHeight;
}

- (NSAttributedString *)buildMessage:(NSString *)message {
    NSDictionary *messageAttributes = @{
                                        NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16],
                                        NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#424756"],
                                        };
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
    self.prevMessage = aPrevMessage;
}

@end
