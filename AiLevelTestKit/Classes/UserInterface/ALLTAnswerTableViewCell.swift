//
//  ALLTAnswerTableViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/08.
//

import UIKit

class ALLTAnswerTableViewCell: ALTBaseTableViewCell {
    class func height(with text: String) -> CGFloat {
        var frame = CGRect.zero
        frame.size.width = UIScreen.main.bounds.size.width - 75.optimized - 42.optimized
        
        let label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.text = text
        label.font = UIFont.systemFont(ofSize: 20.optimized, weight: .semibold)
        label.sizeToFit()
        return label.bounds.size.height + 18.optimized
    }
    
    internal let _labelNumber = UILabel()
    internal let _labelAnswer = UILabel()
    
    internal let _imageViewCheck = UIImageView()
    
    var numbering: Int = 0 {
        didSet {
            guard numbering > 0 else { return }
            
            _labelNumber.text = "\(numbering)"
        }
    }
    
    var answer: String? {
        didSet {
            _labelAnswer.text = answer
            self.contentView.layoutIfNeeded()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            _imageViewCheck.isHidden = !isSelected
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separator.isHidden = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.layer.cornerRadius = 9.optimized
        backView.layer.borderColor = ColourKit.Code.Hex222222.cgColor
        backView.layer.borderWidth = 1
        self.contentView.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 9.optimized).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 42.optimized).isActive = true
        backView.widthAnchor.constraint(equalToConstant: backView.layer.cornerRadius * 2).isActive = true
        backView.heightAnchor.constraint(equalToConstant: backView.layer.cornerRadius * 2).isActive = true
        
        _labelNumber.translatesAutoresizingMaskIntoConstraints = false
        _labelNumber.textAlignment = .center
        _labelNumber.textColor = ColourKit.Code.Hex222222
        _labelNumber.font = UIFont.systemFont(ofSize: 16.optimized, weight: .semibold)
        backView.addSubview(_labelNumber)
        
        _labelNumber.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _labelNumber.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        _labelNumber.trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
        
        _labelAnswer.translatesAutoresizingMaskIntoConstraints = false
        _labelAnswer.textColor = ColourKit.Code.Hex222222
        _labelAnswer.font = UIFont.systemFont(ofSize: 20.optimized, weight: .semibold)
        _labelAnswer.numberOfLines = 2
        self.contentView.addSubview(_labelAnswer)
        
        _labelAnswer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 9.optimized).isActive = true
        _labelAnswer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -9.optimized).isActive = true
        _labelAnswer.leadingAnchor.constraint(equalTo: backView.trailingAnchor, constant: 15.optimized).isActive = true
        _labelAnswer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -42.optimized).isActive = true
        
        _imageViewCheck.translatesAutoresizingMaskIntoConstraints = false
        _imageViewCheck.image = UIImage(named: "img_check", in:Bundle(for: type(of: self)), compatibleWith:nil)
        _imageViewCheck.contentMode = .scaleAspectFit
        self.contentView.addSubview(_imageViewCheck)
        
        _imageViewCheck.widthAnchor.constraint(equalToConstant: 30.optimized).isActive = true
        _imageViewCheck.heightAnchor.constraint(equalToConstant: 25.optimized).isActive = true
        _imageViewCheck.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        _imageViewCheck.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 40.optimized).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
