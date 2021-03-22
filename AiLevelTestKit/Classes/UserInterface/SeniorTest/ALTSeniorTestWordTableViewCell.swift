//
//  ALTSeniorTestWordTableViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALTSeniorTestWordTableViewCell: ALTBaseTableViewCell {
    class var height: CGFloat { return 66.optimized }
    
    internal let _labelTitle = UILabel()
    
    override var isSelected: Bool {
        didSet {
            _labelTitle.superview?.backgroundColor = isSelected ? ColourKit.Code.Hex000000 : ColourKit.Code.HexFFFFFF
            _labelTitle.textColor = isSelected ? ColourKit.Code.HexFFFFFF : ColourKit.Code.Hex888888
        }
    }
    
    var title: String? {
        didSet {
            _labelTitle.text = title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let isiPad = UIDevice.current.userInterfaceIdiom == .pad
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.HexFFFFFF
//        backView.layer.borderWidth = 1
//        backView.layer.borderColor = ColourKit.Code.Hex888888.cgColor
        self.contentView.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: isiPad ? 5.optimized : 3.optimized).isActive = true
        backView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: isiPad ? -5.optimized : -3.optimized).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20.optimized).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20.optimized).isActive = true
        
        _labelTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle.textAlignment = .center
        _labelTitle.font = UIFont.systemFont(ofSize: 17.optimized, weight: .regular)
        _labelTitle.numberOfLines = 2
        backView.addSubview(_labelTitle)
        
        _labelTitle.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _labelTitle.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _labelTitle.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20.optimized).isActive = true
        _labelTitle.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20.optimized).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
