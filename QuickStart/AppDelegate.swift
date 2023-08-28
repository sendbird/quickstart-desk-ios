//
//  AppDelegate.swift
//  Quickstart
//
//  Created by Minhyuk Kim on 2021/11/25.
//

import UIKit
import SendbirdUIKit
import SendBirdDesk
import SendbirdChatSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let initParams = InitParams(
            applicationId: <#YOUR_APP_ID#>,
            isLocalCachingEnabled: true,
            logLevel: .debug
        )
        SendbirdChat.initialize(params: initParams)
        SBDSKMain.initializeDesk()
        SBDSKTicket.createTicket(with: "", userName: "", priority: .high)
        
        // Set up queue for delegates
        SBDSKMain.setCompletionHandlerDelegateQueue(.main)
        
        // Disable unused string set
        SBUStringSet.Message_Edited = ""
        return true
    }
}

