//
//  ALTSeniorListeningTestSelectableCollectionViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//


import UIKit

class ALTSeniorListeningTestSelectableCollectionViewCell: UICollectionViewCell {
    class var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20).optimized
    }
    
    class var interItemSpacing: CGFloat {
        return 4.optimized
    }
    
    class var lineSpacing: CGFloat {
        return 4.optimized
    }
    
    class func itemSize(with string: String) -> CGSize {
        var itemSize = CGSize.zero
        
        let label = UILabel()
        label.text = string
        label.font = UIFont.systemFont(ofSize: 17.optimized, weight: .regular)
        label.sizeToFit()
        itemSize.width = label.bounds.size.width + 42.optimized
        
        itemSize.height = 50.optimized
        
        return itemSize
    }
    
    internal let _backView = UIView()
    internal let _labelTitle = UILabel()
    
    var title: String? {
        didSet {
            _labelTitle.text = title
        }
    }
    
    override var isSelected: Bool {
        didSet {
            _backView.backgroundColor = isSelected ? ColourKit.Code.Hex000000 : ColourKit.Code.HexFFFFFF
            _labelTitle.textColor = isSelected ? ColourKit.Code.HexFFFFFF : ColourKit.Code.Hex222222
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _backView.translatesAutoresizingMaskIntoConstraints = false
        _backView.backgroundColor = isSelected ? ColourKit.Code.Hex000000 : ColourKit.Code.HexFFFFFF
        _backView.layer.borderColor = ColourKit.Code.HexAAAAAA.cgColor
        _backView.layer.borderWidth = 1
        self.contentView.addSubview(_backView)
        
        _backView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        _backView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        _backView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        _backView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        _labelTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle.textColor = isSelected ? ColourKit.Code.HexFFFFFF : ColourKit.Code.Hex222222
        _labelTitle.textAlignment = .center
        _labelTitle.font = UIFont.systemFont(ofSize: 17.optimized, weight: .regular)
        self.contentView.addSubview(_labelTitle)
        
        _labelTitle.topAnchor.constraint(equalTo: _backView.topAnchor).isActive = true
        _labelTitle.bottomAnchor.constraint(equalTo: _backView.bottomAnchor).isActive = true
        _labelTitle.leadingAnchor.constraint(equalTo: _backView.leadingAnchor).isActive = true
        _labelTitle.trailingAnchor.constraint(equalTo: _backView.trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
