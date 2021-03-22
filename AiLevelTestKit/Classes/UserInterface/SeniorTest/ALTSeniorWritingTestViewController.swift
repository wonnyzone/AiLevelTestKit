//
//  ALTSeniorWritingTestViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit
import AVFoundation

class ALTSeniorWritingTestViewController: ALLTSeniorTestBaseViewController {
    lazy internal var _collectionView: UICollectionView = {
        let flowLayout = UIDevice.current.userInterfaceIdiom == .pad ? CenterAlignedCollectionViewFlowLayout() : LeftAlignedCollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    lazy internal var _constraintCollectionViewHeight: NSLayoutConstraint = {
        return _collectionView.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    internal var _collectionViewPadLeft: UICollectionView?
    
    lazy internal var _constraintCollectionViewPadLeftHeight: NSLayoutConstraint? = {
        return _collectionViewPadLeft?.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    internal var _selectedIndexes = [Int?]()
    internal var _collectionData = [String]()
   
    internal var _answerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _answerCount = testData.quiz?.details?["answer_count"] as? Int ?? 0
        
        _guideString = "빈칸을 모두 채워서 문장을 완성하세요.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.backgroundColor = .clear
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        _collectionView.register(ALTSeniorWritingTestHeaderCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorWritingTestHeaderCollectionViewCell")
        _collectionView.register(ALTSeniorWritingTestAnswerCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorWritingTestAnswerCollectionViewCell")
        _collectionView.register(ALTSeniorWritingTestSelectableCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorWritingTestSelectableCollectionViewCell")
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.view.backgroundColor = ColourKit.Code.HexF0F0F0
            
            let leftView = UIView()
            leftView.translatesAutoresizingMaskIntoConstraints = false
            leftView.clipsToBounds = true
            leftView.backgroundColor = ColourKit.Code.HexFFFFFF
            leftView.layer.cornerRadius = 10
            self.view.addSubview(leftView)
            
            leftView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26.optimized).isActive = true
            leftView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -26.optimized).isActive = true
            leftView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 26.optimized).isActive = true
            leftView.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -6.optimized).isActive = true
            
            _collectionViewPadLeft = UICollectionView(frame: .zero, collectionViewLayout: CenterAlignedCollectionViewFlowLayout())
            _collectionViewPadLeft!.translatesAutoresizingMaskIntoConstraints = false
            _collectionViewPadLeft!.backgroundColor = .clear
            _collectionViewPadLeft!.delegate = self
            _collectionViewPadLeft!.dataSource = self
            _collectionViewPadLeft!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
            _collectionViewPadLeft!.register(ALTSeniorWritingTestHeaderCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorWritingTestHeaderCollectionViewCell")
            _collectionViewPadLeft!.register(ALTSeniorWritingTestAnswerCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorWritingTestAnswerCollectionViewCell")
            _collectionViewPadLeft!.register(ALTSeniorWritingTestSelectableCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorWritingTestSelectableCollectionViewCell")
            leftView.addSubview(_collectionViewPadLeft!)
            
            _constraintCollectionViewPadLeftHeight?.isActive = true
            _collectionViewPadLeft!.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
            _collectionViewPadLeft!.leadingAnchor.constraint(equalTo: leftView.leadingAnchor).isActive = true
            _collectionViewPadLeft!.trailingAnchor.constraint(equalTo: leftView.trailingAnchor).isActive = true
            
            let rightView = UIView()
            rightView.translatesAutoresizingMaskIntoConstraints = false
            rightView.clipsToBounds = true
            rightView.backgroundColor = ColourKit.Code.HexD0D0D0
            rightView.layer.cornerRadius = 10
            self.view.addSubview(rightView)
            
            rightView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26.optimized).isActive = true
            rightView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -26.optimized).isActive = true
            rightView.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 6.optimized).isActive = true
            rightView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -26.optimized).isActive = true
            
            rightView.addSubview(_collectionView)
            
            _constraintCollectionViewHeight.isActive = true
            _collectionView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor).isActive = true
            _collectionView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor).isActive = true
            _collectionView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor).isActive = true
        } else {
            _collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
            self.view.addSubview(_collectionView)
            
            _collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            _collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            _collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            _collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
        
        reloadData()
    }
    
    private func reloadData() {
        _selectedIndexes.removeAll()
        _collectionData.removeAll()
        
        if let value = (testData.rawData["question_list"] as? [String:Any])?["exam_list"] as? [String] {
            _collectionData.append(contentsOf: value)
        }
        
        _collectionData.shuffle()
        
        _collectionView.reloadData()
        _collectionViewPadLeft?.reloadData()
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: {[weak self] (timer) in
            if let collectionView = self?._collectionViewPadLeft {
                self?._constraintCollectionViewPadLeftHeight?.constant = collectionView.contentSize.height
            }

            self?._constraintCollectionViewHeight.constant = self?._collectionView.contentSize.height ?? 0
            self?.view.layoutIfNeeded()
        })
    }
}

extension ALTSeniorWritingTestViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var index = -1
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if collectionView == _collectionViewPadLeft, indexPath.row < _selectedIndexes.count {
                index = _selectedIndexes[indexPath.row] ?? -1
            } else if collectionView == _collectionView {
                index = indexPath.row
            }
        } else {
            if indexPath.section == 1, indexPath.row < _selectedIndexes.count {
                index = _selectedIndexes[indexPath.row] ?? -1
            } else if indexPath.section == 3 {
                index = indexPath.row
            }
        }
        
        guard index >= 0 else { return }
        
        if let row = _selectedIndexes.firstIndex(of: index) {
            _selectedIndexes[row] = nil
        } else {
            if let nilIdx = _selectedIndexes.firstIndex(of: nil) {
                _selectedIndexes[nilIdx] = index
            } else if _selectedIndexes.count < _answerCount {
                _selectedIndexes.append(index)
            }
        }
        
        _buttonNext.isEnabled = _selectedIndexes.count >= _answerCount && _selectedIndexes.firstIndex(of: nil) == nil
        
        if _buttonNext.isEnabled {
            _guideString = "\'NEXT\' 버튼을 누르면 다음 문제로 넘어갑니다."
        }
        
        _isSkippable = true
        
        if _selectedIndexes.count > 0 {
            var answerString = ""
            for i in 0 ..< _selectedIndexes.count {
                if i > 0 {
                    answerString += " "
                }
                let index = _selectedIndexes[i]
                answerString += index != nil ? _collectionData[index!] : ""
            }
            
            if answerString.count > 0 {
                _answer = answerString
//                _guideString = "수정 시 선택한 단어를 클릭하면 취소됩니다."
            } else {
                _guideString = "빈칸을 모두 채워서 문장을 완성하세요.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
            }
        } else {
            _guideString = "빈칸을 모두 채워서 문장을 완성하세요.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
        }
        
        _collectionView.reloadData()
        _collectionViewPadLeft?.reloadData()
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {[weak self] (timer) in
            if let collectionView = self?._collectionViewPadLeft {
                self?._constraintCollectionViewPadLeftHeight?.constant = collectionView.contentSize.height
            }

            self?._constraintCollectionViewHeight.constant = self?._collectionView.contentSize.height ?? 0
            self?.view.layoutIfNeeded()
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return 4 }
        return collectionView == _collectionView ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var numberOfItems = 1
            
             if section == 1 {
                numberOfItems = _answerCount
            } else if section == 3 {
                numberOfItems = _collectionData.count
            }
            
            return numberOfItems
        }
        
        if collectionView == _collectionView { return _collectionData.count }
        
        return section == 0 ? 1 : _answerCount
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var inset = UIEdgeInsets.zero
            
            if section == 1 {
                inset = ALTSeniorWritingTestAnswerCollectionViewCell.sectionInsets
            } else if section == 3 {
                inset = ALTSeniorWritingTestSelectableCollectionViewCell.sectionInsets
            }
            
            return inset
        }
        
        var inset = UIEdgeInsets.zero
        
        if collectionView == _collectionViewPadLeft, section == 1 {
            inset = ALTSeniorWritingTestAnswerCollectionViewCell.sectionInsets
        } else if collectionView == _collectionView {
            inset = ALTSeniorWritingTestSelectableCollectionViewCell.sectionInsets
        }
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var lineSpacing = CGFloat(0)
            
            if section == 1 {
                lineSpacing = ALTSeniorWritingTestAnswerCollectionViewCell.lineSpacing
            } else if section == 3 {
                lineSpacing = ALTSeniorWritingTestSelectableCollectionViewCell.lineSpacing
            }
            
            return lineSpacing
        }
        
        var lineSpacing = CGFloat(0)
        
        if collectionView == _collectionViewPadLeft, section == 1 {
            lineSpacing = ALTSeniorWritingTestAnswerCollectionViewCell.lineSpacing
        } else if collectionView == _collectionView {
            lineSpacing = ALTSeniorWritingTestSelectableCollectionViewCell.lineSpacing
        }
        
        return lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var interSpacing = CGFloat(0)
            
            if section == 1 {
                interSpacing = ALTSeniorWritingTestAnswerCollectionViewCell.interItemSpacing
            } else if section == 3 {
                interSpacing = ALTSeniorWritingTestSelectableCollectionViewCell.interItemSpacing
            }
            
            return interSpacing
        }
        
        var interSpacing = CGFloat(0)
        
        if collectionView == _collectionViewPadLeft, section == 1 {
            interSpacing = ALTSeniorWritingTestAnswerCollectionViewCell.interItemSpacing
        } else if collectionView == _collectionView {
            interSpacing = ALTSeniorWritingTestSelectableCollectionViewCell.interItemSpacing
        }
        
        return interSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var itemSize = CGSize.zero
            
            if indexPath.section == 0 {
                itemSize = ALTSeniorWritingTestHeaderCollectionViewCell.itemSize(with: testData.quiz?.quiz ?? "")
            } else if indexPath.section == 1 {
                if indexPath.row < _selectedIndexes.count, let index = _selectedIndexes[indexPath.row] {
                    return ALTSeniorWritingTestAnswerCollectionViewCell.itemSize(with:  _collectionData[index])
                } else {
                    return ALTSeniorWritingTestAnswerCollectionViewCell.itemSize()
                }
            } else if indexPath.section == 2 {
                itemSize.width = UIScreen.main.bounds.size.width
                itemSize.height = 40.optimized
            } else if indexPath.section == 3 {
                itemSize = ALTSeniorWritingTestSelectableCollectionViewCell.itemSize(with: _collectionData[indexPath.row])
            }
            return itemSize
        }
        
        var itemSize = CGSize.zero
        
        if collectionView == _collectionViewPadLeft {
            if indexPath.section == 0 {
                itemSize = ALTSeniorWritingTestHeaderCollectionViewCell.itemSize(with: testData.quiz?.quiz ?? "")
            } else if indexPath.section == 1 {
                if indexPath.row < _selectedIndexes.count, let index = _selectedIndexes[indexPath.row] {
                    itemSize = ALTSeniorWritingTestAnswerCollectionViewCell.itemSize(with:  _collectionData[index])
                } else {
                    itemSize = ALTSeniorWritingTestAnswerCollectionViewCell.itemSize()
                }
            }
        }
        
        if collectionView == _collectionView {
            itemSize = ALTSeniorWritingTestSelectableCollectionViewCell.itemSize(with: _collectionData[indexPath.row])
        }
        
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            if indexPath.section == 0, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorWritingTestHeaderCollectionViewCell", for: indexPath) as? ALTSeniorWritingTestHeaderCollectionViewCell {
                cell.translatedString = testData.quiz?.quiz
                return cell
            } else if indexPath.section == 1, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorWritingTestAnswerCollectionViewCell", for: indexPath) as? ALTSeniorWritingTestAnswerCollectionViewCell {
                if indexPath.row < _selectedIndexes.count, let index = _selectedIndexes[indexPath.row] {
                    cell.text = _collectionData[index]
                } else {
                    cell.text = nil
                }
                return cell
            } else if indexPath.section == 3, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorWritingTestSelectableCollectionViewCell", for: indexPath) as? ALTSeniorWritingTestSelectableCollectionViewCell {
                let title =  _collectionData[indexPath.row]
                cell.title = title
                cell.isSelected = _selectedIndexes.firstIndex(of: indexPath.row) != nil
                return cell
            }
            
            return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        }
        
        if collectionView == _collectionViewPadLeft {
            if indexPath.section == 0, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorWritingTestHeaderCollectionViewCell", for: indexPath) as? ALTSeniorWritingTestHeaderCollectionViewCell {
                cell.translatedString = testData.quiz?.quiz
                return cell
            } else if indexPath.section == 1, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorWritingTestAnswerCollectionViewCell", for: indexPath) as? ALTSeniorWritingTestAnswerCollectionViewCell {
                if indexPath.row < _selectedIndexes.count, let index = _selectedIndexes[indexPath.row] {
                    cell.text = _collectionData[index]
                } else {
                    cell.text = nil
                }
                return cell
            }
        } else if collectionView == _collectionView, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorWritingTestSelectableCollectionViewCell", for: indexPath) as? ALTSeniorWritingTestSelectableCollectionViewCell {
            let title =  _collectionData[indexPath.row]
            cell.title = title
            cell.isSelected = _selectedIndexes.firstIndex(of: indexPath.row) != nil
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
                insets = ALTSeniorListeningTestAnswerCollectionViewCell.sectionInsets
                interSpacing = ALTSeniorListeningTestAnswerCollectionViewCell.interItemSpacing
            } else if layoutAttribute.indexPath.section == 3 {
                insets = ALTSeniorListeningTestSelectableCollectionViewCell.sectionInsets
                interSpacing = ALTSeniorListeningTestSelectableCollectionViewCell.interItemSpacing
            }
            
            if layoutAttribute.frame.origin.y >= maxY || layoutAttribute.indexPath.row == 0 {
                leftMargin = insets.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + interSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}

fileprivate class CenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        // Copy each item to prevent "UICollectionViewFlowLayout has cached frame mismatch" warning
        guard let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
        
        // Constants
        let leftPadding: CGFloat = 8
        let interItemSpacing = minimumInteritemSpacing
        
        // Tracking values
        var leftMargin: CGFloat = leftPadding // Modified to determine origin.x for each item
        var maxY: CGFloat = -1.0 // Modified to determine origin.y for each item
        var rowSizes: [[CGFloat]] = [] // Tracks the starting and ending x-values for the first and last item in the row
        var currentRow: Int = 0 // Tracks the current row
        attributes.forEach { layoutAttribute in
            
            // Each layoutAttribute represents its own item
            if layoutAttribute.frame.origin.y >= maxY {
                
                // This layoutAttribute represents the left-most item in the row
                leftMargin = leftPadding
                
                // Register its origin.x in rowSizes for use later
                if rowSizes.count == 0 {
                    // Add to first row
                    rowSizes = [[leftMargin, 0]]
                } else {
                    // Append a new row
                    rowSizes.append([leftMargin, 0])
                    currentRow += 1
                }
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
            
            // Add right-most x value for last item in the row
            rowSizes[currentRow][1] = leftMargin - interItemSpacing
        }
        
        // At this point, all cells are left aligned
        // Reset tracking values and add extra left padding to center align entire row
        leftMargin = leftPadding
        maxY = -1.0
        currentRow = 0
        attributes.forEach { layoutAttribute in
            
            // Each layoutAttribute is its own item
            if layoutAttribute.frame.origin.y >= maxY {
                
                // This layoutAttribute represents the left-most item in the row
                leftMargin = leftPadding
                
                // Need to bump it up by an appended margin
                let rowWidth = rowSizes[currentRow][1] - rowSizes[currentRow][0] // last.x - first.x
                let appendedMargin = (collectionView!.frame.width - leftPadding  - rowWidth - leftPadding) / 2
                leftMargin += appendedMargin
                
                currentRow += 1
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}
