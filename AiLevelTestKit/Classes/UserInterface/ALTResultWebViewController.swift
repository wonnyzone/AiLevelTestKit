//
//  ALTResultWebViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/12/08.
//

import UIKit

import WebKit

class ALTResultWebViewController: ALTBaseViewController {
    lazy private var _webView: WKWebView = {
        let contentController = WKUserContentController()
        
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.javaScriptEnabled = true
        config.userContentController = contentController
        
        contentController.add(self, name: "Dismiss")
        
        return WKWebView(frame: .zero, configuration: config)
    }()
    
    let testSrl: Int?
    
    init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, testSrl: Int?) {
        self.testSrl = testSrl
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        self.modalPresentationStyle = .fullScreen
        
        _webView.translatesAutoresizingMaskIntoConstraints = false
        _webView.backgroundColor = .black
        _webView.navigationDelegate = self
        _webView.uiDelegate = self
        self.view.addSubview(_webView)
        
        _webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        _webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        let stdView = UIView(frame: .zero)
        _webView.scrollView.addSubview(stdView)
        
        guard let url = URL(string: RequestUrl.Result.GetDetails + "?email=\(UserDataManager.manager.userId ?? "")&code=\(UserDataManager.manager.groupCode ?? "")&api_type=ios") else { return }
        
        UIPasteboard.general.string = url.absoluteString
        
//        print(url.absoluteString)
//        let javascript = "leveldirectResult(\"\(UserDataManager.manager.groupCode!)\",\"\(UserDataManager.manager.userId!)\",\(testSrl))"
//        print(javascript)
        
        let request = URLRequest(url: url)
        _webView.load(request)
    }
    
    func dismiss() {
        super.dismiss(animated: true)
    }
}

extension ALTResultWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let groupCode = UserDataManager.manager.groupCode, let userId = UserDataManager.manager.userId else { return }
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {[weak self] (timer) in
            var javascript = "leveltestResult()"
            if let testSrl = self?.testSrl {
                javascript = "leveldirectResult(\"\(groupCode)\",\"\(userId)\",\(testSrl))"
            }
            webView.evaluateJavaScript(javascript, completionHandler: nil)
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.mainDocumentURL, url.path.range(of: "/pdf/MypageResult.php") != nil {
            QIndicatorViewManager.shared.showIndicatorView {[weak self] (complete) in
                let viewController = ALTPDFViewController(with: url)
                let navController = UINavigationController(rootViewController: viewController)
                self?.present(navController, animated: true, completion: {
                    QIndicatorViewManager.shared.hideIndicatorView()
                })
            }
            
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
}

extension ALTResultWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        alertController.addAction(UIAlertAction(title: "예", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension ALTResultWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "Dismiss" {
            dismiss()
        }
    }
}
