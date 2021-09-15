//
//  ALTJuniorWritingViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/25.
//

import UIKit
import AVFoundation

class ALTJuniorWritingViewController: ALTJuniorTestBaseViewController {
    lazy internal var _collectionView: UICollectionView = {
        let flowLayout = UIDevice.current.userInterfaceIdiom == .pad ? CenterAlignedCollectionViewFlowLayout() : LeftAlignedCollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    internal var _selectedIndexes = [Int?]()
    internal var _collectionData = [String]()
   
    internal var _answerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _answerCount = testData.quiz?.details?["answer_count"] as? Int ?? 0
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.backgroundColor = .clear
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        _collectionView.register(ALTJuniorWritingFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "ALTJuniorWritingFooterReusableView")
        _collectionView.register(ALTJuniorWritingHeaderCollectionViewCell.self, forCellWithReuseIdentifier: "ALTJuniorWritingHeaderCollectionViewCell")
        _collectionView.register(ALTSeniorWritingTestAnswerCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorWritingTestAnswerCollectionViewCell")
        _collectionView.register(ALTSeniorWritingTestSelectableCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorWritingTestSelectableCollectionViewCell")
        self.view.addSubview(_collectionView)
        
        _collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        _collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        reloadData()
    }
    
    private func reloadData() {
        _selectedIndexes.removeAll()
        _collectionData.removeAll()
        
        if let value = (testData.rawData["question_list"] as? [String:Any])?["exam_list"] as? [String] {
            _collectionData.append(contentsOf: value)
        }
        
        _collectionView.reloadData()
    }
}

extension ALTJuniorWritingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var index = -1
        
        if indexPath.section == 1, indexPath.row < _selectedIndexes.count {
            index = _selectedIndexes[indexPath.row] ?? -1
        } else if indexPath.section == 3 {
            index = indexPath.row
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
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard section == 3 else { return .zero}
        return _footerView.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 3, kind == UICollectionView.elementKindSectionFooter, let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ALTJuniorWritingFooterReusableView", for: indexPath) as? ALTJuniorWritingFooterReusableView {
            for subview in reusableView.subviews {
                subview.removeFromSuperview()
            }
            var frame = _footerView.frame
            frame.origin.x = -ALTSeniorWritingTestSelectableCollectionViewCell.sectionInsets.left
            _footerView.frame = frame
            reusableView.addSubview(_footerView)
            return reusableView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 1
        
        if section == 0 {
            numberOfItems = 2
        } else if section == 1 {
            numberOfItems = _answerCount
        } else if section == 3 {
            numberOfItems = _collectionData.count
        }
        
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var inset = UIEdgeInsets.zero
        
        if section == 1 {
            inset = ALTSeniorWritingTestAnswerCollectionViewCell.sectionInsets
        } else if section == 3 {
            inset = ALTSeniorWritingTestSelectableCollectionViewCell.sectionInsets
        }
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var lineSpacing = CGFloat(0)
        
        if section == 1 {
            lineSpacing = ALTSeniorWritingTestAnswerCollectionViewCell.lineSpacing
        } else if section == 3 {
            lineSpacing = ALTSeniorWritingTestSelectableCollectionViewCell.lineSpacing
        }
        
        return lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        var interSpacing = CGFloat(0)
        
        if section == 1 {
            interSpacing = ALTSeniorWritingTestAnswerCollectionViewCell.interItemSpacing
        } else if section == 3 {
            interSpacing = ALTSeniorWritingTestSelectableCollectionViewCell.interItemSpacing
        }
        
        return interSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemSize = CGSize.zero
        
        if indexPath.section == 0 {
            var size = CGSize.zero
            size.width = UIScreen.main.bounds.size.width
            size.height = indexPath.row == 0 ? ALTJuniorWritingHeaderCollectionViewCell.height(with: testData.quiz!) : 80.optimizedWithHeight
            return size
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTJuniorWritingHeaderCollectionViewCell", for: indexPath) as? ALTJuniorWritingHeaderCollectionViewCell {
                cell.quiz = testData.quiz
                return cell
            }
            return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
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
}

class ALTJuniorWritingHeaderCollectionViewCell: UICollectionViewCell {
    class func height(with quiz: ALTLevelTest.Quiz) -> CGFloat {
        var height = 5.optimizedWithHeight
        
        var frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 84.optimized, height: 0)
        
        var label = UILabel(frame: frame)
        label.text = quiz.quizDesc
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22.optimizedWithHeight, weight: .heavy)
        label.numberOfLines = 0
        label.sizeToFit()
        height += label.frame.size.height
        
        height += 5.optimizedWithHeight
        
        frame.size.width = UIScreen.main.bounds.size.width - 72.optimized
        
        label = UILabel(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = quiz.quiz
        label.font = UIFont.systemFont(ofSize: 20.optimizedWithHeight, weight: .heavy)
        label.numberOfLines = 0
        label.sizeToFit()
        var aHeight = label.frame.size.height
        if aHeight < 70.optimizedWithHeight {
            aHeight = 70.optimizedWithHeight
        }
        height += aHeight
        
        height += label.frame.size.height
        
        height += 40.optimizedWithHeight
        
        return height
    }
    
    private let _labelQuizDesc = UILabel()
    private let _labelQuiz = UILabel()
    
    var quiz: ALTLevelTest.Quiz? {
        didSet {
            _labelQuizDesc.text = quiz?.quizDesc
            _labelQuiz.text = quiz?.quiz
            
            self.layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _labelQuizDesc.translatesAutoresizingMaskIntoConstraints = false
        _labelQuizDesc.textAlignment = .center
        _labelQuizDesc.textColor = ColourKit.Code.Hex222222
        _labelQuizDesc.font = UIFont.systemFont(ofSize: 22.optimizedWithHeight, weight: .heavy)
        _labelQuizDesc.numberOfLines = 0
        self.contentView.addSubview(_labelQuizDesc)
        
        _labelQuizDesc.topAnchor.constraint(equalTo: self.topAnchor, constant: 5.optimizedWithHeight).isActive = true
        _labelQuizDesc.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 42.optimized).isActive = true
        _labelQuizDesc.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -42.optimized).isActive = true
        _labelQuizDesc.heightAnchor.constraint(equalToConstant: 90.optimizedWithHeight).isActive = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.HexFFFFFF
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 10.optimized
        self.contentView.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: _labelQuizDesc.bottomAnchor, constant: 5.optimizedWithHeight).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.optimized).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16.optimized).isActive = true
        
        _labelQuiz.translatesAutoresizingMaskIntoConstraints = false
        _labelQuiz.textColor = ColourKit.Code.Hex222222
        _labelQuiz.font = UIFont.systemFont(ofSize: 20.optimizedWithHeight, weight: .heavy)
        _labelQuiz.numberOfLines = 0
        backView.addSubview(_labelQuiz)
        
        _labelQuiz.topAnchor.constraint(equalTo: backView.topAnchor, constant: 10.optimizedWithHeight).isActive = true
        _labelQuiz.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -10.optimizedWithHeight).isActive = true
        _labelQuiz.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 19.optimized).isActive = true
        _labelQuiz.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -19.optimized).isActive = true
        _labelQuiz.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -10.optimizedWithHeight).isActive = true
        _labelQuiz.heightAnchor.constraint(greaterThanOrEqualToConstant: 70.optimizedWithHeight).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

class ALTJuniorWritingFooterReusableView: UICollectionReusableView {}
    
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

