//
//  ALLTSeniorTestProgressBarView.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALLTSeniorTestProgressBarView: UIView {
    private var _labels = [Int:UILabel]()
    private var _labelCount = UILabel()
    
    private var _step = 0
    var step: Int {
        get { return _step }
        set { setStep(newValue, animated: false) }
    }
    
    private var _totalQuizCount = 0
    
    private var _constraintCurrentCategory = [Int:NSLayoutConstraint]()
    
    var currentStep = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.Hex222222
        backView.layer.cornerRadius = 9
        backView.clipsToBounds = true
        self.addSubview(backView)
        
        backView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        _labelCount.translatesAutoresizingMaskIntoConstraints = false
        _labelCount.textColor = ColourKit.Code.HexFFFFFF
        _labelCount.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        backView.addSubview(_labelCount)
        
        _labelCount.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        _labelCount.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        _labelCount.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 7).isActive = true
        _labelCount.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -7).isActive = true
        
        reloadData()
        
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func reloadData() {
        for subview in self.subviews {
            guard subview != _labelCount.superview else { continue }
            
            subview.removeFromSuperview()
        }
        
        _totalQuizCount = LevelTestManager.manager.totalQuizCount
        
        var leadingAnchor: NSLayoutXAxisAnchor?
        
        for i in 0 ..< LevelTestManager.manager.categories.count {
            let category = LevelTestManager.manager.categories[i]
            
            guard category.numberOfQuizs > 0 else { continue }
            
            if i > 0, leadingAnchor != nil {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = " - "
                label.textColor = ColourKit.Code.HexAAAAAA
                label.font = UIFont.systemFont(ofSize: 14.optimized, weight: .regular)
                self.addSubview(label)
                
                label.leadingAnchor.constraint(equalTo: leadingAnchor!).isActive = true
                label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                
                leadingAnchor = label.trailingAnchor
            }
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = category.name
            label.textColor = ColourKit.Code.HexAAAAAA
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14.optimized, weight: .regular)
            self.addSubview(label)
            
//            label.bottomAnchor.constraint(equalTo: _contentView.bottomAnchor).isActive = true
            if leadingAnchor == nil {
                label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.optimized).isActive = true
            } else {
                label.leadingAnchor.constraint(equalTo: leadingAnchor!).isActive = true
            }
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            _labels[i] = label
            
            _constraintCurrentCategory[i] = _labelCount.superview?.centerXAnchor.constraint(equalTo: label.centerXAnchor)
            
            leadingAnchor = label.trailingAnchor
        }
        
        setStep(0)
    }
    
    func setStep(_ step: Int, animated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            self?.layer.removeAllAnimations()
            
            var remaining = step
            var categoryIndex = -1
            
            var count = 0
            for i in 0 ..< LevelTestManager.manager.categories.count {
                let category = LevelTestManager.manager.categories[i]
                
                guard step < count + category.numberOfQuizs else {
                    count += category.numberOfQuizs
                    continue
                }
                
                remaining = step - count
                categoryIndex = i
                break
            }
            
            guard categoryIndex >= 0 else { return }
            
            self?.currentStep = step
            
            self?._labelCount.text = "\(remaining + 1)/\(LevelTestManager.manager.categories[categoryIndex].numberOfQuizs)"
           
            let animations = {[weak self] in
                for i in 0 ..< LevelTestManager.manager.categories.count {
                    self?._constraintCurrentCategory[i]?.isActive = categoryIndex == i
                    self?._labels[i]?.textColor = categoryIndex == i ? ColourKit.Code.Hex222222 : ColourKit.Code.HexAAAAAA
                }
                
                self?.layoutIfNeeded()
            }
            
            self?.layer.removeAllAnimations()
            
            guard animated else {
                animations()
                return
            }
            
            UIView.animate(withDuration: 0.25, animations: animations)
        }
    }
}
