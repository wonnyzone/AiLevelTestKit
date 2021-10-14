//
//  ALTJuniorSpeakingViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/25.
//

import UIKit
import AVFoundation

import OCWaveView

class ALTJuniorSpeakingViewController: ALTJuniorTestBaseViewController {
    internal let _buttonPlay = UIButton()
    internal let _tailviewPlay = UIImageView()
    
    internal var _constraintAnswering = [Bool:NSLayoutConstraint]()
    
    internal let _viewRecord = UIView()
    internal let _tailviewRecord = UIImageView()
    internal let _waveView = WaveView()
    
    internal let _labelResult = UILabel()
    
    internal let _buttonRecordSingle = UIButton()
    
    internal let _buttonRecord = UIButton()
    
    internal var _remainingPlay: Int = 2 {
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
    
    internal var _remainingRecord = 3 {
        didSet {
            var attributes = QTextAttributes(withForegroundColour: .white, font: UIFont.systemFont(ofSize: 18.optimizedWithHeight, weight: .semibold))
            attributes.alignment = .center
            var attributedString = NSMutableAttributedString(string: "다시녹음\n", attributes: attributes.attributes)
            
            let bold = "\(_remainingRecord)회"
            let string = "\(bold) 가능"
            
            attributes = QTextAttributes(withForegroundColour: .white, font: UIFont.systemFont(ofSize: 12.optimizedWithHeight, weight: .semibold))
            attributes.alignment = .center
                
            let attrStr = NSMutableAttributedString(string: string, attributes: attributes.attributes)
            if let range = string.nsRange(of: bold) {
                attributes.foregroundColour = #colorLiteral(red: 0.9137254902, green: 0.968627451, blue: 0.2117647059, alpha: 1)
                attrStr.addAttributes(attributes.attributes, range: range)
            }
            attributedString.append(attrStr)
            
            _buttonRecord.setAttributedTitle(attributedString, for: .normal)
            
            attributes = QTextAttributes(withForegroundColour: ColourKit.Code.HexFFFFFF, font: UIFont.systemFont(ofSize: 24.optimizedWithHeight, weight: .semibold))
            attributedString = NSMutableAttributedString(string: "종료", attributes: attributes.attributes)
            _buttonRecord.setAttributedTitle(attributedString, for: .selected)
            
            _buttonRecordSingle.isHidden = _remainingRecord < 3
            _buttonNext.superview?.isHidden = _remainingRecord == 3
        }
    }
    
    internal var _player: AVPlayer?
    
    internal var _isRecordable: Bool = true {
        didSet {
            _buttonRecordSingle.isEnabled = _isRecordable
            _buttonRecord.isEnabled = _isRecordable
        }
    }
    
    internal var _isRecording: Bool = true {
        didSet {
            var points = [CGPoint]()
            points.append(CGPoint(x: 0, y: 0))
            points.append(CGPoint(x: 1, y: 0.5))
            points.append(CGPoint(x: 0, y: 1))
            let imageSettings = QImageSettings()
            imageSettings.size = CGSize(width: 12, height: 10).optimized
            imageSettings.colour = _isRecording ? #colorLiteral(red: 0.05490196078, green: 0.4431372549, blue: 0.9490196078, alpha: 1) : ColourKit.Code.HexFFFFFF
            imageSettings.fillColour = _isRecording ? #colorLiteral(red: 0.05490196078, green: 0.4431372549, blue: 0.9490196078, alpha: 1) : ColourKit.Code.HexFFFFFF
            _tailviewRecord.image = QImageMaker.shapeButton(with: imageSettings, vertexes: points, isClosedPath: true)
            
            _viewRecord.backgroundColor = _isRecording ? #colorLiteral(red: 0.05490196078, green: 0.4431372549, blue: 0.9490196078, alpha: 1) : ColourKit.Code.HexFFFFFF
            
            _waveView.isHidden = !_isRecording
            _labelResult.isHidden = _isRecording
        }
    }
    
    internal var _isPlayable: Bool = true {
        didSet {
            var points = [CGPoint]()
            points.append(CGPoint(x: 1, y: 0))
            points.append(CGPoint(x: 0, y: 0.5))
            points.append(CGPoint(x: 1, y: 1))
            let imageSettings = QImageSettings()
            imageSettings.size = CGSize(width: 12, height: 10).optimized
            imageSettings.colour = _isPlayable ? ColourKit.Code.HexCCCCCC : ColourKit.Code.HexAAAAAA
            imageSettings.fillColour = _isPlayable ? ColourKit.Code.HexCCCCCC : ColourKit.Code.HexAAAAAA
            _tailviewPlay.image = QImageMaker.shapeButton(with: imageSettings, vertexes: points, isClosedPath: true)
            
            _buttonPlay.isEnabled = _isPlayable
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item = AVPlayerItem(url: URL(string: "http://aileveltest.com/plugin/data/voice/ko_en_mictest.mp3")!)
        _player = AVPlayer(playerItem: item)
        
        self.additionalSafeAreaInsets = ALTJuniorTestNavigationController.additionalSafeAreaInsets
        
        self.view.backgroundColor = ColourKit.Code.HexF0F0F0
        
        _labelGuide.translatesAutoresizingMaskIntoConstraints = false
        _labelGuide.text = "하단 녹음 버튼을 누른 후\n\"Hello\"라고 말해주세요."
        _labelGuide.textColor = ColourKit.Code.Hex222222
        _labelGuide.textAlignment = .center
        _labelGuide.font = UIFont.systemFont(ofSize: 22.optimizedWithHeight, weight: .semibold)
        _labelGuide.numberOfLines = 0
        self.view.addSubview(_labelGuide)

        _labelGuide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        _labelGuide.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.optimized).isActive = true
        _labelGuide.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.optimized).isActive = true
        _labelGuide.heightAnchor.constraint(equalToConstant: 130.optimizedWithHeight).isActive = true

        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40.optimizedWithHeight
        imageView.backgroundColor = ColourKit.Code.HexFFFFFF
        imageView.image = UIImage(named: "img_char_female")
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        
        imageView.widthAnchor.constraint(equalToConstant: imageView.layer.cornerRadius * 2).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageView.layer.cornerRadius * 2).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.optimized).isActive = true
        imageView.topAnchor.constraint(equalTo: _labelGuide.bottomAnchor, constant: 6.optimizedWithHeight).isActive = true
        
        _buttonPlay.translatesAutoresizingMaskIntoConstraints = false
        _buttonPlay.clipsToBounds = true
        _buttonPlay.layer.cornerRadius = 8.optimized
        _buttonPlay.setBackgroundImage(UIImage.withSolid(colour: #colorLiteral(red: 0, green: 0.8235294118, blue: 0.7176470588, alpha: 1)), for: .normal)
        _buttonPlay.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .highlighted)
        _buttonPlay.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexAAAAAA), for: .disabled)
        _buttonPlay.setImage(UIImage(named: "img_volume")?.recolour(with: .white).resize(maxWidth: 21.optimized), for: .normal)
        _buttonPlay.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5).optimized
        _buttonPlay.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0).optimized
        _buttonPlay.addTarget(self, action: #selector(self.play(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonPlay)

        _buttonPlay.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        _buttonPlay.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 13.optimized).isActive = true
        _buttonPlay.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.optimized).isActive = true
        _buttonPlay.heightAnchor.constraint(equalToConstant: 60.optimizedWithHeight).isActive = true

        _tailviewPlay.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_tailviewPlay)
        
        _tailviewPlay.widthAnchor.constraint(equalToConstant: 12.optimizedWithHeight).isActive = true
        _tailviewPlay.heightAnchor.constraint(equalToConstant: 10.optimizedWithHeight).isActive = true
        _tailviewPlay.bottomAnchor.constraint(equalTo: _buttonPlay.bottomAnchor, constant: -20.optimized).isActive = true
        _tailviewPlay.trailingAnchor.constraint(equalTo: _buttonPlay.leadingAnchor).isActive = true
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40.optimizedWithHeight
        imageView.backgroundColor = ColourKit.Code.HexFFFFFF
        imageView.image = UIImage(named: "img_char_male")
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        
        imageView.widthAnchor.constraint(equalToConstant: imageView.layer.cornerRadius * 2).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageView.layer.cornerRadius * 2).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.optimized).isActive = true
        imageView.topAnchor.constraint(equalTo: _buttonPlay.bottomAnchor, constant: 60.optimizedWithHeight).isActive = true
        
        _viewRecord.translatesAutoresizingMaskIntoConstraints = false
        _viewRecord.backgroundColor = ColourKit.Code.HexFFFFFF
        _viewRecord.clipsToBounds = true
        _viewRecord.layer.cornerRadius = 8.optimized
        self.view.addSubview(_viewRecord)
        
        _viewRecord.topAnchor.constraint(equalTo: _buttonPlay.bottomAnchor, constant: 30.optimizedWithHeight).isActive = true
        _viewRecord.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.optimized).isActive = true
        _viewRecord.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -13.optimized).isActive = true
        _viewRecord.heightAnchor.constraint(equalToConstant: 200.optimizedWithHeight).isActive = true
        
        _waveView.translatesAutoresizingMaskIntoConstraints = false
        _waveView.value = 0
        _viewRecord.addSubview(_waveView)

        _waveView.topAnchor.constraint(equalTo: _viewRecord.topAnchor, constant: 16.optimizedWithHeight).isActive = true
        _waveView.bottomAnchor.constraint(equalTo: _viewRecord.bottomAnchor, constant: -16.optimizedWithHeight).isActive = true
        _waveView.leadingAnchor.constraint(equalTo: _viewRecord.leadingAnchor, constant: 9.optimized).isActive = true
        _waveView.trailingAnchor.constraint(equalTo: _viewRecord.trailingAnchor, constant: -9.optimized).isActive = true
        
        _labelResult.translatesAutoresizingMaskIntoConstraints = false
        _labelResult.text = ""
        _labelResult.textAlignment = .center
        _labelResult.textColor = ColourKit.Code.Hex222222
        _labelResult.font = UIFont.systemFont(ofSize: 18.optimizedWithHeight, weight: .semibold)
        _labelResult.numberOfLines = 3
        _viewRecord.addSubview(_labelResult)

        _labelResult.topAnchor.constraint(equalTo: _viewRecord.topAnchor, constant: 16.optimizedWithHeight).isActive = true
        _labelResult.bottomAnchor.constraint(equalTo: _viewRecord.bottomAnchor, constant: -16.optimizedWithHeight).isActive = true
        _labelResult.leadingAnchor.constraint(equalTo: _viewRecord.leadingAnchor, constant: 9.optimized).isActive = true
        _labelResult.trailingAnchor.constraint(equalTo: _viewRecord.trailingAnchor, constant: -9.optimized).isActive = true
        
        _tailviewRecord.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_tailviewRecord)
        
        _tailviewRecord.widthAnchor.constraint(equalToConstant: 12.optimizedWithHeight).isActive = true
        _tailviewRecord.heightAnchor.constraint(equalToConstant: 10.optimizedWithHeight).isActive = true
        _tailviewRecord.centerYAnchor.constraint(equalTo: _viewRecord.centerYAnchor).isActive = true
        _tailviewRecord.leadingAnchor.constraint(equalTo: _viewRecord.trailingAnchor).isActive = true
        
        var attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Hex555555, font: UIFont.systemFont(ofSize: 15.optimizedWithHeight, weight: .medium)).attributes
        if UIScreen.main.bounds.size.width > 400 {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.underlineColor] = ColourKit.Code.Hex555555.cgColor
        }
        
        _buttonSkip.translatesAutoresizingMaskIntoConstraints = false
        _buttonSkip.setAttributedTitle(NSAttributedString(string: "모르겠어요", attributes: attributes), for: .normal)
        _buttonSkip.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20).optimizedWithHeight
        _buttonSkip.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonSkip)
        
        _buttonSkip.topAnchor.constraint(equalTo: _viewRecord.bottomAnchor, constant: 50.optimizedWithHeight).isActive = true
        _buttonSkip.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        _buttonRecordSingle.translatesAutoresizingMaskIntoConstraints = false
        _buttonRecordSingle.layer.cornerRadius = 40.optimizedWithHeight
        _buttonRecordSingle.clipsToBounds = true
        _buttonRecordSingle.setTitle("녹음", for: .normal)
        _buttonRecordSingle.setTitle("종료", for: .selected)
        _buttonRecordSingle.setBackgroundImage(UIImage.withSolid(colour: AiLevelTestKit.shared.themeColour), for: .normal)
        _buttonRecordSingle.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex000000), for: .selected)
        _buttonRecordSingle.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonRecordSingle.setTitleColor(.white, for: .normal)
        _buttonRecordSingle.setTitleColor(ColourKit.Code.HexFFFFFF, for: .selected)
        _buttonRecordSingle.titleLabel?.font = UIFont.systemFont(ofSize: 24.optimizedWithHeight, weight: .regular)
        _buttonRecordSingle.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonRecordSingle)

        _buttonRecordSingle.topAnchor.constraint(equalTo: _buttonSkip.bottomAnchor, constant: 30.optimizedWithHeight).isActive = true
        _buttonRecordSingle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _buttonRecordSingle.widthAnchor.constraint(equalToConstant: 80.optimizedWithHeight).isActive = true
        _buttonRecordSingle.heightAnchor.constraint(equalToConstant: 80.optimizedWithHeight).isActive = true
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: _buttonRecordSingle.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: _buttonRecordSingle.bottomAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        _buttonRecord.translatesAutoresizingMaskIntoConstraints = false
        _buttonRecord.layer.cornerRadius = 40.optimizedWithHeight
        _buttonRecord.clipsToBounds = true
        _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: AiLevelTestKit.shared.themeColour), for: .normal)
        _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex000000), for: .selected)
        _buttonRecord.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonRecord.titleLabel?.numberOfLines = 2
        _buttonRecord.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        containerView.addSubview(_buttonRecord)

        _buttonRecord.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        _buttonRecord.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        _buttonRecord.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        _buttonRecord.widthAnchor.constraint(equalTo: _buttonRecord.heightAnchor).isActive = true
        
        _buttonNext.translatesAutoresizingMaskIntoConstraints = false
        _buttonNext.layer.cornerRadius = 40.optimizedWithHeight
        _buttonNext.clipsToBounds = true
        _buttonNext.setTitle("다음", for: .normal)
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex000000), for: .normal)
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonNext.setTitleColor(ColourKit.Code.HexFFFFFF, for: .normal)
        _buttonNext.setTitleColor(.white, for: .disabled)
        _buttonRecord.titleLabel?.font = UIFont.systemFont(ofSize: 24.optimizedWithHeight, weight: .regular)
        _buttonNext.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonNext.isEnabled = false
        containerView.addSubview(_buttonNext)

        _buttonNext.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        _buttonNext.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        _buttonNext.leadingAnchor.constraint(equalTo: _buttonRecord.trailingAnchor, constant: 10.optimized).isActive = true
        _buttonNext.widthAnchor.constraint(equalTo: _buttonRecord.heightAnchor).isActive = true
        _buttonNext.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        containerView.isHidden = true
        
        _remainingPlay = 3
        
        _isPlayable = false
        _isRecording = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ALTSpeechToTextManager.manager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.navigationItem.leftBarButtonItems = []
        self.navigationItem.rightBarButtonItems = []
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = self.view.backgroundColor
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        }
        
        let label = UILabel()
        label.text = self.title
        label.textColor = ColourKit.Code.Hex222222
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.sizeToFit()
        self.navigationItem.titleView = label
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
        
        _isPlayable = false
        _player?.play()
        _isRecordable = false

        _guideString = "음성을 잘 들어주세요.\n음성이 들리지 않을 경우 미디어 음량을 확인해주세요."
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        switch button {
        case _buttonRecord, _buttonRecordSingle:
            _player?.pause()
            
            if ALTSpeechToTextManager.manager.isRecording {
                _isRecordable = false
                ALTSpeechToTextManager.manager.stop()
            } else {
                ALTSpeechToTextManager.manager.start(languageCode: LevelTestManager.manager.examInfo?.testLanguage ?? "en")
                _isPlayable = false
                _buttonNext.isEnabled = false
                _isSkippable = false
                
                _isRecordable = false
                _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {[weak self] (timer) in
                    self?._isRecordable = true
                })
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
        
        _isPlayable = false
        _isRecordable = false
        
        _buttonNext.isEnabled = false
        _isSkippable = false
        
        _player?.seek(to: .zero)
        _player?.play()
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        _remainingPlay -= 1
        
        _guideString = _answer != nil ? "'NEXT' 버튼을 누르면 다음 문제로 넘어갑니다." : "녹음은 최대 3회까지 가능합니다."
        
        _initiallyStarted = false
        
        _isRecordable = _remainingRecord > 0
        _buttonNext.isEnabled = (_answer ?? "").count > 0 || _remainingRecord == 0
        
        _isPlayable = _remainingPlay > 0
        _isSkippable = true
    }
}

extension ALTJuniorSpeakingViewController: ALTSpeechToTextManagerDelegate {
    func speechToTextManager(didStart manager: ALTSpeechToTextManager) {
        _labelResult.isHidden = true
        _waveView.isHidden = false
        
        _isRecording = true
        
        _buttonRecord.isSelected = true
        _buttonRecordSingle.isSelected = true
        _isSkippable = false
        
        _guideString = "마이크 가까이에서 녹음을 진행해주세요."
    }
    
    func speechToTextManager(didStop manager: ALTSpeechToTextManager, withResult text: String?) {
        _labelResult.text = text ?? "인식된 문장이 없습니다."
        _labelResult.isHidden = false
        _waveView.isHidden = true
        
        _isRecording = false
        
        _buttonRecord.isSelected = false
        _buttonRecordSingle.isSelected = false
        
        _answer = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        _isPlayable = _remainingPlay > 0
        _buttonNext.isEnabled = (_answer ?? "").count > 0 || _remainingRecord == 0
        _isSkippable = true
        
        let remainingRecord = _remainingRecord
        
        guard text != nil else {
            _remainingRecord = remainingRecord             // 텍스트 변경
            _isRecordable = true
            return
        }
        
        _remainingRecord = remainingRecord - 1
        _isRecordable = _remainingRecord > 0
    }
    
    func speechToTextManager(_ manager: ALTSpeechToTextManager, didRecognizeAudio power: CGFloat) {
        _waveView.value = power
    }
    
    func speechToTextManager(_ manager: ALTSpeechToTextManager?, didRecognizeText text: String?) {
        
    }
}

