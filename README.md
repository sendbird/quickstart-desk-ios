Senbird Desk - QuickStart for iOS
===========
## Introduction
SendBird Desk is a chat customer service platform built on SendBird SDK and API.

Desk iOS SDK provides customer-side integration on your own application, so you can easily implement a ticketing system with chat inquiry, inquiries inbox with UI theming. 

This repo was made to share a barebones quickstart implementation of how to use SendBird Desk.
It goes through the steps of:
- Connecting to SendBird
- Connecting to SendBird Desk
- Creating a Ticket
- Retrieving Closed Tickets

## Table of Contents

  1. [Introduction](#introduction)
  2. [Prerequisites](#prerequisites)
  3. [Creating a SendBird application](#creating-a-sendbird-application)
  4. [Install via CocoaPods](#loading-inbox)
  5. [Install SendBirdDesk framework manually](#installing-sendbirddesk-framework-manually)
  6. [Install via Carthage](#install-via-carthage)
  7. [Reference](#reference)
  
## Prerequisites 
- iOS 8.0 or higher
- SendBird iOS SDK 3.0.90 or higher
  
## Installation

## Creating a SendBird application
1. Login or Sign-up for an account at [dashboard](https://dashboard.sendbird.com/).
2. Create or select an application on the SendBird Dashboard.
3. Note the Application ID for future reference.
4. [Contact sales](https://sendbird.com/contact-sales) to get the Desk menu enabled in the dashboard. Sendbird Desk is available only for free-trial or Enterprise plan 

## 1. Install via CocoaPods

First of all, you need SendBird App ID to start (It can be created on [SendBird Dashboard](https://dashboard.sendbird.com), but for Desk usage, you may need upgrade.), so please contact [desk@sendbird.com](mailto:desk@sendbird.com) if you want one.

1. Create or edit your `Podfile`

```
# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'

target 'YOUR_PROJECT' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for SendBird Desk
  pod 'SendBirdSDK', '>= 3.0.90'
  pod 'SendBirdDesk'
end
```
2. Run `pod install`.
3. Open `QuickStart.xcworkspace`.

## 2. Install SendBirdDesk framework manually
* Add `UserNotifications.framework` to `Linked Frameworks and Libraries`.
* Add `SendBirdDesk.framework` to `Embedded Binaries`.

### 3. Install via Carthage
1. Add `github "sendbird/sendbird-desk-ios-framework"`  to your `Cartfile`.
2. Run `carthage update`.
3. A `Cartfile.resolved` file and a `Carthage` directory will appear in the same directory as `.xcodeproj` or `.xcworkspace`.
4. Drag the built `.framework` binaries from `Carthage/Build/iOS` into the application’s Xcode project.
5. On the application targets’ `Build Phases` settings tab, click the `+` icon and choose `New Run Script Phase`. Create a `Run Script` that specifies the desired shell (e.g. `/bin/sh`), then add the following contents to the script area below the shell:
```bash
/usr/local/bin/carthage copy-frameworks`.
```
6. Add the paths to the desired frameworks under `Input Files`. For example:
```
$(SRCROOT)/Carthage/Build/iOS/SendBirdCalls.framework
$(SRCROOT)/Carthage/Build/iOS/WebRTC.framework
```
7. Add the paths to the copied frameworks to the `Output Files`. For example:
```
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SendBirdCalls.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/WebRTC.framework
```

## Reference
Please see the following link for iOS Desk SDK Documentation: https://github.com/sendbird/SendBird-Desk-iOS-Framework