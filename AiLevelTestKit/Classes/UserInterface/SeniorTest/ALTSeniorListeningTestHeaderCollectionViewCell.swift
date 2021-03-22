//
//  ALTSeniorListeningTestHeaderCollectionViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALTSeniorListeningTestHeaderCollectionViewCell: UICollectionViewCell {
    class var itemSize: CGSize {
        get {
            var hratio = (UIScreen.main.bounds.size.height - 667) / (812 - 667)
            if hratio < 0 { hratio = 0 }
            else if hratio > 1 { hratio = 1 }
            let height = 104.optimized + (46.optimized * hratio)
            
            var itemSize = CGSize.zero
            itemSize.width = UIScreen.main.bounds.size.width
            itemSize.height = height
            return itemSize
        }
    }
    
    internal let _buttonPlay = UIButton()
    internal let _labelButtonTitle = UILabel()
    internal let _imageViewPlay = UIImageView()
    
    var remainingPlayCount: Int = 2 {
        didSet {
            let attributedString = NSMutableAttributedString()
            
            var attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Hex000000, font: UIFont.systemFont(ofSize: 12.optimized, weight: .semibold)).attributes
            attributedString.append(NSAttributedString(string: "문제 듣기", attributes: attributes))
            attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Hex000000, font: UIFont.systemFont(ofSize: 12.optimized, weight: .regular)).attributes
            attributedString.append(NSAttributedString(string:"\n\(remainingPlayCount)번의 듣기가 남았습니다.", attributes: attributes))
            
            _labelButtonTitle.attributedText = attributedString
            
            self.contentView.layoutIfNeeded()
        }
    }
    
    var isButtonEnabled: Bool = true {
        didSet {
            _imageViewPlay.image = isButtonEnabled ? UIImage(named: "img_playOn", in:Bundle(for: type(of: self)), compatibleWith:nil) : UIImage(named: "img_playOff", in:Bundle(for: type(of: self)), compatibleWith:nil)
            _buttonPlay.isEnabled = isButtonEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "문제를 듣고 문장을 완성하세요."
        label.textColor = ColourKit.Code.Hex888888
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.isHidden = true
        self.contentView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 21.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.optimized).isActive = true
        
        _buttonPlay.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(_buttonPlay)
        
        _buttonPlay.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -27.optimized).isActive = true
        _buttonPlay.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20.optimized).isActive = true
        _buttonPlay.heightAnchor.constraint(equalToConstant: 44.optimized).isActive = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.isUserInteractionEnabled = false
        backView.backgroundColor = ColourKit.Code.HexFFFFFF
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 22.optimized
        _buttonPlay.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: _buttonPlay.topAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: _buttonPlay.bottomAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: _buttonPlay.leadingAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: _buttonPlay.trailingAnchor).isActive = true
        
        _imageViewPlay.translatesAutoresizingMaskIntoConstraints = false
        _imageViewPlay.isUserInteractionEnabled = false
        _imageViewPlay.image = UIImage(named: "img_playOn", in:Bundle(for: type(of: self)), compatibleWith:nil)
        _buttonPlay.addSubview(_imageViewPlay)
        
        _imageViewPlay.topAnchor.constraint(equalTo: _buttonPlay.topAnchor).isActive = true
        _imageViewPlay.bottomAnchor.constraint(equalTo: _buttonPlay.bottomAnchor).isActive = true
        _imageViewPlay.leadingAnchor.constraint(equalTo: _buttonPlay.leadingAnchor).isActive = true
        _imageViewPlay.widthAnchor.constraint(equalTo: _imageViewPlay.heightAnchor).isActive = true
        
        _labelButtonTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelButtonTitle.isUserInteractionEnabled = false
        _labelButtonTitle.numberOfLines = 2
        _buttonPlay.addSubview(_labelButtonTitle)
        
        _labelButtonTitle.topAnchor.constraint(equalTo: _buttonPlay.topAnchor).isActive = true
        _labelButtonTitle.bottomAnchor.constraint(equalTo: _buttonPlay.bottomAnchor).isActive = true
        _labelButtonTitle.leadingAnchor.constraint(equalTo: _imageViewPlay.trailingAnchor, constant: 9.optimized).isActive = true
        _labelButtonTitle.trailingAnchor.constraint(equalTo: _buttonPlay.trailingAnchor, constant: -21.optimized).isActive = true
        
        remainingPlayCount = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func addTarget(_ target: Any, action: Selector, for event: UIControl.Event) {
        _buttonPlay.addTarget(target, action: action, for: event)
    }
}
