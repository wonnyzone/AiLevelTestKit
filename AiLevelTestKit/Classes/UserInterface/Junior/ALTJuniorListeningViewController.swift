//
//  ALTJuniorListeningViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/25.
//

import UIKit

import AVFoundation

class ALTJuniorListeningViewController: ALTJuniorTestBaseViewController {
    internal var _collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    internal var _collectionData = [ALTLevelTest.Quiz.Answer]()
    
    internal let _buttonPlay = UIButton()
    
    internal var _remainingPlay: Int = 3 {
        didSet {
            let attributes = QTextAttributes(withForegroundColour: .white, font: UIFont.systemFont(ofSize: 18.optimizedWithHeight, weight: .semibold))
            
            let bold = "\(_remainingPlay)회"
            let string = "문제듣기 \(bold)가능"
            
            let attributedString = NSMutableAttributedString(string: string, attributes: attributes.attributes)
            if let range = string.nsRange(of: bold) {
                attributes.foregroundColour = #colorLiteral(red: 0.9137254902, green: 0.968627451, blue: 0.2117647059, alpha: 1)
                attributedString.addAttributes(attributes.attributes, range: range)
            }
            _buttonPlay.setAttributedTitle(attributedString, for: .normal)
            
            self.view.layoutIfNeeded()
        }
    }
    internal var _initiallyStarted = true
    
    internal var _player: AVPlayer?
    
    internal var _selectedIndex: Int?
    
    
    override var canGoNext: Bool {
        return _answer != nil
    }
    
    internal var _isPlayable: Bool = true
    internal var _isPlaying = false
    
    internal var _showImage: Bool {
        get {
            return testData.quiz?.form == "C"
        }
    }
    
    internal var _cellWidth: CGFloat = UIScreen.main.bounds.size.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let examSrl = testData.testInfo?.examSrl ?? 0
        let level = testData.quiz?.level ?? 0
        let folder = testData.quiz?.folder ?? 0
        let quizOrder = testData.quiz?.quizOrder ?? 0
        
        let assetUrl = RequestUrl.AWS +  "/voice/leveltest/\(examSrl)/Listen2/level\(level)-\(folder)/\(quizOrder).mp3"
        
        let item = AVPlayerItem(url: URL(string: assetUrl)!)
        _player = AVPlayer(playerItem: item)
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.backgroundColor = .clear
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "defaultCell")
        _collectionView.register(ALTJuniorListeningHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ALTJuniorListeningHeaderReusableView")
        _collectionView.register(ALTJuniorListeningFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "ALTJuniorListeningFooterReusableView")
        _collectionView.register(ALTJuniorListeningImageCollectionViewCell.self, forCellWithReuseIdentifier: "ALTJuniorListeningImageCollectionViewCell")
        _collectionView.register(ALTJuniorListeningTextCollectionViewCell.self, forCellWithReuseIdentifier: "ALTJuniorListeningTextCollectionViewCell")
        self.view.addSubview(_collectionView)
        
        _collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        _collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
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
        _isPlayable = _remainingPlay > 0
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard _initiallyStarted else { return }
        
        _player?.play()
        
        _isSkippable = false
        
        if _player != nil {
            _isPlaying = true
            _isPlayable = false
        }
        
        _collectionView.reloadData()
    }
    
    private func reloadData() {
        _collectionData.removeAll()
        
        let array = testData.quiz?.answerList ?? []
        
        for i in 0 ..< array.count {
            _collectionData.append(array[i])
            
            guard UIDevice.current.userInterfaceIdiom == .pad else { continue }
            
            let label = UILabel()
            label.text = array[i].answer
            label.font = UIFont.systemFont(ofSize: 24.optimizedWithHeight, weight: .bold)
            label.sizeToFit()
            
            let width = label.frame.size.width + 38.optimized + 84.optimized
            
            if i == 0 {
                _cellWidth = width
            } else {
                _cellWidth = max(_cellWidth, width)
            }
        }
        
        _collectionView.reloadData()
    }
    
    @objc private func play(_ button: UIButton) {
        _buttonNext.isEnabled = false
        _isSkippable = false

        _player?.seek(to: .zero)
        _player?.play()

        if _player != nil {
            _isPlaying = true
            _isPlayable = false
            _guideString = "음성을 잘 들어주세요."
        }
        
        _collectionView.reloadData()
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        _remainingPlay -= 1

        _isPlaying = false
        _isPlayable = _remainingPlay > 0

        _initiallyStarted = false

//        _buttonNext.isEnabled = _selectedIndexes.count > 0
        _isSkippable = true

        _collectionView.reloadData()

//        _guideString = _selectedIndexes.count > 0 ? "완료 후  ‘NEXT’ 버튼을 누르면 다음 문제로 넘어갑니다." : "문제를 듣고 문장을 완성하세요.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
    }
}

extension ALTJuniorListeningViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard _isPlaying == false else {
            collectionView.reloadData()
            return
        }
        
        _answer = _collectionData[indexPath.row].answer
        _selectedIndex = indexPath.row
        
        _buttonNext.isEnabled = _answer != nil
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return ALTJuniorListeningHeaderReusableView.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return _footerView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader, let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ALTJuniorListeningHeaderReusableView", for: indexPath) as? ALTJuniorListeningHeaderReusableView {
            reusableView.question = testData.quiz?.quizDesc
            reusableView.isPlayable = _isPlayable
            reusableView.remainingCount = _remainingPlay
            reusableView.addTarget(self, action: #selector(self.play(_:)), for: .touchUpInside)
            return reusableView
        } else if kind == UICollectionView.elementKindSectionFooter, let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ALTJuniorListeningFooterReusableView", for: indexPath) as? ALTJuniorListeningFooterReusableView {
            for subview in reusableView.subviews {
                subview.removeFromSuperview()
            }
            reusableView.addSubview(_footerView)
            return reusableView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return _showImage ? UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16).optimizedWithHeight : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard _showImage else {
            var size = CGSize.zero
            size.width = UIScreen.main.bounds.size.width
            size.height = ALTJuniorListeningTextCollectionViewCell.height(with: _collectionData[indexPath.row].answer)
            return size
        }
        
        return ALTJuniorListeningImageCollectionViewCell.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if _showImage == false, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTJuniorListeningTextCollectionViewCell", for: indexPath) as? ALTJuniorListeningTextCollectionViewCell {
            cell.width = _cellWidth
            cell.numbering = indexPath.row + 1
            cell.answer = _collectionData[indexPath.row].answer
            cell.isSelected = indexPath.row == _selectedIndex
            return cell
        }
        
        if _showImage, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ALTJuniorListeningImageCollectionViewCell", for: indexPath) as? ALTJuniorListeningImageCollectionViewCell {
            cell.numbering = indexPath.row + 1
            cell.imageUrl = RequestUrl.AWS + "/image/leveltest/\(testData.testInfo?.examSrl ?? 0)/Listen2/\(_collectionData[indexPath.row].answer).png"
            cell.isSelected = indexPath.row == _selectedIndex
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath)
    }
}

class ALTJuniorListeningHeaderReusableView: UICollectionReusableView {
    class var itemSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIDevice.current.userInterfaceIdiom == .pad ? 222.optimizedWithHeight : 236.optimizedWithHeight)
    }
    
    var question: String? {
        didSet {
            _labelQuestion.text = question
        }
    }
    
    private let _labelQuestion = UILabel()
    private let _buttonPlay = UIButton()
    
    var remainingCount: Int = 0 {
        didSet {
            let attributes = QTextAttributes(withForegroundColour: .white, font: UIFont.systemFont(ofSize: 18.optimizedWithHeight, weight: .semibold))
            
            let bold = "\(remainingCount)회"
            let string = "문제듣기 \(bold)가능"
            
            let attributedString = NSMutableAttributedString(string: string, attributes: attributes.attributes)
            _buttonPlay.setAttributedTitle(attributedString, for: .disabled)
            if let range = string.nsRange(of: bold) {
                attributes.foregroundColour = #colorLiteral(red: 0.9137254902, green: 0.968627451, blue: 0.2117647059, alpha: 1)
                attributedString.addAttributes(attributes.attributes, range: range)
            }
            _buttonPlay.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    var isPlayable: Bool = true {
        didSet {
            _buttonPlay.isEnabled = isPlayable
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _buttonPlay.translatesAutoresizingMaskIntoConstraints = false
        _buttonPlay.clipsToBounds = true
        _buttonPlay.layer.cornerRadius = 8.optimized
        _buttonPlay.setBackgroundImage(UIImage.withSolid(colour: #colorLiteral(red: 0, green: 0.8235294118, blue: 0.7176470588, alpha: 1)), for: .normal)
        _buttonPlay.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .highlighted)
        _buttonPlay.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexAAAAAA), for: .disabled)
        _buttonPlay.setImage(UIImage(named: "img_volume")?.recolour(with: .white).resize(maxWidth: 21.optimized), for: .normal)
        _buttonPlay.setImage(UIImage(named: "img_volume")?.recolour(with: .white).resize(maxWidth: 21.optimized), for: .disabled)
        _buttonPlay.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5).optimized
        _buttonPlay.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0).optimized
        self.addSubview(_buttonPlay)
        
        _buttonPlay.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: UIDevice.current.userInterfaceIdiom == .pad ? -47.optimizedWithHeight : -50.optimizedWithHeight).isActive = true
        _buttonPlay.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 48.optimized).isActive = UIDevice.current.userInterfaceIdiom != .pad
        _buttonPlay.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -48.optimized).isActive = UIDevice.current.userInterfaceIdiom != .pad
        _buttonPlay.widthAnchor.constraint(equalToConstant: 280.optimized).isActive = UIDevice.current.userInterfaceIdiom == .pad
        _buttonPlay.heightAnchor.constraint(equalToConstant: 60.optimizedWithHeight).isActive = true
        
        _labelQuestion.translatesAutoresizingMaskIntoConstraints = false
        _labelQuestion.textColor = ColourKit.Code.Hex222222
        _labelQuestion.textAlignment = .center
        _labelQuestion.font = UIFont.systemFont(ofSize: 26.optimizedWithHeight, weight: .bold)
        _labelQuestion.numberOfLines = 0
        self.addSubview(_labelQuestion)
        
        _labelQuestion.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        _labelQuestion.bottomAnchor.constraint(equalTo: _buttonPlay.topAnchor).isActive = true
        _labelQuestion.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.optimized).isActive = true
        _labelQuestion.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16.optimized).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func addTarget(_ target: Any, action: Selector, for event: UIControl.Event) {
        _buttonPlay.addTarget(target, action: action, for: event)
    }
}

class ALTJuniorListeningFooterReusableView: UICollectionReusableView {}

class ALTJuniorListeningTextCollectionViewCell: UICollectionViewCell {
    class func height(with text: String) -> CGFloat {
        
        var frame = CGRect.zero
        frame.size.width = UIScreen.main.bounds.size.width - 75.optimized - 42.optimized
        
        let label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.text = text
        label.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 24.optimizedWithHeight : 20.optimizedWithHeight, weight: .semibold)
        label.sizeToFit()
        return label.bounds.size.height + 18.optimized
    }
    
    internal let _labelNumber = UILabel()
    internal let _labelAnswer = UILabel()
    
    internal let _imageViewCheck = UIImageView()
    
    var width: CGFloat = 0 {
        didSet {
            _constraintContentWidth.constant = width
            self.contentView.layoutIfNeeded()
        }
    }
    
    var numbering: Int = 0 {
        didSet {
            guard numbering > 0 else { return }
            
            _labelNumber.text = "\(numbering)"
        }
    }
    
    var answer: String? {
        didSet {
            _labelAnswer.text = answer
            self.contentView.layoutIfNeeded()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            _imageViewCheck.isHidden = !isSelected
        }
    }
    
    lazy private var _constraintContentWidth: NSLayoutConstraint = {
        return _labelAnswer.superview!.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.layer.cornerRadius = 9.optimized
        backView.layer.borderColor = ColourKit.Code.Hex222222.cgColor
        backView.layer.borderWidth = 1
        containerView.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12.optimized).isActive = true
        backView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 42.optimized).isActive = true
        backView.widthAnchor.constraint(equalToConstant: backView.layer.cornerRadius * 2).isActive = true
        backView.heightAnchor.constraint(equalToConstant: backView.layer.cornerRadius * 2).isActive = true
        
        _labelNumber.translatesAutoresizingMaskIntoConstraints = false
        _labelNumber.textAlignment = .center
        _labelNumber.textColor = ColourKit.Code.Hex222222
        _labelNumber.font = UIFont.systemFont(ofSize:  UIDevice.current.userInterfaceIdiom == .pad ? 20.optimizedWithHeight : 16.optimized, weight: .semibold)
        backView.addSubview(_labelNumber)
        
        _labelNumber.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _labelNumber.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _labelNumber.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        _labelNumber.trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
        
        _labelAnswer.translatesAutoresizingMaskIntoConstraints = false
        _labelAnswer.textColor = ColourKit.Code.Hex222222
        _labelAnswer.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 24.optimizedWithHeight : 20.optimizedWithHeight, weight: .semibold)
        _labelAnswer.numberOfLines = 2
        containerView.addSubview(_labelAnswer)
        
        _labelAnswer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 9.optimized).isActive = true
        _labelAnswer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -9.optimized).isActive = true
        _labelAnswer.leadingAnchor.constraint(equalTo: backView.trailingAnchor, constant: 15.optimized).isActive = true
        _labelAnswer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -42.optimized).isActive = true
        
        _imageViewCheck.translatesAutoresizingMaskIntoConstraints = false
        _imageViewCheck.image = UIImage(named: "img_check", in:Bundle(for: type(of: self)), compatibleWith:nil)
        _imageViewCheck.contentMode = .scaleAspectFit
        _imageViewCheck.isHidden = true
        containerView.addSubview(_imageViewCheck)
        
        _imageViewCheck.widthAnchor.constraint(equalToConstant: 30.optimizedWithHeight).isActive = true
        _imageViewCheck.heightAnchor.constraint(equalToConstant: 25.optimizedWithHeight).isActive = true
        _imageViewCheck.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        _imageViewCheck.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40.optimizedWithHeight).isActive = true
        
        _constraintContentWidth.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

class ALTJuniorListeningImageCollectionViewCell: UICollectionViewCell {
    class var itemSize: CGSize {
        get {
            var size = CGSize.zero
            size.width = ((UIScreen.main.bounds.size.width - 32.optimizedWithHeight) / (UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2)).rounded(.down)
            size.height = size.width * 181 / 187
            return size
        }
    }
    
    internal let _labelNumber = UILabel()
    internal let _imageViewContent = UIImageView()
    
    internal let _imageViewCheck = UIImageView()
    
    internal let _imageDownloader = QImageDownloader()
    
    var numbering: Int = 0 {
        didSet {
            guard numbering > 0 else { return }
            
            _labelNumber.text = "\(numbering)"
        }
    }
    
    var imageUrl: String? {
        didSet {
//            _imageViewContent.pin_setImage(from: URL(string: imageUrl ?? ""))
            _imageDownloader.request(imageUrl ?? "") {[weak self] (image) in
                DispatchQueue.main.async { [weak self] in
                    self?._imageViewContent.image = image
                }
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            _imageViewCheck.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = false
        self.contentView.addSubview(containerView)
        
        containerView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.layer.cornerRadius = 9.optimized
        backView.layer.borderColor = ColourKit.Code.Hex222222.cgColor
        backView.layer.borderWidth = 1
        containerView.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        backView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        backView.widthAnchor.constraint(equalToConstant: backView.layer.cornerRadius * 2).isActive = true
        backView.heightAnchor.constraint(equalToConstant: backView.layer.cornerRadius * 2).isActive = true
        
        _labelNumber.translatesAutoresizingMaskIntoConstraints = false
        _labelNumber.textAlignment = .center
        _labelNumber.textColor = ColourKit.Code.Hex222222
        _labelNumber.font = UIFont.systemFont(ofSize:  UIDevice.current.userInterfaceIdiom == .pad ? 20.optimizedWithHeight : 16.optimized, weight: .semibold)
        backView.addSubview(_labelNumber)
        
        _labelNumber.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _labelNumber.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _labelNumber.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        _labelNumber.trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
        
        _imageViewCheck.translatesAutoresizingMaskIntoConstraints = false
        _imageViewCheck.image = UIImage(named: "img_check", in:Bundle(for: type(of: self)), compatibleWith:nil)
        _imageViewCheck.contentMode = .scaleAspectFit
        _imageViewCheck.isHidden = true
        self.contentView.addSubview(_imageViewCheck)
        
        _imageViewCheck.widthAnchor.constraint(equalToConstant: 30.optimizedWithHeight).isActive = true
        _imageViewCheck.heightAnchor.constraint(equalToConstant: 25.optimizedWithHeight).isActive = true
        _imageViewCheck.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -3.optimizedWithHeight).isActive = true
        _imageViewCheck.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: -2.optimizedWithHeight).isActive = true
        
        _imageViewContent.translatesAutoresizingMaskIntoConstraints = false
        _imageViewContent.contentMode = .scaleAspectFit
        containerView.addSubview(_imageViewContent)
        
        _imageViewContent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.optimizedWithHeight).isActive = true
        _imageViewContent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16.optimizedWithHeight).isActive = true
        _imageViewContent.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 4.optimizedWithHeight).isActive = true
        _imageViewContent.heightAnchor.constraint(equalTo: _imageViewContent.widthAnchor).isActive = true
        _imageViewContent.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        self.contentView.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
