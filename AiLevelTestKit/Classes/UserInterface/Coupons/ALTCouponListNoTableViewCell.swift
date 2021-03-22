//
//  ALTCouponListNoTableViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/16.
//

import UIKit

class ALTCouponListNoTableViewCell: ALTBaseTableViewCell {
    class var height: CGFloat { return 72.optimized }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = ColourKit.Code.Hex121212
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.Hex222222
        self.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.optimized).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16.optimized).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "등록된 쿠폰이 없습니다."
        label.textColor = ColourKit.Code.Hex888888
        label.font = UIFont.systemFont(ofSize: 14.optimized, weight: .regular)
        backView.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
