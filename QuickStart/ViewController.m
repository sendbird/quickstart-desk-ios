//
//  ViewController.m
//  QuickStart
//
//  Created by SendBird on 3/19/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+Utils.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomMargin;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong) NSString *channelUrl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view bringSubviewToFront:self.activityIndicatorView];
    self.self.activityIndicatorView.hidden = YES;
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbirddesk_user_id"];
    NSString *userNickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbirddesk_user_nickname"];
    
    self.userIdTextField.text = userId;
    self.nicknameTextField.text = userNickname;
    
    // Initialize keyboard control
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.scrollViewBottomMargin.constant = keyboardFrameBeginRect.size.height;
        [self.view layoutIfNeeded];
    });
}

- (void)keyboardWillHide:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.scrollViewBottomMargin.constant = 0;
        [self.view layoutIfNeeded];
    });
}

- (IBAction)clickInboxButton:(id)sender {
    self.channelUrl = nil;
    [self connect];
}

- (void)connect {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView startAnimating];
    });
    
    NSString *userId = [self.userIdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *nickname = [self.nicknameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (userId.length == 0 || nickname.length == 0) {
        return;
    }
    
    [SBDMain connectWithUserId:userId accessToken:nil completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
        if (error != nil) {
            // Error handling.
            dispatch_async(dispatch_get_main_queue(), ^{
                self.activityIndicatorView.hidden = YES;
                [self.activityIndicatorView stopAnimating];
            });
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"sendbirddesk_user_id"];
        [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:@"sendbirddesk_user_nickname"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
            if (error != nil) {
                NSLog(@"APNS registration failed.");
                return;
            }
            if (status == SBDPushTokenRegistrationStatusPending) {
                NSLog(@"Push registration is pending.");
            }
            else {
                NSLog(@"APNS Token is registered.");
            }
        }];
        
        [SBDMain updateCurrentUserInfoWithNickname:nickname profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                // Error handling.
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.activityIndicatorView.hidden = YES;
                    [self.activityIndicatorView stopAnimating];
                });
                return;
            }
            
            [SBDSKMain authenticateWithUserId:userId accessToken:nil completionHandler:^(SBDError * _Nullable error) {
                if (error != nil) {
                    // Error handling.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.activityIndicatorView.hidden = YES;
                        [self.activityIndicatorView stopAnimating];
                    });
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.activityIndicatorView.hidden = YES;
                    [self.activityIndicatorView stopAnimating];
                    
                    InboxViewController *vc = [[InboxViewController alloc] init];
                    vc.previousViewController = nil;
                    vc.channelUrl = self.channelUrl;
                    self.channelUrl = nil;
                    [self presentViewController:vc animated:YES completion:nil];
                });
            }];
        }];
    }];
}

- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    self.channelUrl = channelUrl;
    [self connect];
}

@end
