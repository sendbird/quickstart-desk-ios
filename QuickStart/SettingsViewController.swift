//
//  SettingsViewController.swift
//  Quickstart
//
//  Created by Minhyuk Kim on 2021/12/19.
//

import UIKit
import SendbirdChatSDK

class SettingsViewController: UIViewController {

    @IBOutlet var userIdLabel: UILabel!
    
    @IBOutlet var pushNotificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdLabel.text = SendbirdChat.getCurrentUser()?.userId
        
        SendbirdChat.getDoNotDisturb { (isDoNotDisturbOn, _, _, _, _, _, error) in
            self.pushNotificationSwitch.isOn = error == nil ? !isDoNotDisturbOn : false
        }
    }
    
    @IBAction func togglePushNotification(_ sender: UISwitch) {
        sender.isEnabled = false
        SendbirdChat.setDoNotDisturb(
            enable: !sender.isOn,
            startHour: 0,
            startMin: 0,
            endHour: 23,
            endMin: 59,
            timezone: "UTC"
        ) { error in
            sender.isEnabled = true
            if error != nil {
                sender.isOn = !sender.isOn
                return
            }
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        SendbirdChat.disconnect {
            self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
        }
    }
}
