//
//  ALTCouponTableViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/23.
//

import UIKit

class ALTCouponTableViewCell: ALTBaseTableViewCell {
    class var height: CGFloat { return 82.optimized }
    
    private let _headingView = UIView()
    
    private let _labelTitle = UILabel()
    private let _labelPeriod = UILabel()
    private let _labelHeading = UILabel()
    
    let buttonUse = UIButton()
    
    private let _labelTitle2 = UILabel()
    private let _labelPeriod2 = UILabel()
    
    private var _constraintsActive = [Bool:NSLayoutConstraint]()
    
    var isActive: Bool = false {
        didSet {
            guard isEnabled else { return }
            
            guard isActive else {
                _constraintsActive[false]?.isActive = true
                _constraintsActive[true]?.isActive = false
                
                self.contentView.layoutIfNeeded()
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?._constraintsActive[false]?.isActive = false
                    self?._constraintsActive[true]?.isActive = true
                    self?.contentView.layoutIfNeeded()
                }
            }
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            _headingView.backgroundColor = isEnabled ? #colorLiteral(red: 1, green: 0.6470588235, blue: 0.7254901961, alpha: 1) : #colorLiteral(red: 0.2078431373, green: 0.2078431373, blue: 0.2078431373, alpha: 1)
            _headingView.superview!.backgroundColor = isEnabled ? ColourKit.Code.HexFFFFFF : #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
            
            _labelHeading.textColor = isEnabled ? .white : #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
            _labelTitle.textColor = isEnabled ? ColourKit.Code.Hex555555 : #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
            _labelPeriod.textColor = isEnabled ? ColourKit.Code.Hex555555 : #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        }
    }
    
    var data: ALTCouponData? {
        didSet {
            _labelHeading.text = "\(data?.perCount ?? 0) / \(data?.perCount ?? 0)"
            
            _labelTitle.text = data?.title
            _labelTitle2.text = data?.title
            
            if let startDate = data?.startDate, let endDate = data?.endDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd"
                let sDateString = formatter.string(from: startDate)
                let eDateString = formatter.string(from: endDate)
                _labelPeriod.text = "\(sDateString) ~ \(eDateString)"
                _labelPeriod2.text = "\(sDateString) ~ \(eDateString)"
            }
            
            self.contentView.layoutIfNeeded()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = ColourKit.Code.Hex121212
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = ColourKit.Code.HexFFFFFF
        self.contentView.addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5.optimized).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5.optimized).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.optimized).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.optimized).isActive = true
        
        _headingView.translatesAutoresizingMaskIntoConstraints = false
        _headingView.backgroundColor = #colorLiteral(red: 1, green: 0.6470588235, blue: 0.7254901961, alpha: 1)
        containerView.addSubview(_headingView)
        
        _headingView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        _headingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        _headingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        _headingView.widthAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        _labelTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle.textColor = ColourKit.Code.Hex555555
        _labelTitle.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        containerView.addSubview(_labelTitle)
        
        _labelTitle.bottomAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -4.optimized).isActive = true
        _labelTitle.leadingAnchor.constraint(equalTo: _headingView.trailingAnchor, constant: 14.optimized).isActive = true
        _labelTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14.optimized).isActive = true
        
        _labelPeriod.translatesAutoresizingMaskIntoConstraints = false
        _labelPeriod.textColor = ColourKit.Code.HexAAAAAA
        _labelPeriod.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        containerView.addSubview(_labelPeriod)
        
        _labelPeriod.topAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 4.optimized).isActive = true
        _labelPeriod.leadingAnchor.constraint(equalTo: _headingView.trailingAnchor, constant: 14.optimized).isActive = true
        _labelPeriod.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14.optimized).isActive = true
        
        let activeView = UIView()
        activeView.translatesAutoresizingMaskIntoConstraints = false
        activeView.clipsToBounds = true
        containerView.addSubview(activeView)
        
        activeView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        activeView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        activeView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        var constraint = activeView.trailingAnchor.constraint(equalTo: containerView.leadingAnchor)
        constraint.isActive = true
        _constraintsActive[false] = constraint
        constraint = activeView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        constraint.isActive = false
        _constraintsActive[true] = constraint
        
        var colours = [CGColor]()
        colours.append(#colorLiteral(red: 0.9411764706, green: 0.5333333333, blue: 0.6235294118, alpha: 1).cgColor)
        colours.append(#colorLiteral(red: 0.8352941176, green: 0.2117647059, blue: 0.4078431373, alpha: 1).cgColor)
        colours.append(#colorLiteral(red: 0.631372549, green: 0.1137254902, blue: 0.4470588235, alpha: 1).cgColor)
        colours.append(#colorLiteral(red: 0.4549019608, green: 0.04705882353, blue: 0.5019607843, alpha: 1).cgColor)
        
        var rect = CGRect.zero
        rect.size.width = UIScreen.main.bounds.size.width - 28.optimized
        rect.size.height = ALTCouponTableViewCell.height
        
        let startPoint = CGPoint(x: 0, y: rect.size.height / 2)
        let endPoint = CGPoint(x: rect.size.width, y: rect.size.height / 2)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.withGradient(colours: colours, startPoint: startPoint, endPoint: endPoint, rect: rect)
        activeView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: rect.size.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: rect.size.height).isActive = true
        
        buttonUse.translatesAutoresizingMaskIntoConstraints = false
        buttonUse.setTitle("사용하기", for: .normal)
        buttonUse.setTitleColor(.white, for: .normal)
        buttonUse.titleLabel?.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        activeView.addSubview(buttonUse)
        
        buttonUse.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        buttonUse.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        buttonUse.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        buttonUse.widthAnchor.constraint(equalTo: buttonUse.heightAnchor).isActive = true
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .white
        activeView.addSubview(separator)
        
        separator.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: buttonUse.leadingAnchor).isActive = true
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        _labelTitle2.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle2.textColor = .white
        _labelTitle2.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        activeView.addSubview(_labelTitle2)
        
        _labelTitle2.bottomAnchor.constraint(equalTo: _labelTitle.bottomAnchor).isActive = true
        _labelTitle2.leadingAnchor.constraint(equalTo: _labelTitle.leadingAnchor).isActive = true
        _labelTitle2.trailingAnchor.constraint(equalTo: separator.leadingAnchor, constant: -6.optimized).isActive = true
        
        _labelPeriod2.translatesAutoresizingMaskIntoConstraints = false
        _labelPeriod2.textColor = .white
        _labelPeriod2.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        activeView.addSubview(_labelPeriod2)
        
        _labelPeriod2.topAnchor.constraint(equalTo: _labelPeriod.topAnchor).isActive = true
        _labelPeriod2.leadingAnchor.constraint(equalTo: _labelPeriod.leadingAnchor).isActive = true
        _labelPeriod2.trailingAnchor.constraint(equalTo: separator.leadingAnchor, constant: -6.optimized).isActive = true
        
        _labelHeading.translatesAutoresizingMaskIntoConstraints = false
        _labelHeading.textAlignment = .center
        _labelHeading.textColor = .white
        _labelHeading.font = UIFont.systemFont(ofSize: 14.optimized, weight: .regular)
        containerView.addSubview(_labelHeading)
        
        _labelHeading.topAnchor.constraint(equalTo: _headingView.topAnchor, constant: 3.optimized).isActive = true
        _labelHeading.bottomAnchor.constraint(equalTo: _headingView.bottomAnchor, constant: -3.optimized).isActive = true
        _labelHeading.leadingAnchor.constraint(equalTo: _headingView.leadingAnchor, constant: 3.optimized).isActive = true
        _labelHeading.trailingAnchor.constraint(equalTo: _headingView.trailingAnchor, constant: -3.optimized).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func addTarget(_ target: Any, action: Selector, for event: UIControl.Event) {
        buttonUse.addTarget(target, action: action, for: event)
    }
}
