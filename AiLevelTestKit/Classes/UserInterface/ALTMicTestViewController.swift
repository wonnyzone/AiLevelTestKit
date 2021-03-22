//
//  ALTMicTestViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/26.
//

import UIKit
import AVFoundation

import OCWaveView

class ALTMicTestViewController: ALTBaseViewController {
    lazy private var _barButtonItemClose: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "img_close_blk", in:Bundle(for: type(of: self)), compatibleWith:nil)?.resize(maxWidth: 32.optimized).withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.pressedNavigationItem(_:)))
        return item
    }()
    
    internal let _buttonNext = UIButton()
    internal let _buttonSkip = UIButton()
    internal let _labelGuide = UILabel()
    
    internal var _isSkippable: Bool = true {
        didSet {
            _buttonSkip.isEnabled = _isSkippable
            _buttonSkip.layer.borderWidth = _isSkippable ? 1 : 0
            _buttonSkip.layer.borderColor = (_isSkippable ? ColourKit.Code.HexAAAAAA : .clear).cgColor
        }
    }
    
    internal let _buttonPlay = UIButton()
    internal let _labelButtonTitle = UILabel()
    internal let _imageViewPlay = UIImageView()
    
    internal let _waveView = WaveView()
    
    internal let _labelResult = UILabel()
    
    internal let _buttonRecord = UIButton()
    internal var _labelRecordCount: UILabel?            // iPad
    
    internal var _answer: String?
    
    internal var _guideString: String? {
        didSet {
            guard (_guideString ?? "").count > 0 else {
                if UIDevice.current.userInterfaceIdiom != .pad {
                    _labelGuide.superview?.isHidden = true
                }
                return
            }
            
            _labelGuide.superview?.isHidden = false
            _labelGuide.text = _guideString
            self.view.layoutIfNeeded()
        }
    }
    
    internal var _remainingPlay: Int = 2 {
        didSet {
            let attributedString = NSMutableAttributedString()
            
            let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 18 : 13.optimized
            
            let highAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex000000, font: UIFont.systemFont(ofSize: fontSize, weight: .semibold)).attributes
            let norAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex000000, font: UIFont.systemFont(ofSize: fontSize, weight: .regular)).attributes
            
            attributedString.append(NSAttributedString(string: "문제 듣기", attributes: highAttr))
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                attributedString.append(NSAttributedString(string:" (", attributes: norAttr))
                attributedString.append(NSAttributedString(string:"\(_remainingPlay)번", attributes: highAttr))
                attributedString.append(NSAttributedString(string:"의 듣기가 남았습니다.)", attributes: norAttr))
            } else {
                attributedString.append(NSAttributedString(string:"\n\(_remainingPlay)번의 듣기가 남았습니다.", attributes: norAttr))
            }
                
            _labelButtonTitle.attributedText = attributedString
            
            self.view.layoutIfNeeded()
        }
    }
    internal var _initiallyStarted = true
    
    internal var _remainingRecord = 3 {
        didSet {
            let bold = "\(_remainingRecord)회"
            var string = String(format: (UIDevice.current.userInterfaceIdiom == .pad ? "%@의 녹음 기회가 남았습니다." : "%@의 녹음\n기회가 남았습니다."), arguments: [bold])
            
            if _answer != nil {
                string = "'NEXT' 버튼을 누르면 다음 문제로 넘어갑니다."
            }
            
            guard UIDevice.current.userInterfaceIdiom == .pad else {
                _guideString = string
                return
            }
            
            var attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Hex888888, font: UIFont.systemFont(ofSize: 18, weight: .regular)).attributes
            
            let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
            if let range = string.nsRange(of: bold) {
                attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Hex000000, font: UIFont.systemFont(ofSize: 18, weight: .regular)).attributes
                attributedString.addAttributes(attributes, range: range)
            }
            
            _labelRecordCount?.attributedText = attributedString
        }
    }
    
    internal var _player: AVPlayer?
    
    internal var _isButtonEnabled: Bool = true {
        didSet {
            _imageViewPlay.image = _isButtonEnabled ? UIImage(named: "img_playOn", in:Bundle(for: type(of: self)), compatibleWith:nil) : UIImage(named: "img_playOff", in:Bundle(for: type(of: self)), compatibleWith:nil)
            _buttonPlay.isEnabled = _isButtonEnabled
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "마이크테스트"
        
        let item = AVPlayerItem(url: URL(string: "http://aileveltest.com/plugin/data/voice/ko_en_mictest.mp3")!)
        _player = AVPlayer(playerItem: item)
        
        var insets = ALLTSeniorTestNavigationController.additionalSafeAreaInsets
        insets.top = 0
        self.additionalSafeAreaInsets = insets
        
        var backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.HexFFFFFF
        backView.clipsToBounds = false
        self.view.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        var containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: ALLTSeniorTestNavigationController.additionalSafeAreaInsets.bottom).isActive = true
        
        _buttonSkip.translatesAutoresizingMaskIntoConstraints = false
        _buttonSkip.layer.cornerRadius = 32.optimized
        _buttonSkip.clipsToBounds = true
        _buttonSkip.setTitle("SKIP", for: .normal)
        _buttonSkip.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonSkip.setTitleColor(ColourKit.Code.HexAAAAAA, for: .normal)
        _buttonSkip.setTitleColor(.white, for: .disabled)
        _buttonSkip.titleLabel?.font = UIFont.systemFont(ofSize: 16.optimized, weight: .regular)
        _buttonSkip.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _isSkippable = false
        _buttonSkip.isHidden = true
        containerView.addSubview(_buttonSkip)
        
        _buttonSkip.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        _buttonSkip.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        _buttonSkip.widthAnchor.constraint(equalToConstant: 64.optimized).isActive = true
        _buttonSkip.heightAnchor.constraint(equalToConstant: 64.optimized).isActive = true
        
        _buttonNext.translatesAutoresizingMaskIntoConstraints = false
        _buttonNext.layer.cornerRadius = 32
        _buttonNext.clipsToBounds = true
        _buttonNext.setTitle("NEXT", for: .normal)
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex000000), for: .normal)
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonNext.setTitleColor(ColourKit.Code.HexFFFFFF, for: .normal)
        _buttonNext.setTitleColor(.white, for: .disabled)
        _buttonNext.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        _buttonNext.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonNext.isEnabled = false
        containerView.addSubview(_buttonNext)
        
        _buttonNext.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        _buttonNext.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        _buttonNext.widthAnchor.constraint(equalToConstant: 64).isActive = true
        _buttonNext.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        _labelGuide.translatesAutoresizingMaskIntoConstraints = false
        _labelGuide.numberOfLines = 0
        containerView.addSubview(_labelGuide)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.view.backgroundColor = ColourKit.Code.HexF0F0F0
            
            _labelGuide.textColor = ColourKit.Code.Hex222222
            _labelGuide.font = UIFont.systemFont(ofSize: 18.optimized, weight: .regular)
            _labelGuide.textAlignment = .center
            containerView.addSubview(_labelGuide)

            _labelGuide.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
            _labelGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
            _labelGuide.leadingAnchor.constraint(equalTo: _buttonSkip.trailingAnchor, constant: 10).isActive = true
            _labelGuide.trailingAnchor.constraint(equalTo: _buttonNext.leadingAnchor, constant: -10).isActive = true
            _labelGuide.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.size.width - 88.optimized).isActive = true
            
            let leftView = UIView()
            leftView.translatesAutoresizingMaskIntoConstraints = false
            leftView.clipsToBounds = true
            leftView.backgroundColor = ColourKit.Code.HexFFFFFF
            leftView.layer.cornerRadius = 10
            self.view.addSubview(leftView)
            
            leftView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26).isActive = true
            leftView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -26).isActive = true
            leftView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 26).isActive = true
            leftView.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -6).isActive = true
            
            _waveView.translatesAutoresizingMaskIntoConstraints = false
            _waveView.value = 0
            leftView.addSubview(_waveView)
            
            _waveView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
            _waveView.leadingAnchor.constraint(equalTo: leftView.leadingAnchor).isActive = true
            _waveView.trailingAnchor.constraint(equalTo: leftView.trailingAnchor).isActive = true
            _waveView.heightAnchor.constraint(equalToConstant: 260.optimized).isActive = true
            
            _labelResult.translatesAutoresizingMaskIntoConstraints = false
            _labelResult.text = "'녹음' 버튼을 누른 후\n\"Hello\"라고 말해주세요."
            _labelResult.textAlignment = .center
            _labelResult.textColor = ColourKit.Code.HexAAAAAA
            _labelResult.font = UIFont.systemFont(ofSize: 24.optimized, weight: .regular)
            _labelResult.numberOfLines = 0
            leftView.addSubview(_labelResult)
            
            _labelResult.topAnchor.constraint(equalTo: _waveView.topAnchor).isActive = true
            _labelResult.bottomAnchor.constraint(equalTo: _waveView.bottomAnchor).isActive = true
            _labelResult.leadingAnchor.constraint(equalTo: _waveView.leadingAnchor, constant: 20.optimized).isActive = true
            _labelResult.trailingAnchor.constraint(equalTo: _waveView.trailingAnchor, constant: -20.optimized).isActive = true
            
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
            
            _buttonPlay.translatesAutoresizingMaskIntoConstraints = false
            _buttonPlay.addTarget(self, action: #selector(self.play(_:)), for: .touchUpInside)
            rightView.addSubview(_buttonPlay)
            
            _buttonPlay.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 20).isActive = true
            _buttonPlay.centerYAnchor.constraint(equalTo: rightView.centerYAnchor).isActive = true
            _buttonPlay.widthAnchor.constraint(equalToConstant: 68).isActive = true
            _buttonPlay.heightAnchor.constraint(equalToConstant: 68).isActive = true
            
            let bundle = Bundle(for: AiLevelTestKit.self)
            
            _imageViewPlay.translatesAutoresizingMaskIntoConstraints = false
            _imageViewPlay.isUserInteractionEnabled = false
            _imageViewPlay.image = UIImage(named: "img_playOn", in:Bundle(for: type(of: self)), compatibleWith:nil)
            _buttonPlay.addSubview(_imageViewPlay)
            
            _imageViewPlay.topAnchor.constraint(equalTo: _buttonPlay.topAnchor).isActive = true
            _imageViewPlay.bottomAnchor.constraint(equalTo: _buttonPlay.bottomAnchor).isActive = true
            _imageViewPlay.leadingAnchor.constraint(equalTo: _buttonPlay.leadingAnchor).isActive = true
            _imageViewPlay.widthAnchor.constraint(equalTo: _imageViewPlay.heightAnchor).isActive = true
            
            _labelButtonTitle.translatesAutoresizingMaskIntoConstraints = false
            _labelButtonTitle.isUserInteractionEnabled = false
            _labelButtonTitle.numberOfLines = 2
            rightView.addSubview(_labelButtonTitle)
            
            _labelButtonTitle.topAnchor.constraint(equalTo: _buttonPlay.topAnchor).isActive = true
            _labelButtonTitle.bottomAnchor.constraint(equalTo: _buttonPlay.bottomAnchor).isActive = true
            _labelButtonTitle.leadingAnchor.constraint(equalTo: _buttonPlay.trailingAnchor, constant: 15).isActive = true
            _labelButtonTitle.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -20).isActive = true
            
            let bottomAnchor = rightView.bottomAnchor
            
            rightView = UIView()
            rightView.translatesAutoresizingMaskIntoConstraints = false
            rightView.clipsToBounds = true
            rightView.backgroundColor = ColourKit.Code.HexD0D0D0
            rightView.layer.cornerRadius = 10
            self.view.addSubview(rightView)
            
            rightView.topAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
            rightView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -26).isActive = true
            rightView.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 6).isActive = true
            rightView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -26).isActive = true
            
            containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            rightView.addSubview(containerView)
            
            containerView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor).isActive = true
            
            _buttonRecord.translatesAutoresizingMaskIntoConstraints = false
            _buttonRecord.layer.cornerRadius = 60
            _buttonRecord.clipsToBounds = true
            _buttonRecord.setTitle("녹음", for: .normal)
            _buttonRecord.setTitle("종료", for: .selected)
            _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: AiLevelTestKit.shared.themeColour), for: .normal)
            _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex000000), for: .selected)
            _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
            _buttonRecord.setTitleColor(.white, for: .normal)
            _buttonRecord.setTitleColor(ColourKit.Code.HexFFFFFF, for: .selected)
            _buttonRecord.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
            _buttonRecord.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
            containerView.addSubview(_buttonRecord)
            
            _buttonRecord.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            _buttonRecord.centerXAnchor.constraint(equalTo: rightView.centerXAnchor).isActive = true
            _buttonRecord.widthAnchor.constraint(equalToConstant: 120).isActive = true
            _buttonRecord.heightAnchor.constraint(equalToConstant: 120).isActive = true
            
            _labelRecordCount = UILabel()
            _labelRecordCount?.translatesAutoresizingMaskIntoConstraints = false
            _labelRecordCount?.textAlignment = .center
            _labelRecordCount?.numberOfLines = 0
            containerView.addSubview(_labelRecordCount!)
            
            _labelRecordCount?.topAnchor.constraint(equalTo: _buttonRecord.bottomAnchor, constant: 20).isActive = true
            _labelRecordCount?.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
            _labelRecordCount?.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
            _labelRecordCount?.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        } else {
            _labelGuide.textColor = ColourKit.Code.HexFFFFFF
            _labelGuide.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
            
            containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = ColourKit.Code.Hex000000
            containerView.clipsToBounds = true
            self.view.addSubview(containerView)
            
            containerView.bottomAnchor.constraint(equalTo: backView.topAnchor, constant: -10.optimized).isActive = true
            containerView.centerXAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
            containerView.heightAnchor.constraint(lessThanOrEqualToConstant: 50.optimized).isActive = true
            
            containerView.addSubview(_labelGuide)

            _labelGuide.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.optimized).isActive = true
            _labelGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.optimized).isActive = true
            _labelGuide.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24.optimized).isActive = true
            _labelGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24.optimized).isActive = true
            _labelGuide.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.size.width - 88.optimized).isActive = true
            
            _buttonPlay.translatesAutoresizingMaskIntoConstraints = false
            _buttonPlay.addTarget(self, action: #selector(self.play(_:)), for: .touchUpInside)
            self.view.addSubview(_buttonPlay)
            
            _buttonPlay.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40.optimized).isActive = true
            _buttonPlay.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.optimized).isActive = true
            _buttonPlay.heightAnchor.constraint(equalToConstant: 44.optimized).isActive = true
            
            backView = UIView()
            backView.translatesAutoresizingMaskIntoConstraints = false
            backView.isUserInteractionEnabled = false
            backView.backgroundColor = ColourKit.Code.HexFFFFFF
            backView.clipsToBounds = true
            backView.layer.cornerRadius = 22.optimized
            _buttonPlay.addSubview(backView)
            
            backView.topAnchor.constraint(equalTo: _buttonPlay.topAnchor).isActive = true
            backView.bottomAnchor.constraint(equalTo: _buttonPlay.bottomAnchor).isActive = true
            backView.leadingAnchor.constraint(equalTo: _buttonPlay.leadingAnchor).isActive = true
            backView.trailingAnchor.constraint(equalTo: _buttonPlay.trailingAnchor).isActive = true
            
            let bundle = Bundle(for: AiLevelTestKit.self)
            
            _imageViewPlay.translatesAutoresizingMaskIntoConstraints = false
            _imageViewPlay.isUserInteractionEnabled = false
            _imageViewPlay.image = UIImage(named: "img_playOn", in:Bundle(for: type(of: self)), compatibleWith:nil)
            _buttonPlay.addSubview(_imageViewPlay)
            
            _imageViewPlay.topAnchor.constraint(equalTo: _buttonPlay.topAnchor).isActive = true
            _imageViewPlay.bottomAnchor.constraint(equalTo: _buttonPlay.bottomAnchor).isActive = true
            _imageViewPlay.leadingAnchor.constraint(equalTo: _buttonPlay.leadingAnchor).isActive = true
            _imageViewPlay.widthAnchor.constraint(equalTo: _imageViewPlay.heightAnchor).isActive = true
            
            _labelButtonTitle.translatesAutoresizingMaskIntoConstraints = false
            _labelButtonTitle.isUserInteractionEnabled = false
            _labelButtonTitle.numberOfLines = 2
            _buttonPlay.addSubview(_labelButtonTitle)
            
            _labelButtonTitle.topAnchor.constraint(equalTo: _buttonPlay.topAnchor).isActive = true
            _labelButtonTitle.bottomAnchor.constraint(equalTo: _buttonPlay.bottomAnchor).isActive = true
            _labelButtonTitle.leadingAnchor.constraint(equalTo: _imageViewPlay.trailingAnchor, constant: 9.optimized).isActive = true
            _labelButtonTitle.trailingAnchor.constraint(equalTo: _buttonPlay.trailingAnchor, constant: -21.optimized).isActive = true
            
            _waveView.translatesAutoresizingMaskIntoConstraints = false
            _waveView.value = 0
            self.view.addSubview(_waveView)
            
            _waveView.topAnchor.constraint(equalTo: _buttonPlay.bottomAnchor, constant: 40.optimized).isActive = true
            _waveView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            _waveView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            _waveView.heightAnchor.constraint(equalToConstant: 260.optimized).isActive = true
            
            _labelResult.translatesAutoresizingMaskIntoConstraints = false
            _labelResult.text = "‘녹음’ 버튼을 누른 후\n“Hello”라고 말해주세요."
            _labelResult.textColor = ColourKit.Code.Hex8A8A8A
            _labelResult.font = UIFont.systemFont(ofSize: 24.optimized, weight: .regular)
            _labelResult.numberOfLines = 0
            self.view.addSubview(_labelResult)
            
            _labelResult.topAnchor.constraint(equalTo: _waveView.topAnchor).isActive = true
            _labelResult.bottomAnchor.constraint(equalTo: _waveView.bottomAnchor).isActive = true
            _labelResult.leadingAnchor.constraint(equalTo: _waveView.leadingAnchor, constant: 20.optimized).isActive = true
            _labelResult.trailingAnchor.constraint(equalTo: _waveView.trailingAnchor, constant: -20.optimized).isActive = true
            
            _buttonRecord.translatesAutoresizingMaskIntoConstraints = false
            _buttonRecord.layer.cornerRadius = 32
            _buttonRecord.clipsToBounds = true
            _buttonRecord.setTitle("녹음", for: .normal)
            _buttonRecord.setTitle("종료", for: .selected)
            _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: AiLevelTestKit.shared.themeColour), for: .normal)
            _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex000000), for: .selected)
            _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
            _buttonRecord.setTitleColor(.white, for: .normal)
            _buttonRecord.setTitleColor(ColourKit.Code.HexFFFFFF, for: .selected)
            _buttonRecord.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            _buttonRecord.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
            _buttonNext.superview!.addSubview(_buttonRecord)
            
            _buttonRecord.centerYAnchor.constraint(equalTo: _buttonNext.superview!.centerYAnchor).isActive = true
            _buttonRecord.centerXAnchor.constraint(equalTo: _buttonNext.superview!.centerXAnchor).isActive = true
            _buttonRecord.widthAnchor.constraint(equalToConstant: 64).isActive = true
            _buttonRecord.heightAnchor.constraint(equalToConstant: 64).isActive = true
        }
        
        _remainingRecord = 3
        _remainingPlay = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ALTSpeechToTextManager.manager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.navigationItem.leftBarButtonItems = []
        self.navigationItem.rightBarButtonItems = [_barButtonItemClose]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex3E3A39), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = ColourKit.Code.Hex3E3A39
        
        let label = UILabel()
        label.text = self.title
        label.textColor = ColourKit.Code.HexFFFFFF
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.sizeToFit()
        self.navigationItem.titleView = label
        
        self.view.bringSubview(toFront: _labelGuide.superview!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ALTSpeechToTextManager.manager.stop()
        
        _player?.pause()
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard _initiallyStarted else { return }
        
        _isButtonEnabled = false
        _player?.play()
        _buttonRecord.isEnabled = false
        
        _guideString = "음성을 잘 들어주세요.\n음성이 들리지 않을 경우 미디어 음량을 확인해주세요."
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let backView = _labelGuide.superview {
            backView.layer.cornerRadius = backView.bounds.size.height / 2
        }
    }
    
    override func pressedNavigationItem(_ item: UIBarButtonItem) {
        super.pressedNavigationItem(item)
        
        switch item {
        case _barButtonItemClose:
            self.dismiss(animated: true)
            break
            
        default:
            break
        }
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        switch button {
        case _buttonRecord:
            _player?.pause()
            
            if ALTSpeechToTextManager.manager.isRecording {
                ALTSpeechToTextManager.manager.stop()
                _isButtonEnabled = _remainingPlay > 0
                _buttonNext.isEnabled = (_answer ?? "").count > 0 || _remainingRecord == 0
                _isSkippable = _answer != nil || _remainingRecord == 0
            } else {
                ALTSpeechToTextManager.manager.start(languageCode: LevelTestManager.manager.examInfo?.testLanguage ?? "en")
                _isButtonEnabled = false
                _buttonNext.isEnabled = false
                _isSkippable = false
                
                _buttonRecord.isEnabled = false
                _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {[weak self] (timer) in
                    self?._buttonRecord.isEnabled = true
                })
            }
            
            break
            
        case _buttonNext, _buttonSkip:
            QIndicatorViewManager.shared.showIndicatorView {(complete) in
                LevelTestManager.manager.startTest {[weak self] (testSrl, errMessage) in
                    QIndicatorViewManager.shared.hideIndicatorView()
                    
                    guard testSrl != nil, errMessage == nil else {
                        QIndicatorViewManager.shared.hideIndicatorView()
                        let alertController = UIAlertController(title: errMessage, message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                        self?.present(alertController, animated: true, completion: nil)
                        return
                    }
                    LevelTestManager.manager.getQuizViewController(isContinue: false) { (viewController, errMessage) in
                        QIndicatorViewManager.shared.hideIndicatorView()
                        
                        guard viewController != nil else {
                            let alertController = UIAlertController(title: errMessage ?? "알 수 없는 오류입니다.", message: nil, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                            self?.present(alertController, animated: true, completion: nil)
                            return
                        }
                        
                        self?.navigationController?.setViewControllers([viewController!], animated: true)
                    }
                }
            }
            break
            
        default: break
        }
    }
    
    @objc private func play(_ button: UIButton) {
        guard _remainingPlay > 0, _player != nil else {
            _initiallyStarted = false
            return
        }
        
        _guideString = "음성을 잘 들어주세요.\n음성이 들리지 않을 경우 미디어 음량을 확인해주세요."
        
        _isButtonEnabled = false
        
        _buttonRecord.isEnabled = false
        _buttonNext.isEnabled = false
        _isSkippable = false
        
        _player?.seek(to: kCMTimeZero)
        _player?.play()
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        if _initiallyStarted == false {
            _remainingPlay -= 1
        }
        
        _guideString = _answer != nil ? "'NEXT' 버튼을 누르면 다음 문제로 넘어갑니다." : "녹음은 최대 3회까지 가능합니다."
        
        _initiallyStarted = false
        
        _buttonRecord.isEnabled = _remainingRecord > 0
        _buttonNext.isEnabled = (_answer ?? "").count > 0 || _remainingRecord == 0
        
        _isButtonEnabled = _remainingPlay > 0
        _isSkippable = _answer != nil || _remainingRecord == 0
    }
}

extension ALTMicTestViewController: ALTSpeechToTextManagerDelegate {
    func speechToTextManager(didStart manager: ALTSpeechToTextManager) {
        _labelResult.isHidden = true
        _waveView.isHidden = false
        
        _buttonRecord.isSelected = true
        _isSkippable = false
        
        _guideString = "마이크 가까이에서 녹음을 진행해주세요."
        
        let attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Hex888888, font: UIFont.systemFont(ofSize: 18, weight: .regular)).attributes
        let attributedString = NSAttributedString(string: "자동 종료가 안 될 경우\n‘종료’ 버튼을 눌러주세요.", attributes: attributes)
        _labelRecordCount?.attributedText = attributedString
    }
    
    func speechToTextManager(didStop manager: ALTSpeechToTextManager, withResult text: String?) {
        _labelResult.text = text ?? "인식된 문장이 없습니다."
        _labelResult.isHidden = false
        _waveView.isHidden = true
        
        _buttonRecord.isSelected = false
        
        _answer = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        _isButtonEnabled = _remainingPlay > 0
        _buttonNext.isEnabled = (_answer ?? "").count > 0 || _remainingRecord == 0
        _isSkippable = _answer != nil || _remainingRecord == 0
        
        let remainingRecord = _remainingRecord
        
        guard text != nil else {
            _remainingRecord = remainingRecord             // 텍스트 변경
            return
        }
        
        _remainingRecord = remainingRecord - 1
        _buttonRecord.isEnabled = _remainingRecord > 0
        _isSkippable = _answer != nil || _remainingRecord == 0
    }
    
    func speechToTextManager(_ manager: ALTSpeechToTextManager, didRecognizeAudio power: CGFloat) {
        _waveView.value = power
    }
    
    func speechToTextManager(_ manager: ALTSpeechToTextManager?, didRecognizeText text: String?) {
        
    }
}
