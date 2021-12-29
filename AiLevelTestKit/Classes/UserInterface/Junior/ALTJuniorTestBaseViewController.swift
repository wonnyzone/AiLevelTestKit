//
//  ALTJuniorTestBaseViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/24.
//

import UIKit

class ALTJuniorTestBaseViewController: ALTBaseTestViewController {
    internal let _footerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var additionalInset = ALTJuniorTestNavigationController.additionalSafeAreaInsets
        additionalInset.bottom = 0
        self.additionalSafeAreaInsets = additionalInset
        
        guard self as? ALTJuniorSpeakingViewController == nil else { return }
        
        _footerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 130.optimizedWithHeight)
        _footerView.clipsToBounds = true
        
        _footerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
        var attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Hex555555, font: UIFont.systemFont(ofSize: 15.optimizedWithHeight, weight: .medium)).attributes
        if UIScreen.main.bounds.size.width > 400 {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.underlineColor] = ColourKit.Code.Hex555555.cgColor
        }
        
        _buttonSkip.translatesAutoresizingMaskIntoConstraints = false
        _buttonSkip.setAttributedTitle(NSAttributedString(string: "모르겠어요", attributes: attributes), for: .normal)
        _buttonSkip.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20).optimizedWithHeight
        _buttonSkip.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _footerView.addSubview(_buttonSkip)
        
        _buttonSkip.topAnchor.constraint(equalTo: _footerView.topAnchor).isActive = true
        _buttonSkip.centerXAnchor.constraint(equalTo: _footerView.centerXAnchor).isActive = true
        
        _buttonNext.translatesAutoresizingMaskIntoConstraints = false
        _buttonNext.layer.cornerRadius = 36.optimizedWithHeight
        _buttonNext.clipsToBounds = true
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex222222), for: .normal)
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonNext.setTitle("다음", for: .normal)
        _buttonNext.setTitleColor(ColourKit.Code.HexFFFFFF, for: .normal)
        _buttonNext.titleLabel?.font = UIFont.systemFont(ofSize: 24.optimizedWithHeight, weight: .regular)
        _buttonNext.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonNext.isEnabled = _answer != nil
        _footerView.addSubview(_buttonNext)
        
        _buttonNext.topAnchor.constraint(equalTo: _buttonSkip.bottomAnchor, constant: 5.optimizedWithHeight).isActive = true
        _buttonNext.centerXAnchor.constraint(equalTo: _footerView.centerXAnchor).isActive = true
        _buttonNext.widthAnchor.constraint(equalToConstant: _buttonNext.layer.cornerRadius * 2).isActive = true
        _buttonNext.heightAnchor.constraint(equalToConstant: _buttonNext.layer.cornerRadius * 2).isActive = true
//        _buttonNext.bottomAnchor.constraint(equalTo: _footerView.bottomAnchor, constant: -30.optimized).isActive = true
        
        _footerView.layoutIfNeeded()
    }
}
