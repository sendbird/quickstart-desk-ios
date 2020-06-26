//
//  SBDSKAdminMessageTableViewCell.h
//  QuickStart
//
//  Created by SendBird on 4/24/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdDesk/SendBirdDesk.h>

@interface SBDSKAdminMessageTableViewCell : UITableViewCell

@property (atomic, readonly) CGFloat cellHeight;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (void)setModel:(SBDAdminMessage *)model;

@end
