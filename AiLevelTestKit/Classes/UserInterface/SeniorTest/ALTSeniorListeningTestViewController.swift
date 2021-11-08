//
//  ALTSeniorListeningTestViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit
import AVFoundation

class ALTSeniorListeningTestViewController: ALLTSeniorTestBaseViewController {
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
    
    internal var _buttonPlay: UIButton?                     // iPad
    internal var _labelButtonTitle: UILabel?                // iPad
    internal var _imageViewPlay: UIImageView?               // iPad
    
    internal var _labelNoSelect: UILabel?                   // iPad
    
    internal var _player: AVPlayer?
    
    internal var _remainingPlayCount = 2 {
        didSet {
            guard UIDevice.current.userInterfaceIdiom == .pad else { return }
            
            let attributedString = NSMutableAttributedString()
            
            let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 18 : 13.optimized
            
            let highAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex000000, font: UIFont.systemFont(ofSize: fontSize, weight: .semibold)).attributes
            let norAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex000000, font: UIFont.systemFont(ofSize: fontSize, weight: .regular)).attributes
            
            attributedString.append(NSAttributedString(string: "문제 듣기", attributes: highAttr))
            attributedString.append(NSAttributedString(string:" (", attributes: norAttr))
            attributedString.append(NSAttributedString(string:"\(_remainingPlayCount)번", attributes: highAttr))
            attributedString.append(NSAttributedString(string:"의 듣기가 남았습니다.)", attributes: norAttr))
                
            _labelButtonTitle?.attributedText = attributedString
            
            self.view.layoutIfNeeded()
        }
    }
    internal var _initiallyStarted = true
    
    internal var _isPlayable: Bool = true {
        didSet {
            guard UIDevice.current.userInterfaceIdiom == .pad else { return }
            _imageViewPlay?.image = _isPlayable ? UIImage(named: "img_playOn", in:Bundle(for: type(of: self)), compatibleWith:nil) : UIImage(named: "img_playOff", in:Bundle(for: type(of: self)), compatibleWith:nil)
            _buttonPlay?.isEnabled = _isPlayable
        }
    }
    
    override var canGoNext: Bool {
        return _answer != nil || _selectedIndexes.count > 0
    }
     
    internal var _isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let examSrl = testData.testInfo?.examSrl ?? 0
        let level = testData.quiz?.level ?? 0
        let folder = testData.quiz?.folder ?? 0
        let lang = LevelTestManager.manager.examInfo?.testLanguage ?? ""
        let quizOrder = testData.quiz?.quizOrder ?? 0
        
        var assetUrl = RequestUrl.AWS +  "/voice/leveltest/\(examSrl)/level\(level)-\(folder)/\(lang)/\(quizOrder)"
        if level == 10 && folder == 50 {
            assetUrl += "/Listen1"
        }
        assetUrl += ".mp3"
        
        let item = AVPlayerItem(url: URL(string: assetUrl)!)
        _player = AVPlayer(playerItem: item)
        
        _guideString = "음성을 잘 들어주세요."
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.backgroundColor = .clear
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        _collectionView.register(ALTSeniorListeningTestHeaderCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorListeningTestHeaderCollectionViewCell")
        _collectionView.register(ALTSeniorListeningTestAnswerCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorListeningTestAnswerCollectionViewCell")
        _collectionView.register(ALTSeniorListeningTestSelectableCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorListeningTestSelectableCollectionViewCell")
        _collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0).optimized
        self.view.addSubview(_collectionView)
        
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
            _collectionViewPadLeft!.register(ALTSeniorListeningTestAnswerCollectionViewCell.self, forCellWithReuseIdentifier: "ALTSeniorListeningTestAnswerCollectionViewCell")
            leftView.addSubview(_collectionViewPadLeft!)
            
            _constraintCollectionViewPadLeftHeight?.isActive = true
            _collectionViewPadLeft!.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
            _collectionViewPadLeft!.leadingAnchor.constraint(equalTo: leftView.leadingAnchor).isActive = true
            _collectionViewPadLeft!.trailingAnchor.constraint(equalTo: leftView.trailingAnchor).isActive = true
            
            _labelNoSelect = UILabel()
            _labelNoSelect?.translatesAutoresizingMaskIntoConstraints = false
            _labelNoSelect?.text = "오른쪽 단어를 선택해주세요."
            _labelNoSelect?.textColor = ColourKit.Code.HexCCCCCC
            _labelNoSelect?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
            leftView.addSubview(_labelNoSelect!)
            
            _labelNoSelect?.centerXAnchor.constraint(equalTo: leftView.centerXAnchor).isActive = true
            _labelNoSelect?.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
            
            var rightView = UIView()
            rightView.translatesAutoresizingMaskIntoConstraints = false
            rightView.clipsToBounds = true
            rightView.backgroundColor = ColourKit.Code.HexD0D0D0
            rightView.layer.cornerRadius = 10
            self.view.addSubview(rightView)
            
            rightView.topAnchor.constraint(equalTo: leftView.topAnchor).isActive = true
            rightView.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 6).isActive = true
            rightView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -26).isActive = true
            rightView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            _buttonPlay = UIButton()
            _buttonPlay!.translatesAutoresizingMaskIntoConstraints = false
            _buttonPlay!.addTarget(self, action: #selector(self.play(_:)), for: .touchUpInside)
            rightView.addSubview(_buttonPlay!)
            
            _buttonPlay!.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 20).isActive = true
            _buttonPlay!.centerYAnchor.constraint(equalTo: rightView.centerYAnchor).isActive = true
            _buttonPlay!.widthAnchor.constraint(equalToConstant: 68).isActive = true
            _buttonPlay!.heightAnchor.constraint(equalToConstant: 68).isActive = true
            
            let bundle = Bundle(for: AiLevelTestKit.self)
            
            _imageViewPlay = UIImageView()
            _imageViewPlay!.translatesAutoresizingMaskIntoConstraints = false
            _imageViewPlay!.isUserInteractionEnabled = false
            _imageViewPlay!.image = UIImage(named: "img_playOn", in:Bundle(for: type(of: self)), compatibleWith:nil)
            _buttonPlay!.addSubview(_imageViewPlay!)
            
            _imageViewPlay!.topAnchor.constraint(equalTo: _buttonPlay!.topAnchor).isActive = true
            _imageViewPlay!.bottomAnchor.constraint(equalTo: _buttonPlay!.bottomAnchor).isActive = true
            _imageViewPlay!.leadingAnchor.constraint(equalTo: _buttonPlay!.leadingAnchor).isActive = true
            _imageViewPlay!.widthAnchor.constraint(equalTo: _imageViewPlay!.heightAnchor).isActive = true
            
            _labelButtonTitle = UILabel()
            _labelButtonTitle!.translatesAutoresizingMaskIntoConstraints = false
            _labelButtonTitle!.isUserInteractionEnabled = false
            _labelButtonTitle!.numberOfLines = 2
            rightView.addSubview(_labelButtonTitle!)
            
            _labelButtonTitle!.topAnchor.constraint(equalTo: _buttonPlay!.topAnchor).isActive = true
            _labelButtonTitle!.bottomAnchor.constraint(equalTo: _buttonPlay!.bottomAnchor).isActive = true
            _labelButtonTitle!.leadingAnchor.constraint(equalTo: _buttonPlay!.trailingAnchor, constant: 15).isActive = true
            _labelButtonTitle!.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -20).isActive = true
            
            let bottomAnchor = rightView.bottomAnchor
            
            rightView = UIView()
            rightView.translatesAutoresizingMaskIntoConstraints = false
            rightView.clipsToBounds = true
            rightView.backgroundColor = ColourKit.Code.HexD0D0D0
            rightView.layer.cornerRadius = 10
            self.view.addSubview(rightView)
            
            rightView.topAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
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
        
        _remainingPlayCount = 2
        
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _player?.pause()
        _isPlaying = false
        _isPlayable = _remainingPlayCount > 0
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard _initiallyStarted else { return }
        
        _player?.play()
        _collectionView.reloadData()
        
        _isSkippable = false
        
        if _player != nil {
            _isPlaying = true
            _isPlayable = false
        }
    }
    
    private func reloadData() {
        _selectedIndexes.removeAll()
        _collectionData.removeAll()
        
        if let value = testData.quiz?.rawData["exam_list"] as? [String] {
            _collectionData.append(contentsOf: value)
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
    
    @objc private func play(_ button: UIButton) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            guard let cell = button.superview?.superview as? ALTSeniorListeningTestHeaderCollectionViewCell, _remainingPlayCount > 0 else { return }
            
            cell.isButtonEnabled = false
        }
            
        _buttonNext.isEnabled = false
        _isSkippable = false
        
        _player?.seek(to: .zero)
        _player?.play()
        
        if _player != nil {
            _isPlaying = true
            _isPlayable = false
            _guideString = "음성을 잘 들어주세요."
        }
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        if _initiallyStarted == false {
            _remainingPlayCount -= 1
        }
        
        _isPlaying = false
        _isPlayable = _remainingPlayCount > 0
        
        _initiallyStarted = false
        
        _buttonNext.isEnabled = _selectedIndexes.count > 0
        _isSkippable = true
        
        _collectionView.reloadData()
        
        _guideString = _selectedIndexes.count > 0 ? "완료 후  ‘NEXT’ 버튼을 누르면 다음 문제로 넘어갑니다." : "문제를 듣고 문장을 완성하세요.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
    }
}

extension ALTSeniorListeningTestViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
//            _selectedIndexes[row] = nil
            _selectedIndexes.remove(at: row)
            
            let count = _selectedIndexes.count
            
            for i in 0 ..< count {
                let idx = count - 1 - i
                let item = _selectedIndexes[idx]
                
                if item != nil { break }
                
                _selectedIndexes.remove(at: idx)
            }
        } else {
            if let nilIdx = _selectedIndexes.firstIndex(of: nil) {
                _selectedIndexes[nilIdx] = index
            } else {
                _selectedIndexes.append(index)
            }
        }
        
        _buttonNext.isEnabled = _selectedIndexes.count > 0 && _isPlaying == false
        
        _guideString = _buttonNext.isEnabled ? "\'NEXT\' 버튼을 누르면 다음 문제로 넘어갑니다." : "문제를 듣고 문장을 완성하세요.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
        
        _isSkippable = !_isPlaying
        
        
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
            }
        }
        
        _labelNoSelect?.isHidden = _selectedIndexes.count > 0
        
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
        return UIDevice.current.userInterfaceIdiom == .pad ? 1 : 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var numberOfItems = 1
            
            if section == 1 {
                numberOfItems = _selectedIndexes.count
            } else if section == 3 {
                numberOfItems = _collectionData.count
            }
            
            return numberOfItems
        }
        
        return collectionView == _collectionView ? _collectionData.count : _selectedIndexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var inset = UIEdgeInsets.zero
            
            if section == 1 {
                inset = ALTSeniorListeningTestAnswerCollectionViewCell.sectionInsets
            } else if section == 3 {
                inset = ALTSeniorListeningTestSelectableCollectionViewCell.sectionInsets
            }
            
            return inset
        }
        
        var inset = UIEdgeInsets.zero
        
        if collectionView == _collectionViewPadLeft {
            inset = ALTSeniorListeningTestAnswerCollectionViewCell.sectionInsets
        } else if collectionView == _collectionView {
            inset = ALTSeniorListeningTestSelectableCollectionViewCell.sectionInsets
        }
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var lineSpacing = CGFloat(0)
            
            if section == 1 {
                lineSpacing = ALTSeniorListeningTestAnswerCollectionViewCell.lineSpacing
            } else if section == 3 {
                lineSpacing = ALTSeniorListeningTestSelectableCollectionViewCell.lineSpacing
            }
            
            return lineSpacing
        }
        
        var lineSpacing = CGFloat(0)
        
        if collectionView == _collectionViewPadLeft {
            lineSpacing = ALTSeniorListeningTestAnswerCollectionViewCell.lineSpacing
        } else if collectionView == _collectionView {
            lineSpacing = ALTSeniorListeningTestSelectableCollectionViewCell.lineSpacing
        }
        
        return lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var interSpacing = CGFloat(0)
            
            if section == 1 {
                interSpacing = ALTSeniorListeningTestAnswerCollectionViewCell.interItemSpacing
            } else if section == 3 {
                interSpacing = ALTSeniorListeningTestSelectableCollectionViewCell.interItemSpacing
            }
            
            return interSpacing
        }
        
        var interSpacing = CGFloat(0)
        
        if collectionView == _collectionViewPadLeft {
            interSpacing = ALTSeniorListeningTestAnswerCollectionViewCell.interItemSpacing
        } else if collectionView == _collectionView {
            interSpacing = ALTSeniorListeningTestSelectableCollectionViewCell.interItemSpacing
        }
        
        return interSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            var itemSize = CGSize.zero
            
            if indexPath.section == 0 {
                itemSize = ALTSeniorListeningTestHeaderCollectionViewCell.itemSize
            } else if indexPath.section == 1 {
                if indexPath.row < _selectedIndexes.count, let index = _selectedIndexes[indexPath.row] {
                    return ALTSeniorListeningTestAnswerCollectionViewCell.itemSize(with: _collectionData[index])
                } else {
                    return ALTSeniorListeningTestAnswerCollectionViewCell.itemSize()
                }
            } else if indexPath.section == 2 {
                itemSize.width = UIScreen.main.bounds.size.width
                itemSize.height = 40.optimized
            } else if indexPath.section == 3 {
                itemSize = ALTSeniorListeningTestSelectableCollectionViewCell.itemSize(with: _collectionData[indexPath.row])
            }
            
            return itemSize
        }
        
        
        var itemSize = CGSize.zero
        
        if collectionView == _collectionView {
            itemSize = ALTSeniorListeningTestSelectableCollectionViewCell.itemSize(with: _collectionData[indexPath.row])
        } else if collectionView == _collectionViewPadLeft {
            if indexPath.row < _selectedIndexes.count, let index = _selectedIndexes[indexPath.row] {
                itemSize = ALTSeniorListeningTestAnswerCollectionViewCell.itemSize(with: _collectionData[index])
            } else {
                itemSize = ALTSeniorListeningTestAnswerCollectionViewCell.itemSize()
            }
        }
        
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            if indexPath.section == 0, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorListeningTestHeaderCollectionViewCell", for: indexPath) as? ALTSeniorListeningTestHeaderCollectionViewCell {
                cell.addTarget(self, action: #selector(self.play(_:)), for: .touchUpInside)
                cell.remainingPlayCount = _remainingPlayCount
                cell.isButtonEnabled = ((_player?.rate ?? 0) == 0 && _remainingPlayCount > 0)
                return cell
            } else if indexPath.section == 1, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorListeningTestAnswerCollectionViewCell", for: indexPath) as? ALTSeniorListeningTestAnswerCollectionViewCell {
                if indexPath.row < _selectedIndexes.count, let index = _selectedIndexes[indexPath.row] {
                    cell.text = _collectionData[index]
                } else {
                    cell.text = nil
                }
                return cell
            } else if indexPath.section == 3, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorListeningTestSelectableCollectionViewCell", for: indexPath) as? ALTSeniorListeningTestSelectableCollectionViewCell {
                let title =  _collectionData[indexPath.row]
                cell.title = title
                cell.isSelected = _selectedIndexes.firstIndex(of: indexPath.row) != nil
                return cell
            }
            
            return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        }
        
        if collectionView == _collectionView, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorListeningTestSelectableCollectionViewCell", for: indexPath) as? ALTSeniorListeningTestSelectableCollectionViewCell {
            let title =  _collectionData[indexPath.row]
            cell.title = title
            cell.isSelected = _selectedIndexes.firstIndex(of: indexPath.row) != nil
            return cell
        } else if collectionView == _collectionViewPadLeft, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTSeniorListeningTestAnswerCollectionViewCell", for: indexPath) as? ALTSeniorListeningTestAnswerCollectionViewCell {
            if indexPath.row < _selectedIndexes.count, let index = _selectedIndexes[indexPath.row] {
                cell.text = _collectionData[index]
            } else {
                cell.text = nil
            }
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
