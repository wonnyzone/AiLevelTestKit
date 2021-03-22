//
//  ALLTWriteHeaderCollectionViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALLTWriteHeaderCollectionViewCell: UICollectionViewCell {
    class func itemSize(with translatedString: String) -> CGSize {
        var itemSize = CGSize.zero
        itemSize.width = UIScreen.main.bounds.size.width
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 72.optimized, height: 0))
        label.text = translatedString
        label.font = UIFont.systemFont(ofSize: 20.optimized, weight: .bold)
        label.numberOfLines = 0
        label.sizeToFit()
        
        itemSize.height = label.bounds.size.height + 250.optimized
        
        return itemSize
    }
    
    internal let _labelTranslated = UILabel()
    
    var translatedString: String? {
        didSet {
            _labelTranslated.text = translatedString
            self.layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let labelTitle = UILabel()
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.text = "주어진 문장을 빈 칸에 맞게\n영어로 완성하세요."
        labelTitle.textAlignment = .center
        labelTitle.textColor = ColourKit.Code.Hex222222
        labelTitle.font = UIFont.systemFont(ofSize: 22.optimized, weight: .heavy)
        labelTitle.numberOfLines = 0
        self.contentView.addSubview(labelTitle)
        
        labelTitle.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 58.optimized).isActive = true
        labelTitle.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 42.optimized).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -42.optimized).isActive = true
        labelTitle.heightAnchor.constraint(equalToConstant: 56.optimized).isActive = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.HexFFFFFF
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 10.optimized
        self.contentView.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 30.optimized).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.optimized).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.optimized).isActive = true
        
        _labelTranslated.translatesAutoresizingMaskIntoConstraints = false
        _labelTranslated.textColor = ColourKit.Code.Hex222222
        _labelTranslated.font = UIFont.systemFont(ofSize: 20.optimized, weight: .bold)
        _labelTranslated.numberOfLines = 0
        _labelTranslated.sizeToFit()
        backView.addSubview(_labelTranslated)
        
        _labelTranslated.topAnchor.constraint(equalTo: backView.topAnchor, constant: 32.optimized).isActive = true
        _labelTranslated.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20.optimized).isActive = true
        _labelTranslated.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20.optimized).isActive = true
        _labelTranslated.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -32.optimized).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
