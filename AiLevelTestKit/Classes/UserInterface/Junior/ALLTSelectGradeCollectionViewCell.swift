//
//  ALLTSelectGradeCollectionViewCell.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/05.
//

import UIKit

class ALLTSelectGradeCollectionViewCell: UICollectionViewCell {
    class var sectionInset: UIEdgeInsets {
        get {
            var insets = UIEdgeInsets.zero
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                insets.left = 8
                insets.right = 8
                break
                
            default:
                insets.left = 27
                insets.right = 27
                break
            }
            
            return insets
        }
    }
    
    class var interItemSpacing: CGFloat { return 8 }
    class var lineSpacing: CGFloat { return 10 }
    
    class var itemSize: CGSize {
        get {
            var size = CGSize.zero
            
            let numberOfItemInRow = UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(4) : CGFloat(2)
            
            let insets = ALLTSelectGradeCollectionViewCell.sectionInset
            
            let totalHorizontalSpacing = ALLTSelectGradeCollectionViewCell.interItemSpacing * (numberOfItemInRow > 0 ? numberOfItemInRow - 1 : 0)
            
            size.width = ((UIScreen.main.bounds.size.width - insets.left - insets.right - totalHorizontalSpacing) / numberOfItemInRow).rounded(.down)
            size.height = (size.width * 160 / 175) - lineSpacing
            
            return size
        }
    }
    
    internal let labelGrade = UILabel()
    internal let imageViewGrade = UIImageView()
    internal let _imageDownloader = QImageDownloader()
    
    var data: ALTJuniorInfo.Exam? {
        didSet {
            reloadData()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? ColourKit.Code.Static.HexFFFF91 : ColourKit.Code.HexFFFFFF
            labelGrade.textColor = isSelected ? ColourKit.Code.Static.Hex222222 : ColourKit.Code.Hex222222
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = ColourKit.Code.HexFFFFFF
        
        labelGrade.translatesAutoresizingMaskIntoConstraints = false
        labelGrade.textColor = ColourKit.Code.Hex222222
        labelGrade.font = UIFont.systemFont(ofSize: 14.optimized, weight: .regular)
        self.contentView.addSubview(labelGrade)
        
        imageViewGrade.translatesAutoresizingMaskIntoConstraints = false
        imageViewGrade.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageViewGrade)
        
        setInternalConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    internal func setInternalConstraints() {
        labelGrade.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10.optimized).isActive = true
        labelGrade.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        
        imageViewGrade.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 98 / 166).isActive = true
        imageViewGrade.heightAnchor.constraint(equalTo: imageViewGrade.widthAnchor, multiplier: 103 / 98).isActive = true
        imageViewGrade.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        imageViewGrade.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
    }
    
    func reloadData() {
        labelGrade.text = data?.name
//        imageViewGrade.pin_setImage(from: URL(string: data?.imageUrl ?? ""))
        _imageDownloader.request(data?.imageUrl ?? "") {[weak self] (image) in
            DispatchQueue.main.async { [weak self] in
                self?.imageViewGrade.image = image
            }
        }
        
        self.contentView.layoutIfNeeded()
    }
}
