//
//  SBDSKFileImage.h
//  QuickStart
//
//  Created by SendBird on 4/28/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NYTPhotoViewer/NYTPhoto.h>

@interface SBDSKFileImage : NSObject<NYTPhoto>

@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end
