//
//  ChattingViewController.m
//  QuickStart
//
//  Created by SendBird on 3/20/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "ChattingViewController.h"
#import "SBDSKAdminMessageTableViewCell.h"
#import "SBDSKIncomingInquireCloseTicketMessageTableViewCell.h"
#import "SBDSKOutgoingUserMessageTableViewCell.h"
#import "SBDSKOutgoingUrlPreviewTableViewCell.h"
#import "SBDSKIncomingUserMessageTableViewCell.h"
#import "SBDSKIncomingUrlPreviewTableViewCell.h"
#import "SBDSKIncomingImageFileMessageTableViewCell.h"
#import "SBDSKOutgoingImageFileMessageTableViewCell.h"
#import "SBDSKOutgoingGeneralFileMessageTableViewCell.h"
#import "SBDSKIncomingGeneralFileMessageTableViewCell.h"
#import "SBDSKIncomingVideoFileMessageTableViewCell.h"
#import "SBDSKOutgoingVideoFileMessageTableViewCell.h"
#import "SBDSKFileImage.h"
#import "InboxViewController.h"
#import "SBDSKUtils.h"
#import "SBDSKWebViewController.h"
#import "SBDSKGeneralUrlPreviewTempModel.h"
#import "FLAnimatedImageView+ImageCache.h"
#import "UIViewController+Utils.h"

@interface ChattingViewController ()

// Views
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *inboxButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButtonBackground;
@property (weak, nonatomic) IBOutlet UIView *navigationBottomLineView;
@property (weak, nonatomic) IBOutlet UIButton *fileAttachmentButton;
@property (weak, nonatomic) IBOutlet UITextView *messageInputTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *messageLoadingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIView *messageInputContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *messageInputContainerTopLineView;
@property (weak, nonatomic) IBOutlet UIView *customNavigatorView;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageInputInnerContainerBottomMargin;

// Sizing Cells
@property (strong, nonatomic) SBDSKAdminMessageTableViewCell *adminMessageSizingTableViewCell;
@property (strong, nonatomic) SBDSKIncomingInquireCloseTicketMessageTableViewCell *incomingInquireCloseTicketMessageSizingTableViewCell;
@property (strong, nonatomic) SBDSKOutgoingUserMessageTableViewCell *outgoingUserMessageSizingTableViewCell;
@property (strong, nonatomic) SBDSKOutgoingUrlPreviewTableViewCell *outgoingUrlPreviewSizingTableViewCell;
@property (strong, nonatomic) SBDSKIncomingUserMessageTableViewCell *incomingUserMessageSizingTableViewCell;
@property (strong, nonatomic) SBDSKIncomingUrlPreviewTableViewCell *incomingUrlPreviewSizingTableViewCell;
@property (strong, nonatomic) SBDSKOutgoingImageFileMessageTableViewCell *outgoingImageFileMessageSizingTableViewCell;
@property (strong, nonatomic) SBDSKIncomingImageFileMessageTableViewCell *incomingImageFileMessageSizingTableViewCell;
@property (strong, nonatomic) SBDSKOutgoingGeneralFileMessageTableViewCell *outgoingGeneralFileMessageSizingTableViewCell;
@property (strong, nonatomic) SBDSKIncomingGeneralFileMessageTableViewCell *incomingGeneralFileMessageSizingTableViewCell;
@property (strong, nonatomic) SBDSKOutgoingVideoFileMessageTableViewCell *outgoingVideoFileMessageSizingTableViewCell;
@property (strong, nonatomic) SBDSKIncomingVideoFileMessageTableViewCell *incomingVideoFileMessageSizingTableViewCell;

// Messages
@property (strong, nonatomic) NSMutableArray<SBDBaseMessage *> *messages;
@property (strong, nonatomic) NSMutableDictionary<NSString *, SBDBaseMessage *> *resendableMessages;
@property (strong, nonatomic) NSMutableDictionary<NSString *, SBDBaseMessage *> *preSendMessages;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *resendableFileData;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *preSendFileData;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, SBDBaseMessage *> *messageMap;

// Variables for each state
@property (atomic) BOOL scrollLock;
@property (atomic) BOOL stopMeasuringVelocity;
@property (atomic) CGPoint lastOffset;
@property (atomic) NSTimeInterval lastOffsetCapture;
@property (atomic) BOOL isScrollingFast;
@property (atomic) BOOL keyboardShown;
@property (atomic) BOOL initialLoading;
@property (atomic) CGFloat lastMessageHeight;
@property (atomic) BOOL hasNext;
@property (atomic) long long minMessageTimestamp;
@property (atomic) BOOL isLoading;

// Photo Viewer
@property (strong, nonatomic) NYTPhotosViewController *photosViewController;
@property (weak, nonatomic) IBOutlet UIView *imageViewerLoadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageViewerLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *imageViewerCloseButton;

// File Download
@property (strong, nonatomic) NSURLSessionConfiguration *config;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableDictionary<NSURLSessionDownloadTask *, NSDictionary *> *downloadTasks;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableDictionary *> *fileMessageDownloadingStatus;
@property (strong, nonatomic) UIDocumentInteractionController *interactionController;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *inquireProgressStatus;

@property (strong, nonatomic) SBDFileMessage *currentFileMessageOnViewer;

@end

@implementation ChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    // Initialize keyboard control
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    // Initialize data.
    self.messages = [[NSMutableArray alloc] init];
    
    self.fileMessageDownloadingStatus = [SBDSKUtils initFileCache];

    // Initialize variables
    self.scrollLock = NO;
    self.stopMeasuringVelocity = NO;
    self.keyboardShown = NO;
    self.initialLoading = YES;
    self.lastMessageHeight = 0;
    self.hasNext = YES;
    self.minMessageTimestamp = LLONG_MAX;
    self.isLoading = NO;
    
    self.resendableMessages = [[NSMutableDictionary alloc] init];
    self.preSendMessages = [[NSMutableDictionary alloc] init];
    
    self.resendableFileData = [[NSMutableDictionary alloc] init];
    self.preSendFileData = [[NSMutableDictionary alloc] init];
    
    self.messageMap = [[NSMutableDictionary alloc] init];
    
    // Initialize views.
    self.messageInputTextView.delegate = self;
    self.sendMessageButton.enabled = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 14, 0);
    
    UITapGestureRecognizer *tableViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView)];
    [self.tableView addGestureRecognizer:tableViewTap];
    
    [self.tableView registerNib:[SBDSKAdminMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKAdminMessageTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKIncomingInquireCloseTicketMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKIncomingInquireCloseTicketMessageTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKOutgoingUserMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKOutgoingUserMessageTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKOutgoingUrlPreviewTableViewCell nib] forCellReuseIdentifier:[SBDSKOutgoingUrlPreviewTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKIncomingUserMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKIncomingUserMessageTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKIncomingUrlPreviewTableViewCell nib] forCellReuseIdentifier:[SBDSKIncomingUrlPreviewTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKOutgoingImageFileMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKOutgoingImageFileMessageTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKIncomingImageFileMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKIncomingImageFileMessageTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKOutgoingGeneralFileMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKOutgoingGeneralFileMessageTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKIncomingGeneralFileMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKIncomingGeneralFileMessageTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKOutgoingVideoFileMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKOutgoingVideoFileMessageTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[SBDSKIncomingVideoFileMessageTableViewCell nib] forCellReuseIdentifier:[SBDSKIncomingVideoFileMessageTableViewCell cellReuseIdentifier]];
    
    self.messageInputTextView.textContainerInset = UIEdgeInsetsMake(self.messageInputTextView.textContainerInset.top, 4, self.messageInputTextView.textContainerInset.bottom, 4);// + self.sendMessageButtonWidth.constant);
    
    self.messageInputTextView.layer.cornerRadius = 4;
    self.messageInputTextView.layer.borderColor = [UIColor colorNamed:@"color_input_textfield_border"].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnteredForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self initSizingCell];
    
    self.imageViewerLoadingView.hidden = YES;
    [self.view bringSubviewToFront:self.imageViewerLoadingView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.messageLoadingActivityIndicator.hidden = NO;
        [self.messageLoadingActivityIndicator startAnimating];
    });

    [self startChattingWithExistTicket];
    
    self.config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:self.config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    self.downloadTasks = [[NSMutableDictionary alloc] init];
    self.inquireProgressStatus = [[NSMutableDictionary alloc] init];
}

- (void)handleEnteredForeground:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.keyboardShown) {
            [self.messageInputTextView becomeFirstResponder];
        }
        else {
            [self.messageInputTextView endEditing:YES];
        }
        [self scrollToBottomWithForce:NO];
    });
    
    if (self.ticket != nil) {
        [self.ticket refreshWithCompletionHandler:^(SBDSKTicket * _Nullable ticket, SBDError * _Nullable error) {
            if (error != nil) {
                return;
            }
            
            self.ticket = ticket;
            if ([self.ticket.status isEqualToString:@"CLOSED"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.tableViewBottomMargin.constant = 0;
                    self.messageInputContainerView.hidden = YES;
                    [self.view sendSubviewToBack:self.messageInputContainerView];
                    
                    if (self.keyboardShown == NO) {
                        return;
                    }
                    
                    [self.view layoutIfNeeded];
                    [self scrollToBottomWithForce:NO];
                    [self.view endEditing:YES];
                });
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self.session invalidateAndCancel];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        [SBDSKUtils saveFileCache:self.fileMessageDownloadingStatus];
    });
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)didTapOnTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
}

- (void)initSizingCell {
    // Admin Message
    self.adminMessageSizingTableViewCell = (SBDSKAdminMessageTableViewCell *)[[[SBDSKAdminMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.adminMessageSizingTableViewCell setFrame:self.view.frame];
    [self.adminMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.adminMessageSizingTableViewCell];
    
    // Inquire Close Ticket Message
    self.incomingInquireCloseTicketMessageSizingTableViewCell = (SBDSKIncomingInquireCloseTicketMessageTableViewCell *)[[[SBDSKIncomingInquireCloseTicketMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingInquireCloseTicketMessageSizingTableViewCell setFrame:self.view.frame];
    [self.incomingInquireCloseTicketMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.incomingInquireCloseTicketMessageSizingTableViewCell];
    
    // Outgoing User Message
    self.outgoingUserMessageSizingTableViewCell = (SBDSKOutgoingUserMessageTableViewCell *)[[[SBDSKOutgoingUserMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingUserMessageSizingTableViewCell setFrame:self.view.frame];
    [self.outgoingUserMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.outgoingUserMessageSizingTableViewCell];
    
    // Outgoing URL Preview
    self.outgoingUrlPreviewSizingTableViewCell = (SBDSKOutgoingUrlPreviewTableViewCell *)[[[SBDSKOutgoingUrlPreviewTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingUrlPreviewSizingTableViewCell setFrame:self.view.frame];
    [self.outgoingUrlPreviewSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.outgoingUrlPreviewSizingTableViewCell];
    
    // Incoming User Message
    self.incomingUserMessageSizingTableViewCell = (SBDSKIncomingUserMessageTableViewCell *)[[[SBDSKIncomingUserMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingUserMessageSizingTableViewCell setFrame:self.view.frame];
    [self.incomingUserMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.incomingUserMessageSizingTableViewCell];
    
    // Incoming URL Preview
    self.incomingUrlPreviewSizingTableViewCell = (SBDSKIncomingUrlPreviewTableViewCell *)[[[SBDSKIncomingUrlPreviewTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingUrlPreviewSizingTableViewCell setFrame:self.view.frame];
    [self.incomingUrlPreviewSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.incomingUrlPreviewSizingTableViewCell];
    
    // Outgoing File Image Message
    self.outgoingImageFileMessageSizingTableViewCell = (SBDSKOutgoingImageFileMessageTableViewCell *)[[[SBDSKOutgoingImageFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingImageFileMessageSizingTableViewCell setFrame:self.view.frame];
    [self.outgoingImageFileMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.outgoingImageFileMessageSizingTableViewCell];
    
    // Incoming File Image Message
    self.incomingImageFileMessageSizingTableViewCell = (SBDSKIncomingImageFileMessageTableViewCell *)[[[SBDSKIncomingImageFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingImageFileMessageSizingTableViewCell setFrame:self.view.frame];
    [self.incomingImageFileMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.incomingImageFileMessageSizingTableViewCell];
    
    // Outgoing General File Message
    self.outgoingGeneralFileMessageSizingTableViewCell = (SBDSKOutgoingGeneralFileMessageTableViewCell *)[[[SBDSKOutgoingGeneralFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingGeneralFileMessageSizingTableViewCell setFrame:self.view.frame];
    [self.outgoingGeneralFileMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.outgoingGeneralFileMessageSizingTableViewCell];
    
    // Incoming General File Message
    self.incomingGeneralFileMessageSizingTableViewCell = (SBDSKIncomingGeneralFileMessageTableViewCell *)[[[SBDSKIncomingGeneralFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingGeneralFileMessageSizingTableViewCell setFrame:self.view.frame];
    [self.incomingGeneralFileMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.incomingGeneralFileMessageSizingTableViewCell];
    
    // Outgoing File Video Message
    self.outgoingVideoFileMessageSizingTableViewCell = (SBDSKOutgoingVideoFileMessageTableViewCell *)[[[SBDSKOutgoingVideoFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingVideoFileMessageSizingTableViewCell setFrame:self.view.frame];
    [self.outgoingVideoFileMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.outgoingVideoFileMessageSizingTableViewCell];
    
    // Incoming File Video Message
    self.incomingVideoFileMessageSizingTableViewCell = (SBDSKIncomingVideoFileMessageTableViewCell *)[[[SBDSKIncomingVideoFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingVideoFileMessageSizingTableViewCell setFrame:self.view.frame];
    [self.incomingVideoFileMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:self.incomingVideoFileMessageSizingTableViewCell];
}

- (void)startChattingWithExistTicket {
    self.titleLabel.text = self.ticket.title;
    
    [self loadPreviousMessage:YES checkDowntime:YES];
}

- (void)startChattingWithChannel {
    self.titleLabel.text = [NSString stringWithFormat:@"#%lld", self.ticket.ticketId];
    
    [self loadPreviousMessage:YES checkDowntime:YES];
}

// Actions for buttons
- (IBAction)clickInboxButton:(id)sender {
    [self openInbox];
}

- (IBAction)clickInboxBackgroundButton:(id)sender {
    [self openInbox];
}

- (void)openInbox {
    [SBDMain removeChannelDelegateForIdentifier:self.description];
    [SBDMain removeConnectionDelegateForIdentifier:self.description];
    
    [SBDMain getTotalUnreadMessageCountWithCompletionHandler:^(NSUInteger unreadCount, SBDError * _Nullable error) {
        if (error == nil) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
        }
    }];
    
    if (self.previousViewController != nil) {
        if ([self.previousViewController isKindOfClass:[InboxViewController class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromLeft;
                [self.view.window.layer addAnimation:transition forKey:nil];
                [self dismissViewControllerAnimated:NO completion:nil];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromLeft;
                [self.view.window.layer addAnimation:transition forKey:nil];
                [self dismissViewControllerAnimated:NO completion:^{
//                    [self startInboxWithTransition:NO];
                }];
            });
        }
    }
    else {
        // Just open.
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionPush;
            transition.subtype = kCATransitionFromLeft;
            [self.view.window.layer addAnimation:transition forKey:nil];
            [self dismissViewControllerAnimated:NO completion:^{
//                [SBDSKMain startInbox];
            }];
        });
    }
}

- (IBAction)clickCloseButton:(id)sender {
    [self closeDesk];
}

- (IBAction)clickCloseBackgroundButton:(id)sender {
    [self closeDesk];
}

- (void)closeDesk {
    [SBDMain removeChannelDelegateForIdentifier:self.description];
    [SBDMain removeConnectionDelegateForIdentifier:self.description];
    
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.delegate != nil) {
            [self.delegate closeSendBirdDesk];
        }
    }];
}

- (IBAction)clickFileAttachmentButton:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"Upload a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
        mediaUI.mediaTypes = mediaTypes;
        [mediaUI setDelegate:self];
        [self presentViewController:mediaUI animated:YES completion:^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
            }];
        }];
    }];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
        cameraUI.mediaTypes = mediaTypes;
        cameraUI.allowsEditing = NO;
        cameraUI.delegate = self;
        [self presentViewController:cameraUI animated:YES  completion:nil];
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *videoLibraryAction = [UIAlertAction actionWithTitle:@"Upload a video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
        mediaUI.mediaTypes = mediaTypes;
        [mediaUI setDelegate:self];
        [self presentViewController:mediaUI animated:YES completion:nil];
    }];
    UIAlertAction *takeVideoAction = [UIAlertAction actionWithTitle:@"Take a video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
        cameraUI.mediaTypes = mediaTypes;
        cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        cameraUI.allowsEditing = NO;
        cameraUI.delegate = self;
        [self presentViewController:cameraUI animated:YES  completion:nil];
    }];
    
    [vc addAction:photoLibraryAction];
    [vc addAction:takePhotoAction];
    
    [vc addAction:videoLibraryAction];
    [vc addAction:takeVideoAction];
    
    [vc addAction:closeAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            UIPopoverPresentationController *popover = vc.popoverPresentationController;
            vc.modalPresentationStyle = UIModalPresentationPopover;
            popover.sourceView = self.fileAttachmentButton;
            popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
            [self presentViewController:vc animated:YES completion:nil];
        }
        else {
            [self presentViewController:vc animated:YES completion:nil];
        }
    });
}

- (IBAction)clickSendMessageButton:(id)sender {
    if (self.messageInputTextView.text.length > 0) {
        self.sendMessageButton.enabled = NO;
        NSString *messageText = [self.messageInputTextView.text copy];
        self.messageInputTextView.text = @"";
        
        self.placeholderLabel.hidden = NO;
        self.sendMessageButton.enabled = NO;
        
//        self.messageInputTextView.layer.borderWidth = [SBDSKMain sharedInstance].messageInputTextViewStandbyBorderWidth;
//        self.messageInputTextView.layer.borderColor = [SBDSKMain sharedInstance].messageInputTextViewStandbyBorderColor.CGColor;
//        self.messageInputTextView.backgroundColor = [SBDSKMain sharedInstance].messageInputTextViewStandbyBackgroundColor;
//
//        self.messageInputTextViewHeight.constant = MESSAGE_INPUT_TEXTVIEW_HEIGHT;
        
        // URL Preview
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        if (error == nil) {
            NSArray *matches = [detector matchesInString:messageText options:0 range:NSMakeRange(0, messageText.length)];
            NSURL *url = nil;
            for (NSTextCheckingResult *match in matches) {
                url = [match URL];
                break;
            }
            
            if (url != nil) {
                SBDSKGeneralUrlPreviewTempModel *tempModel = [[SBDSKGeneralUrlPreviewTempModel alloc] init];
                tempModel.createdAt = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
                tempModel.message = messageText;
                
                [self.messages addObject:tempModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self scrollToBottomWithForce:YES];
                    });
                });
                
                // Send preview;
                [self sendUrlPreview:url message:messageText tempModel:tempModel];
                
                return;
            }
        }
        
        SBDUserMessageParams *params = [[SBDUserMessageParams alloc] initWithMessage:messageText];
        SBDUserMessage *preSendMessage = [self.ticket.channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                SBDUserMessage *preSendMessage = (SBDUserMessage *)self.preSendMessages[userMessage.requestId];
                [self.preSendMessages removeObjectForKey:userMessage.requestId];
                
                if (error != nil) {
                    self.resendableMessages[userMessage.requestId] = userMessage;
                    [self.tableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self scrollToBottomWithForce:YES];
                    });
                    
                    return;
                }
                
                if (self.delegate != nil) {
                    [self.delegate updateOpenTicket:self.ticket.ticketId];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (preSendMessage != nil) {
                        [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:userMessage];
                    }
                    
                    NSIndexPath *index = [NSIndexPath indexPathForRow:[self.messages indexOfObject:preSendMessage] inSection:0];
                    [UIView setAnimationsEnabled:NO];
                    [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
                    [UIView setAnimationsEnabled:YES];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self scrollToBottomWithForce:YES];
                    });
                });
                
            });
        }];
        self.preSendMessages[preSendMessage.requestId] = preSendMessage;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.preSendMessages[preSendMessage.requestId] == nil) {
                return;
            }
            [self.tableView beginUpdates];
            [self.messages addObject:preSendMessage];
            
            [UIView setAnimationsEnabled:NO];
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messages indexOfObject:preSendMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [UIView setAnimationsEnabled:YES];
            [self.tableView endUpdates];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToBottomWithForce:YES];
                self.sendMessageButton.enabled = YES;
            });
        });
    }
}

- (void)sendUrlPreview:(NSURL * _Nonnull)url message:(NSString * _Nonnull)message tempModel:(SBDSKGeneralUrlPreviewTempModel * _Nonnull)aTempModel {
    SBDSKGeneralUrlPreviewTempModel *tempModel = aTempModel;
    NSURL *preViewUrl = url;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            [self sendMessageWithReplacement:aTempModel];
            [session invalidateAndCancel];
            
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *contentType = (NSString *)httpResponse.allHeaderFields[@"Content-Type"];
        if ([contentType containsString:@"text/html"]) {
            NSString *htmlBody = [NSString stringWithUTF8String:[data bytes]];
            
            HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlBody];
            HTMLDocument *document = [parser parseDocument];
            HTMLElement *head = document.head;
            
            NSString *title = nil;
            NSString *desc = nil;
            
            NSString *ogUrl = nil;
            NSString *ogSiteName = nil;
            NSString *ogTitle = nil;
            NSString *ogDesc = nil;
            NSString *ogImage = nil;
            NSString *ogImageUrl = nil;
            
            NSString *twtUrl = nil;
            NSString *twtSiteName = nil;
            NSString *twtTitle = nil;
            NSString *twtDesc = nil;
            NSString *twtImage = nil;
            
            NSString *finalUrl = nil;
            NSString *finalTitle = nil;
            NSString *finalSiteName = nil;
            NSString *finalDesc = nil;
            NSString *finalImage = nil;
            
            for (id node in head.childNodes) {
                if ([node isKindOfClass:[HTMLElement class]]) {
                    HTMLElement *element = (HTMLElement *)node;
                    if ([element.tagName isEqualToString:@"meta"]) {
                        if (element.attributes[@"property"] != nil && ![element.attributes[@"property"] isKindOfClass:[NSNull class]]) {
                            if (ogUrl == nil && [element.attributes[@"property"] isEqualToString:@"og:url"]) {
                                ogUrl = element.attributes[@"content"];
                                //                                NSLog(@"URL - %@", element.attributes[@"content"]);
                            }
                            else if (ogSiteName == nil && [element.attributes[@"property"] isEqualToString:@"og:site_name"]) {
                                ogSiteName = element.attributes[@"content"];
                                //                                NSLog(@"Site Name - %@", element.attributes[@"content"]);
                            }
                            else if (ogTitle == nil && [element.attributes[@"property"] isEqualToString:@"og:title"]) {
                                ogTitle = element.attributes[@"content"];
                                //                                NSLog(@"Title - %@", element.attributes[@"content"]);
                            }
                            else if (ogDesc == nil && [element.attributes[@"property"] isEqualToString:@"og:description"]) {
                                ogDesc = element.attributes[@"content"];
                                //                                NSLog(@"Description - %@", element.attributes[@"content"]);
                            }
                            else if (ogImage == nil && [element.attributes[@"property"] isEqualToString:@"og:image"]) {
                                ogImage = element.attributes[@"content"];
                                //                                NSLog(@"Image - %@", element.attributes[@"content"]);
                            }
                            else if (ogImageUrl == nil && [element.attributes[@"property"] isEqualToString:@"og:image:url"]) {
                                ogImageUrl = element.attributes[@"content"];
                                //                                NSLog(@"Image URL - %@", element.attributes[@"content"]);
                            }
                        }
                        else if (element.attributes[@"name"] != nil && ![element.attributes[@"name"] isKindOfClass:[NSNull class]]) {
                            if (twtSiteName == nil && [element.attributes[@"name"] isEqualToString:@"twitter:site"]) {
                                twtSiteName = element.attributes[@"content"];
                                //                                NSLog(@"Site Name - %@", element.attributes[@"content"]);
                            }
                            else if (twtTitle == nil && [element.attributes[@"name"] isEqualToString:@"twitter:title"]) {
                                twtTitle = element.attributes[@"content"];
                                //                                NSLog(@"Title - %@", element.attributes[@"content"]);
                            }
                            else if (twtDesc == nil && [element.attributes[@"name"] isEqualToString:@"twitter:description"]) {
                                twtDesc = element.attributes[@"content"];
                                //                                NSLog(@"Description - %@", element.attributes[@"content"]);
                            }
                            else if (twtImage == nil && [element.attributes[@"name"] isEqualToString:@"twitter:image"]) {
                                twtImage = element.attributes[@"content"];
                                //                                NSLog(@"Image - %@", element.attributes[@"content"]);
                            }
                            else if (desc == nil && [element.attributes[@"name"] isEqualToString:@"description"]) {
                                desc = element.attributes[@"content"];
                            }
                        }
                    }
                    else if ([element.tagName isEqualToString:@"title"]) {
                        if (element.childNodes.count > 0) {
                            if ([element.childNodes[0] isKindOfClass:[HTMLText class]]) {
                                title = ((HTMLText *)element.childNodes[0]).data;
                            }
                        }
                    }
                }
            }
            
            if (ogUrl != nil) {
                finalUrl = ogUrl;
            }
            else if (twtUrl != nil) {
                finalUrl = twtUrl;
            }
            else {
                finalUrl = [preViewUrl absoluteString];
            }
            
            if (ogSiteName != nil) {
                finalSiteName = ogSiteName;
            }
            else if (twtSiteName != nil) {
                finalSiteName = twtSiteName;
            }
            else {
                finalSiteName = @"";
            }
            
            if (title != nil) {
                finalTitle = title;
            }
            else if (ogTitle != nil) {
                finalTitle = ogTitle;
            }
            else if (twtTitle != nil) {
                finalTitle = twtTitle;
            }
            
            if (ogDesc != nil) {
                finalDesc = ogDesc;
            }
            else if (twtDesc != nil) {
                finalDesc = twtDesc;
            }
            else {
                finalDesc = @"";
            }
            
            if (ogImage != nil) {
                finalImage = ogImage;
            }
            else if (ogImageUrl != nil) {
                finalImage = ogImageUrl;
            }
            else if (twtImage != nil) {
                finalImage = twtImage;
            }
            
            if (!(finalUrl == nil || finalTitle == nil || finalImage == nil)) {
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                data[@"type"] = @"SENDBIRD_DESK_URL_PREVIEW";
                data[@"body"] = @{
                                  @"title": finalTitle,
                                  @"image": finalImage,
                                  @"url": finalUrl,
                                  @"site_name": finalSiteName,
                                  @"description": finalDesc,
                                  };
                NSError *err;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&err];
                NSString *dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                SBDUserMessageParams *params = [[SBDUserMessageParams alloc] initWithMessage:message];
                params.data = dataString;
                params.customType = @"SENDBIRD_DESK_RICH_MESSAGE";
                [self.ticket.channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                    // Do nothing.
                    
                    if (error != nil) {
                        [self sendMessageWithReplacement:aTempModel];
                        
                        return;
                    }
                    
                    [self.messages replaceObjectAtIndex:[self.messages indexOfObject:tempModel] withObject:userMessage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self scrollToBottomWithForce:YES];
                        });
                    });
                }];
            }
            else {
                [self sendMessageWithReplacement:aTempModel];
            }
        }
        
        [session invalidateAndCancel];
    }] resume];
}

- (void)sendMessageWithReplacement:(SBDSKGeneralUrlPreviewTempModel * _Nonnull)replacement {
    SBDUserMessageParams *params = [[SBDUserMessageParams alloc] initWithMessage:replacement.message];
    params.targetLanguages = @[@"ar", @"de", @"fr", @"nl", @"ja", @"ko", @"pt", @"es", @"zh-CHS"];
    SBDUserMessage *preSendMessage = [self.ticket.channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            SBDUserMessage *preSendMessage = (SBDUserMessage *)self.preSendMessages[userMessage.requestId];
            [self.preSendMessages removeObjectForKey:userMessage.requestId];
            
            if (error != nil) {
                self.resendableMessages[userMessage.requestId] = userMessage;
                [self.tableView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scrollToBottomWithForce:YES];
                });
                
                return;
            }
            
            if (preSendMessage != nil) {
                [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:userMessage];
            }
            
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToBottomWithForce:YES];
            });
        });
    }];
    [self.messages replaceObjectAtIndex:[self.messages indexOfObject:replacement] withObject:preSendMessage];
    self.preSendMessages[preSendMessage.requestId] = preSendMessage;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToBottomWithForce:YES];
        });
    });
}

- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self dismissViewControllerAnimated:NO completion:^{
        InboxViewController *currentVc = (InboxViewController *)[UIViewController currentViewController];
        [currentVc openChatWithChannelUrl:channelUrl];
    }];
}

#pragma mark - Load messages
- (void)loadPreviousMessage:(BOOL)initial checkDowntime:(BOOL)checkDowntime {
    long long timestamp = 0;
    if (initial) {
        self.hasNext = YES;
        timestamp = LLONG_MAX;
    }
    else {
        timestamp = self.minMessageTimestamp;
    }
    
    if (self.hasNext == NO) {
        return;
    }
    
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    [self.ticket.channel getPreviousMessagesByTimestamp:timestamp limit:30 reverse:!initial messageType:SBDMessageTypeFilterAll customType:nil completionHandler:^(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error) {
        if (error != nil) {
            self.isLoading = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.messageLoadingActivityIndicator.hidden = YES;
            });
            
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Customer Service Error" message:@"Failed to load messages. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:^{
                    [self closeDesk];
                }];
            }];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            return;
        }
        
        if (messages.count == 0) {
            self.hasNext = NO;
        }
        
        if (initial) {
            [self.messages removeAllObjects];
            [self.messageMap removeAllObjects];
            
            for (SBDBaseMessage *message in messages) {
                if (self.minMessageTimestamp > message.createdAt) {
                    self.minMessageTimestamp = message.createdAt;
                }
                
                if ([message isKindOfClass:[SBDAdminMessage class]]) {
                    SBDAdminMessage *adminMessage = (SBDAdminMessage *)message;
                    
                    if ([adminMessage.customType isEqualToString:@"SENDBIRD_DESK_ADMIN_MESSAGE_CUSTOM_TYPE"]) {
                        NSDictionary *result = nil;
                        NSError *error = nil;
                        @autoreleasepool {
                            result = [NSJSONSerialization JSONObjectWithData:[adminMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                        }
                        
                        if ([result[@"type"] isEqualToString:@"TICKET_CLOSE"]) {
//                            self.tableViewBottomMargin.constant = 0;
                            self.messageInputContainerView.hidden = YES;
                            [self.view sendSubviewToBack:self.messageInputContainerView];
                        }
                        
                        continue;
                    }
                }
                
                if (self.messageMap[@(message.messageId)] == nil) {
                    [self.messages addObject:message];
                    self.messageMap[@(message.messageId)] = message;
                }
                else {
                    NSLog(@"Duplicated message.");
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *resendableMessagesKeys = [self.resendableMessages allKeys];
                for (NSString *key in resendableMessagesKeys) {
                    [self.messages addObject:self.resendableMessages[key]];
                }
                
                NSArray *preSendMessagesKeys = [self.preSendMessages allKeys];
                for (NSString *key in preSendMessagesKeys) {
                    [self.messages addObject:self.preSendMessages[key]];
                }
            });
            
            if ([UIViewController currentViewController] == self) {
                [self.ticket.channel markAsRead];
            }
            
            self.initialLoading = YES;
            
            if (messages.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.tableView layoutIfNeeded];
                    
//                    CGFloat keyboardHeight = 0;
//                    if (self.keyboardShown) {
//                        keyboardHeight = self.tableViewBottomMargin.constant;
//                    }
//
//                    CGFloat viewHeight = [[UIScreen mainScreen] bounds].size.height - self.customNavigatorView.frame.size.height - self.tableViewBottomMargin.constant - keyboardHeight - 14;
//
//                    CGSize contentSize = self.tableView.contentSize;
//
//                    if (contentSize.height > viewHeight) {
//                        CGPoint newContentOffset = CGPointMake(0, contentSize.height - viewHeight);
//                        [self.tableView setContentOffset:newContentOffset animated:NO];
//                        [self scrollToBottomWithForce:YES];
//                    }
                    
                    [self scrollToBottomWithForce:YES];
                    
                    self.messageLoadingActivityIndicator.hidden = YES;
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.messageLoadingActivityIndicator.hidden = YES;
                });
            }
            
//            self.initialLoading = NO;
            self.isLoading = NO;
            
            // Initialize SendBirdSDK delegate
            [SBDMain addChannelDelegate:self identifier:self.description];
            [SBDMain addConnectionDelegate:self identifier:self.description];
            
            if (self.ticket != nil && ![self.ticket.status isEqualToString:@"CLOSED"] && checkDowntime) {
//                if (![self checkIfLastMessageIsDowntimeMessage]) {
//                    [self checkDowntimeMessage];
//                }
            }
        }
        else {
            if (messages.count > 0) {
                for (SBDBaseMessage *message in messages) {
                    if (self.minMessageTimestamp > message.createdAt) {
                        self.minMessageTimestamp = message.createdAt;
                    }
                    
                    if ([message isKindOfClass:[SBDAdminMessage class]]) {
                        SBDAdminMessage *adminMessage = (SBDAdminMessage *)message;
                        
                        if ([adminMessage.customType isEqualToString:@"SENDBIRD_DESK_ADMIN_MESSAGE_CUSTOM_TYPE"]) {
                            continue;
                        }
                    }
                    
                    if (self.messageMap[@(message.messageId)] == nil) {
                        [self.messages insertObject:message atIndex:0];
                        self.messageMap[@(message.messageId)] = message;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGSize contentSizeBefore = self.tableView.contentSize;
                    
                    [self.tableView reloadData];
                    [self.tableView layoutIfNeeded];
                    
                    CGSize contentSizeAfter = self.tableView.contentSize;
                    
                    CGPoint newContentOffset = CGPointMake(0, contentSizeAfter.height - contentSizeBefore.height);
                    [self.tableView setContentOffset:newContentOffset animated:NO];
                });
            }
            
            self.isLoading = NO;
        }
    }];
}

- (void)enterBackground:(NSNotification *)notification {
    [SBDMain getTotalUnreadMessageCountWithCompletionHandler:^(NSUInteger unreadCount, SBDError * _Nullable error) {
        if (error == nil) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
        }
    }];
}

#pragma mark - Keyboard control
- (void)keyboardWillShow:(NSNotification *)notification {
    self.keyboardShown = YES;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Keyboard Height: %lf", keyboardFrameBeginRect.size.height);
        self.tableViewBottomMargin.constant = keyboardFrameBeginRect.size.height + 44 - self.view.safeAreaInsets.bottom;
        self.messageInputInnerContainerBottomMargin.constant = keyboardFrameBeginRect.size.height - self.view.safeAreaInsets.bottom;
        [self.view layoutIfNeeded];
        self.stopMeasuringVelocity = YES;
        [self scrollToBottomWithForce:NO];
    });
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardShown = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableViewBottomMargin.constant = 44;
        self.messageInputInnerContainerBottomMargin.constant = 0;
        [self.view layoutIfNeeded];
        [self scrollToBottomWithForce:NO];
    });
}

- (void)hideKeyboardWhenFastScrolling {
    if (self.keyboardShown == NO) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableViewBottomMargin.constant = 44;
        self.messageInputInnerContainerBottomMargin.constant = 0;
//        if ([SBDSKUtils isIPhoneX]) {
//            self.messageInputContainerViewBottomMarginViewHeight.constant = MESSAGE_INPUT_BOTTOM_MARGIN_IPHONEX;
//        }
//        else {
//            self.messageInputContainerViewBottomMarginViewHeight.constant = 0;
//        }
//        self.tableViewBottomMargin.constant = TABLEVIEW_BOTTOM_MARGIN + self.messageInputContainerViewBottomMarginViewHeight.constant;
        [self.view layoutIfNeeded];
        [self scrollToBottomWithForce:NO];
        
        [self.view endEditing:YES];
    });
}

#pragma mark - Scrolling
- (void)scrollToBottomWithForce:(BOOL)force {
    if (self.messages.count == 0) {
        return;
    }
    
    if (self.scrollLock && force == NO) {
        return;
    }
    
    NSInteger currentRowNumber = [self.tableView numberOfRowsInSection:0];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowNumber - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    self.initialLoading = NO;
}

- (void)scrollToPosition:(NSInteger)position {
    if (self.messages.count == 0) {
        return;
    }
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.messageInputTextView) {
        if (textView.text.length > 0) {
            self.placeholderLabel.hidden = YES;
            self.sendMessageButton.enabled = YES;
            
//            self.messageInputTextView.layer.borderWidth = [SBDSKMain sharedInstance].messageInputTextViewActiveBorderWidth;
//            self.messageInputTextView.layer.borderColor = [SBDSKMain sharedInstance].messageInputTextViewActiveBorderColor.CGColor;
//            self.messageInputTextView.backgroundColor = [SBDSKMain sharedInstance].messageInputTextViewActiveBackgroundColor;
            
//            if (self.messageInputTextView.contentSize.height <= MESSAGE_INPUT_TEXTVIEW_HEIGHT) {
//                self.messageInputTextViewHeight.constant = MESSAGE_INPUT_TEXTVIEW_HEIGHT;
//            }
//            else if (self.messageInputTextView.contentSize.height > MESSAGE_INPUT_TEXTVIEW_HEIGHT && self.messageInputTextView.contentSize.height <= MESSAGE_INPUT_TEXTVIEW_HEIGHT * 1.5) {
//                self.messageInputTextViewHeight.constant = MESSAGE_INPUT_TEXTVIEW_HEIGHT * 1.2;
//            }
//            else {
//                self.messageInputTextViewHeight.constant = MESSAGE_INPUT_TEXTVIEW_HEIGHT * 1.5;
//            }
        }
        else {
            self.placeholderLabel.hidden = NO;
            self.sendMessageButton.enabled = NO;
            
//            self.messageInputTextView.layer.borderWidth = [SBDSKMain sharedInstance].messageInputTextViewStandbyBorderWidth;
//            self.messageInputTextView.layer.borderColor = [SBDSKMain sharedInstance].messageInputTextViewStandbyBorderColor.CGColor;
//            self.messageInputTextView.backgroundColor = [SBDSKMain sharedInstance].messageInputTextViewStandbyBackgroundColor;
//
//            self.messageInputTextViewHeight.constant = MESSAGE_INPUT_TEXTVIEW_HEIGHT;
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.stopMeasuringVelocity = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.stopMeasuringVelocity = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        if (self.stopMeasuringVelocity == NO) {
            CGPoint currentOffset = scrollView.contentOffset;
            NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
            
            NSTimeInterval timeDiff = currentTime - self.lastOffsetCapture;
            if (timeDiff > 0.1) {
                CGFloat distance = currentOffset.y - self.lastOffset.y;
                //The multiply by 10, / 1000 isn't really necessary.......
                CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
                
                CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
                if (scrollSpeed > 0.5) {
                    self.isScrollingFast = YES;
                } else {
                    self.isScrollingFast = NO;
                }
                
                self.lastOffset = currentOffset;
                self.lastOffsetCapture = currentTime;
            }
            
            if (self.isScrollingFast) {
                [self hideKeyboardWhenFastScrolling];
            }
        }
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height + self.lastMessageHeight < scrollView.contentSize.height) {
            self.scrollLock = YES;
        }
        else {
            self.scrollLock = NO;
        }
        
        if (scrollView.contentOffset.y == 0) {
            if (self.messages.count > 0 && self.initialLoading == NO) {
                [self loadPreviousMessage:NO checkDowntime:NO];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 200;
    UITableViewCell *cell = nil;
    if (tableView == self.tableView) {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        
        if ([baseMessage isKindOfClass:[SBDAdminMessage class]]) {
            SBDAdminMessage *adminMessage = (SBDAdminMessage *)baseMessage;
            
            cell = self.adminMessageSizingTableViewCell;
            [cell setFrame:self.view.frame];
            
            if (indexPath.row > 0) {
                [((SBDSKAdminMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
            }
            else {
                [((SBDSKAdminMessageTableViewCell *)cell) setPreviousMessage:nil];
            }
            
            [((SBDSKAdminMessageTableViewCell *)cell) setModel:adminMessage];
            height = [((SBDSKAdminMessageTableViewCell *)cell) cellHeight];
        }
        else if ([baseMessage isKindOfClass:[SBDUserMessage class]]) {
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            if ([userMessage.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                // Outgoing
                BOOL hasUrlPreview = NO;
                if (userMessage.customType != nil && [userMessage.customType isEqualToString:@"SENDBIRD_DESK_RICH_MESSAGE"]) {
                    NSDictionary *customData = nil;
                    NSError *jsonError = nil;
                    @autoreleasepool {
                        customData = [NSJSONSerialization JSONObjectWithData:[userMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
                    }
                    
                    if (customData[@"type"] != nil && ![customData[@"type"] isKindOfClass:[NSNull class]] && [customData[@"type"] isEqualToString:@"SENDBIRD_DESK_URL_PREVIEW"]) {
                        hasUrlPreview = YES;
                    }
                }
                
                if (hasUrlPreview) {
                    cell = self.outgoingUrlPreviewSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) setModel:userMessage];
                    height = [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) cellHeight];
                }
                else {
                    cell = self.outgoingUserMessageSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingUserMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingUserMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingUserMessageTableViewCell *)cell) setModel:userMessage];
                    height = [((SBDSKOutgoingUserMessageTableViewCell *)cell) cellHeight];
                }
            }
            else {
                // Incoming
                BOOL isRichMessage = NO;
                BOOL hasUrlPreview = NO;
                if (userMessage.customType != nil && [userMessage.customType isEqualToString:@"SENDBIRD_DESK_RICH_MESSAGE"]) {
                    isRichMessage = YES;
                    NSDictionary *customData = nil;
                    NSError *jsonError = nil;
                    @autoreleasepool {
                        customData = [NSJSONSerialization JSONObjectWithData:[userMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
                    }
                    
                    if (customData[@"type"] != nil && ![customData[@"type"] isKindOfClass:[NSNull class]] && [customData[@"type"] isEqualToString:@"SENDBIRD_DESK_URL_PREVIEW"]) {
                        hasUrlPreview = YES;
                    }
                    
                    //                    if (customData[@"type"] != nil && ![customData[@"type"] isKindOfClass:[NSNull class]] && [customData[@"type"] isEqualToString:@"SENDBIRD_DESK_INQUIRE_TICKET_CLOSURE"]) {
                    //                        hasTicketClosure = YES;
                    //                    }
                }
                
                if (isRichMessage && !hasUrlPreview) {
                    NSDictionary *customData = nil;
                    NSError *jsonError = nil;
                    @autoreleasepool {
                        customData = [NSJSONSerialization JSONObjectWithData:[userMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
                    }
                    
                    if (customData != nil || jsonError == nil) {
                        cell = self.incomingInquireCloseTicketMessageSizingTableViewCell;
                        [cell setFrame:self.view.frame];
                        
                        if (indexPath.row > 0) {
                            [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                        }
                        else {
                            [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setPreviousMessage:nil];
                        }
                        
                        if (self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", userMessage.messageId]] != nil) {
                            [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setInquireStatus:self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", userMessage.messageId]]];
                        }
                        else {
                            [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setInquireStatus:@""];
                        }
                        
                        [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setModel:userMessage];
                        height = [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) cellHeight];
                    }
                    else {
                        cell = self.incomingUserMessageSizingTableViewCell;
                        [cell setFrame:self.view.frame];
                        
                        if (indexPath.row > 0) {
                            [((SBDSKIncomingUserMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                        }
                        else {
                            [((SBDSKIncomingUserMessageTableViewCell *)cell) setPreviousMessage:nil];
                        }
                        
                        [((SBDSKIncomingUserMessageTableViewCell *)cell) setModel:userMessage];
                        height = [((SBDSKIncomingUserMessageTableViewCell *)cell) cellHeight];
                    }
                }
                else if (isRichMessage && hasUrlPreview) {
                    cell = self.incomingUrlPreviewSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingUrlPreviewTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingUrlPreviewTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKIncomingUrlPreviewTableViewCell *)cell) setModel:userMessage];
                    height = [((SBDSKIncomingUrlPreviewTableViewCell *)cell) cellHeight];
                }
                else {
                    cell = self.incomingUserMessageSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingUserMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingUserMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKIncomingUserMessageTableViewCell *)cell) setModel:userMessage];
                    height = [((SBDSKIncomingUserMessageTableViewCell *)cell) cellHeight];
                }
            }
        }
        else if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
            SBDFileMessage *fileMessage = (SBDFileMessage *)baseMessage;
            if ([fileMessage.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                // Outgoing
                if ([fileMessage.type hasPrefix:@"image"]) {
                    cell = self.outgoingImageFileMessageSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingImageFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingImageFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingImageFileMessageTableViewCell *)cell) setModel:fileMessage];
                    height = [((SBDSKOutgoingImageFileMessageTableViewCell *)cell) cellHeight];
                }
                // Outgoing
                else if ([fileMessage.type hasPrefix:@"video"]) {
                    cell = self.outgoingVideoFileMessageSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingVideoFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingVideoFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingVideoFileMessageTableViewCell *)cell) setModel:fileMessage];
                    height = [((SBDSKOutgoingVideoFileMessageTableViewCell *)cell) cellHeight];
                }
                else {
                    cell = self.outgoingGeneralFileMessageSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) setModel:fileMessage];
                    height = [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) cellHeight];
                }
            }
            else {
                // Incoming
                if ([fileMessage.type hasPrefix:@"image"]) {
                    cell = self.incomingImageFileMessageSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingImageFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingImageFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKIncomingImageFileMessageTableViewCell *)cell) setModel:fileMessage];
                    height = [((SBDSKIncomingImageFileMessageTableViewCell *)cell) cellHeight];
                }
                else if ([fileMessage.type hasPrefix:@"video"]) {
                    cell = self.incomingVideoFileMessageSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingVideoFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingVideoFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKIncomingVideoFileMessageTableViewCell *)cell) setModel:fileMessage];
                    height = [((SBDSKIncomingVideoFileMessageTableViewCell *)cell) cellHeight];
                }
                else {
                    cell = self.incomingGeneralFileMessageSizingTableViewCell;
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setModel:fileMessage];
                    height = [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) cellHeight];
                }
            }
        }
        else if ([baseMessage isKindOfClass:[SBDSKGeneralUrlPreviewTempModel class]]) {
            SBDSKGeneralUrlPreviewTempModel *urlPreviewTempMessage = (SBDSKGeneralUrlPreviewTempModel *)baseMessage;
            
            cell = self.outgoingUrlPreviewSizingTableViewCell;
            [cell setFrame:self.view.frame];
            
            if (indexPath.row > 0) {
                [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
            }
            else {
                [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) setPreviousMessage:nil];
            }
            
            [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) setModel:urlPreviewTempMessage];
            height = [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) cellHeight];
        }
        
        if (self.messages.count > 0 && self.messages.count - 1 == indexPath.row) {
            self.lastMessageHeight = height;
        }
    }
    
    return height;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (tableView == self.tableView) {
        SBDBaseMessage *baseMessage = self.messages[indexPath.row];
        
        if ([baseMessage isKindOfClass:[SBDAdminMessage class]]) {
            SBDAdminMessage *adminMessage = (SBDAdminMessage *)baseMessage;
            cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKAdminMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
            [cell setFrame:self.view.frame];
            
            if (indexPath.row > 0) {
                [((SBDSKAdminMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
            }
            else {
                [((SBDSKAdminMessageTableViewCell *)cell) setPreviousMessage:nil];
            }
            
            [((SBDSKAdminMessageTableViewCell *)cell) setModel:adminMessage];
        }
        else if ([baseMessage isKindOfClass:[SBDUserMessage class]]) {
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            if ([userMessage.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                // Outgoing
                BOOL hasUrlPreview = NO;
                if (userMessage.customType != nil && [userMessage.customType isEqualToString:@"SENDBIRD_DESK_RICH_MESSAGE"]) {
                    NSDictionary *customData = nil;
                    NSError *jsonError = nil;
                    @autoreleasepool {
                        customData = [NSJSONSerialization JSONObjectWithData:[userMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
                    }
                    
                    if (customData[@"type"] != nil && ![customData[@"type"] isKindOfClass:[NSNull class]] && [customData[@"type"] isEqualToString:@"SENDBIRD_DESK_URL_PREVIEW"]) {
                        hasUrlPreview = YES;
                    }
                }
                
                if (hasUrlPreview) {
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKOutgoingUrlPreviewTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    
                    ((SBDSKOutgoingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView.image = nil;
                    
                    NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *previewData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSDictionary *previewBody = previewData[@"body"];
                    NSString *imageUrlString = previewBody[@"image"];
                    NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
                    if (imageUrl != nil && imageUrl.scheme == nil) {
                        imageUrlString = [NSString stringWithFormat:@"http:%@", imageUrlString];
                        imageUrl = [NSURL URLWithString:imageUrlString];
                    }
                    
                    [((SBDSKOutgoingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView setAnimatedImageWithURL:[NSURL URLWithString:imageUrlString] success:^(FLAnimatedImage * _Nullable image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SBDSKOutgoingUrlPreviewTableViewCell *updateCell = (SBDSKOutgoingUrlPreviewTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                ((SBDSKOutgoingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView.hidden = NO;
                                [((SBDSKOutgoingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView setAnimatedImage:image];
                            }
                        });
                    } failure:^(NSError * _Nullable error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SBDSKOutgoingUrlPreviewTableViewCell *updateCell = (SBDSKOutgoingUrlPreviewTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                [((SBDSKOutgoingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView setImageWithURL:[NSURL URLWithString:imageUrlString]];
                                ((SBDSKOutgoingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView.hidden = NO;
                            }
                        });
                    }];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingUrlPreviewTableViewCell *)cell) setModel:userMessage];
                    ((SBDSKOutgoingUrlPreviewTableViewCell *)cell).delegate = self;
                    
                    if (self.preSendMessages[userMessage.requestId] != nil && ![self.preSendMessages[userMessage.requestId] isKindOfClass:[NSNull class]]) {
                        [(SBDSKOutgoingUrlPreviewTableViewCell *)cell showSendingStatus];
                    }
                    else {
                        if (self.resendableMessages[userMessage.requestId] != nil && ![self.resendableMessages[userMessage.requestId] isKindOfClass:[NSNull class]]) {
                            [(SBDSKOutgoingUrlPreviewTableViewCell *)cell showMessageControlButton];
                        }
                        else {
                            [(SBDSKOutgoingUrlPreviewTableViewCell *)cell setSentMessage];
                        }
                    }
                }
                else {
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKOutgoingUserMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingUserMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingUserMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingUserMessageTableViewCell *)cell) setModel:userMessage];
                    ((SBDSKOutgoingUserMessageTableViewCell *)cell).delegate = self;
                    
                    if (self.preSendMessages[userMessage.requestId] != nil && ![self.preSendMessages[userMessage.requestId] isKindOfClass:[NSNull class]]) {
                        [(SBDSKOutgoingUserMessageTableViewCell *)cell showSendingStatus];
                    }
                    else {
                        if (self.resendableMessages[userMessage.requestId] != nil && ![self.resendableMessages[userMessage.requestId] isKindOfClass:[NSNull class]]) {
                            [(SBDSKOutgoingUserMessageTableViewCell *)cell showMessageControlButton];
                        }
                        else {
                            [(SBDSKOutgoingUserMessageTableViewCell *)cell setSentMessage];
                        }
                    }
                }
            }
            else {
                // Incoming
                BOOL isRichMessage = NO;
                BOOL hasUrlPreview = NO;
                BOOL hasTicketClosure = NO;
                if (userMessage.customType != nil && [userMessage.customType isEqualToString:@"SENDBIRD_DESK_RICH_MESSAGE"]) {
                    isRichMessage = YES;
                    NSDictionary *customData = nil;
                    NSError *jsonError = nil;
                    @autoreleasepool {
                        customData = [NSJSONSerialization JSONObjectWithData:[userMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
                    }
                    
                    if (customData[@"type"] != nil && ![customData[@"type"] isKindOfClass:[NSNull class]] && [customData[@"type"] isEqualToString:@"SENDBIRD_DESK_URL_PREVIEW"]) {
                        hasUrlPreview = YES;
                    }
                    
                    if (customData[@"type"] != nil && ![customData[@"type"] isKindOfClass:[NSNull class]] && [customData[@"type"] isEqualToString:@"SENDBIRD_DESK_INQUIRE_TICKET_CLOSURE"]) {
                        hasTicketClosure = YES;
                    }
                }
                
                if (isRichMessage && hasTicketClosure) {
                    NSDictionary *customData = nil;
                    NSError *jsonError = nil;
                    @autoreleasepool {
                        customData = [NSJSONSerialization JSONObjectWithData:[userMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
                    }
                    
                    if (customData != nil || jsonError == nil) {
                        cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKIncomingInquireCloseTicketMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                        [cell setFrame:self.view.frame];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SBDSKIncomingInquireCloseTicketMessageTableViewCell *updateCell = (SBDSKIncomingInquireCloseTicketMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                ((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell).delegate = self;
                                
                                if (indexPath.row > 0) {
                                    [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                                }
                                else {
                                    [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setPreviousMessage:nil];
                                }
                                
                                if (self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", userMessage.messageId]] != nil) {
                                    [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setInquireStatus:self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", userMessage.messageId]]];
                                    NSString *status = self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", userMessage.messageId]];
                                    if ([status isEqualToString:@"FAILED"]) {
                                        [self.inquireProgressStatus removeObjectForKey:[NSString stringWithFormat:@"%lld", userMessage.messageId]];
                                    }
                                }
                                else {
                                    [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setInquireStatus:@""];
                                }
                                
                                [((SBDSKIncomingInquireCloseTicketMessageTableViewCell *)cell) setModel:userMessage];
                            }
                        });
                    }
                    else {
                        cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKIncomingUserMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                        [cell setFrame:self.view.frame];
                        
                        if (indexPath.row > 0) {
                            [((SBDSKIncomingUserMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                        }
                        else {
                            [((SBDSKIncomingUserMessageTableViewCell *)cell) setPreviousMessage:nil];
                        }
                        
                        if (self.messages.count - indexPath.row >= 2) {
                            [((SBDSKIncomingUserMessageTableViewCell *)cell) setNextMessage:self.messages[indexPath.row + 1]];
                        }
                        else {
                            [((SBDSKIncomingUserMessageTableViewCell *)cell) setNextMessage:nil];
                        }
                        
                        [((SBDSKIncomingUserMessageTableViewCell *)cell) setModel:userMessage];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SBDSKIncomingUserMessageTableViewCell *updateCell = (SBDSKIncomingUserMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                NSString *encodedUrl = [SBDSKUtils percentEscapedStringFromString:userMessage.sender.profileUrl];
                                
                                [((SBDSKIncomingUserMessageTableViewCell *)cell).profileImageView setImageWithURL:[NSURL URLWithString:encodedUrl]];
                            }
                        });
                    }
                }
                else if (isRichMessage && hasUrlPreview) {
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKIncomingUrlPreviewTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    
                    ((SBDSKIncomingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView.image = nil;
                    ((SBDSKIncomingUrlPreviewTableViewCell *)cell).delegate = self;
                    
                    NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *previewData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSDictionary *previewBody = previewData[@"body"];
                    NSString *imageUrl = previewBody[@"image"];
                    
                    [((SBDSKIncomingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView setAnimatedImageWithURL:[NSURL URLWithString:imageUrl] success:^(FLAnimatedImage * _Nullable image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SBDSKIncomingUrlPreviewTableViewCell *updateCell = (SBDSKIncomingUrlPreviewTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                ((SBDSKIncomingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView.hidden = NO;
                                [((SBDSKIncomingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView setAnimatedImage:image];
                            }
                        });
                    } failure:^(NSError * _Nullable error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SBDSKIncomingUrlPreviewTableViewCell *updateCell = (SBDSKIncomingUrlPreviewTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                [((SBDSKIncomingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView setImageWithURL:[NSURL URLWithString:imageUrl]];
                                ((SBDSKIncomingUrlPreviewTableViewCell *)cell).urlPreviewThumbnailImageView.hidden = NO;
                            }
                        });
                    }];
                    
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingUrlPreviewTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingUrlPreviewTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    if (self.messages.count - indexPath.row >= 2) {
                        [((SBDSKIncomingUrlPreviewTableViewCell *)cell) setNextMessage:self.messages[indexPath.row + 1]];
                    }
                    else {
                        [((SBDSKIncomingUrlPreviewTableViewCell *)cell) setNextMessage:nil];
                    }
                    
                    [((SBDSKIncomingUrlPreviewTableViewCell *)cell) setModel:userMessage];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SBDSKIncomingUrlPreviewTableViewCell *updateCell = (SBDSKIncomingUrlPreviewTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            NSString *encodedUrl = [SBDSKUtils percentEscapedStringFromString:userMessage.sender.profileUrl];
                            [((SBDSKIncomingUrlPreviewTableViewCell *)cell).profileImageView setImageWithURL:[NSURL URLWithString:encodedUrl]];
                        }
                    });
                }
                else {
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKIncomingUserMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    
                    ((SBDSKIncomingUserMessageTableViewCell *)cell).delegate = self;
                    
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingUserMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingUserMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    if (self.messages.count - indexPath.row >= 2) {
                        [((SBDSKIncomingUserMessageTableViewCell *)cell) setNextMessage:self.messages[indexPath.row + 1]];
                    }
                    else {
                        [((SBDSKIncomingUserMessageTableViewCell *)cell) setNextMessage:nil];
                    }
                    
                    [((SBDSKIncomingUserMessageTableViewCell *)cell) setModel:userMessage];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SBDSKIncomingUserMessageTableViewCell *updateCell = (SBDSKIncomingUserMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            NSString *encodedUrl = [SBDSKUtils percentEscapedStringFromString:userMessage.sender.profileUrl];
                            [((SBDSKIncomingUserMessageTableViewCell *)cell).profileImageView setImageWithURL:[NSURL URLWithString:encodedUrl]];
                        }
                    });
                }
            }
        }
        else if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
            SBDFileMessage *fileMessage = (SBDFileMessage *)baseMessage;
            if ([fileMessage.sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                // Outgoing
                if ([fileMessage.type hasPrefix:@"image"]) {
                    // Image
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKOutgoingImageFileMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    ((SBDSKOutgoingImageFileMessageTableViewCell *)cell).delegate = self;
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingImageFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingImageFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingImageFileMessageTableViewCell *)cell) setModel:fileMessage];
                    ((SBDSKOutgoingImageFileMessageTableViewCell *)cell).delegate = self;
                    
                    if (self.preSendMessages[fileMessage.requestId] != nil && ![self.preSendMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                        [(SBDSKOutgoingImageFileMessageTableViewCell *)cell showSendingStatus];
                        [(SBDSKOutgoingImageFileMessageTableViewCell *)cell setHasImageCacheData:YES];
                        [(SBDSKOutgoingImageFileMessageTableViewCell *)cell setImageData:(NSData *)self.preSendFileData[fileMessage.requestId][@"data"] type:(NSString *)self.preSendFileData[fileMessage.requestId][@"type"]];
                    }
                    else {
                        if (self.preSendMessages[fileMessage.requestId] != nil && ![self.preSendMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                            [(SBDSKOutgoingImageFileMessageTableViewCell *)cell showSendingStatus];
                            
                            [(SBDSKOutgoingImageFileMessageTableViewCell *)cell setHasImageCacheData:YES];
                            [(SBDSKOutgoingImageFileMessageTableViewCell *)cell setImageData:(NSData *)self.preSendFileData[fileMessage.requestId][@"data"] type:(NSString *)self.preSendFileData[fileMessage.requestId][@"type"]];
                        }
                        else {
                            if (self.resendableMessages[fileMessage.requestId] != nil && ![self.resendableMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                                [(SBDSKOutgoingImageFileMessageTableViewCell *)cell setImageData:(NSData *)self.preSendFileData[fileMessage.requestId][@"data"] type:(NSString *)self.preSendFileData[fileMessage.requestId][@"type"]];
                                [(SBDSKOutgoingImageFileMessageTableViewCell *)cell setHasImageCacheData:YES];
                                [self.preSendFileData removeObjectForKey:fileMessage.requestId];
                                [(SBDSKOutgoingImageFileMessageTableViewCell *)cell showMessageControlButton];
                            }
                            else {
                                NSString *fileImageUrl = @"";
                                if (fileMessage.thumbnails.count > 0 && ![fileMessage.type isEqualToString:@"image/gif"]) {
                                    fileImageUrl = fileMessage.thumbnails[0].url;
                                }
                                else {
                                    fileImageUrl = fileMessage.url;
                                }
                                
                                if ([fileMessage.type isEqualToString:@"image/gif"]) {
                                    [((SBDSKOutgoingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImageWithURL:[NSURL URLWithString:fileImageUrl] success:^(FLAnimatedImage * _Nullable image) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            SBDSKOutgoingImageFileMessageTableViewCell *updateCell = (SBDSKOutgoingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                            if (updateCell) {
                                                [((SBDSKOutgoingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImage:image];
                                                [((SBDSKOutgoingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator stopAnimating];
                                                ((SBDSKOutgoingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator.hidden = YES;
                                            }
                                        });
                                    } failure:^(NSError * _Nullable error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            SBDSKOutgoingImageFileMessageTableViewCell *updateCell = (SBDSKOutgoingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                            if (updateCell) {
                                                [((SBDSKOutgoingImageFileMessageTableViewCell *)cell).fileImageView setImageWithURL:[NSURL URLWithString:fileImageUrl]];
                                                [((SBDSKOutgoingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator stopAnimating];
                                                ((SBDSKOutgoingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator.hidden = YES;
                                            }
                                        });
                                    }];
                                }
                                else {
                                    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:fileImageUrl]];
                                    [((SBDSKOutgoingImageFileMessageTableViewCell *)cell).fileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            SBDSKOutgoingImageFileMessageTableViewCell *updateCell = (SBDSKOutgoingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                            if (updateCell) {
                                                [((SBDSKOutgoingImageFileMessageTableViewCell *)cell).fileImageView setImage:image];

                                                [((SBDSKOutgoingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator stopAnimating];
                                                ((SBDSKOutgoingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator.hidden = YES;
                                            }
                                        });
                                    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            SBDSKOutgoingImageFileMessageTableViewCell *updateCell = (SBDSKOutgoingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                            if (updateCell) {
                                                [((SBDSKOutgoingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator stopAnimating];
                                                ((SBDSKOutgoingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator.hidden = YES;
                                            }
                                        });
                                    }];
                                }
                                
                                [(SBDSKOutgoingImageFileMessageTableViewCell *)cell setSentMessage];
                            }
                        }
                    }
                }
                else if ([fileMessage.type hasPrefix:@"video"]) {
                    // Video
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKOutgoingVideoFileMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    ((SBDSKOutgoingVideoFileMessageTableViewCell *)cell).delegate = self;
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingVideoFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingVideoFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingVideoFileMessageTableViewCell *)cell) setModel:fileMessage];
                    ((SBDSKOutgoingVideoFileMessageTableViewCell *)cell).delegate = self;
                    
                    if (self.preSendMessages[fileMessage.requestId] != nil && ![self.preSendMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                        [(SBDSKOutgoingVideoFileMessageTableViewCell *)cell showSendingStatus];
                    }
                    else {
                        if (self.preSendMessages[fileMessage.requestId] != nil && ![self.preSendMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                            [(SBDSKOutgoingVideoFileMessageTableViewCell *)cell showSendingStatus];
                        }
                        else {
                            if (self.resendableMessages[fileMessage.requestId] != nil && ![self.resendableMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                                [self.preSendFileData removeObjectForKey:fileMessage.requestId];
                                [(SBDSKOutgoingVideoFileMessageTableViewCell *)cell showMessageControlButton];
                            }
                            else {
                                if (fileMessage.thumbnails.count > 0) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        SBDSKOutgoingVideoFileMessageTableViewCell *updateCell = (SBDSKOutgoingVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                        if (updateCell) {
                                            NSString *encodedThumbnailUrl = [SBDSKUtils percentEscapedStringFromString:fileMessage.thumbnails.firstObject.url];
                                            [((SBDSKOutgoingVideoFileMessageTableViewCell *)cell).fileImageView setImageWithURL:[NSURL URLWithString:encodedThumbnailUrl]];
                                        }
                                    });
                                }
                                
                                [(SBDSKOutgoingVideoFileMessageTableViewCell *)cell setSentMessage];
                            }
                        }
                    }
                }
                else {
                    // General file
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKOutgoingGeneralFileMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    ((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell).delegate = self;
                    if (indexPath.row > 0) {
                        [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) setModel:fileMessage];
                    ((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell).delegate = self;
                    
                    if (self.preSendMessages[fileMessage.requestId] != nil && ![self.preSendMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                        [(SBDSKOutgoingGeneralFileMessageTableViewCell *)cell showSendingStatus];
                    }
                    else {
                        if (self.preSendMessages[fileMessage.requestId] != nil && ![self.preSendMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                            [(SBDSKOutgoingGeneralFileMessageTableViewCell *)cell showSendingStatus];
                        }
                        else {
                            if (self.resendableMessages[fileMessage.requestId] != nil && ![self.resendableMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                                [self.preSendFileData removeObjectForKey:fileMessage.requestId];
                                [(SBDSKOutgoingGeneralFileMessageTableViewCell *)cell showMessageControlButton];
                            }
                            else {
                                [(SBDSKOutgoingGeneralFileMessageTableViewCell *)cell setSentMessage];
                                
                                if (self.fileMessageDownloadingStatus[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] != nil) {
                                    NSDictionary *statusDict = self.fileMessageDownloadingStatus[[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                                    if (statusDict != nil) {
                                        int status = [statusDict[@"status"] intValue];
                                        float progress = [statusDict[@"progress"] floatValue];
                                        [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) setFileDownloadingStatus:status];
                                        [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) setDownloadingProgress:progress];
                                    }
                                }
                                else {
                                    [((SBDSKOutgoingGeneralFileMessageTableViewCell *)cell) setFileDownloadingStatus:0];
                                }
                            }
                        }
                    }
                }
            }
            else {
                // Incoming
                if ([fileMessage.type hasPrefix:@"image"]) {
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKIncomingImageFileMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    ((SBDSKIncomingImageFileMessageTableViewCell *)cell).delegate = self;
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingImageFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingImageFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    if (self.messages.count - indexPath.row >= 2) {
                        [((SBDSKIncomingImageFileMessageTableViewCell *)cell) setNextMessage:self.messages[indexPath.row + 1]];
                    }
                    else {
                        [((SBDSKIncomingImageFileMessageTableViewCell *)cell) setNextMessage:nil];
                    }
                    
                    [((SBDSKIncomingImageFileMessageTableViewCell *)cell) setModel:fileMessage];
                    
                    NSString *fileImageUrl = @"";
                    if (fileMessage.thumbnails.count > 0 && ![fileMessage.type isEqualToString:@"image/gif"]) {
                        fileImageUrl = fileMessage.thumbnails[0].url;
                    }
                    else {
                        fileImageUrl = fileMessage.url;
                    }
                    
                    if ([fileMessage.type isEqualToString:@"image/gif"]) {
                        ((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator.hidden = NO;
                        [((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator startAnimating];
                        [((SBDSKIncomingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImageWithURL:[NSURL URLWithString:fileImageUrl] success:^(FLAnimatedImage * _Nullable image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                SBDSKIncomingImageFileMessageTableViewCell *updateCell = (SBDSKIncomingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [((SBDSKIncomingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImage:image];
                                    
                                    [((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator stopAnimating];
                                    ((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator.hidden = YES;
                                }
                                
                            });
                        } failure:^(NSError * _Nullable error) {
                            [((SBDSKIncomingImageFileMessageTableViewCell *)cell).fileImageView setImageWithURL:[NSURL URLWithString:fileImageUrl]];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                SBDSKIncomingImageFileMessageTableViewCell *updateCell = (SBDSKIncomingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator stopAnimating];
                                    ((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator.hidden = YES;
                                }
                            });
                        }];
                        
                    }
                    else {
                        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:fileImageUrl]];
                        [((SBDSKIncomingImageFileMessageTableViewCell *)cell).fileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                SBDSKIncomingImageFileMessageTableViewCell *updateCell = (SBDSKIncomingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [((SBDSKIncomingImageFileMessageTableViewCell *)cell).fileImageView setImage:image];
                                    [((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator stopAnimating];
                                    ((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator.hidden = YES;
                                }
                            });
                        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                SBDSKIncomingImageFileMessageTableViewCell *updateCell = (SBDSKIncomingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator stopAnimating];
                                    ((SBDSKIncomingImageFileMessageTableViewCell *)cell).imageLoadingActivityIndicator.hidden = YES;
                                }
                            });
                        }];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SBDSKIncomingImageFileMessageTableViewCell *updateCell = (SBDSKIncomingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            NSString *encodedUrl = [SBDSKUtils percentEscapedStringFromString:fileMessage.sender.profileUrl];
                            [((SBDSKIncomingImageFileMessageTableViewCell *)updateCell).profileImageView setImageWithURL:[NSURL URLWithString:encodedUrl]];
                        }
                    });
                }
                else if ([fileMessage.type hasPrefix:@"video"]) {
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKIncomingVideoFileMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    ((SBDSKIncomingVideoFileMessageTableViewCell *)cell).delegate = self;
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingVideoFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingVideoFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    if (self.messages.count - indexPath.row >= 2) {
                        [((SBDSKIncomingVideoFileMessageTableViewCell *)cell) setNextMessage:self.messages[indexPath.row + 1]];
                    }
                    else {
                        [((SBDSKIncomingVideoFileMessageTableViewCell *)cell) setNextMessage:nil];
                    }
                    
                    [((SBDSKIncomingVideoFileMessageTableViewCell *)cell) setModel:fileMessage];
                    
                    if (fileMessage.thumbnails.count > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SBDSKIncomingVideoFileMessageTableViewCell *updateCell = (SBDSKIncomingVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                NSString *encodedThumbnailUrl = [SBDSKUtils percentEscapedStringFromString:fileMessage.thumbnails.firstObject.url];
                                [((SBDSKIncomingVideoFileMessageTableViewCell *)cell).fileImageView setImageWithURL:[NSURL URLWithString:encodedThumbnailUrl]];
                            }
                        });
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SBDSKIncomingVideoFileMessageTableViewCell *updateCell = (SBDSKIncomingVideoFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            NSString *encodedUrl = [SBDSKUtils percentEscapedStringFromString:fileMessage.sender.profileUrl];
                            [((SBDSKIncomingVideoFileMessageTableViewCell *)updateCell).profileImageView setImageWithURL:[NSURL URLWithString:encodedUrl]];
                        }
                    });
                }
                else {
                    cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKIncomingGeneralFileMessageTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
                    [cell setFrame:self.view.frame];
                    ((SBDSKIncomingGeneralFileMessageTableViewCell *)cell).delegate = self;
                    if (indexPath.row > 0) {
                        [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setPreviousMessage:self.messages[indexPath.row - 1]];
                    }
                    else {
                        [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setPreviousMessage:nil];
                    }
                    
                    if (self.messages.count - indexPath.row >= 2) {
                        [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setNextMessage:self.messages[indexPath.row + 1]];
                    }
                    else {
                        [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setNextMessage:nil];
                    }
                    
                    [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setModel:fileMessage];
                    
                    if (self.fileMessageDownloadingStatus[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] != nil) {
                        NSDictionary *statusDict = self.fileMessageDownloadingStatus[[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                        if (statusDict != nil) {
                            int status = [statusDict[@"status"] intValue];
                            float progress = [statusDict[@"progress"] floatValue];
                            [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setFileDownloadingStatus:status];
                            [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setDownloadingProgress:progress];
                        }
                    }
                    else {
                        [((SBDSKIncomingGeneralFileMessageTableViewCell *)cell) setFileDownloadingStatus:0];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SBDSKIncomingGeneralFileMessageTableViewCell *updateCell = (SBDSKIncomingGeneralFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            NSString *encodedUrl = [SBDSKUtils percentEscapedStringFromString:fileMessage.sender.profileUrl];
                            [((SBDSKIncomingGeneralFileMessageTableViewCell *)updateCell).profileImageView setImageWithURL:[NSURL URLWithString:encodedUrl]];
                        }
                    });
                }
                
            }
        }
        else if ([baseMessage isKindOfClass:[SBDSKGeneralUrlPreviewTempModel class]]) {
            SBDSKGeneralUrlPreviewTempModel *urlPreviewTempMessage = (SBDSKGeneralUrlPreviewTempModel *)baseMessage;
            
            cell = [tableView dequeueReusableCellWithIdentifier:[SBDSKOutgoingUrlPreviewTableViewCell cellReuseIdentifier] forIndexPath:indexPath];
            [cell setFrame:self.view.frame];
            
            if (indexPath.row > 0) {
                [(SBDSKOutgoingUrlPreviewTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
            }
            else {
                [(SBDSKOutgoingUrlPreviewTableViewCell *)cell setPreviousMessage:nil];
            }
            [(SBDSKOutgoingUrlPreviewTableViewCell *)cell setModel:urlPreviewTempMessage];
        }
    }
    if (cell != nil) {
        return cell;
    } else {
        return [UITableViewCell new];
    }
}

#pragma mark - SBDConnectionDelegate

- (void)didStartReconnection {
    self.messageInputTextView.editable = NO;
    self.sendMessageButton.enabled = NO;
    self.fileAttachmentButton.enabled = NO;
}

- (void)didSucceedReconnection {
    self.messageInputTextView.editable = YES;
    self.sendMessageButton.enabled = YES;
    self.fileAttachmentButton.enabled = YES;
    [self loadPreviousMessage:YES checkDowntime:YES];
    if (self.ticket != nil) {
        [self.ticket refreshWithCompletionHandler:^(SBDSKTicket * _Nullable ticket, SBDError * _Nullable error) {
            if (error != nil) {
//                [SBDSKMain logWithLevel:SBDSKLogLevelError format:@"[SBDSK] Can't update ticket info: %@", error];
                return;
            }
            
            self.ticket = ticket;
            if ([self.ticket.status isEqualToString:@"CLOSED"]) {
//                self.isClosedTicket = YES;
                self.tableViewBottomMargin.constant = 0;
                self.messageInputContainerView.hidden = YES;
                [self.view sendSubviewToBack:self.messageInputContainerView];
            }
        }];
    }
}

- (void)didFailReconnection {
    self.messageInputTextView.editable = NO;
    self.sendMessageButton.enabled = NO;
    self.fileAttachmentButton.enabled = NO;
}

#pragma mark - SBDChannelDelegate

- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    if (sender == self.ticket.channel) {
        if ([UIViewController currentViewController] == self) {
            [self.ticket.channel markAsRead];
        }
        
        if ([message isKindOfClass:[SBDAdminMessage class]]) {
            SBDAdminMessage *adminMessage = (SBDAdminMessage *)message;
            
            if ([adminMessage.customType isEqualToString:@"SENDBIRD_DESK_ADMIN_MESSAGE_CUSTOM_TYPE"]) {
                NSDictionary *result = nil;
                NSError *error = nil;
                @autoreleasepool {
                    result = [NSJSONSerialization JSONObjectWithData:[adminMessage.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                }
                if (error == nil) {
                    if ([result[@"type"] isEqualToString:@"TICKET_CLOSE"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.tableViewBottomMargin.constant = 0;
                            self.messageInputContainerView.hidden = YES;
                            [self.view sendSubviewToBack:self.messageInputContainerView];
                            
                            if (self.keyboardShown == NO) {
                                return;
                            }
                            
                            [self.view layoutIfNeeded];
                            [self scrollToBottomWithForce:NO];
                            [self.view endEditing:YES];
                        });
                    }
                }
                
                return;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.messageMap[@(message.messageId)] == nil) {
                [self.messages addObject:message];
                self.messageMap[@(message.messageId)] = message;
                [self.tableView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scrollToBottomWithForce:NO];
                });
            }
            else {
                NSLog(@"Duplicated message.");
            }
        });
    }
    else {
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
        
        if ([UIViewController currentViewController] != self) {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
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
                        //                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            }
            else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                localNotification.userInfo = @{
                                               @"sendbird": @{
                                                       @"type": type,
                                                       @"custom_type": customType,
                                                       @"channel": @{
                                                               @"channel_url": sender.channelUrl,
                                                               },
                                                       @"data": data,
                                                       },
                                               };
                localNotification.category = @"NEW_MESSAGE";
                localNotification.alertTitle = title;
                localNotification.alertBody = body;
                
                
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
#pragma clang diagnostic pop
            }
        }
    }
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender didUpdateMessage:(SBDBaseMessage * _Nonnull)message {
    if (![SBDSKMain isDeskChannel:sender]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", message.messageId]] = @"COMPLETE";
        SBDBaseMessage *oldMessage = self.messageMap[@(message.messageId)];
        if (oldMessage != nil) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messages indexOfObject:oldMessage] inSection:0];
            [self.messages replaceObjectAtIndex:[self.messages indexOfObject:oldMessage] withObject:message];
            self.messageMap[@(message.messageId)] = message;
            [UIView setAnimationsEnabled:NO];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [UIView setAnimationsEnabled:YES];
        }
    });
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
    
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [picker dismissViewControllerAnimated:YES completion:^{
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            // For Camera
            UIImage *originalImage;
            
            // Photo Library
            PHAsset *asset;
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.networkAccessAllowed = NO;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            
            NSURL *imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            
            if (imagePath == nil) {
                originalImage = (UIImage *)[info objectForKey: UIImagePickerControllerOriginalImage];
                
                TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:originalImage];
                cropController.delegate = self;
                [self presentViewController:cropController animated:NO completion:nil];
            }
            else {
                asset = info[UIImagePickerControllerPHAsset];
                [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                    NSString *MIME = (__bridge NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)contentEditingInput.uniformTypeIdentifier, kUTTagClassMIMEType);
                    
                    if ([MIME isEqualToString:@"image/gif"]) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
                            
                            SBDFileMessage *preSendMessage = [self.ticket.channel sendFileMessageWithBinaryData:imageData filename:@"image.gif" type:MIME size:imageData.length thumbnailSizes:@[thumbnailSize] data:@"" customType:@"" progressHandler:nil completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                                    SBDFileMessage *preSendMessage = (SBDFileMessage *)self.preSendMessages[fileMessage.requestId];
                                    [self.preSendMessages removeObjectForKey:fileMessage.requestId];
                                    
                                    if (error != nil) {
                                        self.resendableMessages[fileMessage.requestId] = preSendMessage;
                                        self.resendableFileData[preSendMessage.requestId] = @{
                                                                                              @"data": imageData,
                                                                                              @"type": MIME
                                                                                              };
                                        [self.tableView reloadData];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self scrollToBottomWithForce:YES];
                                        });
                                        
                                        return;
                                    }
                                    
                                    if (self.delegate != nil) {
                                        [self.delegate updateOpenTicket:self.ticket.ticketId];
                                    }
                                    
                                    if (fileMessage != nil) {
                                        [self.resendableMessages removeObjectForKey:fileMessage.requestId];
                                        [self.resendableFileData removeObjectForKey:fileMessage.requestId];
                                        [self.preSendMessages removeObjectForKey:fileMessage.requestId];
                                        [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.tableView reloadData];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self scrollToBottomWithForce:YES];
                                            });
                                        });
                                    }
                                });
                            }];
                            
                            self.preSendFileData[preSendMessage.requestId] = @{
                                                                               @"data": imageData,
                                                                               @"type": MIME
                                                                               };
                            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
                            [self.messages addObject:preSendMessage];
                            [self.tableView reloadData];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self scrollToBottomWithForce:YES];
                            });
                        }];
                    }
                    else {
                        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            if (result != nil) {
                                NSData *imageData = UIImageJPEGRepresentation(result, 1.0);
                                
                                UIImage *imageToUse = [UIImage imageWithData:imageData];
                                TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:imageToUse];
                                cropController.delegate = self;
                                [self presentViewController:cropController animated:NO completion:nil];
                            }
                        }];
                    }
                }];
            }
        }
        else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSData *videoFileData = [NSData dataWithContentsOfURL:videoURL];
            NSString *videoName = [videoURL lastPathComponent];
            
            NSString *ext = [videoName pathExtension];
            NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
            NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
            
            // success, data is in imageData
            /***********************************/
            /* Thumbnail is a premium feature. */
            /***********************************/
            SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
            
            SBDFileMessage *preSendMessage = [self.ticket.channel sendFileMessageWithBinaryData:videoFileData filename:videoName type:mimeType size:videoFileData.length thumbnailSizes:@[thumbnailSize] data:@"" customType:@"" progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                NSLog(@"total bytes sent: %lld", totalBytesSent);
            } completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    SBDFileMessage *preSendMessage = (SBDFileMessage *)self.preSendMessages[fileMessage.requestId];
                    [self.preSendMessages removeObjectForKey:fileMessage.requestId];
                    
                    if (error != nil) {
                        self.resendableMessages[fileMessage.requestId] = preSendMessage;
                        self.resendableFileData[preSendMessage.requestId] = @{
                                                                              @"data": videoFileData,
                                                                              @"type": mimeType
                                                                              };
                        [self.tableView reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self scrollToBottomWithForce:YES];
                        });
                        
                        return;
                    }
                    
                    if (fileMessage != nil) {
                        [self.resendableMessages removeObjectForKey:fileMessage.requestId];
                        [self.resendableFileData removeObjectForKey:fileMessage.requestId];
                        [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self scrollToBottomWithForce:YES];
                            });
                        });
                    }
                });
            }];
            
            self.preSendFileData[preSendMessage.requestId] = @{
                                                               @"data": videoFileData,
                                                               @"type": mimeType
                                                               };
            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
            [self.messages addObject:preSendMessage];
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToBottomWithForce:YES];
            });
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - SBDSKMessageCellDelegate
- (void)clickMessage:(UIView *)view message:(SBDBaseMessage *)message {
    if ([message isKindOfClass:[SBDUserMessage class]]) {
        
    }
    else if ([message isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)message;
        self.currentFileMessageOnViewer = fileMessage;
        __block NSString *type = fileMessage.type;
        __block NSString *url = fileMessage.url;
        
        if ([type hasPrefix:@"image"]) {
            [self showImageViewerLoading];
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error != nil) {
                    [self hideImageViewerLoading];
                    return;
                }
                
                NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                if ([resp statusCode] >= 200 && [resp statusCode] < 300) {
                    NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                    [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:request];
                    
                    SBDSKFileImage *photo = [[SBDSKFileImage alloc] init];
                    photo.imageData = data;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
                        [self presentViewController:self.photosViewController animated:NO completion:^{
                            [self hideImageViewerLoading];
                        }];
                    });
                }
                else {
                    [self hideImageViewerLoading];
                }
            }] resume];
        }
        else if ([type hasPrefix:@"video"]) {
            NSURL *videoUrl = [NSURL URLWithString:fileMessage.url];
            AVPlayer *player = [[AVPlayer alloc] initWithURL:videoUrl];
            AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
            vc.player = player;
            [self presentViewController:vc animated:YES completion:^{
                [player play];
            }];
        }
    }
}

- (void)clickResendFailedMessage:(UIView *)view message:(SBDBaseMessage *)message {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Resend failed message" message:@"Do you want to resend a failed message?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *resendAction = [UIAlertAction actionWithTitle:@"Resend" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([message isKindOfClass:[SBDUserMessage class]]) {
            SBDUserMessage *resendableUserMessage = (SBDUserMessage *)message;
            
            // URL Preview
            NSError *error = nil;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
            if (error == nil) {
                NSArray *matches = [detector matchesInString:resendableUserMessage.message options:0 range:NSMakeRange(0, resendableUserMessage.message.length)];
                NSURL *url = nil;
                for (NSTextCheckingResult *match in matches) {
                    url = [match URL];
                    break;
                }
                
                if (url != nil) {
                    SBDSKGeneralUrlPreviewTempModel *tempModel = [[SBDSKGeneralUrlPreviewTempModel alloc] init];
                    tempModel.createdAt = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
                    tempModel.message = resendableUserMessage.message;
                    
                    [self.resendableMessages removeObjectForKey:resendableUserMessage.requestId];
                    [self.messages removeObject:resendableUserMessage];
                    [self.messages addObject:tempModel];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self scrollToBottomWithForce:YES];
                        });
                    });
                    
                    // Send preview;
                    [self sendUrlPreview:url message:resendableUserMessage.message tempModel:tempModel];
                    
                    return;
                }
            }
            
            NSArray<NSString *> *targetLanguages = nil;
            if (resendableUserMessage.translations != nil) {
                targetLanguages = [resendableUserMessage.translations allKeys];
            }
            
            SBDUserMessageParams *params = [[SBDUserMessageParams alloc] initWithMessage:resendableUserMessage.message];
            params.data = resendableUserMessage.data;
            params.customType = resendableUserMessage.customType;
            params.targetLanguages = targetLanguages;
            SBDUserMessage *preSendMessage = [self.ticket.channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    SBDUserMessage *preSendMessage = (SBDUserMessage *)self.preSendMessages[userMessage.requestId];
                    [self.preSendMessages removeObjectForKey:userMessage.requestId];
                    
                    if (error != nil) {
                        self.resendableMessages[userMessage.requestId] = userMessage;
                        [self.tableView reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self scrollToBottomWithForce:YES];
                        });
                        
                        return;
                    }
                    
                    if (self.delegate != nil) {
                        [self.delegate updateOpenTicket:self.ticket.ticketId];
                    }
                    
                    if (preSendMessage != nil) {
                        [self.messages removeObject:preSendMessage];
                        [self.messages addObject:userMessage];
                    }
                    [self.tableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self scrollToBottomWithForce:YES];
                    });
                });
            }];
            [self.messages replaceObjectAtIndex:[self.messages indexOfObject:resendableUserMessage] withObject:preSendMessage];
            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
            [self.resendableMessages removeObjectForKey:resendableUserMessage.requestId];
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToBottomWithForce:YES];
            });
        }
        else if ([message isKindOfClass:[SBDFileMessage class]]) {
            __block SBDFileMessage *resendableFileMessage = (SBDFileMessage *)message;
            
            NSMutableArray<SBDThumbnailSize *> *thumbnailsSizes = [[NSMutableArray alloc] init];
            for (SBDThumbnail *thumbnail in resendableFileMessage.thumbnails) {
                [thumbnailsSizes addObject:[SBDThumbnailSize makeWithMaxCGSize:thumbnail.maxSize]];
            }
            SBDFileMessage *preSendMessage = [self.ticket.channel sendFileMessageWithBinaryData:(NSData *)self.resendableFileData[resendableFileMessage.requestId][@"data"] filename:resendableFileMessage.name type:resendableFileMessage.type size:resendableFileMessage.size thumbnailSizes:thumbnailsSizes data:resendableFileMessage.data customType:resendableFileMessage.customType progressHandler:nil completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    SBDFileMessage *preSendMessage = (SBDFileMessage *)self.preSendMessages[fileMessage.requestId];
                    [self.preSendMessages removeObjectForKey:fileMessage.requestId];
                    
                    if (error != nil) {
                        self.resendableMessages[fileMessage.requestId] = fileMessage;
                        self.resendableFileData[fileMessage.requestId] = self.preSendFileData[fileMessage.requestId];
                        [self.preSendFileData removeObjectForKey:fileMessage.requestId];
                        [self.preSendMessages removeObjectForKey:fileMessage.requestId];
                        [self.tableView reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self scrollToBottomWithForce:YES];
                        });
                        
                        return;
                    }
                    
                    if (self.delegate != nil) {
                        [self.delegate updateOpenTicket:self.ticket.ticketId];
                    }
                    
                    if (preSendMessage != nil) {
                        [self.messages removeObject:preSendMessage];
                        [self.messages addObject:fileMessage];
                    }
                    
                    [self.tableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self scrollToBottomWithForce:YES];
                    });
                });
            }];
            [self.messages replaceObjectAtIndex:[self.messages indexOfObject:resendableFileMessage] withObject:preSendMessage];
            self.preSendMessages[preSendMessage.requestId] = preSendMessage;
            self.preSendFileData[preSendMessage.requestId] = self.resendableFileData[resendableFileMessage.requestId];
            [self.resendableMessages removeObjectForKey:resendableFileMessage.requestId];
            [self.resendableFileData removeObjectForKey:resendableFileMessage.requestId];
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToBottomWithForce:YES];
            });
        }
    }];
    
    [vc addAction:closeAction];
    [vc addAction:resendAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)clickDeleteFailedMessage:(UIView *)view message:(SBDBaseMessage *)message {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Delete failed message" message:@"Do you want to delete a failed message?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *requestId = nil;
        if ([message isKindOfClass:[SBDUserMessage class]]) {
            requestId = ((SBDUserMessage *)message).requestId;
        }
        else if ([message isKindOfClass:[SBDFileMessage class]]) {
            requestId = ((SBDFileMessage *)message).requestId;
        }
        [self.resendableFileData removeObjectForKey:requestId];
        [self.resendableMessages removeObjectForKey:requestId];
        [self.messages removeObject:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    [vc addAction:closeAction];
    [vc addAction:deleteAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

static BOOL g_isClickedIncomingFile = NO;

- (void)clickViewMessage:(UIView *)view message:(SBDBaseMessage *)message {
    if (g_isClickedIncomingFile) {
        return;
    }
    g_isClickedIncomingFile = YES;
    
    if ([message isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)message;
        if ([fileMessage.type hasPrefix:@"audio"]) {
            NSURL *videoUrl = [NSURL URLWithString:fileMessage.url];
            AVPlayer *player = [[AVPlayer alloc] initWithURL:videoUrl];
            AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
            vc.player = player;
            [self presentViewController:vc animated:YES completion:^{
                g_isClickedIncomingFile = NO;
                [player play];
            }];
            return;
        }
        else {
            int status = 0;
            if (self.fileMessageDownloadingStatus[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] != nil) {
                NSDictionary *statusDict = self.fileMessageDownloadingStatus[[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                status = [statusDict[@"status"] intValue];
            }
            
            if (status == 0) {
                // Download
                NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:[NSURL URLWithString:fileMessage.url]];
                self.downloadTasks[task] = @{
                                             @"task": task,
                                             @"message": message,
                                             };
                self.fileMessageDownloadingStatus[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = [[NSMutableDictionary alloc] initWithDictionary:@{@"status": @(1), @"progress": @(0.0)}];
                [task resume];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (long row = 0; row < self.messages.count; row++) {
                        if (self.messages[row].messageId == message.messageId) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            
                            break;
                        }
                    }
                    g_isClickedIncomingFile = NO;
                });
                
                return;
            }
            else if (status == 2) {
                NSArray *pathHome = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                if (pathHome == nil || pathHome.count == 0) {
                    g_isClickedIncomingFile = NO;
                    return;
                }
                
                NSString *pathDownload = [[pathHome objectAtIndex:0] stringByAppendingPathComponent:@"SBDSKDownload"];
                BOOL isDirectoryDownload = YES;
                if (![[NSFileManager defaultManager] fileExistsAtPath:pathDownload isDirectory:&isDirectoryDownload]) {
                    g_isClickedIncomingFile = NO;
                    return;
                }
                
                if (!isDirectoryDownload) {
                    g_isClickedIncomingFile = NO;
                    return;
                }
                
                NSString *fullFileName = [NSString stringWithFormat:@"%@_%lld_%@", [SBDMain getApplicationId], fileMessage.messageId, fileMessage.name];
                NSString *dstPath = [pathDownload stringByAppendingPathComponent:fullFileName];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:nil]) {
                    g_isClickedIncomingFile = NO;
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (int row = 0; row < self.messages.count; row++) {
                        if (self.messages[row].messageId == fileMessage.messageId) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            
                            break;
                        }
                    }
                    
                    self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:dstPath]];

                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                        [self.interactionController presentOptionsMenuFromRect:self.titleLabel.frame inView:self.view animated:YES];
                    }
                    else {
                        [self.interactionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
                    }
                    
                    g_isClickedIncomingFile = NO;
                });
            }
        }
    }
}

- (void)clickInquireCloseMessageYes:(UIView *)view message:(SBDBaseMessage *)message {
    if (self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", message.messageId]] == nil) {
        self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", message.messageId]] = @"YES_IN_PROGRESS";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (long row = 0; row < self.messages.count; row++) {
                if (self.messages[row].messageId == message.messageId) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    break;
                }
            }
            
            [SBDSKTicket confirmEndOfChatWithMessage:(SBDUserMessage *)message confirm:YES completionHandler:^(SBDSKTicket * _Nullable ticket, SBDError * _Nullable error) {
                
            }];
        });
    }
}

- (void)clickInquireCloseMessageNo:(UIView *)view message:(SBDBaseMessage *)message {
    if (self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", message.messageId]] == nil) {
        self.inquireProgressStatus[[NSString stringWithFormat:@"%lld", message.messageId]] = @"NO_IN_PROGRESS";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (long row = 0; row < self.messages.count; row++) {
                if (self.messages[row].messageId == message.messageId) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    break;
                }
            }

            [SBDSKTicket confirmEndOfChatWithMessage:(SBDUserMessage *)message confirm:NO completionHandler:^(SBDSKTicket * _Nullable ticket, SBDError * _Nullable error) {
                
            }];
        });
        
    }
}

- (void)clickUrlInMessage:(UIView *)view message:(SBDBaseMessage *)message url:(NSURL *)url {
    SBDSKWebViewController *vc = [[SBDSKWebViewController alloc] init];
    vc.url = url;
    vc.message = message;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    });
}

#pragma mark - SBDSKViewControllerDelegate
- (void)closeSendBirdDesk {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.delegate != nil) {
            [self.delegate closeSendBirdDesk];
        }
    }];
}

- (void)updateOpenTicket:(long long)ticketId {
    if (self.delegate != nil) {
        [self.delegate updateOpenTicket:ticketId];
    }
}

- (void)closeImageViewer {
    self.currentFileMessageOnViewer = nil;
    
    if (self.photosViewController != nil) {
        [self.photosViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)saveImageFromViewer {
//    NSData *imageData = self.photosViewController.currentlyDisplayedPhoto.imageData;
//    if (imageData != nil) {
//        UIImage *image = [UIImage imageWithData:imageData];
//        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIView *resultContainerView = [[UIView alloc] init];
    UILabel *resultLabel = [[UILabel alloc] init];
    
    [resultContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [resultLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    resultLabel.textColor = [UIColor whiteColor];
    resultLabel.numberOfLines = 1;
    resultLabel.textAlignment = NSTextAlignmentCenter;
    
    resultContainerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    resultContainerView.layer.cornerRadius = 18;
    resultContainerView.layer.masksToBounds = YES;
    
    [self.photosViewController.view addSubview:resultContainerView];
    [resultContainerView addSubview:resultLabel];
    
    [resultContainerView addConstraint:[NSLayoutConstraint constraintWithItem:resultLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:resultContainerView attribute:NSLayoutAttributeLeading multiplier:1 constant:12]];
    [resultContainerView addConstraint:[NSLayoutConstraint constraintWithItem:resultContainerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:resultLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:12]];
    [resultContainerView addConstraint:[NSLayoutConstraint constraintWithItem:resultContainerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:resultLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self.photosViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:resultContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:36]];
    
    [self.photosViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photosViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:resultContainerView attribute:NSLayoutAttributeBottom multiplier:1 constant:24]];
    [self.photosViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photosViewController.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:resultContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    if (error != nil) {
        resultLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Failed to save." attributes:@{
                                                                                                                                                           NSFontAttributeName: @"Helvetica",
                                                                                                                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                                                           }];
    }
    else {
        resultLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Saved." attributes:@{
                                                                                                                                                            NSFontAttributeName: @"Helvetica",
                                                                                                                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                                                            }];
    }
    
    [UIView animateWithDuration:1.5 animations:^{
        resultContainerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [resultContainerView removeFromSuperview];
    }];
}

#pragma mark - Image Viewer.
- (void)showImageViewerLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageViewerLoadingView.hidden = NO;
        self.imageViewerLoadingIndicator.hidden = NO;
        [self.imageViewerLoadingIndicator startAnimating];
    });
}

- (void)hideImageViewerLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageViewerLoadingView.hidden = YES;
        self.imageViewerLoadingIndicator.hidden = YES;
        [self.imageViewerLoadingIndicator stopAnimating];
    });
}

- (IBAction)clickImageViewerCloseBackgroundButton:(id)sender {
    [self hideImageViewerLoading];
}

- (IBAction)clickImageViewerCloseButton:(id)sender {
    [self hideImageViewerLoading];
}

#pragma mark - TOCropViewControllerDelegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
    UIImage *imageToUse = image;
    CGFloat newWidth = 0;
    CGFloat newHeight = 0;
    UIImage *newImage;
    NSString *mimeType = @"image/jpg";
    if (imageToUse.size.width > 1280 || imageToUse.size.height > 1280) {
        if (imageToUse.size.width > imageToUse.size.height) {
            newWidth = 1280;
            newHeight = newWidth * imageToUse.size.height / imageToUse.size.width;
        }
        else {
            newHeight = 1280;
            newWidth = newHeight * imageToUse.size.width / imageToUse.size.height;
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.0);
        [imageToUse drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else {
        newImage = image;
    }
    
    NSData *resizeImageData = UIImageJPEGRepresentation(newImage, 0.7);
    SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
    
    SBDFileMessage *preSendMessage = [self.ticket.channel sendFileMessageWithBinaryData:resizeImageData filename:@"image.jpg" type:mimeType size:resizeImageData.length thumbnailSizes:@[thumbnailSize] data:@"" customType:@"" progressHandler:nil completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            SBDFileMessage *preSendMessage = (SBDFileMessage *)self.preSendMessages[fileMessage.requestId];
            [self.preSendMessages removeObjectForKey:fileMessage.requestId];
            
            if (error != nil) {
                self.resendableMessages[fileMessage.requestId] = preSendMessage;
                self.resendableFileData[preSendMessage.requestId] = @{
                                                                      @"data": resizeImageData,
                                                                      @"type": mimeType
                                                                      };
                [self.tableView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scrollToBottomWithForce:YES];
                });
                
                return;
            }
            
            if (self.delegate != nil) {
                [self.delegate updateOpenTicket:self.ticket.ticketId];
            }
            
            if (fileMessage != nil) {
                [self.resendableMessages removeObjectForKey:fileMessage.requestId];
                [self.resendableFileData removeObjectForKey:fileMessage.requestId];
                [self.preSendMessages removeObjectForKey:fileMessage.requestId];
                [self.messages replaceObjectAtIndex:[self.messages indexOfObject:preSendMessage] withObject:fileMessage];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self scrollToBottomWithForce:YES];
                    });
                });
            }
        });
    }];
    
    self.preSendFileData[preSendMessage.requestId] = @{
                                                       @"data": resizeImageData,
                                                       @"type": mimeType
                                                       };
    self.preSendMessages[preSendMessage.requestId] = preSendMessage;
    [self.messages addObject:preSendMessage];
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollToBottomWithForce:YES];
    });
    
    [cropViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSURLSessionTaskDelegate for file transfer progress
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSDictionary *downloadTaskDict = self.downloadTasks[downloadTask];
    if (downloadTaskDict != nil) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)downloadTaskDict[@"message"];
        NSMutableDictionary *statusDict = self.fileMessageDownloadingStatus[[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
        float progress = ((float)totalBytesWritten / (float)totalBytesExpectedToWrite) * 100.0;
        statusDict[@"progress"] = @(progress);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int row = 0; row < self.messages.count; row++) {
                if (self.messages[row].messageId == fileMessage.messageId) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    if ([cell isKindOfClass:[SBDSKIncomingGeneralFileMessageTableViewCell class]]) {
                        SBDSKIncomingGeneralFileMessageTableViewCell *fileIncomingCell = (SBDSKIncomingGeneralFileMessageTableViewCell *)cell;
                        [fileIncomingCell setFileDownloadingStatus:1];
                        [fileIncomingCell setDownloadingProgress:progress];
                    }
                    else if ([cell isKindOfClass:[SBDSKOutgoingGeneralFileMessageTableViewCell class]]) {
                        SBDSKOutgoingGeneralFileMessageTableViewCell *fileOutgoingCell = (SBDSKOutgoingGeneralFileMessageTableViewCell *)cell;
                        [fileOutgoingCell setFileDownloadingStatus:1];
                        [fileOutgoingCell setDownloadingProgress:progress];
                    }
                    
                    break;
                }
            }
        });
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSDictionary *downloadTaskDict = self.downloadTasks[downloadTask];
    if (downloadTaskDict != nil) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)downloadTaskDict[@"message"];
        NSString *fileName = fileMessage.name;
        
        NSArray *pathHome = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (pathHome != nil && pathHome.count > 0) {
            NSString *pathDownload = [[pathHome objectAtIndex:0] stringByAppendingPathComponent:@"SBDSKDownload"];
            BOOL isDirectoryDownload = YES;
            if ([[NSFileManager defaultManager] fileExistsAtPath:location.path] == NO) {
                //                NSLog(@"ASDF");
            }
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:pathDownload isDirectory:&isDirectoryDownload] == NO) {
                NSError *createDirectoryError = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:pathDownload withIntermediateDirectories:NO attributes:nil error:&createDirectoryError];
                if (createDirectoryError != nil) {
                    // Show Alert
                    // Cannot download file.
                    
                    return;
                }
            }
            
            if (isDirectoryDownload == YES) {
                NSString *fullFileName = [NSString stringWithFormat:@"%@_%lld_%@", [SBDMain getApplicationId], fileMessage.messageId, fileName];
                NSString *dstPath = [pathDownload stringByAppendingPathComponent:fullFileName];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:nil] == NO) {
                    NSError *fileMoveError = nil;
                    [[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:dstPath] error:&fileMoveError];
                    if (fileMoveError != nil) {
                        // Show Alert
                        // Cannot download file.
                        
                        [self.fileMessageDownloadingStatus removeObjectForKey:[NSString stringWithFormat:@"%lld", fileMessage.messageId]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (int row = 0; row < self.messages.count; row++) {
                                if (self.messages[row].messageId == fileMessage.messageId) {
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                                    if ([cell isKindOfClass:[SBDSKIncomingGeneralFileMessageTableViewCell class]]) {
                                        SBDSKIncomingGeneralFileMessageTableViewCell *fileIncomingCell = (SBDSKIncomingGeneralFileMessageTableViewCell *)cell;
                                        [fileIncomingCell setFileDownloadingStatus:0];
                                    }
                                    else if ([cell isKindOfClass:[SBDSKOutgoingGeneralFileMessageTableViewCell class]]) {
                                        SBDSKOutgoingGeneralFileMessageTableViewCell *fileOutgoingCell = (SBDSKOutgoingGeneralFileMessageTableViewCell *)cell;
                                        [fileOutgoingCell setFileDownloadingStatus:0];
                                    }
                                    
                                    break;
                                }
                            }
                        });
                        
                    }
                    else {
                        self.fileMessageDownloadingStatus[[NSString stringWithFormat:@"%lld", fileMessage.messageId]] = [[NSMutableDictionary alloc] initWithDictionary:@{@"status": @(2), @"progress@": @(100.0)}];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (int row = 0; row < self.messages.count; row++) {
                                if (self.messages[row].messageId == fileMessage.messageId) {
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                                    if ([cell isKindOfClass:[SBDSKIncomingGeneralFileMessageTableViewCell class]]) {
                                        SBDSKIncomingGeneralFileMessageTableViewCell *fileIncomingCell = (SBDSKIncomingGeneralFileMessageTableViewCell *)cell;
                                        [fileIncomingCell setFileDownloadingStatus:2];
                                    }
                                    else if ([cell isKindOfClass:[SBDSKOutgoingGeneralFileMessageTableViewCell class]]) {
                                        SBDSKOutgoingGeneralFileMessageTableViewCell *fileOutgoingCell = (SBDSKOutgoingGeneralFileMessageTableViewCell *)cell;
                                        [fileOutgoingCell setFileDownloadingStatus:2];
                                    }
                                    
                                    break;
                                }
                            }
                        });
                    }
                }
            }
            else {
                // Show Alert
                // Cannot download file.
            }
            
        }
        else {
            
        }
    }
    else {

    }
}

//- (BOOL)checkIfLastMessageIsDowntimeMessage {
//    BOOL result = NO;
//    if (self.messages != nil && self.messages.count > 0) {
//        SBDBaseMessage *lastMessage = self.messages[self.messages.count - 1];
//        if (lastMessage != nil && [lastMessage isKindOfClass:[SBDAdminMessage class]]) {
//            NSString *data = ((SBDAdminMessage *)lastMessage).data;
//            if (data != nil && data.length > 0) {
//                NSError *jsonError = nil;
//                NSDictionary *dataObj = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
//                if (jsonError == nil) {
//                    NSString *type = dataObj[@"type"];
//                    BOOL enabled = [dataObj[@"enabled"] boolValue];
//                    if ([type isEqualToString:@"TICKET_PROJECT_DOWNTIME"] && enabled) {
//                        result = YES;
//                    }
//                }
//            }
//        }
//    }
//
//    return result;
//}

//- (void)checkDowntimeMessage {
//    long long ticketId = self.ticket != nil ? self.ticket.ticketId : -1;
//    [SBDSKMain checkDowntimeMessageWithMessageId:ticketId completionHandler:^(SBDSKTicket * _Nullable ticket, NSError * _Nullable error) {
//        
//    }];
//}

@end
