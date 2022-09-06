//
//  FAQBotMessageCell.swift
//  Quickstart
//
//  Created by Jaesung Lee on 2021/12/19.
//

import UIKit
import SendBirdDesk
import SendbirdChatSDK

protocol FAQBotMessageCellDelegate: AnyObject {
    func didSelectQuestion(_ faqFileID: Int64, question: String)
}

class FAQBotMessageCell: UITableViewCell {
    static let identifier = String(describing: FAQBotMessageCell.self)
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var faqStackView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var faqData: SBDSKFAQData?
    weak var delegate: FAQBotMessageCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(message: BaseMessage, faqData: SBDSKFAQData) {
        self.faqData = faqData
        if let url = URL(string: message.sender?.profileURL ?? "") {
            profileImageView.load(url: url)
        }
        
        let timeFormat = "hh:mm"
        dateLabel.text = Date
            .from(message.createdAt)
            .sbu_toString(dateFormat: timeFormat)
        
        // Create FAQ message views and add to the stack view
        faqStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        faqData.faqResults.forEach { result in
            let faqMessageView = FAQMessageView(result: result)
            faqMessageView.frame = CGRect(x: 0, y: 0, width: 244, height: 82)
            faqMessageView.delegate = self
            faqStackView.addArrangedSubview(faqMessageView)
        }
        faqStackView.updateConstraints()
    }
}

extension FAQBotMessageCell: FAQMessageViewDelegate {
    func didSelect(_ question: String) {
        guard let faqFileID = faqData?.faqFileId else { return }
        delegate?.didSelectQuestion(faqFileID, question: question)
    }
}
