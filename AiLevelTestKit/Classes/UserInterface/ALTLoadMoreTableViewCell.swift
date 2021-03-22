//
//  ALTLoadMoreTableViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/23.
//

import UIKit

class ALTLoadMoreTableViewCell: ALTBaseTableViewCell {
    class var estimatedHeight: CGFloat { return 72 }
    
    private let _indicatorView = UIActivityIndicatorView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.heightAnchor.constraint(equalToConstant: ALTLoadMoreTableViewCell.estimatedHeight).isActive = true
        
        _indicatorView.translatesAutoresizingMaskIntoConstraints = false
//
//        _indicatorView.hidew
//        lottieView.contentMode = .scaleAspectFit
//        self.contentView.addSubview(lottieView)
//
//        lottieView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
//        lottieView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
//        lottieView.widthAnchor.constraint(equalToConstant: 180 * QUtils.optimizeRatio()).isActive = true
//        lottieView.heightAnchor.constraint(equalToConstant: 40 * QUtils.optimizeRatio()).isActive = true
        
        self.layoutIfNeeded()
        
//        lottieView.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
//        lottieView.stop()
    }
}
