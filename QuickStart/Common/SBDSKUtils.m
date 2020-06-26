//
//  SBDSKUtils.m
//  QuickStart
//
//  Created by SendBird on 5/2/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "SBDSKUtils.h"
#import <SendBirdDesk/SendBirdDesk.h>

@implementation SBDSKUtils

+ (nullable UIColor *)colorWithHex:(NSString * _Nonnull)hexColor {
    if ([hexColor hasPrefix:@"#"]) {
        NSString *hexString = [hexColor substringWithRange:NSMakeRange(1, hexColor.length - 1)];
        NSString *hexR = @"";
        NSString *hexG = @"";
        NSString *hexB = @"";
        NSString *hexA = @"FF";
        if (hexString.length >= 6) {
            hexR = [hexString substringWithRange:NSMakeRange(0, 2)];
            hexG = [hexString substringWithRange:NSMakeRange(2, 2)];
            hexB = [hexString substringWithRange:NSMakeRange(4, 2)];
            if(hexString.length == 8) {
                hexA = [hexString substringWithRange:NSMakeRange(6, 2)];
            }
        }
        
        if (hexR != nil && hexG != nil && hexB != nil && hexA != nil) {
            unsigned redInt = 0;
            unsigned greenInt = 0;
            unsigned blueInt = 0;
            unsigned alphaInt = 0;
            
            NSScanner *scannerRedHex = [NSScanner scannerWithString:hexR];
            [scannerRedHex scanHexInt:&redInt];
            
            NSScanner *scannerGreenHex = [NSScanner scannerWithString:hexG];
            [scannerGreenHex scanHexInt:&greenInt];
            
            NSScanner *scannerBlueHex = [NSScanner scannerWithString:hexB];
            [scannerBlueHex scanHexInt:&blueInt];
            
            NSScanner *scannerAlphaHex = [NSScanner scannerWithString:hexA];
            [scannerAlphaHex scanHexInt:&alphaInt];
            
            UIColor *color = [UIColor colorWithRed:((CGFloat)redInt)/255.0 green:((CGFloat)greenInt)/255.0 blue:((CGFloat)blueInt)/255.0 alpha:((CGFloat)alphaInt)/255.0];
            
            return color;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

+ (nullable UIColor *)colorWithHex:(NSString * _Nonnull)hexColor opacity:(CGFloat)opacity {
    if ([hexColor hasPrefix:@"#"]) {
        NSString *hexString = [hexColor substringWithRange:NSMakeRange(1, hexColor.length - 1)];
        NSString *hexR = @"";
        NSString *hexG = @"";
        NSString *hexB = @"";
        if (hexString.length >= 6) {
            hexR = [hexString substringWithRange:NSMakeRange(0, 2)];
            hexG = [hexString substringWithRange:NSMakeRange(2, 2)];
            hexB = [hexString substringWithRange:NSMakeRange(4, 2)];

        }
        
        if (hexR != nil && hexG != nil && hexB != nil) {
            unsigned redInt = 0;
            unsigned greenInt = 0;
            unsigned blueInt = 0;
            
            NSScanner *scannerRedHex = [NSScanner scannerWithString:hexR];
            [scannerRedHex scanHexInt:&redInt];
            
            NSScanner *scannerGreenHex = [NSScanner scannerWithString:hexG];
            [scannerGreenHex scanHexInt:&greenInt];
            
            NSScanner *scannerBlueHex = [NSScanner scannerWithString:hexB];
            [scannerBlueHex scanHexInt:&blueInt];
            
            UIColor *color = [UIColor colorWithRed:((CGFloat)redInt)/255.0 green:((CGFloat)greenInt)/255.0 blue:((CGFloat)blueInt)/255.0 alpha:opacity];
            
            return color;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

+ (nullable NSString *)localizedStringForKey:(NSString * _Nonnull)key bundle:(NSBundle * _Nonnull)bundle assetFile:(NSString * _Nonnull)assetFile stringFile:(NSString * _Nonnull)stringFile {
    NSString *bundleResourcePath = bundle.resourcePath;
    NSString *assetPath = [bundleResourcePath stringByAppendingPathComponent:assetFile];
    return NSLocalizedStringFromTableInBundle(key, stringFile, [NSBundle bundleWithPath:assetPath], nil);
}

+ (nullable NSString *)fileSizeFromByteSize:(long long)byteSize {
    NSString *fileSizeString = @"";
    if (byteSize < 1024) {
        fileSizeString = [NSString stringWithFormat:@"%lld B", byteSize];
    }
    else if (byteSize < 1024 * 1024) {
        fileSizeString = [NSString stringWithFormat:@"%.2lf KB", (double)((double)byteSize / 1024.0)];
    }
    else if (byteSize < 1024 * 1024 * 1024) {
        fileSizeString = [NSString stringWithFormat:@"%.2lf MB", (double)((double)byteSize / (1024.0 * 1024.0))];
    }
    else {
        fileSizeString = [NSString stringWithFormat:@"%.2lf MB", (double)((double)byteSize / (1024.0 * 1024.0 * 1024.0))];
    }
    
    return fileSizeString;
}

+ (nullable NSMutableDictionary *)initFileCache {
    NSMutableDictionary *fileCacheDict = [[NSMutableDictionary alloc] init];
    NSArray *pathHome = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (pathHome != nil && pathHome.count > 0) {
        NSString *pathDownload = [[pathHome objectAtIndex:0] stringByAppendingPathComponent:@"SBDSKDownload"];
        BOOL isDirectoryDownload = YES;
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathDownload isDirectory:&isDirectoryDownload] == NO) {
            NSError *createDirectoryError = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:pathDownload withIntermediateDirectories:NO attributes:nil error:&createDirectoryError];
            if (createDirectoryError != nil) {
                return fileCacheDict;
            }
        }
            
        if (isDirectoryDownload == YES) {
            NSString *jsonfile = [NSString stringWithFormat:@"%@.json", [SBDMain getApplicationId]];
            NSString *dstPath = [pathDownload stringByAppendingPathComponent:jsonfile];
                
            if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:nil] == YES) {
                NSData *jsonData = [NSData dataWithContentsOfFile:dstPath];
                NSError *jsonError = nil;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError == nil) {
                    fileCacheDict = [[NSMutableDictionary alloc] initWithDictionary:jsonDict];
                }
            }
        }
    }

    return fileCacheDict;
}

+ (void)saveFileCache:(NSDictionary * _Nullable)fileCacheDict {
    NSString *dstPath;
    NSArray *pathHome = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (pathHome != nil && pathHome.count > 0) {
        NSString *pathDownload = [[pathHome objectAtIndex:0] stringByAppendingPathComponent:@"SBDSKDownload"];
        BOOL isDirectoryDownload = YES;
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathDownload isDirectory:&isDirectoryDownload] == NO) {
            NSError *createDirectoryError = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:pathDownload withIntermediateDirectories:NO attributes:nil error:&createDirectoryError];
            if (createDirectoryError != nil) {
                return;
            }
        }
        
        if (isDirectoryDownload == YES) {
            NSString *jsonfile = [NSString stringWithFormat:@"%@.json", [SBDMain getApplicationId]];
            dstPath = [pathDownload stringByAppendingPathComponent:jsonfile];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:nil] == YES) {
                NSError *removeError = nil;
                [[NSFileManager defaultManager] removeItemAtPath:dstPath error:&removeError];
                if (removeError != nil) {
                    return;
                }
            }
        }
    }
    
    NSString *jsonStr = @"{}";
    @autoreleasepool {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fileCacheDict options:NSJSONWritingPrettyPrinted error:&error];
        
        if (!jsonData) {
            if (error != nil) {

            }
        }
        else {
            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    
    [jsonStr writeToFile:dstPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

+ (void)clearDownloadedFiles {
    NSArray *pathHome = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (pathHome != nil && pathHome.count > 0) {
        NSString *pathDownload = [[pathHome objectAtIndex:0] stringByAppendingPathComponent:@"SBDSKDownload"];
        BOOL isDirectoryDownload = YES;
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathDownload isDirectory:&isDirectoryDownload] == YES) {
            NSDirectoryEnumerator *en = [[NSFileManager defaultManager] enumeratorAtPath:pathDownload];
            NSString *file;
            while (file = [en nextObject]) {
                [[NSFileManager defaultManager] removeItemAtPath:[pathDownload stringByAppendingPathComponent:file] error:nil];
            }
        }
    }
}

+ (BOOL)isIPhoneX {
    CGFloat height = [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.height * [[UIScreen mainScreen] scale];
    CGFloat width = [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width * [[UIScreen mainScreen] scale];
    
    if (width == 1125.0 && height == 2436.0) {
        // iPhone X
        return YES;
    }
    else {
        return NO;
    }
}

//+ (SBDSKDevice)currentDevice {
//    CGFloat height = [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.height * [[UIScreen mainScreen] scale];
//    CGFloat width = [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width * [[UIScreen mainScreen] scale];
//    SBDSKDevice device = SBDSKDeviceUnknown;
//    
//    if (width == 640 && height == 960) {
//        device = SBDSKDeviceiPhone4;
//    }
//    else if (width == 640 & height == 1126) {
//        device = SBDSKDeviceiPhone5;
//    }
//    else if (width == 750 && height == 1334) {
//        device = SBDSKDeviceiPhone8;
//    }
//    else if (width == 1242 && height == 2208) {
//        device = SBDSKDeviceiPhone8Plus;
//    }
//    else if (width == 1125 && height == 2436) {
//        device = SBDSKDeviceiPhoneX;
//    }
//    else if (width == 768 && height == 1024) {
//        device = SBDSKDeviceiPad;
//    }
//    else if (width == 1536 && height == 2048) {
//        device = SBDSKDeviceiPadMini;
//    }
//    else if (width == 1668 && height == 2224) {
//        device = SBDSKDeviceiPadPro105;
//    }
//    else if (width == 2048 && height == 2732) {
//        device = SBDSKDeviceiPadPro129;
//    }
//    
//    return device;
//}

+ (NSString *)percentEscapedStringFromString:(NSString *)string {
    if (string == nil) {
        return nil;
    }
    
    static NSString * const kSBDSKCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kSBDSKCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kSBDSKCharactersGeneralDelimitersToEncode stringByAppendingString:kSBDSKCharactersSubDelimitersToEncode]];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}


@end
