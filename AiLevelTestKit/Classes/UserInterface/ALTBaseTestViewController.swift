//
//  ALTBaseTestViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/24.
//

import UIKit

class ALTBaseTestViewController: ALTBaseViewController {
    let step: Int
    
    internal let _buttonSkip = UIButton()
    internal let _buttonNext = UIButton()
    internal let _labelGuide = UILabel()
    
    internal var _isSkippable: Bool = true {
        didSet {
            _buttonSkip.isEnabled = _isSkippable
            _buttonSkip.layer.borderWidth = (_isSkippable && LevelTestManager.manager.isJunior == false) ? 1 : 0
            _buttonSkip.layer.borderColor = ((_isSkippable && LevelTestManager.manager.isJunior == false) ? ColourKit.Code.HexAAAAAA : .clear).cgColor
        }
    }
    
    internal var _answer: String?
    
    let testData: ALTLevelTest
    
    internal var canGoNext: Bool {
        return true
    }
    
    internal var _guideString: String?
    
    init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, step: Int, testData: ALTLevelTest) {
        self.testData = testData
        
        self.step = step
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        QIndicatorViewManager.shared.hideIndicatorView()
        
        (self.navigationController as? ALLTSeniorTestNavigationController)?.isComponentHidden = false
        (self.navigationController as? ALTJuniorTestNavigationController)?.isComponentHidden = false
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem()]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem()]
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        (self.navigationController as? ALLTSeniorTestNavigationController)?.progressBarView.setStep(step, animated: true)
        (self.navigationController as? ALTJuniorTestNavigationController)?.progressBarView.setStep(step, animated: true)
        (self.navigationController as? ALTJuniorTestNavigationController)?.setStep(step)
        
        if let sview = _labelGuide.superview {
            self.view.bringSubview(toFront: sview)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LevelTestManager.manager.startTimerIfNeed()
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        switch button {
        case _buttonSkip:
            guard _isSkippable else { break }
            
            let alertController = UIAlertController(title: "다음 문제로 넘어가겠습니까?", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "계속하기", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "넘어가기", style: .default, handler: {[weak self] (action) in
                guard let self = self else { return }
                self._answer = "SKIP!"
                self.pressedButton(self._buttonNext)
            }))
            self.present(alertController, animated: true, completion: nil)
            break
        
        case _buttonNext:
            if button == _buttonNext, _answer == nil { return }
            
            guard canGoNext else { break }
            
            DispatchQueue.main.async {[weak self] in
                self?._buttonNext.isEnabled = false
                self?._isSkippable = false
            }
                
            QIndicatorViewManager.shared.showIndicatorView {[weak self] (complete) in
                let httpClient = QHttpClient()
                httpClient.method = .Post
                
                var params = [String:Any]()
                params["test_srl"] = self?.testData.testInfo?.testSrl
                params["set_srl"] = self?.testData.quiz?.category?.setSrl
                params["level_srl"] = self?.testData.quiz?.levelSrl
                params["answer"] = self?._answer ?? ""
                params["sequence"] = self?.testData.quiz?.sequence
                params["order"] = (self?.step ?? 0) + 1
                params["active_time"] = LevelTestManager.manager.activeTime
                httpClient.parameters = QHttpClient.Parameter(dict: params)
                
                httpClient.sendRequest(to: RequestUrl.Test.Quiz.Answer) { [weak self] (code, errMessage, response) in
                    let showError = {[weak self] in
                        QIndicatorViewManager.shared.hideIndicatorView()
                        
                        self?._buttonNext.isEnabled = true
                        
                        let alertController = UIAlertController(title: errMessage ?? "알 수 없는 오류입니다.", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                        self?.present(alertController, animated: true, completion: nil)
                    }
                    
                    guard code == .success, let responseData = response as? [String:Any], let testSrl = (responseData["test_info"] as? [String:Any])?["test_srl"] as? Int else {
                        showError()
                        return
                    }
                    
                    let isCompleted = responseData["complete"] as? Bool ?? false
                    
                    guard isCompleted == false else {
                        if LevelTestManager.manager.examInfo?.examSetup2 == 1 {
                            self?.dismiss(animated: true, completion: {
                                let viewController = ALTResultWebViewController(testSrl: testSrl)
                                viewController.modalPresentationStyle = .overFullScreen
                                UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: {
                                    QIndicatorViewManager.shared.hideIndicatorView()
                                })
                            })
                        } else if LevelTestManager.manager.examInfo?.examSetup2 == 2 {
                            let alertController = UIAlertController(title: "모든 문제를 완료하셨습니다.\n결과를 확인해보시겠어요?", message: nil, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: nil))
                            alertController.addAction(UIAlertAction(title: "결과 확인", style: .default, handler: {[weak self] (action) in
                                self?.dismiss(animated: true, completion: {
                                    let viewController = ALTResultWebViewController(testSrl: testSrl)
                                    viewController.modalPresentationStyle = .overFullScreen
                                    UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: {
                                        QIndicatorViewManager.shared.hideIndicatorView()
                                    })
                                })
                            }))
                            self?.present(alertController, animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: "모든 문제를 완료하셨습니다.", message: nil, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                            self?.present(alertController, animated: true, completion: nil)
                        }
                        
                        return
                    }
                    
                    guard let order = self?.testData.quiz?.order else {
                        showError()
                        return
                    }
                    
                    LevelTestManager.manager.getQuizViewController(for: order, isContinue: true) { (viewController, errMessage) in
                        guard viewController != nil else {
                            QIndicatorViewManager.shared.hideIndicatorView()
                            
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
            
        default:
            break
        }
    }
}
