//
//  ALLTProgressBarView.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/06.
//

import UIKit

class ALLTProgressBarView: UIView {
    private let _progressView = UIView()
    private let _contentView = UIView()
    
    private var _step = 0
    var step: Int {
        get { return _step }
        set { setStep(newValue, animated: false) }
    }
    
    private var _totalQuizCount = 0
    
    lazy private var _constraintProgressWidth: NSLayoutConstraint = {
        return _progressView.widthAnchor.constraint(equalToConstant: 20.optimized)
    }()
    
    var currentStep = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.backgroundColor = ColourKit.Code.HexCCCCCC
        
        _progressView.translatesAutoresizingMaskIntoConstraints = false
//        _progressView.backgroundColor = ColourKit.Code.Static.HexF44F69
        _progressView.backgroundColor = AiLevelTestKit.shared.themeColour
        self.addSubview(_progressView)
        
        _progressView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        _progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        _progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        _constraintProgressWidth.isActive = true
        
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(_contentView)
        
        _contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        _contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        _contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.optimized).isActive = true
        _contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.optimized).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.size.height / 2
    }
    
    func reloadData() {
        for subview in _contentView.subviews {
            subview.removeFromSuperview()
        }
        
        _totalQuizCount = LevelTestManager.manager.totalQuizCount
        
        var leadingAnchor = _contentView.leadingAnchor
        
        for i in 0 ..< LevelTestManager.manager.categories.count {
            let category = LevelTestManager.manager.categories[i]
            
            guard category.numberOfQuizs > 0 else { continue }
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = category.name
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12.optimized, weight: .regular)
            _contentView.addSubview(label)
            
            label.topAnchor.constraint(equalTo: _contentView.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: _contentView.bottomAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            label.widthAnchor.constraint(equalTo: _contentView.widthAnchor, multiplier: 1 / CGFloat(LevelTestManager.manager.categories.count)).isActive = true
            
            leadingAnchor = label.trailingAnchor
            
            guard i < LevelTestManager.manager.categories.count - 1 else { continue }
            
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            separator.tag = 1001 + i
            _contentView.addSubview(separator)
            
            separator.topAnchor.constraint(equalTo: _contentView.topAnchor).isActive = true
            separator.bottomAnchor.constraint(equalTo: _contentView.bottomAnchor).isActive = true
            separator.centerXAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
            separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        setStep(0)
    }
    
    func setStep(_ step: Int, animated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            self?.layer.removeAllAnimations()
            
            self?.currentStep = step
            
            let unit = ((self?.bounds.size.width ?? 0) - 40.optimized) / CGFloat(LevelTestManager.manager.categories.count)
            
            let animations = {[weak self] () -> Void in
                var width = 20.optimized
                
                var tracking = 0
                var stop = false
                
                for i in 0 ..< LevelTestManager.manager.categories.count {
                    if tracking == step, stop { break }
                    
                    let category = LevelTestManager.manager.categories[i]
                    let subunit = unit / CGFloat(category.numberOfQuizs)
                    
                    for _ in 0 ..< category.numberOfQuizs {
                        if tracking == step {
                            stop = true
                            break
                        }
                        
                        width += subunit
                        
                        tracking += 1
                    }
                }
                
                self?._constraintProgressWidth.constant = width
                
                self?.layoutIfNeeded()
            }
            
            guard animated else {
                animations()
                return
            }
            
            UIView.animate(withDuration: 0.25, animations: animations)
        }
    }
}
