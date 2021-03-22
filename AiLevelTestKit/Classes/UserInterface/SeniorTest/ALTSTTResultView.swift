//
//  ALTSTTResultView.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/01/28.
//

import UIKit

class ALTSTTResultView: UIView {
    class Data: ALTBaseData {
        var pronounce: CGFloat {
            guard let value = rawData["pronounce"] as? String, let doubleValue = Double(value) else { return 0 }
            return CGFloat(doubleValue) / 10
        }
        
        var speed: CGFloat {
            guard let value = rawData["speed"] as? String, let doubleValue = Double(value) else { return 0 }
            return CGFloat(doubleValue) / 10
        }
        
        var intonation: CGFloat {
            guard let value = rawData["accent"] as? String, let doubleValue = Double(value) else { return 0 }
            return CGFloat(doubleValue) / 10
        }
        
        var accuracy: CGFloat {
            guard let value = rawData["percent"] as? String, let doubleValue = Double(value) else { return 0 }
            return CGFloat(doubleValue) / 100
        }
        
        var assessment: String {
            return rawData["assessment"] as? String ?? ""
        }
    }
    
    var title: String?
    
    private let _labelTitle = UILabel()
    
    private let _viewBarPronunciation = UIView()
    private let _labelPronunciationIn = UILabel()
    private let _labelPronunciationOut = UILabel()
    lazy private var _constraintPronunciationWidth: NSLayoutConstraint = {
        return _viewBarPronunciation.widthAnchor.constraint(equalToConstant: 0)
    }()
    
    private let _viewBarIntonation = UIView()
    private let _labelIntonationIn = UILabel()
    private let _labelIntonationOut = UILabel()
    lazy private var _constraintIntonationWidth: NSLayoutConstraint = {
        return _viewBarIntonation.widthAnchor.constraint(equalToConstant: 0)
    }()
    
    private let _viewBarAccuracy = UIView()
    private let _labelAccuracyIn = UILabel()
    private let _labelAccuracyOut = UILabel()
    lazy private var _constraintAccuracyWidth: NSLayoutConstraint = {
        return _viewBarAccuracy.widthAnchor.constraint(equalToConstant: 0)
    }()
    
    private var _timer: Timer?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 15.optimized
        
        _labelTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle.textColor = ColourKit.Code.Hex000000
        _labelTitle.font = UIFont.systemFont(ofSize: 24.optimized, weight: .bold)
        self.addSubview(_labelTitle)
        
        _labelTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 20.optimized).isActive = true
        _labelTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        _labelTitle.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, constant: -20.optimized).isActive = true
        _labelTitle.heightAnchor.constraint(equalToConstant: 27.optimized).isActive = true
        
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "발음"
        label.textColor = ColourKit.Code.Hex000000
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        self.addSubview(label)
        
        label.topAnchor.constraint(equalTo: _labelTitle.bottomAnchor, constant: 16.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.optimized).isActive = true
        label.widthAnchor.constraint(equalToConstant: 49.optimized).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20.optimized).isActive = true
        
        var backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.clipsToBounds = true
        self.addSubview(backView)
        
        self.sendSubview(toBack: backView)
        
        backView.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10.optimized).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        _viewBarPronunciation.translatesAutoresizingMaskIntoConstraints = false
        _viewBarPronunciation.backgroundColor = AiLevelTestKit.shared.themeColour
        _viewBarPronunciation.clipsToBounds = true
        backView.addSubview(_viewBarPronunciation)
        
        _viewBarPronunciation.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _viewBarPronunciation.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _constraintPronunciationWidth.isActive = true
        _viewBarPronunciation.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        
        var roundView = UIView()
        roundView.translatesAutoresizingMaskIntoConstraints = false
        roundView.layer.cornerRadius = 10.optimized
        roundView.clipsToBounds = true
        roundView.backgroundColor = AiLevelTestKit.shared.themeColour
        backView.addSubview(roundView)
        
        roundView.centerXAnchor.constraint(equalTo: _viewBarPronunciation.trailingAnchor).isActive = true
        roundView.topAnchor.constraint(equalTo: _viewBarPronunciation.topAnchor).isActive = true
        roundView.bottomAnchor.constraint(equalTo: _viewBarPronunciation.bottomAnchor).isActive = true
        roundView.widthAnchor.constraint(equalTo: roundView.heightAnchor).isActive = true
        
        self.sendSubview(toBack: roundView)
        
        _labelPronunciationIn.translatesAutoresizingMaskIntoConstraints = false
        _labelPronunciationIn.textColor = .white
        _labelPronunciationIn.font = UIFont.systemFont(ofSize: 11.optimized, weight: .regular)
        _labelPronunciationIn.isHidden = true
        self.addSubview(_labelPronunciationIn)
        
        _labelPronunciationIn.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        _labelPronunciationIn.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        _labelPronunciationIn.trailingAnchor.constraint(equalTo: _viewBarPronunciation.trailingAnchor).isActive = true
        
        _labelPronunciationOut.translatesAutoresizingMaskIntoConstraints = false
        _labelPronunciationOut.textColor = ColourKit.Code.Hex000000
        _labelPronunciationOut.font = UIFont.systemFont(ofSize: 11.optimized, weight: .regular)
        self.addSubview(_labelPronunciationOut)
        
        _labelPronunciationOut.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        _labelPronunciationOut.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        _labelPronunciationOut.leadingAnchor.constraint(equalTo: roundView.trailingAnchor, constant: 10.optimized).isActive = true
        
        var bottomAnchor = _viewBarPronunciation.bottomAnchor
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "억양"
        label.textColor = ColourKit.Code.Hex000000
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        self.addSubview(label)
        
        label.topAnchor.constraint(equalTo: bottomAnchor, constant: 10.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.optimized).isActive = true
        label.widthAnchor.constraint(equalToConstant: 49.optimized).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20.optimized).isActive = true
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.clipsToBounds = true
        self.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10.optimized).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        _viewBarIntonation.translatesAutoresizingMaskIntoConstraints = false
        _viewBarIntonation.backgroundColor = AiLevelTestKit.shared.themeColour
        _viewBarIntonation.clipsToBounds = true
        backView.addSubview(_viewBarIntonation)
        
        _viewBarIntonation.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _viewBarIntonation.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _constraintIntonationWidth.isActive = true
        _viewBarIntonation.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        
        roundView = UIView()
        roundView.translatesAutoresizingMaskIntoConstraints = false
        roundView.layer.cornerRadius = 10.optimized
        roundView.clipsToBounds = true
        roundView.backgroundColor = AiLevelTestKit.shared.themeColour
        backView.addSubview(roundView)
        
        roundView.centerXAnchor.constraint(equalTo: _viewBarIntonation.trailingAnchor).isActive = true
        roundView.topAnchor.constraint(equalTo: _viewBarIntonation.topAnchor).isActive = true
        roundView.bottomAnchor.constraint(equalTo: _viewBarIntonation.bottomAnchor).isActive = true
        roundView.widthAnchor.constraint(equalTo: roundView.heightAnchor).isActive = true
        
        self.sendSubview(toBack: roundView)
        
        _labelIntonationIn.translatesAutoresizingMaskIntoConstraints = false
        _labelIntonationIn.textColor = .white
        _labelIntonationIn.font = UIFont.systemFont(ofSize: 11.optimized, weight: .regular)
        _labelIntonationIn.isHidden = true
        self.addSubview(_labelIntonationIn)
        
        _labelIntonationIn.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        _labelIntonationIn.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        _labelIntonationIn.trailingAnchor.constraint(equalTo: _viewBarIntonation.trailingAnchor).isActive = true
        
        _labelIntonationOut.translatesAutoresizingMaskIntoConstraints = false
        _labelIntonationOut.textColor = ColourKit.Code.Hex000000
        _labelIntonationOut.font = UIFont.systemFont(ofSize: 11.optimized, weight: .regular)
        self.addSubview(_labelIntonationOut)
        
        _labelIntonationOut.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        _labelIntonationOut.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        _labelIntonationOut.leadingAnchor.constraint(equalTo: roundView.trailingAnchor, constant: 10.optimized).isActive = true
        
        bottomAnchor = _viewBarIntonation.bottomAnchor
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "정확도"
        label.textColor = ColourKit.Code.Hex000000
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        self.addSubview(label)
        
        label.topAnchor.constraint(equalTo: bottomAnchor, constant: 10.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.optimized).isActive = true
        label.widthAnchor.constraint(equalToConstant: 49.optimized).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20.optimized).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -27.optimized).isActive = true
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.clipsToBounds = true
        self.addSubview(backView)
        
        self.sendSubview(toBack: backView)
        
        backView.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10.optimized).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        _viewBarAccuracy.translatesAutoresizingMaskIntoConstraints = false
        _viewBarAccuracy.backgroundColor = AiLevelTestKit.shared.themeColour
        _viewBarAccuracy.clipsToBounds = true
        backView.addSubview(_viewBarAccuracy)
        
        _viewBarAccuracy.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _viewBarAccuracy.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _constraintAccuracyWidth.isActive = true
        _viewBarAccuracy.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        
        roundView = UIView()
        roundView.translatesAutoresizingMaskIntoConstraints = false
        roundView.layer.cornerRadius = 10.optimized
        roundView.clipsToBounds = true
        roundView.backgroundColor = AiLevelTestKit.shared.themeColour
        backView.addSubview(roundView)
        
        roundView.centerXAnchor.constraint(equalTo: _viewBarAccuracy.trailingAnchor).isActive = true
        roundView.topAnchor.constraint(equalTo: _viewBarAccuracy.topAnchor).isActive = true
        roundView.bottomAnchor.constraint(equalTo: _viewBarAccuracy.bottomAnchor).isActive = true
        roundView.widthAnchor.constraint(equalTo: roundView.heightAnchor).isActive = true
        
        self.sendSubview(toBack: roundView)
        
        _labelAccuracyIn.translatesAutoresizingMaskIntoConstraints = false
        _labelAccuracyIn.textColor = .white
        _labelAccuracyIn.font = UIFont.systemFont(ofSize: 11.optimized, weight: .regular)
        _labelAccuracyIn.isHidden = true
        self.addSubview(_labelAccuracyIn)
        
        _labelAccuracyIn.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        _labelAccuracyIn.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        _labelAccuracyIn.trailingAnchor.constraint(equalTo: _viewBarAccuracy.trailingAnchor).isActive = true
        
        _labelAccuracyOut.translatesAutoresizingMaskIntoConstraints = false
        _labelAccuracyOut.textColor = ColourKit.Code.Hex000000
        _labelAccuracyOut.font = UIFont.systemFont(ofSize: 11.optimized, weight: .regular)
        self.addSubview(_labelAccuracyOut)
        
        _labelAccuracyOut.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        _labelAccuracyOut.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        _labelAccuracyOut.leadingAnchor.constraint(equalTo: roundView.trailingAnchor, constant: 10.optimized).isActive = true
        
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setResult(result: Data, animated: Bool) {
        _timer?.invalidate()
        _timer = nil
        
        _labelTitle.text = result.assessment
        
        let maxWidth = self.bounds.size.width - _viewBarPronunciation.superview!.frame.origin.x - 40.optimized
        
        guard animated else {
            _labelPronunciationIn.text = "\(Int(result.pronounce * 100))%"
            _labelPronunciationIn.isHidden = result.pronounce < 0.3
            _labelPronunciationOut.text = "\(Int(result.pronounce * 100))%"
            _labelPronunciationOut.isHidden = result.pronounce >= 0.3
            _constraintPronunciationWidth.constant = maxWidth * result.pronounce
            
            _labelIntonationIn.text = "\(Int(result.intonation * 100))%"
            _labelIntonationIn.isHidden = result.intonation < 0.3
            _labelIntonationOut.text = "\(Int(result.intonation * 100))%"
            _labelIntonationOut.isHidden = result.intonation >= 0.3
            _constraintIntonationWidth.constant = maxWidth * result.intonation
            
            _labelAccuracyIn.text = "\(Int(result.accuracy * 100))%"
            _labelAccuracyIn.isHidden = result.accuracy < 0.3
            _labelAccuracyOut.text = "\(Int(result.accuracy * 100))%"
            _labelAccuracyOut.isHidden = result.accuracy >= 0.3
            _constraintAccuracyWidth.constant = maxWidth * result.accuracy
            
            self.layoutIfNeeded()
            return
        }
        
        print(result.pronounce)
        
        var pronounce = CGFloat(0), intonation = CGFloat(0), accuracy = CGFloat(0)
        
        var time = Double(0)
        let timeInterval = Double(0.01)
        let maxTimeInterval = Double(0.5)
        
        let unitPron = result.pronounce / CGFloat(maxTimeInterval / timeInterval)
        let unitInto = result.intonation / CGFloat(maxTimeInterval / timeInterval)
        let unitAccu = result.accuracy / CGFloat(maxTimeInterval / timeInterval)
        
        _timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: {[weak self] (timer) in
            pronounce += unitPron
            intonation += unitInto
            accuracy += unitAccu
            
            self?._labelPronunciationIn.text = "\(Int(pronounce * 100))%"
            self?._labelPronunciationIn.isHidden = pronounce < 0.3
            self?._labelPronunciationOut.text = "\(Int(pronounce * 100))%"
            self?._labelPronunciationOut.isHidden = pronounce >= 0.3
            self?._constraintPronunciationWidth.constant = maxWidth * pronounce
            
            self?._labelIntonationIn.text = "\(Int(intonation * 100))%"
            self?._labelIntonationIn.isHidden = intonation < 0.3
            self?._labelIntonationOut.text = "\(Int(intonation * 100))%"
            self?._labelIntonationOut.isHidden = intonation >= 0.3
            self?._constraintIntonationWidth.constant = maxWidth * intonation
            
            self?._labelAccuracyIn.text = "\(Int(accuracy * 100))%"
            self?._labelAccuracyIn.isHidden = accuracy < 0.3
            self?._labelAccuracyOut.text = "\(Int(accuracy * 100))%"
            self?._labelAccuracyOut.isHidden = accuracy >= 0.3
            self?._constraintAccuracyWidth.constant = maxWidth * accuracy
            
            self?.layoutIfNeeded()
            
            time += timeInterval
            if time >= maxTimeInterval {
                self?._timer?.invalidate()
                self?._timer = nil
            }
        })
    }
}
