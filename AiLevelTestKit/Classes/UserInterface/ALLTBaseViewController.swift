//
//  ALLTBaseViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/05.
//

import UIKit

class ALLTBaseViewController: ALTBaseViewController {
    let step: Int
    let data: ALTLevelTest.Data
    
    internal let _labelRemainingCount = UILabel()
    
    init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, step: Int, data: ALTLevelTest.Data) {
        let totalQuizCount = LevelTestManager.manager.totalQuizCount
        guard step < totalQuizCount else {
            fatalError("Out of index: \(step). There are only \(totalQuizCount) quiz data(s).")
        }
        
        self.step = step
        self.data = data
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.additionalSafeAreaInsets = ALLTNavigationViewController.additionalSafeAreaInsets
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.Static.Hex00C9B7
        backView.layer.cornerRadius = 12.optimized
        backView.clipsToBounds = true
        self.view.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        backView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        backView.heightAnchor.constraint(equalToConstant: backView.layer.cornerRadius * 2).isActive = true
        
        let remaining = LevelTestManager.manager.totalQuizCount - step
        
        _labelRemainingCount.translatesAutoresizingMaskIntoConstraints = false
        _labelRemainingCount.text = remaining == 0 ? "마지막 문제입니다." : "\(remaining)문제 남았습니다."
        _labelRemainingCount.textAlignment = .center
        _labelRemainingCount.textColor = .white
        _labelRemainingCount.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
        backView.addSubview(_labelRemainingCount)
        
        _labelRemainingCount.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _labelRemainingCount.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _labelRemainingCount.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20.optimized).isActive = true
        _labelRemainingCount.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20.optimized).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.bringSubviewToFront(_labelRemainingCount.superview!)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        (self.navigationController as? ALLTNavigationViewController)?.progressBarView.setStep(step, animated: true)
    }
}
