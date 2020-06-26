//
//  SBDSKIncomingUrlPreviewTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 7/19/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "SBDSKIncomingUrlPreviewTableViewCell.h"
#import "FLAnimatedImageView+ImageCache.h"
#import "SBDSKMessageCellDelegate.h"
#import "SBDSKUtils.h"

@interface SBDSKIncomingUrlPreviewTableViewCell()

// Views
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateDividerLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIView *urlPreviewContainerView;
@property (weak, nonatomic) IBOutlet UITextView *urlPreviewTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *urlPreviewDomainTextView;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateDividerLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelHeight;

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
@property (strong, nonatomic) SBDBaseMessage *nextMessage;
@property (strong, nonatomic) SBDUserMessage *message;

@property (strong, nonatomic) NSString *previewUrlString;

@end

@implementation SBDSKIncomingUrlPreviewTableViewCell

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
    
    self.messageTextView.textContainerInset = UIEdgeInsetsZero;
    self.messageTextView.textContainer.lineFragmentPadding = 0;
    
    self.urlPreviewContainerView.layer.cornerRadius = 12;
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

    self.urlPreviewContainerView.layer.masksToBounds = YES;

    [self.urlPreviewThumbnailImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUrlPreview)]];

    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(SBDUserMessage *)model {
    self.cellHeight = 0;
    self.message = model;
    NSAttributedString *attributedMessage = [self buildMessage:model.message];
    
    self.messageTextView.attributedText = attributedMessage;
    self.messageTextView.linkTextAttributes = @{
                                                NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_url_preview_link"],
                                                NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                                };
    self.nicknameLabel.attributedText = [self buildNickname:model.sender.nickname];
    
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
    CGFloat extraHeight = self.dateDividerLabelTopMargin.constant + self.dateDividerLabelHeight.constant + self.nicknameLabelTopMargin.constant + self.nicknameLabelHeight.constant + self.messageContainerViewTopMargin.constant + self.messageTextViewTopMargin.constant + self.messageDateLabelTopMargin.constant + self.messageDateLabelHeight.constant + self.messageDateLabelBottomMargin.constant;
    CGFloat messageTextViewMaxWidth = (self.frame.size.width - (self.profileImageViewLeftMargin.constant + self.profileImageViewWidth.constant + self.messageContainerViewLeftMargin.constant + self.messageTextViewLeftMargin.constant + self.messageTextViewRightMargin.constant)) * 0.7;
    CGRect attributedMessageRect = [attributedMessage boundingRectWithSize:CGSizeMake((messageTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    CGRect attributedMessageDateRect = [attributedMessageDate boundingRectWithSize:CGSizeMake((messageTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    if (attributedMessageRect.size.width < messageTextViewMaxWidth) {
        CGFloat messageTextViewWidth = 0;
        if (attributedMessageDateRect.size.width > attributedMessageRect.size.width) {
            messageTextViewWidth = attributedMessageDateRect.size.width;
        }
        else {
            messageTextViewWidth = attributedMessageRect.size.width;
        }
        
        self.messageTextViewWidth.constant = messageTextViewWidth + 1;
    }
    else {
        self.messageTextViewWidth.constant = messageTextViewMaxWidth;
    }
    [self updateConstraints];
    
    self.cellHeight = attributedMessageRect.size.height + extraHeight;
    
    // URL Preview
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
    self.previewUrlString = url;
    
    NSURL *parsedUrl = [NSURL URLWithString:url];

    // Calculate height
    CGFloat extraHeight2 = self.urlPreviewContainerViewTopMargin.constant + self.urlPreviewThumbnailImageViewHeight.constant + self.urlPreviewTitleTextViewTopMargin.constant + self.urlPreviewDomainTextViewTopMargin.constant + self.urlPreviewDomainTextViewBottomMargin.constant;
    
    CGFloat urlPreviewTitleTextViewMaxWidth = self.urlPreviewContainerViewWidth.constant - self.urlPreviewTitleTextViewLeftMargin.constant - self.urlPreviewTitleTextViewRightMargin.constant;
    
    
    NSAttributedString *attributedTitle = [self buildUrlPreviewTitle:title];
    CGRect attributedTitleRect = CGRectZero;
    if (attributedTitle != nil) {
        attributedTitleRect = [attributedTitle boundingRectWithSize:CGSizeMake((urlPreviewTitleTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    }

    CGFloat urlPreviewDomainTextViewMaxWidth = self.urlPreviewContainerViewWidth.constant - self.urlPreviewTitleTextViewLeftMargin.constant - self.urlPreviewTitleTextViewRightMargin.constant;
    NSAttributedString *attributedDomain = [self buildUrlPreviewDomain:[parsedUrl host]];
    CGRect attributedDomainRect = CGRectZero;
    if (attributedDomain != nil) {
        attributedDomainRect = [attributedDomain boundingRectWithSize:CGSizeMake((urlPreviewDomainTextViewMaxWidth), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    }

    self.urlPreviewTitleTextViewHeight.constant = attributedTitleRect.size.height;
    self.urlPreviewDomainTextViewHeight.constant = attributedDomainRect.size.height;
    
    self.urlPreviewTitleTextView.attributedText = attributedTitle;
    self.urlPreviewDomainTextView.attributedText = attributedDomain;
    
    self.cellHeight += extraHeight2 + self.urlPreviewTitleTextViewHeight.constant + self.urlPreviewDomainTextViewHeight.constant;
}

- (NSAttributedString *)buildNickname:(NSString *)nickname {
    NSDictionary *nicknameAttributes = @{
                                         NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14],
                                         NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_url_preview_nickname"],
                                         };
    NSMutableAttributedString *attributedNickname = [[NSMutableAttributedString alloc] initWithString:nickname];
    [attributedNickname addAttributes:nicknameAttributes range:NSMakeRange(0, attributedNickname.length)];
    
    return attributedNickname;
}

- (NSAttributedString *)buildMessage:(NSString *)message {
    NSDictionary *messageAttributes = @{
                                        NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16],
                                        NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_url_preview_text"],
                                        };
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
    [attributedMessage addAttributes:messageAttributes range:NSMakeRange(0, attributedMessage.length)];
    
    return attributedMessage;
}

- (NSAttributedString *)buildMessageDate:(NSString *)plainDate {
    NSDictionary *messageDateAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12],
                                            NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_url_preview_date"],
                                            };
    NSMutableAttributedString *attributedMessageDate = [[NSMutableAttributedString alloc] initWithString:plainDate];
    [attributedMessageDate addAttributes:messageDateAttributes range:NSMakeRange(0, attributedMessageDate.length)];
    
    return attributedMessageDate;
}

- (NSAttributedString *)buildUrlPreviewTitle:(NSString *)title {
    if (title != nil && title.length > 0) {
        NSDictionary *urlPreviewTitleLabelAttribute = @{
                                                        NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:13],
                                                        NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_url_preview_text"],
                                                        };
        NSMutableAttributedString *attributedUrlPreviewTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [attributedUrlPreviewTitle addAttributes:urlPreviewTitleLabelAttribute range:NSMakeRange(0, attributedUrlPreviewTitle.length)];
    
        return attributedUrlPreviewTitle;
    }
    else {
        return nil;
    }
}

- (NSAttributedString *)buildUrlPreviewDomain:(NSString *)domain {
    if (domain != nil && domain.length > 0) {
        NSDictionary *urlPreviewDomainLabelAttribute = @{
                                                         NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:13],
                                                         NSForegroundColorAttributeName: [UIColor colorNamed:@"color_incoming_url_preview_domain"],
                                                         };
        NSMutableAttributedString *attributedUrlPreviewDomain = [[NSMutableAttributedString alloc] initWithString:domain];
        [attributedUrlPreviewDomain addAttributes:urlPreviewDomainLabelAttribute range:NSMakeRange(0, attributedUrlPreviewDomain.length)];
        
        return attributedUrlPreviewDomain;
    }
    else {
        return nil;
    }
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (void)setNextMessage:(SBDBaseMessage *)aNextMessage {
    _nextMessage = aNextMessage;
}

#pragma mark -
- (void)clickUrlPreview {
    if (self.delegate != nil && self.previewUrlString != nil) {
        [self.delegate clickUrlInMessage:self message:self.message url:[NSURL URLWithString:self.previewUrlString]];
    }
}

@end
