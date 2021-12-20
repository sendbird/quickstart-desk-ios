//
//  SBUMessageDataView.swift
//  Quickstart
//
//  Created by Jaesung Lee on 2021/12/19.
//

import UIKit

class SBUMessageDateView: UIView {
    var theme = SBUTheme.messageCellTheme
    
    lazy var dateLabel: UILabel = {
        let view = UILabel()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    public init() {
        super.init(frame: .zero)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "init(frame:)")
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }
    
    func setupViews() {
        self.dateLabel.textAlignment = .center
        self.addSubview(self.dateLabel)
    }
    
    func setupAutolayout() {
        self.dateLabel
            .setConstraint(from: self, centerX: true, centerY: true)
            .setConstraint(width: 91, height: 20)
        
        self.setConstraint(height: 20, priority: .defaultLow)
    }
    
    func setupStyles() {
        self.backgroundColor = .clear
        
        self.dateLabel.font = theme.dateFont
        self.dateLabel.textColor = theme.dateTextColor
        self.dateLabel.backgroundColor = theme.dateBackgroundColor
    }
    
    func configure(timestamp: Int64) {
        let timestampString = String(format: "%lld", baseTimestamp)
        let timeInterval = timestampString.count == 10
        ? TimeInterval(baseTimestamp)
        : TimeInterval(Double(baseTimestamp) / 1000.0)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        self.dateLabel.text = Date.sbu_from(timestamp).sbu_toString(format: .EMMMdd)
    }
}
