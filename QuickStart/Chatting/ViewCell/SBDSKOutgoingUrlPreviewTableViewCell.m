//
//  SBDSKOutgoingUrlPreviewTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 7/18/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "SBDSKOutgoingUrlPreviewTableViewCell.h"
#import "SBDSKGeneralUrlPreviewTempModel.h"
#import "FLAnimatedImageView+ImageCache.h"
#import "SBDSKUtils.h"

@interface SBDSKOutgoingUrlPreviewTableViewCell()

// Views
@property (weak, nonatomic) IBOutlet UILabel *dateDividerLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *messageStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *urlPreviewContainerView;

@property (weak, nonatomic) IBOutlet UITextView *urlPreviewTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *urlPreviewDomainTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *urlPreviewGeneratingActivityIndicator;

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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewThumbnailImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewTitleTextViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewDomainTextViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewDomainTextViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewTitleTextViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewDomainTextViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewContainerViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewTitleTextViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewTitleTextViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewDomainTextViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlPreviewDomainTextViewRightMargin;

@property (atomic) CGFloat cellHeight;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (strong, nonatomic) SBDBaseMessage *message;

@property (strong, nonatomic) NSString *previewUrl;

@end

@implementation SBDSKOutgoingUrlPreviewTableViewCell

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
    self.messageContainerView.layer.borderColor = [UIColor colorNamed:@"color_outgoing_url_preview_border"].CGColor;
    
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
    
    self.urlPreviewContainerView.layer.borderWidth = 1;
    self.urlPreviewContainerView.layer.cornerRadius = 12;
    self.urlPreviewContainerView.layer.borderColor = [UIColor colorNamed:@"color_outgoing_url_preview_border"].CGColor;
    
    self.urlPreviewContainerView.userInteractionEnabled = YES;
    [self.urlPreviewContainerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUrlPreview)]];

    self.urlPreviewTitleTextView.textContainerInset = UIEdgeInsetsZero;
    self.urlPreviewTitleTextView.textContainer.lineFragmentPadding = 0;
    self.urlPreviewTitleTextView.delegate = self;
    [self.urlPreviewTitleTextView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUrlPreview)]];

    self.urlPreviewDomainTextView.textContainerInset = UIEdgeInsetsZero;
    self.urlPreviewDomainTextView.textContainer.lineFragmentPadding = 0;
    self.urlPreviewDomainTextView.delegate = self;
    [self.urlPreviewDomainTextView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUrlPreview)]];

    self.urlPreviewGeneratingActivityIndicator.hidden = YES;
    self.urlPreviewContainerView.layer.masksToBounds = YES;
    
    self.urlPreviewThumbnailImageView.image = nil;
    self.urlPreviewThumbnailImageView.animatedImage = nil;
    [self.urlPreviewThumbnailImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUrlPreview)]];

    self.backgroundColor = [UIColor clearColor];
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

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (void)setModel:(SBDBaseMessage *)model {
    self.message = model;
    self.cellHeight = 0;
    self.previewUrl = nil;

    self.urlPreviewThumbnailImageView.image = nil;
    self.urlPreviewThumbnailImageView.animatedImage = nil;
    [self.urlPreviewThumbnailImageView setNeedsDisplay];
    
    // Original Message
    if ([self.message isKindOfClass:[SBDSKGeneralUrlPreviewTempModel class]] || [self.message isKindOfClass:[SBDUserMessage class]]) {
        if ([self.message isKindOfClass:[SBDSKGeneralUrlPreviewTempModel class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.urlPreviewGeneratingActivityIndicator.hidden = NO;
                [self.urlPreviewGeneratingActivityIndicator startAnimating];
            });
        }
        else {
            self.urlPreviewGeneratingActivityIndicator.hidden = YES;
        }
        
        NSString *messageText = @"";
        if ([self.message isKindOfClass:[SBDSKGeneralUrlPreviewTempModel class]]) {
            messageText = ((SBDSKGeneralUrlPreviewTempModel *)self.message).message;
        }
        else {
            messageText = ((SBDUserMessage *)self.message).message;
        }
        
        NSAttributedString *attributedMessage = [self buildMessage:messageText];
        
        self.messageTextView.attributedText = attributedMessage;
        self.messageTextView.linkTextAttributes = @{
                                                    NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#27A9FF"],
                                                    NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                                    };
        
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
        self.messageDateLabel.text = messageDateString;
        self.messageDateLabelHeight.constant = 14;
        
        // Default
        self.dateDividerLabel.hidden = NO;
        self.dateDividerLabelTopMargin.constant = 16;
        self.dateDividerLabelHeight.constant = 15;
        self.messageContainerViewTopMargin.constant = 14;
        
        if ([self.message isKindOfClass:[SBDUserMessage class]]) {
            [self.resendButton addTarget:self action:@selector(clickResendFailedUserMessage) forControlEvents:UIControlEventTouchUpInside];
            [self.deleteButton addTarget:self action:@selector(clickDeleteFiledUserMessage) forControlEvents:UIControlEventTouchUpInside];
        }
        
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
                    
                    currMessageSender = [SBDMain getCurrentUser];
                    
                    if (prevMessageSender != nil) {
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
    
    // URL Preview
    if ([self.message isKindOfClass:[SBDUserMessage class]]) {
        self.urlPreviewContainerView.hidden = NO;
        self.urlPreviewThumbnailImageView.hidden = NO;
        self.urlPreviewTitleTextView.hidden = NO;
        self.urlPreviewDomainTextView.hidden = NO;
        
        self.urlPreviewThumbnailImageViewHeight.constant = 141;
        
        NSData *data = [((SBDUserMessage *)self.message).data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *previewData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *previewBody = previewData[@"body"];
        
        NSString *title = previewBody[@"title"];
        NSString *url = previewBody[@"url"];
        self.previewUrl = url;
        
        NSURL *parsedUrl = [NSURL URLWithString:url];

        // Calculate height
        CGFloat extraHeight = self.urlPreviewContainerViewTopMargin.constant + self.urlPreviewThumbnailImageViewHeight.constant + self.urlPreviewTitleTextViewTopMargin.constant + self.urlPreviewDomainTextViewTopMargin.constant + self.urlPreviewDomainTextViewBottomMargin.constant;
        
        CGFloat urlPreviewTitleTextViewMaxWidth = self.urlPreviewContainerViewWidth.constant - self.urlPreviewTitleTextViewLeftMargin.constant - self.urlPreviewTitleTextViewRightMargin.constant;
        NSAttributedString *attributedTitle = [self buildUrlPreviewTitle:title];
        CGRect attributedTitleRect = [attributedTitle boundingRectWithSize:CGSizeMake((urlPreviewTitleTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        
        CGFloat urlPreviewDomainTextViewMaxWidth = self.urlPreviewContainerViewWidth.constant - self.urlPreviewTitleTextViewLeftMargin.constant - self.urlPreviewTitleTextViewRightMargin.constant;
        NSAttributedString *attributedDomain = [self buildUrlPreviewDomain:[parsedUrl host]];
        CGRect attributedDomainRect = [attributedDomain boundingRectWithSize:CGSizeMake((urlPreviewDomainTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        
        self.urlPreviewTitleTextViewHeight.constant = attributedTitleRect.size.height;
        self.urlPreviewDomainTextViewHeight.constant = attributedDomainRect.size.height;
        
        self.urlPreviewTitleTextView.attributedText = attributedTitle;
        self.urlPreviewDomainTextView.attributedText = attributedDomain;
        
        self.cellHeight += extraHeight + self.urlPreviewTitleTextViewHeight.constant + self.urlPreviewDomainTextViewHeight.constant;
    }
    else {
        self.urlPreviewContainerView.hidden = YES;
        self.urlPreviewThumbnailImageView.hidden = YES;
        self.urlPreviewTitleTextView.hidden = YES;
        self.urlPreviewDomainTextView.hidden = YES;
        
        self.urlPreviewTitleTextViewHeight.constant = 0;
        self.urlPreviewDomainTextViewHeight.constant = 0;
        self.urlPreviewThumbnailImageViewHeight.constant = 0;
    }
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
                                            NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#9675F9"],
                                            };
    NSMutableAttributedString *attributedMessageDate = [[NSMutableAttributedString alloc] initWithString:plainDate];
    [attributedMessageDate addAttributes:messageDateAttributes range:NSMakeRange(0, attributedMessageDate.length)];
    
    return attributedMessageDate;
}

- (NSAttributedString *)buildUrlPreviewTitle:(NSString *)title {
    NSDictionary *urlPreviewTitleLabelAttribute = @{
                                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:13],
                                                    NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#424756"],
                                                    };
    NSMutableAttributedString *attributedUrlPreviewTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedUrlPreviewTitle addAttributes:urlPreviewTitleLabelAttribute range:NSMakeRange(0, attributedUrlPreviewTitle.length)];
    
    return attributedUrlPreviewTitle;
}

- (NSAttributedString *)buildUrlPreviewDomain:(NSString *)domain {
    NSDictionary *urlPreviewDomainLabelAttribute = @{
                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:13],
                                                     NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:@"#777777"],
                                                     };
    NSMutableAttributedString *attributedUrlPreviewDomain = [[NSMutableAttributedString alloc] initWithString:domain];
    [attributedUrlPreviewDomain addAttributes:urlPreviewDomainLabelAttribute range:NSMakeRange(0, attributedUrlPreviewDomain.length)];
    
    return attributedUrlPreviewDomain;
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

- (void)clickUrlPreview {
    if (self.delegate != nil && self.previewUrl != nil) {
        [self.delegate clickUrlInMessage:self message:self.message url:[NSURL URLWithString:self.previewUrl]];
    }
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
