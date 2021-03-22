//
//  ALTJuniorTestNavigationController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/24.
//

import UIKit

class ALTJuniorTestNavigationController: ALTNavigationController {
    class var additionalSafeAreaInsets: UIEdgeInsets {
        guard UIDevice.current.userInterfaceIdiom != .pad else {
            return UIEdgeInsets(top: 80, left: 0, bottom: 120, right: 0)
        }
        
        return UIEdgeInsets(top: 80, left: 0, bottom: 100, right: 0)
    }
    
    var isComponentHidden = false {
        didSet {
            progressBarView.isHidden = isComponentHidden
            _labelStep.superview?.isHidden = isComponentHidden
//            buttonClose.isHidden = isComponentHidden
//            _labelTime.superview?.isHidden = isComponentHidden
        }
    }
    
    let progressBarView = ALLTProgressBarView()
    private let _labelStep = UILabel()
    
    let buttonClose = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressBarView.translatesAutoresizingMaskIntoConstraints = false
        progressBarView.layer.zPosition = 1000
        self.view.addSubview(progressBarView)

        progressBarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        if UIDevice.current.userInterfaceIdiom == .phone {
            progressBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
            progressBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -60).isActive = true
        } else {
            progressBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 84).isActive = true
            progressBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -84).isActive = true
        }
        progressBarView.heightAnchor.constraint(equalToConstant: ALLTNavigationViewController.additionalSafeAreaInsets.top - 16).isActive = true

        progressBarView.reloadData()
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.clipsToBounds = true
        backView.backgroundColor = #colorLiteral(red: 0, green: 0.8235294118, blue: 0.7176470588, alpha: 1)
        backView.layer.cornerRadius = 12.optimizedWithHeight
        self.view.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: progressBarView.bottomAnchor, constant: 5.optimizedWithHeight).isActive = true
        backView.centerXAnchor.constraint(equalTo: progressBarView.centerXAnchor).isActive = true
        backView.heightAnchor.constraint(equalToConstant: backView.layer.cornerRadius * 2).isActive = true
        
        _labelStep.translatesAutoresizingMaskIntoConstraints = false
        _labelStep.textColor = .white
        _labelStep.font = UIFont.systemFont(ofSize: 12.optimizedWithHeight, weight: .regular)
        backView.addSubview(_labelStep)
        
        _labelStep.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _labelStep.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _labelStep.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20.optimized).isActive = true
        _labelStep.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20.optimized).isActive = true

        buttonClose.translatesAutoresizingMaskIntoConstraints = false
        buttonClose.setImage(UIImage(named: "img_close", in:Bundle(for: type(of: self)), compatibleWith:nil)?.resize(maxWidth: 32), for: .normal)
        buttonClose.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(buttonClose)

        buttonClose.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        buttonClose.leadingAnchor.constraint(equalTo: progressBarView.trailingAnchor).isActive = true
        buttonClose.widthAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .phone ? 54 : 88).isActive = true
        buttonClose.heightAnchor.constraint(equalToConstant: ALTJuniorTestNavigationController.additionalSafeAreaInsets.top).isActive = true
    }
    
    func setStep(_ step: Int) {
        _labelStep.text = "\(LevelTestManager.manager.totalQuizCount - 1 - step) 문제 남았습니다."
        self.view.layoutIfNeeded()
    }
    
    @objc private func pressedButton(_ button: UIButton) {
        switch button {
        case buttonClose:
            self.dismiss(animated: true, completion: nil)
            break
            
        default:
            break
        }
    }
}
