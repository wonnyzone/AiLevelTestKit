//
//  ALLTNavigationViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/08.
//

import UIKit

class ALLTNavigationViewController: ALTNavigationController {
    let progressBarView = ALLTProgressBarView()
    
    let buttonClose = UIButton()
    
    class var additionalSafeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 46, left: 0, bottom: 0, right: 0)
    }
    
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

        buttonClose.translatesAutoresizingMaskIntoConstraints = false
        buttonClose.setImage(UIImage(named: "img_close", in:Bundle(for: type(of: self)), compatibleWith:nil)?.resize(maxWidth: 32), for: .normal)
        buttonClose.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(buttonClose)

        buttonClose.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        buttonClose.leadingAnchor.constraint(equalTo: progressBarView.trailingAnchor).isActive = true
        buttonClose.widthAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .phone ? 54 : 88).isActive = true
        buttonClose.heightAnchor.constraint(equalToConstant: ALLTNavigationViewController.additionalSafeAreaInsets.top).isActive = true
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
