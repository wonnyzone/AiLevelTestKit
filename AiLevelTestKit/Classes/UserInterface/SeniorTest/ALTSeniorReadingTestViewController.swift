//
//  ALTSeniorReadingTestViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit
import AVFoundation

import OCWaveView

class ALTSeniorReadingTestViewController: ALLTSeniorTestBaseViewController {
    internal let _waveView = WaveView()
    
    internal let _buttonPlay = UIButton()
    internal let _labelButtonTitle = UILabel()
    internal let _imageViewPlay = UIImageView()
    
    internal let _labelNotice = UILabel()
    internal let _labelResult = UITextView()
    
    internal let _buttonRecord = UIButton()
    internal var _labelRecordCount: UILabel?            // iPad
    
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
            let string = String(format: (UIDevice.current.userInterfaceIdiom == .pad ? "%@의 녹음 기회가 남았습니다." : "%@의 녹음\n기회가 남았습니다."), arguments: [bold])
            
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
    
    internal var _isPlayable: Bool = true {
        didSet {
            _imageViewPlay.image = _isPlayable ? UIImage(named: "img_playOn", in:Bundle(for: type(of: self)), compatibleWith:nil) : UIImage(named: "img_playOff", in:Bundle(for: type(of: self)), compatibleWith:nil)
            _buttonPlay.isEnabled = _isPlayable
        }
    }
    
    internal let _resultView = ALTSTTResultView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ALTSpeechToTextManager.manager.initialize(languageCode: LevelTestManager.manager.examInfo?.testLanguage ?? "en")
        
        let examSrl = testData.testInfo?.examSrl ?? 0
        let level = testData.quiz?.level ?? 0
        let folder = testData.quiz?.folder ?? 0
        let lang = LevelTestManager.manager.examInfo?.testLanguage ?? ""
        let quizOrder = testData.quiz?.quizOrder ?? 0
        
        let assetUrl = RequestUrl.AWS +  "/voice/leveltest/\(examSrl)/level\(level)-\(folder)/\(lang)/\(quizOrder).mp3"
        
        let item = AVPlayerItem(url: URL(string: assetUrl)!)
        _player = AVPlayer(playerItem: item)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
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
            
            _resultView.translatesAutoresizingMaskIntoConstraints = false
            _resultView.layer.borderWidth = 1
            _resultView.layer.borderColor = ColourKit.Code.HexCCCCCC.cgColor
            _resultView.isHidden = true
            leftView.addSubview(_resultView)
            
            if LevelTestManager.manager.recogResultType == 2 {
                _resultView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
            } else if LevelTestManager.manager.recogResultType == 3 {
                _resultView.bottomAnchor.constraint(equalTo: leftView.bottomAnchor, constant: -40).isActive = true
            }
            _resultView.leadingAnchor.constraint(equalTo: leftView.leadingAnchor, constant: 30).isActive = true
            _resultView.trailingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: -30).isActive = true
            
            _labelResult.translatesAutoresizingMaskIntoConstraints = false
            _labelResult.backgroundColor = .clear
            _labelResult.textAlignment = .center
            _labelResult.textColor = ColourKit.Code.HexAAAAAA
            _labelResult.font = UIFont.systemFont(ofSize: 24.optimized, weight: .medium)
//            _labelResult.numberOfLines = 0
            _labelResult.isHidden = true
            leftView.addSubview(_labelResult)
            
            _labelResult.topAnchor.constraint(equalTo: leftView.topAnchor,constant: 40).isActive = true
            if LevelTestManager.manager.recogResultType == 1 {
                _labelResult.bottomAnchor.constraint(equalTo: leftView.bottomAnchor, constant: -40).isActive = true
            } else if LevelTestManager.manager.recogResultType == 3 {
                _labelResult.bottomAnchor.constraint(equalTo: _resultView.topAnchor).isActive = true
            }
            _labelResult.leadingAnchor.constraint(equalTo: leftView.leadingAnchor, constant: 20).isActive = true
            _labelResult.trailingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: -20).isActive = true
            
            _labelNotice.translatesAutoresizingMaskIntoConstraints = false
            _labelNotice.text = "들린 \(LevelTestManager.manager.examInfo?.testLanguageString ?? "영어") 문장을 ‘녹음’ 버튼을\n누른 후 따라서 말하세요."
            _labelNotice.textAlignment = .center
            _labelNotice.textColor = ColourKit.Code.HexAAAAAA
            _labelNotice.font = UIFont.systemFont(ofSize: 24.optimized, weight: .medium)
            _labelNotice.numberOfLines = 0
            leftView.addSubview(_labelNotice)
            
            _labelNotice.topAnchor.constraint(equalTo: _waveView.topAnchor).isActive = true
            _labelNotice.bottomAnchor.constraint(equalTo: _waveView.bottomAnchor).isActive = true
            _labelNotice.leadingAnchor.constraint(equalTo: _waveView.leadingAnchor, constant: 20.optimized).isActive = true
            _labelNotice.trailingAnchor.constraint(equalTo: _waveView.trailingAnchor, constant: -20.optimized).isActive = true
            
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
            
//            let bundle = Bundle(for: AiLevelTestKit.self)
            
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
            
            let containerView = UIView()
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
            var hratio = (UIScreen.main.bounds.size.height - 667) / (812 - 667)
            if hratio < 0 { hratio = 0 }
            else if hratio > 1 { hratio = 1 }
            let height = 20.optimized + (36.optimized * hratio)
                
            _buttonPlay.translatesAutoresizingMaskIntoConstraints = false
            _buttonPlay.addTarget(self, action: #selector(self.play(_:)), for: .touchUpInside)
            self.view.addSubview(_buttonPlay)
            
            _buttonPlay.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: height).isActive = true
            _buttonPlay.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.optimized).isActive = true
            _buttonPlay.heightAnchor.constraint(equalToConstant: 44.optimized).isActive = true
            
            let backView = UIView()
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
            _waveView.isHidden = true
            self.view.addSubview(_waveView)
            
            _waveView.topAnchor.constraint(equalTo: _buttonPlay.bottomAnchor).isActive = true
            _waveView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            _waveView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            _waveView.heightAnchor.constraint(equalToConstant: 260.optimized).isActive = true
            
            _resultView.translatesAutoresizingMaskIntoConstraints = false
            _resultView.layer.borderWidth = 1
            _resultView.layer.borderColor = ColourKit.Code.HexCCCCCC.cgColor
            _resultView.isHidden = true
            self.view.addSubview(_resultView)
            
            _resultView.topAnchor.constraint(equalTo: _buttonPlay.bottomAnchor, constant: 60.optimized).isActive = true
            _resultView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.optimized).isActive = true
            _resultView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.optimized).isActive = true
            
            _labelResult.translatesAutoresizingMaskIntoConstraints = false
            _labelResult.backgroundColor = .clear
            _labelResult.textColor = ColourKit.Code.HexAAAAAA
            _labelResult.font = UIFont.systemFont(ofSize: 24.optimized, weight: .medium)
//            _labelResult.numberOfLines = 0
            _labelResult.isHidden = true
            self.view.addSubview(_labelResult)
            
            if LevelTestManager.manager.recogResultType == 1 {
                _labelResult.topAnchor.constraint(equalTo: _buttonPlay.bottomAnchor, constant: 60.optimized).isActive = true
            } else if LevelTestManager.manager.recogResultType == 3 {
                _labelResult.topAnchor.constraint(equalTo: _resultView.bottomAnchor,constant: 40.optimized).isActive = true
            }
            _labelResult.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
            _labelResult.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.optimized).isActive = true
            _labelResult.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.optimized).isActive = true
            
            _labelNotice.translatesAutoresizingMaskIntoConstraints = false
            _labelNotice.text = "들린 \(LevelTestManager.manager.examInfo?.testLanguageString ?? "영어") 문장을 ‘녹음’ 버튼을\n누른 후 따라서 말하세요."
            _labelNotice.textColor = ColourKit.Code.Hex8A8A8A
            _labelNotice.font = UIFont.systemFont(ofSize: 24.optimized, weight: .regular)
            _labelNotice.numberOfLines = 0
            self.view.addSubview(_labelNotice)
            
            _labelNotice.topAnchor.constraint(equalTo: _waveView.topAnchor).isActive = true
            _labelNotice.bottomAnchor.constraint(equalTo: _waveView.bottomAnchor).isActive = true
            _labelNotice.leadingAnchor.constraint(equalTo: _waveView.leadingAnchor, constant: 20.optimized).isActive = true
            _labelNotice.trailingAnchor.constraint(equalTo: _waveView.trailingAnchor, constant: -20.optimized).isActive = true
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "자동 종료가 안 될 경우 하단의 녹음 버튼을 다시 클릭하면\n종료됩니다. 마이크 가까이에서 녹음을 진행해주세요."
            label.textColor = AiLevelTestKit.shared.themeColour
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.numberOfLines = 2
            label.isHidden = true
            self.view.addSubview(label)
            
            label.topAnchor.constraint(equalTo: _labelNotice.bottomAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.optimized).isActive = true
            label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.optimized).isActive = true
            
            _buttonRecord.translatesAutoresizingMaskIntoConstraints = false
            _buttonRecord.layer.cornerRadius = 42
            _buttonRecord.clipsToBounds = true
            _buttonRecord.setTitle("녹음", for: .normal)
            _buttonRecord.setTitle("종료", for: .selected)
            _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: AiLevelTestKit.shared.themeColour), for: .normal)
            _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex000000), for: .selected)
            _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexAAAAAA), for: .disabled)
            _buttonRecord.setTitleColor(.white, for: .normal)
            _buttonRecord.setTitleColor(ColourKit.Code.HexFFFFFF, for: .selected)
            _buttonRecord.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            _buttonRecord.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
            _buttonNext.superview!.addSubview(_buttonRecord)
            
            _buttonRecord.centerYAnchor.constraint(equalTo: _buttonNext.superview!.centerYAnchor).isActive = true
            _buttonRecord.centerXAnchor.constraint(equalTo: _buttonNext.superview!.centerXAnchor).isActive = true
            _buttonRecord.widthAnchor.constraint(equalToConstant: 84).isActive = true
            _buttonRecord.heightAnchor.constraint(equalToConstant: 84).isActive = true
        }
        
        _guideString = "음성을 잘 들어주세요."
        
        _buttonRecord.isEnabled = false
        
        _remainingRecord = 3
        _remainingPlay = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ALTSpeechToTextManager.manager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ALTSpeechToTextManager.manager.stop(immdiately: true)
        
        _player?.pause()
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard _initiallyStarted else { return }
        
        _isPlayable = false
        _player?.play()
        _buttonRecord.isEnabled = false
        
        _isSkippable = false
        
        _guideString = "음성을 잘 들어주세요.\n음성이 들리지 않을 경우 미디어 음량을 확인해주세요."
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        switch button {
        case _buttonRecord:
            guard _remainingRecord > 0 else { break }
            
            _player?.pause()
            
            if ALTSpeechToTextManager.manager.isRecording {
                _buttonRecord.isEnabled = false
                ALTSpeechToTextManager.manager.stop()
            } else {
                _answer = nil
                
                ALTSpeechToTextManager.manager.start(languageCode: LevelTestManager.manager.examInfo?.testLanguage ?? "en")
                _isPlayable = false
                _buttonNext.isEnabled = false
                _isSkippable = false
                _buttonRecord.isEnabled = false
                
                _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {[weak self] (timer) in
                    self?._buttonRecord.isEnabled = true
                })
            }
            
            break
            
        default: break
        }
    }
    
    @objc private func play(_ button: UIButton) {
        guard _remainingPlay > 0 else { return }
            
        _isPlayable = false
        
        _buttonRecord.isEnabled = false
        _buttonNext.isEnabled = false
        _isSkippable = false
        
        _player?.seek(to: .zero)
        _player?.play()
        
        _guideString = "음성을 잘 들어주세요.\n음성이 들리지 않을 경우 미디어 음량을 확인해주세요."
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        if _initiallyStarted == false {
            _remainingPlay -= 1
        }
        
        _initiallyStarted = false
        
        _buttonRecord.isEnabled = _remainingRecord > 0
        _buttonNext.isEnabled = (_answer ?? "").count > 0 || _remainingRecord == 0
        _isSkippable = true
        
        _isPlayable = _remainingPlay > 0
        
        if _remainingRecord == 3 {
            _guideString = "녹음은 최대 3회까지 가능합니다.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
        } else {
            _guideString = "\(_remainingRecord)회의 녹음 기회가 남았습니다.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
        }
    }
}

extension ALTSeniorReadingTestViewController: ALTSpeechToTextManagerDelegate {
    func speechToTextManager(didStart manager: ALTSpeechToTextManager) {
        _labelNotice.isHidden = true
        _labelResult.isHidden = true
        _resultView.isHidden = true
        
        _waveView.isHidden = false
        
        _buttonRecord.isSelected = true
        
        _guideString = "마이크 가까이에서 녹음을 진행해주세요.\n자동 종료가 안 될 경우 종료 버튼을 눌러주세요."
    }
    
    func speechToTextManager(didStop manager: ALTSpeechToTextManager, withResult text: String?) {
        _labelNotice.text = text == nil ? "인식된 문장이 없습니다." : "음성 인식 중..."
        _labelNotice.isHidden = false
        
        _waveView.isHidden = true
        
        _buttonRecord.isSelected = false
        
        
        guard text != nil else {
            if _remainingRecord == 3 {
                _guideString = "녹음은 최대 3회까지 가능합니다.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
            } else {
                _guideString = "\(_remainingRecord)회의 녹음 기회가 남았습니다.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
            }
            
            _buttonRecord.isEnabled = true
            
            _isPlayable = _remainingPlay > 0
            _buttonNext.isEnabled = (_answer ?? "").count > 0 || _remainingRecord == 0
            _isSkippable = true
            return
        }
        
        _buttonRecord.isEnabled = false
        
        _remainingRecord -= 1
        
        if _remainingRecord == 3 {
            _guideString = "녹음은 최대 3회까지 가능합니다."
        } else {
            _guideString = "\(_remainingRecord)회의 녹음 기회가 남았습니다."
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false, block: {[weak self] (timer) in
            ALTSpeechToTextManager.manager.uploadFile(isMicTest: false,
                                                      levelSrl: self?.testData.quiz?.levelSrl,
                                                      order: self?.testData.quiz?.order,
                                                      path: self?.testData.quiz?.category?.path,
                                                      userLanguage: self?.testData.testInfo?.examInfo?.userLanguage,
                                                      testLanguage: self?.testData.testInfo?.examInfo?.testLanguage,
                                                      answerText: text!) {[weak self] (responseData) in
                DispatchQueue.main.async {[weak self] in
                    self?._buttonRecord.isEnabled = (self?._remainingRecord ?? 0) > 0
                    
                    self?._isPlayable = (self?._remainingPlay ?? 0) > 0
                    self?._isSkippable = true
                    
                    guard responseData != nil else {
                        if self?._remainingRecord == 3 {
                            self?._guideString = "녹음은 최대 3회까지 가능합니다.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
                        } else {
                            self?._guideString = "\(self?._remainingRecord ?? 0)회의 녹음 기회가 남았습니다.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
                        }
                        
                        self?._labelNotice.text = "인식된 문장이 없습니다."
                        self?._buttonNext.isEnabled = (self?._answer ?? "").count > 0 || (self?._remainingRecord ?? 0) == 0
                        return
                    }
                    
                    if self?._remainingRecord == 3 {
                        self?._guideString = "녹음은 최대 3회까지 가능합니다.\n'NEXT' 버튼을 누르면 다음 문제로 넘어갑니다."
                    } else {
                        self?._guideString = "\(self?._remainingRecord ?? 0)회의 녹음 기회가 남았습니다.\n'NEXT' 버튼을 누르면 다음 문제로 넘어갑니다."
                    }
                    
                    self?._answer = text
                    self?._buttonNext.isEnabled = (self?._answer ?? "").count > 0 || (self?._remainingRecord ?? 0) == 0

                    self?._labelNotice.isHidden = true
                    self?._labelResult.isHidden = LevelTestManager.manager.recogResultType == 2

                    self?._labelResult.text = text

                    self?._resultView.isHidden = LevelTestManager.manager.recogResultType == 1
                    self?._resultView.setResult(result: ALTSTTResultView.Data(with: responseData!), animated: true)
                    
                    self?.view.layoutIfNeeded()
                }
            }
        })
    }
    
    func speechToTextManager(_ manager: ALTSpeechToTextManager, didRecognizeAudio power: CGFloat) {
        _waveView.value = power
    }
    
    func speechToTextManager(_ manager: ALTSpeechToTextManager?, didRecognizeText text: String?) {
        
    }
}
