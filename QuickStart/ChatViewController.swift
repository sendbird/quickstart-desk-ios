//
//  ChatViewController.swift
//  Quickstart
//
//  Created by Minhyuk Kim on 2021/11/25.
//

import SendBirdDesk
import SendbirdChatSDK
import SendbirdUIKit
import UIKit

class ChatViewController: SBUGroupChannelViewController {
    var ticket: SBDSKTicket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.useRightBarButtonItem = false
    }
    
    // MARK: - Hide System messages
     
    /// When this flag is set to true, system messages will be hidden from the message list view. See `isVisible(message:)` for implementation
    static let shouldHideSystemMessages = false
    
    override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, fullMessagesInTableView tableView: UITableView) -> [BaseMessage] {
        let filtered = self.viewModel?.fullMessageList.filter { Self.isVisible(message: $0) || !Self.shouldHideSystemMessages }
        return filtered ?? []
    }
    
    static func isVisible(message: BaseMessage) -> Bool {
        if let message = message as? AdminMessage, let data = message.data.data(using: .utf8), data.isEmpty == false {
            let isSystemMessage = (message.customType == "SENDBIRD_DESK_ADMIN_MESSAGE_CUSTOM_TYPE")

            let dataObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let type = dataObject?["type"] as? String
            return !isSystemMessage &&
                type != "ASSIGN" &&
                type != "TRANSFER" &&
                type != "CLOSE"
        }

        return true
    }
  
    // MARK: - Send confirmation of ticket closing
    
    override func baseChannelViewModel(_ viewModel: SBUBaseChannelViewModel, didReceiveNewMessage message: BaseMessage, forChannel channel: BaseChannel) {
    // When the message is inquire ticket closure
        if let userMessage = message as? UserMessage,
            userMessage.data.contains("\"type\":\"SENDBIRD_DESK_INQUIRE_TICKET_CLOSURE\""),
            userMessage.data.contains("\"state\":\"WAITING\"") {
            self.presentConfirmationAlert(of: userMessage)
        }
        super.baseChannelViewModel(viewModel, didReceiveNewMessage: message, forChannel: channel)
    }
    
    /// Presents alert controller to ask the confirmation of ticket closing.
    /// - Parameter ticketClosingMessage: `UserMessage` object that its data contains `SENDBIRD_DESK_INQUIRE_TICKET_CLOSURE` type and `WAITING` state
    func presentConfirmationAlert(of ticketClosingMessage: UserMessage) {
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
    
    /// Sends confirmation of ticket closing and send user message when the completion block is called.
    ///
    /// When `confirmed` is true, it sends user message with the text saying "Yes". If it's `false`, sends the text saying "No".
    ///
    /// - NOTE: [Documentations | Send confirmation of ticket closing](https://sendbird.com/docs/desk/sdk/v1/ios/features/confirmation-request#2-send-confirmation-of-ticket-closing)
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

extension ChatViewController: DeskChannelModuleListDelegate {
    func deskChannelModule(_ listComponent: SBUGroupChannelModule.List, didSelectQuestion question: String, forID faqFileID: Int64) {
        ticket.selectQuestion(faqFileId: faqFileID, question: question) { error in
            // ...
            // This will send admin message:
            // e.g. "The customer selected {question}"
        }
    }
}

protocol DeskChannelModuleListDelegate: SBUGroupChannelModuleListDelegate {
    func deskChannelModule(_ listComponent: SBUGroupChannelModule.List, didSelectQuestion question: String, forID faqFileID: Int64)
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
