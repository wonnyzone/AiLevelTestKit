//
//  ALTMyPageTestTableViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/10/16.
//

import UIKit

class ALTMyPageTestTableViewCell: ALTBaseTableViewCell {
    struct Data {
        let title: String
        let info: String?
        let testDate: Double
        let duration: Double?
    }
    
    class var height: CGFloat {
        return 148.optimized
    }
    
    private let _labelTitle = UILabel()
    private let _resultView = UIView()
    private let _labelAvgResult = UILabel()
    
    private let _labelInfo = UILabel()
    private let _buttonDetail = UIButton()
    
    var showLevel = true
    
    var data: ALTLevelTestResultData? {
        didSet {
            reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = ColourKit.Code.HexFFFFFF
        self.contentView.addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4.optimized).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4.optimized).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        var attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Static.Hex3296D7, font: UIFont.systemFont(ofSize: 12.optimized, weight: .regular)).attributes
        attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        attributes[.underlineColor] = ColourKit.Code.Static.Hex3296D7
        
        _buttonDetail.translatesAutoresizingMaskIntoConstraints = false
        _buttonDetail.setTitle("결과보기>", for: .normal)
        _buttonDetail.setTitleColor(ColourKit.Code.Static.Hex3296D7, for: .normal)
        _buttonDetail.titleLabel?.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        _buttonDetail.sizeToFit()
        containerView.addSubview(_buttonDetail)
        
        _buttonDetail.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 9.optimized).isActive = true
        _buttonDetail.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        _buttonDetail.widthAnchor.constraint(equalToConstant: _buttonDetail.bounds.size.width + 34.optimized).isActive = true
        _buttonDetail.heightAnchor.constraint(equalToConstant: 47.optimized).isActive = true
        
        _labelTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle.textColor = ColourKit.Code.Hex555555
        _labelTitle.font = UIFont.systemFont(ofSize: 16.optimized, weight: .bold)
        containerView.addSubview(_labelTitle)
        
        _labelTitle.centerYAnchor.constraint(equalTo: _buttonDetail.centerYAnchor).isActive = true
        _labelTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 17.optimized).isActive = true
        _labelTitle.trailingAnchor.constraint(equalTo: _buttonDetail.leadingAnchor).isActive = true
        
        _labelInfo.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(_labelInfo)
        
        _labelInfo.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -7.optimized).isActive = true
        _labelInfo.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.optimized).isActive = true
        _labelInfo.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7.optimized).isActive = true
        _labelInfo.heightAnchor.constraint(equalToConstant: 28.optimized).isActive = true
        
        _resultView.translatesAutoresizingMaskIntoConstraints = false
        _resultView.backgroundColor = ColourKit.Code.HexF0F0F0
        containerView.addSubview(_resultView)
        
        _resultView.topAnchor.constraint(equalTo: _labelTitle.bottomAnchor, constant: 15.optimized).isActive = true
        _resultView.bottomAnchor.constraint(equalTo: _labelInfo.topAnchor).isActive = true
        _resultView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.optimized).isActive = true
        _resultView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16.optimized).isActive = true
        
        self.contentView.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        _buttonDetail.addTarget(target, action: action, for: event)
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self._labelTitle.text = self.data?.examTitle
            
            self._buttonDetail.setTitle(self.data?.isFinished == true ? "결과보기>" : "이어하기>", for: .normal)
            self._buttonDetail.setTitleColor(self.data?.isFinished == true ? ColourKit.Code.Static.Hex3296D7 : #colorLiteral(red: 0.8823529412, green: 0.2549019608, blue: 0.431372549, alpha: 1), for: .normal)
            
            for subview in self._resultView.subviews {
                subview.removeFromSuperview()
            }
            
            let unitWidth = (UIScreen.main.bounds.size.width - 32.optimized) / 6
            
            let sectionNames = self.data?.info?.sectionNames ?? []
            let sectionValues = (self.showLevel ? self.data?.info?.sectionLevels : self.data?.info?.sectionScores) ?? []
            
            var leadingAnchor = self._resultView.leadingAnchor
            
            var norAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex888888, font: UIFont.systemFont(ofSize: 12.optimized, weight: .regular), alignment: .center)
            var boldAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex555555, font: UIFont.systemFont(ofSize: 13.optimized, weight: .bold), alignment: .center)
            
            for i in 0 ..< min(sectionNames.count, sectionValues.count) {
                guard i < 5 else { break }
                
                let attributedString = NSMutableAttributedString()
                attributedString.append(NSAttributedString(string: "\(sectionNames[i])\n", attributes: norAttr.attributes))
                
                let string = self.showLevel ? "Lv \(sectionValues[i])" : "\(sectionValues[i])점"
                attributedString.append(NSAttributedString(string: string, attributes: boldAttr.attributes))
                
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.attributedText = attributedString
                label.textAlignment = .center
                label.numberOfLines = 2
                self._resultView.addSubview(label)
                
                label.topAnchor.constraint(equalTo: self._resultView.topAnchor, constant: 11.optimized).isActive = true
                label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                label.widthAnchor.constraint(equalToConstant: unitWidth).isActive = true
                
                leadingAnchor = label.trailingAnchor
            }
            
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = ColourKit.Code.HexCCCCCC
            self._resultView.addSubview(separator)
            
            separator.topAnchor.constraint(equalTo: self._resultView.topAnchor, constant: 6.optimized).isActive = true
            separator.bottomAnchor.constraint(equalTo: self._resultView.bottomAnchor, constant: -6.optimized).isActive = true
            separator.leadingAnchor.constraint(equalTo: self._resultView.leadingAnchor, constant: unitWidth * 5).isActive = true
            separator.widthAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
            
            var attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(string: (self.showLevel ? "레벨" : "평균점수") + "\n", attributes: norAttr.attributes))
            attributedString.append(NSAttributedString(string: self.showLevel ? "Lv \(self.data?.info?.totalLevel ?? 0)" : "\(self.data?.info?.totalScore ?? 0)점", attributes: boldAttr.attributes))
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.attributedText = attributedString
            label.textAlignment = .center
            label.numberOfLines = 2
            self._resultView.addSubview(label)
            
            label.topAnchor.constraint(equalTo: self._resultView.topAnchor, constant: 11.optimized).isActive = true
            label.leadingAnchor.constraint(equalTo: separator.leadingAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: unitWidth).isActive = true
            
            attributedString = NSMutableAttributedString()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            norAttr = QTextAttributes(withForegroundColour: ColourKit.Code.HexAAAAAA, font: UIFont.systemFont(ofSize: 10.optimized, weight: .regular))
            boldAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex555555, font: UIFont.systemFont(ofSize: 10.optimized, weight: .bold))
            
            if let timeInterval = self.data?.startDate {
                attributedString.append(NSAttributedString(string: "응시날짜  ", attributes: boldAttr.attributes))
                attributedString.append(NSAttributedString(string: formatter.string(from: Date(timeIntervalSince1970: timeInterval)) + "   ", attributes: norAttr.attributes))
            }
            
            if let duration = self.data?.period {
                attributedString.append(NSAttributedString(string: "소요시간  ", attributes: boldAttr.attributes))
                attributedString.append(NSAttributedString(string: duration, attributes: norAttr.attributes))
            }
            
            self._labelInfo.attributedText = attributedString
            
            self.contentView.layoutIfNeeded()
        }
    }
}

class ALTMyPageTestContinueTableViewCell: ALTBaseTableViewCell {
    struct Data {
        let title: String
        let info: String?
        let testDate: Double
        let duration: Double?
    }
    
    class var height: CGFloat {
        return 80.optimized
    }
    
    private let _labelTitle = UILabel()
    private let _buttonDetail = UIButton()
    
    var showLevel = true
    
    var data: ALTLevelTestResultData? {
        didSet {
            reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = ColourKit.Code.HexFFFFFF
        self.contentView.addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4.optimized).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4.optimized).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        var attributes = QTextAttributes(withForegroundColour: #colorLiteral(red: 0.8823529412, green: 0.2549019608, blue: 0.431372549, alpha: 1), font: UIFont.systemFont(ofSize: 12.optimized, weight: .regular)).attributes
        attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        attributes[.underlineColor] = ColourKit.Code.Static.Hex3296D7
        
        _buttonDetail.translatesAutoresizingMaskIntoConstraints = false
        _buttonDetail.setTitle("이어하기>", for: .normal)
        _buttonDetail.setTitleColor(#colorLiteral(red: 0.8823529412, green: 0.2549019608, blue: 0.431372549, alpha: 1), for: .normal)
        _buttonDetail.titleLabel?.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        _buttonDetail.sizeToFit()
        containerView.addSubview(_buttonDetail)
        
        _buttonDetail.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 9.optimized).isActive = true
        _buttonDetail.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        _buttonDetail.widthAnchor.constraint(equalToConstant: _buttonDetail.bounds.size.width + 34.optimized).isActive = true
        _buttonDetail.heightAnchor.constraint(equalToConstant: 47.optimized).isActive = true
        
        _labelTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle.textColor = ColourKit.Code.Hex555555
        _labelTitle.font = UIFont.systemFont(ofSize: 16.optimized, weight: .bold)
        containerView.addSubview(_labelTitle)
        
        _labelTitle.centerYAnchor.constraint(equalTo: _buttonDetail.centerYAnchor).isActive = true
        _labelTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 17.optimized).isActive = true
        _labelTitle.trailingAnchor.constraint(equalTo: _buttonDetail.leadingAnchor).isActive = true
        
        self.contentView.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        _buttonDetail.addTarget(target, action: action, for: event)
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self._labelTitle.text = self.data?.examTitle
            
            self.contentView.layoutIfNeeded()
        }
    }
}
