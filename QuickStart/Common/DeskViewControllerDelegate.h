//
//  DeskViewControllerDelegate.h
//  QuickStart
//
//  Created by SendBird on 3/19/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

#ifndef DeskViewControllerDelegate_h
#define DeskViewControllerDelegate_h

#import <Foundation/Foundation.h>

@protocol DeskViewControllerDelegate<NSObject>

@optional
- (void)closeSendBirdDesk;
- (void)updateOpenTicket:(long long)ticketId;

@end

#endif /* DeskViewControllerDelegate_h */
