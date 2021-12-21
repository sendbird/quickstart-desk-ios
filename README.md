# Sendbird Desk for iOS sample

![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)

## Introduction

Built with Sendbird Chat platform, Sendbird Desk is a live chat customer support that offers customer satisfaction through enhanced engagement. Through its integration, Desk SDK for iOS enables you to easily customize your ticketing support system with a UI theme, thereby elevating your overall customers’ experience. For example, you can modify the inbox - a management tool and storage unit for the agents’ and tickets’ conversations - to fit within your color scheme and layout.

### More about Sendbird Desk for iOS

Find out more about Sendbird Desk for iOs on [Desk for iOS doc](https://sendbird.com/docs/desk/v1/ios/getting-started/about-desk-sdk). If you need any help in resolving any issues or have questions, visit [our community](https://community.sendbird.com).

<br />

## Before getting started

This section shows you the prerequisites you need for testing Sendbird Desk for iOS sample app.

### Requirements

- iOS 11.0 or later
- Swift 5.0 or later
- [Chat SDK for iOS](https://github.com/sendbird/sendbird-ios-framework) 3.0.238 or later
- [UIKit SDK for iOS](https://github.com/sendbird/sendbird-uikit-ios) 2.1.16 or later

### Try the sample app using your data 

If you would like to customize the sample app for your usage, you can replace the default sample app ID with your ID - which you can obtain by [creating your Sendbird application from the dashboard](https://sendbird.com/docs/chat/v3/ios/getting-started/install-chat-sdk#2-step-1-create-a-sendbird-application-from-your-dashboard).

> Note: After creating the Sendbird application, please be sure to contact [sales](https://get.sendbird.com/talk-to-sales.html) to enable the **Desk** menu onto the dashboard. Currently, Sendbird Desk is available only for **free-trial** or **Enterprise** plans.

Following the previous instructions will allow you to experience the sample app with your data from the Sendbird application.

<br />

## Getting started

This section explains how to install Desk SDK for iOS before testing the sample app. If you're familiar with using external libraries or SDKs in your projects, installing the Desk SDK will be an easy and straightforward process.

### Create a project

Create a project to get started.

### Install Desk SDK for iOS

You can install the Desk SDK through either [CocoaPods](https://cocoapods.org/), [Carthage](https://github.com/Carthage/Carthage) or [Swift Package Manager](https://www.swift.org/package-manager/).

#### - CocoaPods

1. Create or edit your `Podfile`

```bash
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'YOUR_PROJECT' do
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    
    # Pods for YOUR_PROJECT
    # Desk
    pod 'SendBirdDesk'
    # UIKit
    pod 'SendBirdUIKit'

end
```
2. Run `pod install`.
3. Open `QuickStart.xcworkspace`.

#### - Carthage

1. Add `SendBirdDesk` and `SendBirdSDK` into your `Cartfile` as below:

```bash
github "sendbird/sendbird-desk-ios-framework"
github "sendbird/sendbird-ios-framework" == 3.0.90
```

2. Install the `SendBirdDesk` framework through `Carthage`.

```bash
$ carthage update --use-xcframeworks
```

#### - Swift Package Manager

1. File -> Swift Packages -> Add package dependency...

2. Choose Package Repository as the SendbirdDesk repository with below link:
```bash
https://github.com/sendbird/SendBird-Desk-iOS-Framework.git
```

3. Select Up to Next Major rules and click the Next button to add the package.

<br />

## For further reference

Please visit the following link to learn more about Desk SDK for iOS: https://github.com/sendbird/SendBird-Desk-iOS-Framework
