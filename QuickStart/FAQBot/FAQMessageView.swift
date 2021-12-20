//
//  FAQMessageCell.swift
//  Quickstart
//
//  Created by Jaesung Lee on 2021/12/19.
//

import SendBirdUIKit
import SendBirdDesk
import UIKit

protocol FAQMessageViewDelegate: AnyObject {
    func didSelect(_ question: String)
}

class FAQMessageView: UIView {
    // MARK: Controls
    
    lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.font = FontSet.headline
        label.textColor = ColorSet.primary
        label.numberOfLines = 3
        return label
    }()
    
    lazy var answerLabel: UILabel = {
        let label = UILabel()
        label.font = FontSet.body
        label.textColor = ColorSet.secondary
        label.numberOfLines = 2
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = ColorSet.tertiary
        return imageView
    }()
    
    
    // MARK: Layouts
    
    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    var url: URL?
    
    var faqResult: SBDSKFAQData.SBDSKFAQResult
    
    weak var delegate: FAQMessageViewDelegate?
    
    init(result: SBDSKFAQData.SBDSKFAQResult) {
        self.faqResult = result
        self.url = URL(string: faqResult.url ?? "")
        
        super.init(frame: .zero)
        
        
        setupViews()
        setupAutoLayouts()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupStyles()
    }
    
    func setupViews() {
        // +-------------------------------+
        // | +-----------+---------------+ |
        // | | imageView | questionLabel | |
        // | |           +---------------+ |
        // | |           |  answerLabel  | |
        // | +-----------+---------------+ |
        // +-------------------------------+
        self.addSubview(containerView)
        
        containerView.addSubview(containerStackView)
        
        [imageView, labelStackView]
            .forEach { containerStackView.addArrangedSubview($0) }
        
        [questionLabel, answerLabel]
            .forEach { labelStackView.addArrangedSubview($0) }
    }
    
    func setupAutoLayouts() {
        [containerStackView, labelStackView, containerView, questionLabel, answerLabel, imageView]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            // containerView
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 82),
            containerView.widthAnchor.constraint(equalToConstant: 244),
            
            // container stack view
            containerStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            containerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // imageView
            imageView.heightAnchor.constraint(equalToConstant: 56),
            imageView.widthAnchor.constraint(equalToConstant: 56),
            
            // questionLabel
            questionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            // answerLabel
            answerLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 56),
        ])
    }
    
    func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setupStyles() {
        questionLabel.text = faqResult.question
        answerLabel.text = faqResult.answer
        
        if let imageURL = URL(string: faqResult.imageURL ?? "") {
            imageView.load(url: imageURL)
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
        } else {
            imageView.isHidden = true
        }
        
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = ColorSet.border.cgColor
    }

    
    // MARK: open URL
    @objc
    func didTap(_ sender: UITapGestureRecognizer? = nil) {
        // Validation checks
        guard let url = url else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }

        // Notify ticket was selected
        if let question = faqResult.question {
            delegate?.didSelect(question)
        }
        
        // open url
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
