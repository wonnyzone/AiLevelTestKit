//
//  BaseTransparentViewController.swift
//  Durutalk
//
//  Created by Jun-kyu Jeon on 2020/04/20.
//  Copyright © 2020 Jun-kyu Jeon. All rights reserved.
//

import UIKit

class ALTBaseTransparentViewController: ALTBaseViewController {
    internal let buttonDismiss = UIButton()
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        
        self.navigationController?.navigationBar.barTintColor = .clear
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        buttonDismiss.translatesAutoresizingMaskIntoConstraints = false
        buttonDismiss.addTarget(self, action: #selector(self.pressedDismissButton(_:)), for: .touchUpInside)
        self.view.addSubview(buttonDismiss)
        
        buttonDismiss.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        buttonDismiss.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        buttonDismiss.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        buttonDismiss.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    @objc private func pressedDismissButton(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
