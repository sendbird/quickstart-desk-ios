//
//  InboxTicketTableViewCell.m
//  QuickStart
//
//  Created by SendBird on 3/19/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "InboxTicketTableViewCell.h"

@interface InboxTicketTableViewCell()

@property (strong) SBDSKTicket *ticket;

@end

@implementation InboxTicketTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(SBDSKTicket *)model {
    self.ticket = model;
    
    self.ticketTitleLabel.text = self.ticket.title;
    if (self.ticket.agent != nil) {
        self.agentNickname.text = self.ticket.agent.name;
    }
    else {
        self.agentNickname.text = @"Virgin Mobile Customer Support";
    }
    
    long long lastUpdatedTimestamp = 0;
    if (self.ticket.channel != nil && self.ticket.channel.lastMessage != nil) {
        if ([self.ticket.channel.lastMessage isKindOfClass:[SBDAdminMessage class]]) {
            self.lastMessageLabel.text = ((SBDAdminMessage *)self.ticket.channel.lastMessage).message;
        }
        else if ([self.ticket.channel.lastMessage isKindOfClass:[SBDUserMessage class]]) {
            self.lastMessageLabel.text = ((SBDUserMessage *)self.ticket.channel.lastMessage).message;
        }
        else if ([self.ticket.channel.lastMessage isKindOfClass:[SBDFileMessage class]]) {
            SBDFileMessage *fileMessage = (SBDFileMessage *)self.ticket.channel.lastMessage;
            if ([fileMessage.type hasPrefix:@"image"]) {
                self.lastMessageLabel.text = @"(Image)";
            }
            else if ([fileMessage.type hasPrefix:@"video"]) {
                self.lastMessageLabel.text = @"(Video)";
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                self.lastMessageLabel.text = @"(Audio)";
            }
            else {
                self.lastMessageLabel.text = @"(File)";
            }
        }
        else {
            self.lastMessageLabel.text = @"";
        }
        
        lastUpdatedTimestamp = self.ticket.channel.lastMessage.createdAt;
    }
    else {
        self.lastMessageLabel.text = @"";
        lastUpdatedTimestamp = self.ticket.channel.createdAt;
    }
    
    // Last message date time
    NSDateFormatter *lastMessageDateFormatter = [[NSDateFormatter alloc] init];
    
    NSDate *lastMessageDate = nil;
    if ([NSString stringWithFormat:@"%lld", lastUpdatedTimestamp].length == 10) {
        lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)lastUpdatedTimestamp];
    }
    else {
        lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)lastUpdatedTimestamp / 1000.0];
    }
    NSDate *currDate = [NSDate date];
    
    NSDateComponents *lastMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:lastMessageDate];
    NSDateComponents *currDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currDate];
    
    if (lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day) {
        [lastMessageDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [lastMessageDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        self.dateLabel.text = [lastMessageDateFormatter stringFromDate:lastMessageDate];
    }
    else {
        [lastMessageDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [lastMessageDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        self.dateLabel.text = [lastMessageDateFormatter stringFromDate:lastMessageDate];
    }
    
    if (self.ticket.channel.unreadMessageCount == 0) {
        self.unreadCountContainerView.hidden = YES;
        self.unreadCountLabel.hidden = YES;
    }
    else if (self.ticket.channel.unreadMessageCount > 0 && self.ticket.channel.unreadMessageCount < 100) {
        self.unreadCountContainerView.hidden = NO;
        self.unreadCountLabel.hidden = NO;
        self.unreadCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.ticket.channel.unreadMessageCount];
        
    }
    else {
        self.unreadCountContainerView.hidden = NO;
        self.unreadCountLabel.hidden = NO;
        self.unreadCountLabel.text = @"+99";
    }
}

- (void)setClosedTicket {
    CGFloat alpha = 0.6;
    
    self.ticketTitleLabel.alpha = alpha;
    self.lastMessageLabel.alpha = alpha;
    self.agentProfileImageView.alpha = alpha;
    self.agentNickname.alpha = alpha;
    self.dateLabel.alpha = alpha;
    self.unreadCountContainerView.alpha = alpha;
}

@end
