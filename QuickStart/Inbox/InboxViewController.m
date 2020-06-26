//
//  InboxViewController.m
//  QuickStart
//
//  Created by SendBird on 3/19/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "InboxViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "InboxTicketTableViewCell.h"
#import "ChattingViewController.h"
#import "SBDSKSettingsViewController.h"
#import "UIViewController+Utils.h"

@interface InboxViewController ()

// Views
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *openTicketTableViewContainerView;
@property (weak, nonatomic) IBOutlet UITableView *openTicketTableView;
@property (weak, nonatomic) IBOutlet UIView *closedTicketTableViewContainerView;
@property (weak, nonatomic) IBOutlet UITableView *closedTicketTableView;

@property (weak, nonatomic) IBOutlet UIView *emptyOpenTicketContainerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *openTicketActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *emptyOpenTicketTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emptyOpenTicketDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *emptyClosedTicketContainerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *closedTicketActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *emptyClosedTicketTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emptyClosedTicketDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *emptyOpenTicketImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyClosedTicketImageView;
@property (strong, nonatomic) UIRefreshControl *openTicketRefreshControl;
@property (strong, nonatomic) UIRefreshControl *closedTicketRefreshControl;

@property (weak, nonatomic) IBOutlet UIButton *openTabButton;
@property (weak, nonatomic) IBOutlet UIButton *closedTabButton;
@property (weak, nonatomic) IBOutlet UIView *tabBottomLineView;
@property (weak, nonatomic) IBOutlet UIScrollView *inboxScrollView;

// start chat button view
@property (weak, nonatomic) IBOutlet UIView *startChatContainerView;
@property (weak, nonatomic) IBOutlet UIButton *startChatButton;
@property (atomic, getter=hasStartedNewChat) BOOL startedNewChat;

@property (strong, nonatomic) NSMutableArray<SBDSKTicket *> *openTickets;
@property (strong, nonatomic) NSMutableArray<SBDSKTicket *> *closedTickets;
@property (atomic) long openTicketsOffset;
@property (atomic) long closedTicketsOffset;

@property (atomic) BOOL isLoadingOpenTickets;
@property (atomic) BOOL isLoadingClosedTickets;
@property (atomic) BOOL hasMoreOpenTicket;
@property (atomic) BOOL hasMoreClosedTicket;
@property (atomic) CGFloat currentOffset;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBottomLineViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBottomLineViewLeftMargin;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customNavigationViewHeight;

@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    self.openTicketTableView.delegate = self;
    self.openTicketTableView.dataSource = self;
    
    self.closedTicketTableView.delegate = self;
    self.closedTicketTableView.dataSource = self;
    
    self.openTicketRefreshControl = [[UIRefreshControl alloc] init];
    self.closedTicketRefreshControl = [[UIRefreshControl alloc] init];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        self.openTicketTableView.refreshControl = self.openTicketRefreshControl;
        self.closedTicketTableView.refreshControl = self.closedTicketRefreshControl;
    }
    else {
        [self.openTicketTableView addSubview:self.openTicketRefreshControl];
        [self.closedTicketTableView addSubview:self.closedTicketRefreshControl];
    }
    
    [self.openTicketRefreshControl addTarget:self action:@selector(refreshOpenTicketTable) forControlEvents:UIControlEventValueChanged];
    [self.closedTicketRefreshControl addTarget:self action:@selector(refreshClosedTicketTable) forControlEvents:UIControlEventValueChanged];
    
    [self.openTicketTableView registerNib:[UINib nibWithNibName:@"InboxTicketTableViewCell" bundle:nil] forCellReuseIdentifier:@"InboxTicketTableViewCell"];
    [self.closedTicketTableView registerNib:[UINib nibWithNibName:@"InboxTicketTableViewCell" bundle:nil] forCellReuseIdentifier:@"InboxTicketTableViewCell"];
    
    self.inboxScrollView.delegate = self;
    self.openTicketTableViewContainerView.hidden = NO;
    self.closedTicketTableViewContainerView.hidden = NO;
    
    [self.openTabButton setTitleColor:[UIColor colorNamed:@"color_tab_title_selected"] forState:UIControlStateNormal];
    [self.closedTabButton setTitleColor:[UIColor colorNamed:@"color_tab_title_normal"] forState:UIControlStateNormal];
    
    self.tabBottomLineView.backgroundColor = [UIColor colorNamed:@"color_tab_border_line_selected"];
    
    [self.openTabButton addTarget:self action:@selector(clickOpenTabButton) forControlEvents:UIControlEventTouchUpInside];
    [self.closedTabButton addTarget:self action:@selector(clickClosedTabButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.openTickets = [[NSMutableArray alloc] init];
    self.closedTickets = [[NSMutableArray alloc] init];
    
    self.openTicketsOffset = 0;
    self.closedTicketsOffset = 0;
    self.isLoadingOpenTickets = NO;
    self.isLoadingClosedTickets = NO;
    self.hasMoreOpenTicket = YES;
    self.hasMoreClosedTicket = YES;
    self.currentOffset = 0;
    
    // start chat view
    [self configureStartChatButtonView];
    
    // Initialize SendBirdSDK
    [SBDMain addChannelDelegate:self identifier:self.description];
    [SBDMain addConnectionDelegate:self identifier:self.description];

    [self loadOpenTickets];
    [self loadClosedTickets];
    
    if (self.channelUrl != nil && self.channelUrl.length > 0) {
        [self openChatWithChannelUrl:self.channelUrl];
        self.channelUrl = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureStartChatButtonView {
    [self.startChatButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Start a New Conversation" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:18], NSForegroundColorAttributeName: [UIColor whiteColor]}] forState:UIControlStateNormal];
//    self.startChatButton.layer.cornerRadius = 24;
//    self.startChatButton.backgroundColor = [UIColor colorWithRed:214.0f/255.0f green:3.0f/255.0f blue:58.0f/255.0f alpha:1];
    self.startChatContainerView.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:0.5];
    self.startedNewChat = NO;
}

- (IBAction)clickSettingsButton:(id)sender {
    [self openSettings];
}

- (IBAction)clickSettingsBackgroundButton:(id)sender {
    [self openSettings];
}

- (void)openSettings {
    dispatch_async(dispatch_get_main_queue(), ^{
        SBDSKSettingsViewController *vc = [[SBDSKSettingsViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)enterBackground:(NSNotification *)notification {
    [SBDMain getTotalUnreadMessageCountWithCompletionHandler:^(NSUInteger unreadCount, SBDError * _Nullable error) {
        if (error == nil) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
        }
    }];
}

- (IBAction)clickCloseButton:(id)sender {
    [self closeDesk];
}

- (IBAction)clickCloseBackgroundButton:(id)sender {
    [self closeDesk];
}

- (void)closeDesk {
    [SBDMain removeAllChannelDelegates];
    [SBDMain removeAllConnectionDelegates];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [SBDMain getTotalUnreadMessageCountWithCompletionHandler:^(NSUInteger unreadCount, SBDError * _Nullable error) {
            if (error == nil) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
            }
            
            [SBDMain disconnectWithCompletionHandler:^{
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sendbirddesk_user_id"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sendbirddesk_user_nickname"];
            }];
        }];

        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(closeSendBirdDesk)]) {
            [self.delegate closeSendBirdDesk];
        }
    }];
}

- (void)refreshOpenTicketTable {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.openTicketsOffset = 0;
        self.hasMoreOpenTicket = YES;
        [self.openTickets removeAllObjects];
        [self.openTicketTableView reloadData];
        [self loadOpenTickets];
    });
    
}

- (void)refreshClosedTicketTable {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.closedTicketsOffset = 0;
        self.hasMoreClosedTicket = YES;
        [self.closedTickets removeAllObjects];
        [self.closedTicketTableView reloadData];
        [self loadClosedTickets];
    });
}

- (void)loadOpenTickets {
    if (self.hasMoreOpenTicket == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.openTicketRefreshControl endRefreshing];
            self.openTicketActivityIndicator.hidden = YES;
            [self.openTicketActivityIndicator stopAnimating];
        });
        
        return;
    }
    
    if (self.isLoadingOpenTickets) {
        return;
    }
    
    self.isLoadingOpenTickets = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.emptyOpenTicketContainerView.hidden = YES;
        if ([self.openTicketRefreshControl isRefreshing]) {
            self.openTicketActivityIndicator.hidden = YES;
        }
        else {
            if (self.openTicketsOffset == 0) {
                self.openTicketActivityIndicator.hidden = NO;
            }
        }
        [self.openTicketActivityIndicator startAnimating];
        
        [SBDSKTicket getOpenedListWithOffset:self.openTicketsOffset completionHandler:^(NSArray<SBDSKTicket *> * _Nonnull tickets, BOOL hasNext, SBDError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.openTicketRefreshControl endRefreshing];
                    self.openTicketActivityIndicator.hidden = YES;
                    [self.openTicketActivityIndicator stopAnimating];
                });
                
                self.isLoadingOpenTickets = NO;
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                }];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
                
                return;
            }
            
            if (tickets.count == 0) {
                self.hasMoreOpenTicket = NO;
            }
            
            if (self.openTickets.count == 0 && tickets.count == 0 && self.openTicketsOffset == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.emptyOpenTicketContainerView.hidden = NO;
                    [self.openTicketRefreshControl endRefreshing];
                    self.openTicketActivityIndicator.hidden = YES;
                    [self.openTicketActivityIndicator stopAnimating];
                    self.isLoadingOpenTickets = NO;
                });
            }
            else {
                self.openTicketsOffset += tickets.count;
                
                if (tickets.count > 0) {
                    [self.openTickets addObjectsFromArray:tickets];
                    self.isLoadingOpenTickets = NO;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.openTicketRefreshControl endRefreshing];
                        self.openTicketActivityIndicator.hidden = YES;
                        [self.openTicketActivityIndicator stopAnimating];
                        [self.openTicketTableView reloadData];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.openTicketRefreshControl endRefreshing];
                        self.isLoadingOpenTickets = NO;
                    });
                }
            }
        }];
    });
}

- (void)loadClosedTickets {
    if (self.hasMoreClosedTicket == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.closedTicketRefreshControl endRefreshing];
            self.closedTicketActivityIndicator.hidden = YES;
            [self.closedTicketActivityIndicator stopAnimating];
        });
        
        return;
    }
    
    if (self.isLoadingClosedTickets == YES) {
        return;
    }
    
    self.isLoadingClosedTickets = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.emptyClosedTicketContainerView.hidden = YES;
        if ([self.closedTicketRefreshControl isRefreshing]) {
            self.closedTicketActivityIndicator.hidden = YES;
        }
        else {
            if (self.closedTicketsOffset == 0) {
                self.closedTicketActivityIndicator.hidden = NO;
            }
        }
        
        [self.closedTicketActivityIndicator startAnimating];
        
        [SBDSKTicket getClosedListWithOffset:self.closedTicketsOffset completionHandler:^(NSArray<SBDSKTicket *> * _Nonnull tickets, BOOL hasNext, SBDError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.closedTicketRefreshControl endRefreshing];
                    self.closedTicketActivityIndicator.hidden = YES;
                    [self.closedTicketActivityIndicator stopAnimating];
                });
                
                self.isLoadingClosedTickets = NO;
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                }];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
                
                return;
            }
            
            if (tickets.count == 0) {
                self.hasMoreClosedTicket = NO;
            }
            
            if (self.closedTickets.count == 0 && tickets.count == 0 && self.closedTicketsOffset == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.emptyClosedTicketContainerView.hidden = NO;
                    [self.closedTicketRefreshControl endRefreshing];
                    self.closedTicketActivityIndicator.hidden = YES;
                    [self.closedTicketActivityIndicator stopAnimating];
                    self.isLoadingClosedTickets = NO;
                });
            }
            else {
                self.closedTicketsOffset += tickets.count;
                
                if (tickets.count > 0) {
                    [self.closedTickets addObjectsFromArray:tickets];
                    self.isLoadingClosedTickets = NO;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.closedTicketRefreshControl endRefreshing];
                        self.closedTicketActivityIndicator.hidden = YES;
                        [self.closedTicketActivityIndicator stopAnimating];
                        [self.closedTicketTableView reloadData];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.closedTicketRefreshControl endRefreshing];
                        self.isLoadingClosedTickets = NO;
                    });
                }
            }
        }];
    });
}

- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [SBDSKTicket getByChannelUrl:channelUrl completionHandler:^(SBDSKTicket * _Nullable ticket, SBDError * _Nullable error) {
        if (error != nil) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ChattingViewController *vc = [[ChattingViewController alloc] init];
            vc.ticket = ticket;
            vc.previousViewController = self;
            vc.delegate = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:NO completion:nil];
            });
        });
    }];
}

#pragma mark - Tab
- (void)clickOpenTabButton {
    [self.inboxScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)clickClosedTabButton {
    [self.inboxScrollView setContentOffset:CGPointMake(self.inboxScrollView.frame.size.width, 0) animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 78;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (tableView == self.openTicketTableView) {
        SBDSKTicket *ticket = self.openTickets[indexPath.row];
        ChattingViewController *vc = [[ChattingViewController alloc] init];
        vc.ticket = ticket;
        vc.previousViewController = self;
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:NO completion:nil];
        });
    }
    else {
        SBDSKTicket *ticket = self.closedTickets[indexPath.row];
        ChattingViewController *vc = [[ChattingViewController alloc] init];
        vc.ticket = ticket;
        vc.previousViewController = self;
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:NO completion:nil];
        });
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.openTicketTableView) {
        if (self.openTickets.count > 0) {
            self.emptyOpenTicketContainerView.hidden = YES;
        }
        else {
            self.emptyOpenTicketContainerView.hidden = NO;
        }
        return self.openTickets.count;
    }
    else {
        if (self.closedTickets.count > 0) {
            self.emptyClosedTicketContainerView.hidden = YES;
        }
        else {
            self.emptyClosedTicketContainerView.hidden = NO;
        }
        
        return self.closedTickets.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxTicketTableViewCell *cell = nil;
    if (tableView == self.openTicketTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InboxTicketTableViewCell"];
        [cell setModel:self.openTickets[indexPath.row]];

        if (self.openTickets.count > 3) {
            if (indexPath.row == self.openTickets.count - 3) {
                [self loadOpenTickets];
            }
        }
        else if (self.openTickets.count > 2) {
            if (indexPath.row == self.openTickets.count - 2) {
                [self loadOpenTickets];
            }
        }
        else {
            if (indexPath.row == self.openTickets.count - 1) {
                [self loadOpenTickets];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            InboxTicketTableViewCell *updateCell = (InboxTicketTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            SBDSKTicket *ticket = self.openTickets[indexPath.row];
            if (ticket.agent != nil) {
                if (ticket.agent.profileUrl == nil || ticket.agent.profileUrl.length == 0) {
                    [updateCell.agentProfileImageView setImage:[UIImage imageNamed:@"img_default_profile"]];
                }
                else {
                    NSURL *agentProfileImageUrl = [NSURL URLWithString:ticket.agent.profileUrl];
                    [updateCell.agentProfileImageView setImageWithURL:agentProfileImageUrl placeholderImage:[UIImage imageNamed:@"img_default_profile"]];
                }
            }
            else {
                [updateCell.agentProfileImageView setImage:[UIImage imageNamed:@"img_default_profile_vm"]];
            }
        });
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InboxTicketTableViewCell"];
        [cell setClosedTicket];
        [cell setModel:self.closedTickets[indexPath.row]];

        if (self.closedTickets.count > 3) {
            if (indexPath.row == self.closedTickets.count - 3) {
                [self loadClosedTickets];
            }
        }
        else if (self.closedTickets.count > 2) {
            if (indexPath.row == self.closedTickets.count - 2) {
                [self loadClosedTickets];
            }
        }
        else {
            if (indexPath.row == self.closedTickets.count - 1) {
                [self loadClosedTickets];
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.startChatContainerView.bounds.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, self.startChatContainerView.bounds.size.height)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - SBDConnectionDelegate

- (void)didStartReconnection {
    
}

- (void)didSucceedReconnection {
    [self refreshOpenTicketTable];
    [self refreshClosedTicketTable];
}

- (void)didFailReconnection {
    
}

#pragma mark - SBDChannelDelegate

- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    if (![SBDSKMain isDeskChannel:sender]) {
        return;
    }

    [SBDSKTicket getByChannelUrl:sender.channelUrl completionHandler:^(SBDSKTicket * _Nullable ticket, SBDError * _Nullable error) {
        if (error != nil) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![ticket.status isEqualToString:@"CLOSED"]) {
                [self.openTickets removeObject:ticket];
                [self.openTickets insertObject:ticket atIndex:0];
                [self.openTicketTableView reloadData];
            }
            else {
                [self.openTickets removeObject:ticket];
                BOOL found = NO;
                for (SBDSKTicket *tkt in self.closedTickets) {
                    if (tkt.ticketId == ticket.ticketId) {
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    [self.closedTickets insertObject:ticket atIndex:0];
                }
                [self.openTicketTableView reloadData];
                [self.closedTicketTableView reloadData];
            }
        });
    }];
    
    UIViewController *topViewController = [UIViewController currentViewController];
    if ([topViewController isKindOfClass:[InboxViewController class]]) {
        return;
    }
    
    if ([topViewController isKindOfClass:[ChattingViewController class]]) {
        ChattingViewController *vc = (ChattingViewController *)topViewController;
        if (vc.ticket == nil || vc.ticket.channel == nil || (vc.ticket.channel != nil && [vc.ticket.channel.channelUrl isEqualToString:sender.channelUrl])) {
            return;
        }
    }
    
    NSString *title = @"";
    NSString *body = @"";
    NSString *data = @"";
    NSString *type = @"";
    NSString *customType = @"";
    if ([message isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *userMessage = (SBDUserMessage *)message;
        SBDUser *agent = userMessage.sender;
        
        type = @"MESG";
        title = agent.nickname;
        body = userMessage.message;
        customType = userMessage.customType;
        
        if (customType != nil && [customType isEqualToString:@"SENDBIRD_DESK_RICH_MESSAGE"]) {
            data = userMessage.data;
        }
    }
    else if ([message isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)message;
        SBDUser *agent = fileMessage.sender;
        
        title = agent.nickname;
        if ([fileMessage.type hasPrefix:@"image"]) {
            body = @"(Image)";
        }
        else if ([fileMessage.type hasPrefix:@"video"]) {
            body = @"(Video)";
        }
        else if ([fileMessage.type hasPrefix:@"audio"]) {
            body = @"(Audio)";
        }
        else {
            body = @"(File)";
        }
    }
    else if ([message isKindOfClass:[SBDAdminMessage class]]) {
        SBDAdminMessage *adminMessage = (SBDAdminMessage *)message;
        
        if ([adminMessage.customType isEqualToString:@"SENDBIRD_DESK_ADMIN_MESSAGE_CUSTOM_TYPE"]) {
            return;
        }
        title = @"";
        body = adminMessage.message;
    }

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:body arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = @"SBDSK_NEW_MESSAGE";
    content.userInfo = @{
                         @"sendbird": @{
                                 @"type": type,
                                 @"custom_type": customType,
                                 @"channel": @{
                                         @"channel_url": sender.channelUrl,
                                         },
                                 @"data": data,
                                 },
                         };
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"SBDSK_NEW_MESSAGE_%@", sender.channelUrl] content:content trigger:trigger];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            //                NSLog(@"%@", error.localizedDescription);
        }
    }];

}

- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender {
    
}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidEnter:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidExit:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasMuted:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnmuted:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasBanned:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnbanned:(SBDUser * _Nonnull)user {
    
}

- (void)channelWasFrozen:(SBDOpenChannel * _Nonnull)sender {
    
}

- (void)channelWasUnfrozen:(SBDOpenChannel * _Nonnull)sender {
    
}

- (void)channelWasChanged:(SBDBaseChannel * _Nonnull)sender {
    if (![SBDSKMain isDeskChannel:sender]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.openTicketTableView reloadData];
        [self.closedTicketTableView reloadData];
    });
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    if (![SBDSKMain isDeskChannel:sender]) {
        return;
    }
}

#pragma mark - SBDSKViewControllerDelegate
- (void)closeSendBirdDesk {
    [self dismissViewControllerAnimated:NO completion:^{
        [SBDMain getTotalUnreadMessageCountWithCompletionHandler:^(NSUInteger unreadCount, SBDError * _Nullable error) {
            if (error == nil) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
            }
        }];
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(closeSendBirdDesk)]) {
            [self.delegate closeSendBirdDesk];
        }
    }];
    
}

- (void)updateOpenTicket:(long long)ticketId {
    dispatch_async(dispatch_get_main_queue(), ^{
        SBDSKTicket *updatedTicket = nil;
        for (SBDSKTicket *ticket in self.openTickets) {
            if (ticket.ticketId == ticketId) {
                updatedTicket = ticket;
                
                [self.openTickets removeObject:updatedTicket];
                break;
            }
        }
        
        if (updatedTicket != nil) {
            [self.openTickets insertObject:updatedTicket atIndex:0];
            [self.openTicketTableView reloadData];
        }
        else {
            [self refreshOpenTicketTable];
        }
    });
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.inboxScrollView) {
        CGFloat contentOffset = scrollView.contentOffset.x;
        
        if (contentOffset > self.currentOffset) {
            // Move to right
            if (contentOffset > scrollView.frame.size.width / 4.0) {
                [self.openTabButton setTitleColor:[UIColor colorNamed:@"color_tab_title_normal"] forState:UIControlStateNormal];
                [self.closedTabButton setTitleColor:[UIColor colorNamed:@"color_tab_title_selected"] forState:UIControlStateNormal];
                
                self.tabBottomLineViewLeftMargin.constant = 14 + self.openTabButton.frame.size.width;
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:0.1 animations:^{
                    [self.view layoutIfNeeded];
                }];
            }
        }
        else {
            // Move to left
            if (contentOffset < scrollView.frame.size.width / 4.0 * 3.0) {
                [self.openTabButton setTitleColor:[UIColor colorNamed:@"color_tab_title_selected"] forState:UIControlStateNormal];
                [self.closedTabButton setTitleColor:[UIColor colorNamed:@"color_tab_title_normal"] forState:UIControlStateNormal];
                
                self.tabBottomLineViewLeftMargin.constant = 14;
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:0.1 animations:^{
                    [self.view layoutIfNeeded];
                }];
            }
        }
        
        self.currentOffset = contentOffset;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.inboxScrollView) {
        CGFloat contentOffset = scrollView.contentOffset.x;
        
        if (contentOffset > self.currentOffset) {
            // Move to right
            if (contentOffset > scrollView.frame.size.width / 2.0) {
                self.tabBottomLineViewLeftMargin.constant = 14 + self.openTabButton.frame.size.width;
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:0.1 animations:^{
                    [self.view layoutIfNeeded];
                }];
            }
        }
        else {
            // Move to left
            if (contentOffset < scrollView.frame.size.width / 2.0) {
                self.tabBottomLineViewLeftMargin.constant = 14;
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:0.1 animations:^{
                    [self.view layoutIfNeeded];
                }];
            }
        }
        
        self.currentOffset = contentOffset;
    }
}

#pragma mark - IBAction
- (IBAction)startChatButtonTapped:(id)sender {
    NSString *ticketTitle = [NSString stringWithFormat:@"#%lld", (long long)[[NSDate date] timeIntervalSince1970]];
    
    [SBDSKTicket createTicketWithTitle:ticketTitle userName:[SBDMain getCurrentUser].nickname completionHandler:^(SBDSKTicket * _Nullable ticket, SBDError * _Nullable error) {
        if (error != nil) {
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ChattingViewController *vc = [[ChattingViewController alloc] init];
            vc.ticket = ticket;
            [self presentViewController:vc animated:NO completion:nil];
        });
    }];
}

@end
