//
//  InboxTicketTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 3/19/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

@interface InboxTicketTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ticketTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *agentProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *agentNickname;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadCountContainerView;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet UIView *dividerView;

- (void)setModel:(SBDSKTicket *)model;
- (void)setClosedTicket;

@end
