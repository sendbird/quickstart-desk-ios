//
//  SBDSKWebViewController.m
//  QuickStart
//
//  Created by SendBird on 6/14/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "SBDSKWebViewController.h"
//#import "SBDSKEventActionKey.h"
#import "SBDSKUtils.h"
#import "UIViewController+Utils.h"
#import "ChattingViewController.h"

@interface SBDSKWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIView *titleLabelContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customNavigationViewHeight;


@end

@implementation SBDSKWebViewController

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    if ([SBDSKUtils isIPhoneX]) {
        self.customNavigationViewHeight.constant = 88;
    }
    
    self.titleLabelContainerView.layer.cornerRadius = 6;
    self.titleLabelContainerView.clipsToBounds = YES;
    
//    self.titleLabelContainerView.backgroundColor = [SBDSKMain sharedInstance].webViewUrlBackgroundColor;
//    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.url.absoluteString attributes:[SBDSKMain sharedInstance].webViewUrlLabelAttribute];
    
//    [self.doneButton setAttributedTitle:[[NSAttributedString alloc] initWithString:[SBDSKMain sharedInstance].localizedWebViewDoneButton attributes:[SBDSKMain sharedInstance].navigationBarButtonAttribute] forState:UIControlStateNormal];
    
//    [self.backButton setImage:[SBDSKMain sharedInstance].webViewBackButtonOnImage forState:UIControlStateNormal];
//    [self.backButton setImage:[SBDSKMain sharedInstance].webViewBackButtonOffImage forState:UIControlStateDisabled];
    
//    [self.forwardButton setImage:[SBDSKMain sharedInstance].webViewForwardButtonOnImage forState:UIControlStateNormal];
//    [self.forwardButton setImage:[SBDSKMain sharedInstance].webViewForwardButtonOffImage forState:UIControlStateDisabled];
    
    [self.backButton setEnabled:[self.webView canGoBack]];
    [self.forwardButton setEnabled:[self.webView canGoForward]];
    
//    [SBDSKMain triggerEvent:SBDSK_WEB_VIEWER_ENTER metaData:@{
//                                                              @"url": self.url == nil ? @"" : self.url,
//                                                              }];
    
//    [SBDMain addChannelDelegate:self identifier:self.description];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

- (IBAction)clickDoneButton:(id)sender {
//    [SBDMain removeChannelDelegateForIdentifier:self.description];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickBackButton:(id)sender {
    [self.webView goBack];
}

- (IBAction)clickForwardButton:(id)sender {
    [self.webView goForward];
}

- (IBAction)clickRefreshButton:(id)sender {
    [self.webView reload];
}

- (IBAction)clickRefreshBackgroundButton:(id)sender {
    [self.webView reload];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:request.URL.absoluteString.lowercaseString attributes:@{
                                                                                                                                        NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16],
//                                                                                                                                        NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:webViewUrlLabelFontColor],
                                                                                                                                        }];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"].lowercaseString;
    
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:currentURL attributes:@{
                                                                                                        NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:16],
//                                                                                                        NSForegroundColorAttributeName: [SBDSKUtils colorWithHex:webViewUrlLabelFontColor],
                                                                                                        }];

    [self.backButton setEnabled:[self.webView canGoBack]];
    [self.forwardButton setEnabled:[self.webView canGoForward]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self dismissViewControllerAnimated:NO completion:^{
        ChattingViewController *currentVc = (ChattingViewController *)[UIViewController currentViewController];
        [currentVc openChatWithChannelUrl:channelUrl];
    }];
}

@end
