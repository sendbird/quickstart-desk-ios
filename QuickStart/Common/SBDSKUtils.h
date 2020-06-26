//
//  SBDSKUtils.h
//  QuickStart
//
//  Created by SendBird on 5/2/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

@interface SBDSKUtils : NSObject

+ (nullable UIColor *)colorWithHex:(NSString * _Nonnull)hexColor;
+ (nullable UIColor *)colorWithHex:(NSString * _Nonnull)hexColor opacity:(CGFloat)opacity;
+ (nullable NSString *)localizedStringForKey:(NSString * _Nonnull)key bundle:(NSBundle * _Nonnull)bundle assetFile:(NSString * _Nonnull)assetFile stringFile:(NSString * _Nonnull)stringFile;
+ (nullable NSString *)fileSizeFromByteSize:(long long)byteSize;

+ (nullable NSMutableDictionary *)initFileCache;
+ (void)saveFileCache:(NSDictionary * _Nullable)fileCacheDict;
+ (void)clearDownloadedFiles;
+ (BOOL)isIPhoneX;
//+ (SBDSKDevice)currentDevice;

+ (nullable NSString *)percentEscapedStringFromString:(nullable NSString *)string;

@end
