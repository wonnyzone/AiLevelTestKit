//
//  ALLTSeniorTestNavigationController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALLTSeniorTestNavigationController: ALTNavigationController {
    class var additionalSafeAreaInsets: UIEdgeInsets {
        guard UIDevice.current.userInterfaceIdiom != .pad else {
            return UIEdgeInsets(top: 60, left: 0, bottom: 120, right: 0)
        }
        
        return UIEdgeInsets(top: 60, left: 0, bottom: 100, right: 0)
    }
    
    var isComponentHidden = false {
        didSet {
            progressBarView.isHidden = isComponentHidden
            buttonClose.isHidden = isComponentHidden
            _labelTime.superview?.isHidden = isComponentHidden
        }
    }
    
    let progressBarView = ALLTSeniorTestProgressBarView()
    
    let buttonClose = UIButton()
    
    private let _labelTime = UILabel()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: LevelTestManager.NotificationName.timeUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: LevelTestManager.NotificationName.timesUp, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonClose.translatesAutoresizingMaskIntoConstraints = false
        buttonClose.setImage(UIImage(named: "img_close_blk", in:Bundle(for: type(of: self)), compatibleWith:nil)?.resize(maxWidth: 32), for: .normal)
        buttonClose.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(buttonClose)

        buttonClose.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        buttonClose.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        buttonClose.widthAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .phone ? 52 : 88).isActive = true
        buttonClose.heightAnchor.constraint(equalToConstant: ALLTSeniorTestNavigationController.additionalSafeAreaInsets.top).isActive = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backView.layer.cornerRadius = 14
        backView.clipsToBounds = true
        self.view.addSubview(backView)
        
        backView.trailingAnchor.constraint(equalTo: buttonClose.leadingAnchor, constant: 4).isActive = true
        backView.centerYAnchor.constraint(equalTo: buttonClose.centerYAnchor).isActive = true
        backView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "img_time", in:Bundle(for: type(of: self)), compatibleWith:nil)
        backView.addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 11).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 9).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 11).isActive = true
        imageView.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        
        let remainingTime = LevelTestManager.manager.remainingTime
        
        let mins = remainingTime / 60
        let secs = remainingTime % 60
        
        _labelTime.translatesAutoresizingMaskIntoConstraints = false
        _labelTime.text = String(format: "%02d:%02d", arguments: [mins, secs])
        _labelTime.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        _labelTime.textAlignment = .center
        _labelTime.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        _labelTime.sizeToFit()
        backView.addSubview(_labelTime)
        
        _labelTime.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _labelTime.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _labelTime.widthAnchor.constraint(equalToConstant: _labelTime.bounds.size.width + 5).isActive = true
        _labelTime.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4).isActive = true
        _labelTime.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -11).isActive = true
        
        progressBarView.translatesAutoresizingMaskIntoConstraints = false
        progressBarView.layer.zPosition = 1000
        self.view.addSubview(progressBarView)

        progressBarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        if UIDevice.current.userInterfaceIdiom == .phone {
            progressBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        } else {
            progressBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10.optimized).isActive = true
        }
        
        progressBarView.trailingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        progressBarView.heightAnchor.constraint(equalToConstant: ALLTSeniorTestNavigationController.additionalSafeAreaInsets.top).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedNotification(_:)), name: LevelTestManager.NotificationName.timeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedNotification(_:)), name: LevelTestManager.NotificationName.timesUp, object: nil)
    }
    
    @objc private func pressedButton(_ button: UIButton) {
        switch button {
        case buttonClose:
            let alertController = UIAlertController(title: "정말 종료하시겠습니까?", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "예", style: .default, handler: {[weak self] (action) in
                LevelTestManager.manager.exitTest()
                self?.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
            break
            
        default:
            break
        }
    }
    
    @objc private func receivedNotification(_ notification: Notification) {
        switch notification.name {
        case LevelTestManager.NotificationName.timeUpdated:
            let remainingTime = LevelTestManager.manager.remainingTime
            
            let mins = remainingTime / 60
            let secs = remainingTime % 60
            
            self._labelTime.text = String(format: "%02d:%02d", arguments: [mins, secs])
            self.view.layoutIfNeeded()
            break
            
        case LevelTestManager.NotificationName.timesUp:
            let alertController = UIAlertController(title: "시간이 초과되었습니다.\n레벨테스트를 다시 진행합니다.", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: {[weak self] (action) in
                guard let testingSrl = LevelTestManager.manager.testSrl else { return }
                
                QIndicatorViewManager.shared.showIndicatorView { [weak self] (complete) in
                    LevelTestManager.manager.RestartTest(testSrl: testingSrl) {[weak self] (testSrl, errMessage) in
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
                            
                            self?.setViewControllers([viewController!], animated: true)
                        }
                    }
                }
            }))
            self.present(alertController, animated: true, completion: nil)
            break
            
        default:
            break
        }
    }
}
