//
//  LoginViewController.swift
//  Quickstart
//
//  Created by Minhyuk Kim on 2021/11/26.
//

import UIKit
import SendBirdDesk
import SendbirdUIKit

class LoginViewController: UIViewController {

    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var nicknameTextField: UITextField!

    @IBAction func login(_ sender: Any) {
        // user ID validation check
        guard let userId = userIdTextField.text?.collapsed else {
            userIdTextField.becomeFirstResponder()
            return
        }
        // nickname validation check
        guard let nickname = nicknameTextField.text?.collapsed else {
            nicknameTextField.becomeFirstResponder()
            return
        }
        
        SBUGlobals.currentUser = SBUUser(userId: userId, nickname: nickname)
        SendbirdUI.connect { user, error in
            guard let user = user, error == nil else { return }
            
            // MARK: Authenticate
            SBDSKMain.authenticate(withUserId: user.userId, accessToken: nil) { error in
                guard error == nil else { return }
                
                self.performSegue(withIdentifier: "authenticate", sender: nil)
            }
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) { }
}
