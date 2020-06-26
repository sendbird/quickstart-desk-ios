//
//  SBDSKSettingsViewController.m
//  QuickStart
//
//  Created by SendBird on 4/27/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "SBDSKSettingsViewController.h"
#import "SBDSKUtils.h"
#import "SBDSKOpenSourceLicenseViewController.h"
#import "InboxViewController.h"
#import "UIViewController+Utils.h"

@interface SBDSKSettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pushNotificationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *applyingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *backTextButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *closeBackgroundButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *clearDownloadedFilesButton;
@property (weak, nonatomic) IBOutlet UIButton *openSourceLicenseButton;
@property (weak, nonatomic) IBOutlet UILabel *clearDownloadedFilesLabel;
@property (weak, nonatomic) IBOutlet UILabel *openSourceLicenseLabel;

@end

@implementation SBDSKSettingsViewController

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    // push notification switch
    self.pushNotificationSwitch.onTintColor = [SBDSKUtils colorWithHex:@"D6033A"];

    self.closeButton.hidden = YES;
    self.closeBackgroundButton.hidden = YES;

#if !(TARGET_OS_SIMULATOR)
    BOOL isRegisteredForRemoteNotifications = YES;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sendbirddesk_push_notification"] != nil) {
        isRegisteredForRemoteNotifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sendbirddesk_push_notification"] boolValue];
    }
    [self.pushNotificationSwitch setOn:isRegisteredForRemoteNotifications];
#else
    self.pushNotificationSwitch.enabled = NO;
#endif
    
    self.applyingActivityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickBackBackgroundButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickBackTextButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickCloseButton:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.delegate != nil) {
            [self.delegate closeSendBirdDesk];
        }
    }];
}

- (IBAction)clickCloseBackgroundButton:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.delegate != nil) {
            [self.delegate closeSendBirdDesk];
        }
    }];
}

- (IBAction)clickPushNotificationSwitch:(id)sender {
#if !(TARGET_OS_SIMULATOR)
    if (sender == self.pushNotificationSwitch) {
        self.applyingActivityIndicator.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.applyingActivityIndicator startAnimating];
            BOOL pushOnOff = [self.pushNotificationSwitch isOn];
            if (pushOnOff) {
                [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
                    if (error != nil) {
                        [self.pushNotificationSwitch setOn:NO];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"sendbirddesk_push_notification"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.applyingActivityIndicator.hidden = YES;
                        [self.applyingActivityIndicator stopAnimating];
                    });
                }];
            }
            else {
                [SBDMain unregisterPushToken:[SBDMain getPendingPushToken] completionHandler:^(NSDictionary * _Nullable response, SBDError * _Nullable error) {
                    if (error != nil) {
                        [self.pushNotificationSwitch setOn:YES];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"sendbirddesk_push_notification"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.applyingActivityIndicator.hidden = YES;
                        [self.applyingActivityIndicator stopAnimating];
                    });
                }];
            }
        });
    }
#endif
}

- (IBAction)clickClearDownloadedFilesButton:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Clear Downloaded Files" message:@"Would you like to clear downloaded files?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [SBDSKUtils clearDownloadedFiles];
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    
    [vc addAction:confirmAction];
    [vc addAction:closeAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (IBAction)clickOpenSourceLicenseButton:(id)sender {
    SBDSKOpenSourceLicenseViewController *vc = [[SBDSKOpenSourceLicenseViewController alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self dismissViewControllerAnimated:NO completion:^{
        InboxViewController *currentVc = (InboxViewController *)[UIViewController currentViewController];
        [currentVc openChatWithChannelUrl:channelUrl];
    }];
}

@end
