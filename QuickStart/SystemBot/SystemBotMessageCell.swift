//
//  SystemBotMessageCell.swift
//  Quickstart
//
//  Created by Jaesung Lee on 2021/12/20.
//

import UIKit
import SendBirdDesk

class SystemBotMessageCell: UITableViewCell {
    static let identifier = String(describing: SystemBotMessageCell.self)
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var message: SBDBaseMessage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(message: SBDBaseMessage) {
        self.message = message
        
        self.messageLabel.text = message.message
        
        let timeFormat = "hh:mm"
        dateLabel.text = Date
            .from(message.createdAt)
            .sbu_toString(formatString: timeFormat)
    }
}
