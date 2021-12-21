//
//  AppDelegate.swift
//  Quickstart
//
//  Created by Minhyuk Kim on 2021/11/25.
//

import UIKit
import SendBirdUIKit
import SendBirdDesk
import SendBirdSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Intialize Chat and Desk SDK
        SBDMain.initWithApplicationId(<#YOUR_APP_ID#>)
        SBDSKMain.initializeDesk()
        
        // Set up queue for delegates
        SBDSKMain.setCompletionHandlerDelegateQueue(.main)
        return true
    }
}

