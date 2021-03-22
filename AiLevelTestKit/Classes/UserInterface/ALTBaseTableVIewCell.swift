//
//  BaseTableVIewCell.swift
//  Bumpbeat
//
//  Created by Jun-kyu Jeon on 2020/04/24.
//  Copyright © 2020 Jun-kyu Jeon. All rights reserved.
//

import UIKit

class ALTBaseTableViewCell: UITableViewCell {
    internal let separator = UIView()
    
    internal var constraintSeparatorLeading: NSLayoutConstraint!
    internal var constraintSeparatorTrailing: NSLayoutConstraint!
    internal var constraintSeparatorHeight: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = ColourKit.Code.HexCCCCCC
        separator.isHidden = true
        self.contentView.addSubview(separator)
        
        separator.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        constraintSeparatorLeading = separator.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor)
        constraintSeparatorLeading.isActive = true
        constraintSeparatorTrailing = separator.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        constraintSeparatorTrailing.isActive = true
        constraintSeparatorHeight = separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        constraintSeparatorHeight.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }}
