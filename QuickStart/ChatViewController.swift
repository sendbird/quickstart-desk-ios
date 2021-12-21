//
//  ChatViewController.swift
//  Quickstart
//
//  Created by Minhyuk Kim on 2021/11/25.
//

import SendBirdUIKit
import SendBirdDesk
import UIKit


class ChatViewController: SBUChannelViewController {
    var ticket: SBDSKTicket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.useRightBarButtonItem = false
        
        // Register XIB: SystemBotMessageCell
        let systemBotNib = UINib(nibName: SystemBotMessageCell.identifier, bundle: nil)
        tableView.register(systemBotNib, forCellReuseIdentifier: SystemBotMessageCell.identifier)
        
        // Register XIB: FAQBotMessageCell
        let faqBotNib = UINib(nibName: FAQBotMessageCell.identifier, bundle: nil)
        tableView.register(faqBotNib, forCellReuseIdentifier: FAQBotMessageCell.identifier)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = fullMessageList[indexPath.row]
        
        // When message has FAQ data or not
        if let faqData = SBDSKFAQData(with: message) {
            UIView.setAnimationsEnabled(false)
            
            // Create FAQBotMessageCell
            let cell = tableView.dequeueReusableCell(withIdentifier: FAQBotMessageCell.identifier, for: indexPath) as! FAQBotMessageCell
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            // To receive selection event
            cell.delegate = self
            // Configure the cell with message info
            cell.configure(message: message, faqData: faqData)
            
            UIView.setAnimationsEnabled(true)
            
            return cell
        }
        // When message is systemt bot message
        else if message.customType == "SENDBIRD:AUTO_EVENT_MESSAGE" || message.data == "{\"type\": \"NOTIFICATION_AUTO_CLOSED\"}" {
            UIView.setAnimationsEnabled(false)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: SystemBotMessageCell.identifier, for: indexPath) as! SystemBotMessageCell
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            
            cell.configure(message: message)
            
            UIView.setAnimationsEnabled(true)
            
            return cell
        }
        // Default message
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
}

extension ChatViewController: FAQBotMessageCellDelegate {
    func didSelectQuestion(_ faqFileID: Int64, question: String) {

        ticket.selectQuestion(faqFileId: faqFileID, question: question) { error in
            // ...
            // This will send admin message:
            // e.g. "The customer selected {question}"
        }
    }
}
