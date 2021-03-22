//
//  ALLTWriteViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALLTWriteViewController: ALLTBaseViewController {
    lazy internal var _collectionView: UICollectionView = {
        let flowLayout = LeftAlignedCollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    internal var _selectedData = [String]()
    internal var _collectionData = [String]()
    
    internal var _answerString = "she need drink more water"
    internal var _translatedString = "그녀는 물을 더 많이 마셔야 한다"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.backgroundColor = .clear
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        _collectionView.register(ALLTWriteHeaderCollectionViewCell.self, forCellWithReuseIdentifier: "ALLTWriteHeaderCollectionViewCell")
        _collectionView.register(ALLTWriteAnswerCollectionViewCell.self, forCellWithReuseIdentifier: "ALLTWriteAnswerCollectionViewCell")
        _collectionView.register(ALLTSelectableCollectionViewCell.self, forCellWithReuseIdentifier: "ALLTSelectableCollectionViewCell")
        self.view.addSubview(_collectionView)
        
        _collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        _collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        reloadData()
    }
    
    private func reloadData() {
        _selectedData.removeAll()
        _collectionData.removeAll()
        
        _collectionData.append(contentsOf: _answerString.components(separatedBy: " "))
        _collectionData.append("special")
        _collectionData.append("dots")
        _collectionData.append("waters")
        _collectionData.append("cup")
        
        _collectionData.shuffle()
        
        _collectionView.reloadData()
    }
}

extension ALLTWriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 3 else { return }
        
        let string = _collectionData[indexPath.row]
        
        if let row = _selectedData.firstIndex(of: string) {
            _selectedData.remove(at: row)
        } else if _selectedData.count < _answerString.components(separatedBy: " ").count - 1 {
            _selectedData.append(string)
        }
        
        _collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0
        
        if section == 0 || section == 2 {
            numberOfItems = 1
        } else if section == 1 {
            numberOfItems = _answerString.components(separatedBy: " ").count
        } else if section == 3 {
            numberOfItems = _collectionData.count
        }
        
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var inset = UIEdgeInsets.zero
        
        if section == 1 {
            inset = ALLTWriteAnswerCollectionViewCell.sectionInsets
        } else if section == 3 {
            inset = ALLTSelectableCollectionViewCell.sectionInsets
        }
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        var lineSpacing = CGFloat(0)
        
        if section == 1 {
            lineSpacing = ALLTWriteAnswerCollectionViewCell.lineSpacing
        } else if section == 3 {
            lineSpacing = ALLTSelectableCollectionViewCell.lineSpacing
        }
        
        return lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        var interSpacing = CGFloat(0)
        
        if section == 1 {
            interSpacing = ALLTWriteAnswerCollectionViewCell.interItemSpacing
        } else if section == 3 {
            interSpacing = ALLTSelectableCollectionViewCell.interItemSpacing
        }
        
        return interSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemSize = CGSize.zero
        
        if indexPath.section == 0 {
            itemSize = ALLTWriteHeaderCollectionViewCell.itemSize(with: _translatedString)
        } else if indexPath.section == 1 {
            if indexPath.row < _selectedData.count {
                return ALLTWriteAnswerCollectionViewCell.itemSize(with: _selectedData[indexPath.row])
            } else {
                return ALLTWriteAnswerCollectionViewCell.itemSize()
            }
        } else if indexPath.section == 2 {
            itemSize.width = UIScreen.main.bounds.size.width
            itemSize.height = 50.optimized
        } else if indexPath.section == 3 {
            itemSize = ALLTSelectableCollectionViewCell.itemSize(with: _collectionData[indexPath.row])
        }
        
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALLTWriteHeaderCollectionViewCell", for: indexPath) as? ALLTWriteHeaderCollectionViewCell {
            cell.translatedString = _translatedString
            return cell
        } else if indexPath.section == 1, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALLTWriteAnswerCollectionViewCell", for: indexPath) as? ALLTWriteAnswerCollectionViewCell {
            if indexPath.row < _selectedData.count {
                cell.text = _selectedData[indexPath.row]
            } else {
                cell.text = nil
            }
            return cell
        } else if indexPath.section == 3, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALLTSelectableCollectionViewCell", for: indexPath) as? ALLTSelectableCollectionViewCell {
            let title =  _collectionData[indexPath.row]
            cell.title = title
            cell.isSelected = _selectedData.firstIndex(of: title) != nil
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
    }
}


fileprivate class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
 
        var leftMargin = CGFloat(0)
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            var insets = UIEdgeInsets.zero
            var interSpacing = CGFloat(0)
            
            if layoutAttribute.indexPath.section == 1 {
                insets = ALLTWriteAnswerCollectionViewCell.sectionInsets
                interSpacing = ALLTWriteAnswerCollectionViewCell.interItemSpacing
            } else if layoutAttribute.indexPath.section == 3 {
                insets = ALLTSelectableCollectionViewCell.sectionInsets
                interSpacing = ALLTSelectableCollectionViewCell.interItemSpacing
            }
            
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = insets.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + interSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}
