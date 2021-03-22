//
//  BaseViewController.swift
//  Pickle
//
//  Created by Jun-kyu Jeon on 16/05/2019.
//  Copyright © 2019 DonutsKorea. All rights reserved.
//

import UIKit

import NotificationCenter

internal let kTagBarButtonItemClose = 101
internal let kTagBarButtonItemBack = 102
internal let kTagBarButtonItemForward = 103

class ALTBaseViewController: UIViewController {
    internal var viewDidAppearAtLeastOnce = false
    
    internal let httpClientSync = QHttpClient()
    internal var instanceHttpClients = [Int:QHttpClient]()
    internal var tagHttpClient = 1001
    
    internal var _imageDownloader = QImageDownloader()
    
    var isModal = false
    var isDarkNavigation = false
    
    var needToReload = false
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        if #available(iOS 13.0, *) {
//            return .darkContent
//        }
//        return .default
//    }
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLanguage), name: ALTAppStringManager.NotificationName.LanguageChanged, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        for (_, httpClient) in instanceHttpClients {
            httpClient.cancel()
        }
        
        NotificationCenter.default.removeObserver(self, name: ALTAppStringManager.NotificationName.LanguageChanged, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColourKit.Code.HexF0F0F0
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.navigationController?.delegate = self
        
        updateLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        (self.navigationController as? ALLTSeniorTestNavigationController)?.isComponentHidden = true
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        
//        UIApplication.appDelegate()?.currentViewController = self
        
        self.navigationItem.titleView = UIView()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "이전", style: .plain, target: nil, action: nil)
        
        if (self.navigationController?.viewControllers ?? []).count > 1 {
//            let backItem = UIBarButtonItem(image: UIImage.navigationBackwardImage.withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(self.pressedNavigationItem(_:)))
//
//            backItem.tintColor = isDarkNavigation ? ColourKit.Identity_Inverted : ColourKit.Identity
//            if #available(iOS 11.0, *) {
//                backItem.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0).optimized
//            }
//            backItem.tag = kTagBarButtonItemBack
//            self.navigationItem.leftBarButtonItems = [backItem]
        } else if self.presentingViewController != nil || self.navigationController?.presentingViewController != nil {
            isModal = true
            let closeItem = UIBarButtonItem(image: UIImage.navigationCloseImage.withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(self.pressedNavigationItem(_:)))
            closeItem.tag = kTagBarButtonItemClose
            self.navigationItem.leftBarButtonItems = [closeItem]
        } else {
//            self.navigationItem.leftBarButtonItems = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearAtLeastOnce = true
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *), let presentationController = self.navigationController?.presentationController ?? self.presentationController {
            presentationController.delegate?.presentationControllerWillDismiss?(presentationController)
        }
        super.dismiss(animated: flag, completion: completion)
    }
    
    internal func setConstraints() {
        
    }
    
    @objc internal func pressedNavigationItem(_ item: UIBarButtonItem) {
        switch item.tag {
        case kTagBarButtonItemClose:
            guard canDimissSelf() else { break }
            doWhenDismissing()
            self.dismiss(animated: true, completion: nil)
            break
            
        case kTagBarButtonItemBack:
            guard canDimissSelf() else { break }
            doWhenDismissing()
            self.navigationController?.popViewController(animated: true)
            break
            
        default:
            break
        }
    }
    
    @objc internal func pressedButton(_ button: UIButton) {}
    
    @objc internal func updateLanguage() {
        
    }
    
    @objc func pressedTabButton() {
        guard (self.navigationController?.viewControllers ?? []).count > 1 else { return }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    internal func canDimissSelf() -> Bool {
        return true
    }
    
    internal func doWhenDismissing() {}
    
    @objc internal func receivedLocalPush(_ notification: Notification) {
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .pad ? .landscapeRight : .portrait
    }
}

extension ALTBaseViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print("presentationControllerWillDismiss")
    }
}

extension ALTBaseViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .pad ? .landscapeRight : .portrait
    }
}
