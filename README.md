# Sendbird Desk for iOS sample

![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Objective--C-orange.svg)

## Introduction

Built with Sendbird Chat platform, Sendbird Desk is a live chat customer support that offers customer satisfaction through enhanced engagement. Through its integration, Desk SDK for iOS enables you to easily customize your ticketing support system with a UI theme, thereby elevating your overall customers’ experience. For example, you can modify the inbox - a management tool and storage unit for the agents’ and tickets’ conversations - to fit within your color scheme and layout.

<br />

## Before getting started

This section shows you the prerequisites you need for testing Sendbird Desk for iOS sample app.

### Requirements

- iOS 8.0 or later
- Chat SDK for iOS 3.0.90 or later

### Try the sample app applied with your data 

If you would like to customize the sample app for your usage, you can replace the default sample app ID with your ID - which you can obtain by [creating your Sendbird application from the dashboard](https://docs.sendbird.com/ios/quick_start#3_install_and_configure_the_chat_sdk_4_step_1_create_a_sendbird_application_from_your_dashboard).

> Note: After creating the Sendbird application, please be sure to contact [sales](https://get.sendbird.com/talk-to-sales.html) to enable the Desk menu onto the dashboard. Currently, Sendbird Desk is available only for free-trial or Enterprise plans.

Following the previous instructions will allow you to experience the sample app with your data from the Sendbird application.

<br />

## Getting started

This section explains how to install Desk SDK for iOS before testing the sample app. If you're familiar with using external libraries or SDKs in your projects, installing the Desk SDK will be an easy and straightforward process.

### Create a project

Create a project to get started.

### Install Desk SDK for iOS

You can install the Desk SDK through either `CocoaPods` or `Carthage` or through manual set-up. 

#### CocoaPods

1. Create or edit your `Podfile`

```bash
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

#### Carthage

1. Add `github "sendbird/sendbird-desk-ios-framework"` to your `Cartfile`.
2. Run `carthage update`.
3. A `Cartfile.resolved` file and a `Carthage` directory will appear in the same directory as `.xcodeproj` or `.xcworkspace`.
4. Drag the built `.framework` binaries from `Carthage/Build/iOS` into the application’s Xcode project.
5. On the application targets’ `Build Phases` settings tab, click the `+` icon and choose `New Run Script Phase`. Create a `Run Script` that specifies the desired shell (e.g. `/bin/sh`), then add the following contents to the script area below the shell:
```bash
/usr/local/bin/carthage copy-frameworks`.
```
6. Add the paths to the desired frameworks under `Input Files`. For example:
```bash
$(SRCROOT)/Carthage/Build/iOS/SendBirdCalls.framework
$(SRCROOT)/Carthage/Build/iOS/WebRTC.framework
```
7. Add the paths to the copied frameworks to the `Output Files`. For example:
```bash
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SendBirdCalls.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/WebRTC.framework
```

#### Manual set-up

* Add `UserNotifications.framework` to `Linked Frameworks and Libraries`.
* Add `SendBirdDesk.framework` to `Embedded Binaries`.

<br />

## For further reference

Please visit the following link to learn more about Desk SDK for iOS: https://github.com/sendbird/SendBird-Desk-iOS-Framework
