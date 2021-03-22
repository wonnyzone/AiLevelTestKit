//
//  ALTSeniorListeningTestAnswerCollectionViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALTSeniorListeningTestAnswerCollectionViewCell: UICollectionViewCell {
    class var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20).optimized
    }
    
    class var interItemSpacing: CGFloat {
        return 10.optimized
    }
    
    class var lineSpacing: CGFloat {
        return 10.optimized
    }
    
    class func itemSize(with string: String? = nil) -> CGSize {
        var itemSize = CGSize.zero
        itemSize.height = 21.optimized
        
        if string != nil {
            let label = UILabel()
            label.text = string
            label.font = UIFont.systemFont(ofSize: 20.optimized, weight: .regular)
            label.sizeToFit()
            itemSize.width = label.bounds.size.width + 20.optimized
        } else {
            itemSize.width = 47.optimized
        }
        
        return itemSize
    }
    
    internal let _underlineView = UIView()
    internal let _labelTitle = UILabel()
    
    var text: String? {
        didSet {
            _labelTitle.text = text
            _underlineView.backgroundColor = text == nil ? ColourKit.Code.Hex000000 : AiLevelTestKit.shared.themeColour
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _labelTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle.textColor = AiLevelTestKit.shared.themeColour
        _labelTitle.textAlignment = .center
        _labelTitle.font = UIFont.systemFont(ofSize: 20.optimized, weight: .regular)
        self.contentView.addSubview(_labelTitle)
        
        _labelTitle.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        _labelTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        _labelTitle.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        _labelTitle.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -1).isActive = true
        
        _underlineView.translatesAutoresizingMaskIntoConstraints = false
        _underlineView.backgroundColor = AiLevelTestKit.shared.themeColour
        self.contentView.addSubview(_underlineView)
        
        _underlineView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        _underlineView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        _underlineView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        _underlineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
