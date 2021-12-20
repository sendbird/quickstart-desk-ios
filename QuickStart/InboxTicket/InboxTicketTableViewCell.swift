//
//  InboxTicketTableViewCell.swift
//  Quickstart
//
//  Created by Minhyuk Kim on 2021/11/25.
//

import UIKit
import SendBirdDesk

class InboxTicketTableViewCell: UITableViewCell {
    static let identifier: String = "InboxTicketTableViewCell"

    @IBOutlet var agentProfileImageView: UIImageView!
    @IBOutlet var agentNicknameLabel: UILabel!
    
    @IBOutlet var lastMessageLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var dividerView: UIView!
    
    @IBOutlet var unreadCountContainerView: UIView!
    @IBOutlet var unreadCountLabel: UILabel!
    
    var ticket: SBDSKTicket?
    
    func configure(ticket: SBDSKTicket) {
        self.ticket = ticket
        
        self.agentNicknameLabel.text = ticket.agent?.name ?? "Mobile Customer Support"
        

        self.lastMessageLabel.text = ticket.channel?.lastMessage?.message
        
        if let channel = ticket.channel {
            let lastUpdatedTimestamp = channel.lastMessage?.createdAt ?? Int64(channel.createdAt)
            let lastUpdatedDate = Date(timeIntervalSince1970: Double(lastUpdatedTimestamp) / 1000)
            
            let dateFormatter = DateFormatter()
            
            let lastMessageDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastUpdatedDate)
            let todayComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
            
            if lastMessageDateComponents.day == todayComponents.day,
               lastMessageDateComponents.month == todayComponents.month,
               lastMessageDateComponents.year == todayComponents.year {
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
            } else {
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
            }

            self.dateLabel.text = dateFormatter.string(from: lastUpdatedDate)
        }
        
        if let unreadMessageCount = ticket.channel?.unreadMessageCount,
           unreadMessageCount > 0 && unreadMessageCount < 100 {
            unreadCountContainerView.isHidden = false
            unreadCountLabel.isHidden = false
            unreadCountLabel.text = String(unreadMessageCount)
        } else if ticket.channel?.unreadMessageCount == 0 {
            unreadCountContainerView.isHidden = true
            unreadCountLabel.isHidden = true
        } else {
            unreadCountContainerView.isHidden = false
            unreadCountLabel.isHidden = false
            unreadCountLabel.text = "+99"
        }
        
        if ticket.status == "CLOSED" {
            self.unreadCountContainerView.isHidden = true
        }
    }
}
