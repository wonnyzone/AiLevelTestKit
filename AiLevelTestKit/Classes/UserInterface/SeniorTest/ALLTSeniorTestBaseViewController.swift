//
//  ALLTSeniorTestBaseViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALLTSeniorTestBaseViewController: ALTBaseTestViewController {
    override var _guideString: String? {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.additionalSafeAreaInsets = ALLTSeniorTestNavigationController.additionalSafeAreaInsets
        
        let backView = UIView()
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
        _buttonSkip.layer.borderWidth = 1
        _buttonSkip.layer.borderColor = ColourKit.Code.HexAAAAAA.cgColor
        _buttonSkip.layer.cornerRadius = 32.optimized
        _buttonSkip.clipsToBounds = true
        _buttonSkip.setTitle("SKIP", for: .normal)
        _buttonSkip.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonSkip.setTitleColor(ColourKit.Code.HexAAAAAA, for: .normal)
        _buttonSkip.setTitleColor(.white, for: .disabled)
        _buttonSkip.titleLabel?.font = UIFont.systemFont(ofSize: 16.optimized, weight: .regular)
        _buttonSkip.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _isSkippable = true
        containerView.addSubview(_buttonSkip)
        
        _buttonSkip.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        _buttonSkip.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        _buttonSkip.widthAnchor.constraint(equalToConstant: 64.optimized).isActive = true
        _buttonSkip.heightAnchor.constraint(equalToConstant: 64.optimized).isActive = true
        
        _buttonNext.translatesAutoresizingMaskIntoConstraints = false
        _buttonNext.layer.cornerRadius = 32.optimized
        _buttonNext.clipsToBounds = true
        _buttonNext.setTitle("NEXT", for: .normal)
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex000000), for: .normal)
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonNext.setTitleColor(ColourKit.Code.HexFFFFFF, for: .normal)
        _buttonNext.setTitleColor(.white, for: .disabled)
        _buttonNext.titleLabel?.font = UIFont.systemFont(ofSize: 16.optimized, weight: .regular)
        _buttonNext.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonNext.isEnabled = false
        containerView.addSubview(_buttonNext)
        
        _buttonNext.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        _buttonNext.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        _buttonNext.widthAnchor.constraint(equalToConstant: 64.optimized).isActive = true
        _buttonNext.heightAnchor.constraint(equalToConstant: 64.optimized).isActive = true
        
        _labelGuide.translatesAutoresizingMaskIntoConstraints = false
        _labelGuide.numberOfLines = 2
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            _labelGuide.textColor = ColourKit.Code.Hex222222
            _labelGuide.font = UIFont.systemFont(ofSize: 18.optimized, weight: .regular)
            _labelGuide.textAlignment = .center
            containerView.addSubview(_labelGuide)

            _labelGuide.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.optimized).isActive = true
            _labelGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.optimized).isActive = true
            _labelGuide.leadingAnchor.constraint(equalTo: _buttonSkip.trailingAnchor, constant: 10.optimized).isActive = true
            _labelGuide.trailingAnchor.constraint(equalTo: _buttonNext.leadingAnchor, constant: -10.optimized).isActive = true
            _labelGuide.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.size.width - 88.optimized).isActive = true
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
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let backView = _labelGuide.superview {
            backView.layer.cornerRadius = backView.bounds.size.height / 2
        }
    }
}
