//
//  ChatViewController.swift
//  Quickstart
//
//  Created by Minhyuk Kim on 2021/11/25.
//

import SendBirdDesk
import SendbirdUIKit
import UIKit

class ChatViewController: SBUGroupChannelViewController {
    var ticket: SBDSKTicket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.useRightBarButtonItem = false
    }
}

extension ChatViewController: DeskChannelModuleListDelegate {
    func deskChannelModule(_ listComponent: SBUGroupChannelModule.List, didSelectQuestion question: String, forID faqFileID: Int64) {
        ticket.selectQuestion(faqFileId: faqFileID, question: question) { error in
            // ...
            // This will send admin message:
            // e.g. "The customer selected {question}"
        }
    }
    
    func deskChannelModule(_ listComponent: SBUGroupChannelModule.List, shouldAskConfirmationOf ticketClosingMessage: UserMessage) {
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { [weak self, ticketClosingMessage] _ in
            guard let self = self else { return }
            self.sendConfirmation(true, ofTicketClosing: ticketClosingMessage)
        }
        let declineAction = UIAlertAction(title: "No", style: .default) { [weak self, ticketClosingMessage] _ in
            guard let self = self else { return }
            self.sendConfirmation(false, ofTicketClosing: ticketClosingMessage)
            
        }
        let alertController = UIAlertController(title: ticketClosingMessage.message, message: nil, preferredStyle: .alert)
        alertController.addAction(confirmAction)
        alertController.addAction(declineAction)
        self.present(alertController, animated: true)
    }
    
    /// Send confirmation of ticket closing and send user message when the completion block is called.
    ///
    /// When `confirmed` is true, it sends user message with the text saying "Yes". If it's `false`, sends the text saying "No".
    ///
    /// - NOTE: [Documentations | Send confirmation of ticket closing]( https://sendbird.com/docs/desk/sdk/v1/ios/features/confirmation-request#2-send-confirmation-of-ticket-closing)
    func sendConfirmation(_ confirmed: Bool, ofTicketClosing message: UserMessage) {
        SBDSKTicket.confirmEndOfChat(with: message, confirm: confirmed) { (ticker, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.viewModel?.sendUserMessage(text: confirmed ? "Yes" : "No")
        }
    }
}

protocol DeskChannelModuleListDelegate: SBUGroupChannelModuleListDelegate {
    func deskChannelModule(_ listComponent: SBUGroupChannelModule.List, didSelectQuestion question: String, forID faqFileID: Int64)
    
    /// Called when it needs to ask the confirmation of ticket closing message.
    ///
    /// See `deskChannelModule(_:shouldPresentReplyOptionsForInquireMessage:)` and `sendConfirmation(_:toInquireMessage:)` in `ChatViewController`
    func deskChannelModule(_ listComponent: SBUGroupChannelModule.List, shouldAskConfirmationOf ticketClosingMessage: UserMessage)
}

class DeskChannelModule {
    class List: SBUGroupChannelModule.List, FAQBotMessageCellDelegate {
        override func setupViews() {
            // Register XIB: SystemBotMessageCell
            let systemBotNib = UINib(nibName: SystemBotMessageCell.identifier, bundle: nil)
            tableView.register(systemBotNib, forCellReuseIdentifier: SystemBotMessageCell.identifier)
            
            // Register XIB: FAQBotMessageCell
            let faqBotNib = UINib(nibName: FAQBotMessageCell.identifier, bundle: nil)
            tableView.register(faqBotNib, forCellReuseIdentifier: FAQBotMessageCell.identifier)
            
            super.setupViews()
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
            // When the message is inquire ticket closure
            else if let userMessage = message as? UserMessage, userMessage.data.contains("\"type\":\"SENDBIRD_DESK_INQUIRE_TICKET_CLOSURE\""), userMessage.data.contains("\"state\":\"WAITING\"") {
                (self.delegate as? DeskChannelModuleListDelegate)?
                    .deskChannelModule(self, shouldAskConfirmationOf: userMessage)
                
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
            
            // Default message
            else {
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
        }
        
        func didSelectQuestion(_ faqFileID: Int64, question: String) {
            (self.delegate as? DeskChannelModuleListDelegate)?
                .deskChannelModule(self, didSelectQuestion: question, forID: faqFileID)
        }
    }
}
