//
//  UIButton+SBDSKButton.m
//  QuickStart
//
//  Created by SendBird on 6/8/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "UIButton+SBDSKButton.h"

@implementation UIButton (SBDSKButton)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[UIButton imageFromColor:backgroundColor] forState:state];
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
