//
//  SBDSKOpenSourceLicenseViewController.m
//  QuickStart
//
//  Created by SendBird on 7/12/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "SBDSKOpenSourceLicenseViewController.h"
#import "SBDSKUtils.h"
#import "UIViewController+Utils.h"
#import "SBDSKSettingsViewController.h"

#define LICENSE_AFNETWORKING @" \
= AFNetworking =\n \
\n \
Copyright (c) 2011-2016 Alamofire Software Foundation (http://alamofire.org/)\n \
\n\
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n \
\n\
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n \
\n\
THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n"

#define LICENSE_NYTPHOTOVIEWER @" \
= NYTPhotoViewer =\n \
\n \
Copyright (c) 2015-2016 The New York Times Company\n \
\n \
Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this library except in compliance with the License. You may obtain a copy of the License at \n \
\n \
http://www.apache.org/licenses/LICENSE-2.0\n \
\n \
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.\n\n"

#define LICENSE_TOPCROPVIEWCONTROLLER @" \
= TOPCropViewController =\n \
\n \
The MIT License (MIT)\n \
\n \
Copyright (c) 2015-2016 Tim Oliver\n \
\n \
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: \n \
\n \
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n \
\n \
THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n"

#define LICENSE_HTMLKIT @" \
= HTMLKit =\n \
\n \
The MIT License (MIT)\n \
\n \
Copyright (c) 2014 Iskandar Abudiab\n \
\n \
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n \
\n \
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n \
\n \
THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n\n"


@interface SBDSKOpenSourceLicenseViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backBackgroundButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *backTextButton;
@property (weak, nonatomic) IBOutlet UITextView *licenseTextView;

@end

@implementation SBDSKOpenSourceLicenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.licenseTextView.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", LICENSE_AFNETWORKING, LICENSE_NYTPHOTOVIEWER, LICENSE_TOPCROPVIEWCONTROLLER, LICENSE_HTMLKIT];
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

- (void)openChatWithChannelUrl:(NSString *)channelUrl {
    [self dismissViewControllerAnimated:NO completion:^{
        SBDSKSettingsViewController *currentVc = (SBDSKSettingsViewController *)[UIViewController currentViewController];
        [currentVc openChatWithChannelUrl:channelUrl];
    }];
}

@end
