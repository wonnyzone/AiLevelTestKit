//
//  ALTSeniorWritingTestHeaderCollectionViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALTSeniorWritingTestHeaderCollectionViewCell: UICollectionViewCell {
    class func itemSize(with translatedString: String) -> CGSize {
        var itemSize = CGSize.zero
        itemSize.width = UIScreen.main.bounds.size.width * (UIDevice.current.userInterfaceIdiom == .pad ? 0.4 : 1)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40.optimized, height: 0))
        label.text = translatedString
        label.font = UIFont.systemFont(ofSize: 20.optimized, weight: .bold)
        label.numberOfLines = 0
        label.sizeToFit()
        
        var hratio = (UIScreen.main.bounds.size.height - 667) / (812 - 667)
        if hratio < 0 { hratio = 0 }
        else if hratio > 1 { hratio = 1 }
        let height = 20.optimized * hratio
        
        itemSize.height = label.bounds.size.height + (UIDevice.current.userInterfaceIdiom == .pad ? 30.optimized : 90.optimized + height)
        
        return itemSize
    }
    
    private let _labelTranslated = UILabel()
    
    var translatedString: String? {
        didSet {
            _labelTranslated.text = translatedString
            self.layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _labelTranslated.translatesAutoresizingMaskIntoConstraints = false
        _labelTranslated.textColor = ColourKit.Code.Hex000000
        _labelTranslated.font = UIFont.systemFont(ofSize: 20.optimized, weight: .bold)
        _labelTranslated.numberOfLines = 0
        self.contentView.addSubview(_labelTranslated)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            _labelTranslated.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            _labelTranslated.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        } else {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "단어들을 사용하여 문장을 완성하세요."
            label.textColor = ColourKit.Code.Hex888888
            label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            label.isHidden = true
            self.contentView.addSubview(label)
            
            var hratio = (UIScreen.main.bounds.size.height - 667) / (812 - 667)
            if hratio < 0 { hratio = 0 }
            else if hratio > 1 { hratio = 1 }
            let height = 20.optimized * hratio
            
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: height).isActive = true
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16.optimized).isActive = true
            
            _labelTranslated.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 35.optimized).isActive = true
            _labelTranslated.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20.optimized).isActive = true
            _labelTranslated.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20.optimized).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
