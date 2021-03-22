//
//  QIndicatorViewManager.swift
//  QKit
//
//  Created by Jun-kyu Jeon on 30/8/16.
//  Copyright © 2016 - present Jun-kyu Jeon. All rights reserved.
//

import UIKit

class QIndicatorViewManager: NSObject {
    static let shared = QIndicatorViewManager()
    
    private var backgroundView: UIView?
    private var indicatorView: UIActivityIndicatorView?
    
    func showIndicatorView() {
        self.showIndicatorView { (complete) in }
    }
    
    func showIndicatorView(completion: @escaping (Bool) -> ()) {
        guard backgroundView == nil else {
            completion(false)
            
            guard let indicatorView = indicatorView else { return }
            indicatorView.startAnimating()
            return
        }
        
        backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)                  // fix colour
        UIApplication.shared.keyWindow?.addSubview(backgroundView!)
        
        let isDarkMode = backgroundView!.traitCollection.userInterfaceStyle == .dark
        
        let group = DispatchGroup()
        group.enter()

        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            
            if #available(iOS 13.0, *) {
                self.indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .large)
            } else {
                self.indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            }
            self.indicatorView?.color = AiLevelTestKit.shared.themeColour
            self.indicatorView?.translatesAutoresizingMaskIntoConstraints = false
            self.indicatorView?.hidesWhenStopped = true
            self.backgroundView?.addSubview(self.indicatorView!)
            
            self.indicatorView?.centerXAnchor.constraint(equalTo: self.backgroundView!.centerXAnchor).isActive = true
            self.indicatorView?.centerYAnchor.constraint(equalTo: self.backgroundView!.centerYAnchor).isActive = true
            
            self.backgroundView?.layoutIfNeeded()
            
            self.indicatorView?.startAnimating()
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(true)
        }
    }
    
    func hideIndicatorView() {
        DispatchQueue.main.async {[weak self] in
            self?.indicatorView?.stopAnimating()
            self?.indicatorView?.removeFromSuperview()
            self?.indicatorView = nil
            
            self?.backgroundView?.removeFromSuperview()
            self?.backgroundView = nil
        }
    }
}
