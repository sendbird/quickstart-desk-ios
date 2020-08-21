# Sendbird Desk for iOS sample

![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Objective--C-orange.svg)

## Introduction

Built with Sendbird Chat platforms, Sendbird Desk is a live chat customer support that offers customer satisfaction through enhanced engagement. Through its integration, Desk SDK for iOS enables you to easily customize your ticketing support system with a UI theme, thereby elevating your overall customers’ experience. For example, you can modify the inbox - a management tool and storage unit for the agents’ and tickets’ conversations - to fit within your color scheme and layout.

<br />

## Before getting started

This section provides the pre-installation steps for Sendbird Desk for iOS sample app. 
  
### Requirements

- iOS 8.0 or later
- Chat SDK foriOS SDK 3.0.90 or later

### Try the sample app applied with your data 

If you would like to customize the sample app for your usage, you can replace the default sample app ID with your ID - which you can obtain by c[creating your Sendbird application from the dashboard](https://docs.sendbird.com/ios/quick_start#3_install_and_configure_the_chat_sdk_4_step_1_create_a_sendbird_application_from_your_dashboard).

> Note: After creating the Sendbird application, please be sure to contact sales to enable the Desk menu onto the dashboard. Currently, Sendbird Desk is available only for free-trial or Enterprise plans.

Following the previous instructions will allow you to experience the sample app with your data from the Sendbird application.

## Creating a Sendbird application
1. Login or Sign-up for an account at [dashboard](https://dashboard.sendbird.com/).
2. Create or select an application on the Sendbird Dashboard.
3. Note the Application ID for future reference.
4. [Contact sales](https://sendbird.com/contact-sales) to get the Desk menu enabled in the dashboard. Sendbird Desk is available only for free-trial or Enterprise plan 

## 1. Install via CocoaPods

First of all, you need Sendbird App ID to start (It can be created on [Sendbird Dashboard](https://dashboard.sendbird.com), but for Desk usage, you may need upgrade.), so please contact [desk@sendbird.com](mailto:desk@sendbird.com) if you want one.

1. Create or edit your `Podfile`

```
# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'

target 'YOUR_PROJECT' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for Sendbird Desk
  pod 'SendBirdSDK', '>= 3.0.90'
  pod 'SendBirdDesk'
end
```
2. Run `pod install`.
3. Open `QuickStart.xcworkspace`.

## 2. Install SendBirdDesk framework manually
* Add `UserNotifications.framework` to `Linked Frameworks and Libraries`.
* Add `SendBirdDesk.framework` to `Embedded Binaries`.

## 3. Install via Carthage
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
