//
//  ALTPDFViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/02.
//

import UIKit

import PDFKit

class ALTPDFViewController: ALTBaseViewController {
    private let _pdfView = PDFView()
    
    private let _url: URL
    
    lazy private var _barButtonItemSave: UIBarButtonItem = {
        let item = UIBarButtonItem(title: ALTAppString.General.Save, style: .plain, target: self, action: #selector(self.pressedNavigationItem(_:)))
        
        let attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Static.Hex3296D7, font: UIFont.systemFont(ofSize: 14.optimized, weight: .regular))
        item.setTitleTextAttributes(attributes.attributes, for: .normal)
        attributes.foregroundColour = ColourKit.Code.Hex555555
        item.setTitleTextAttributes(attributes.attributes, for: .highlighted)
        return item
    }()
    
    init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, with url: URL) {
        _url = url
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_pdfView)
        
        _pdfView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        _pdfView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _pdfView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _pdfView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        guard let pdfDoc = PDFDocument(url: _url) else { return }
        _pdfView.document = pdfDoc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItems = [_barButtonItemSave]
    }
    
    override func pressedNavigationItem(_ item: UIBarButtonItem) {
        super.pressedNavigationItem(item)
        
        switch item {
        case _barButtonItemSave:
            QIndicatorViewManager.shared.showIndicatorView {[weak self] (complete) in
                guard let self = self else {
                    QIndicatorViewManager.shared.hideIndicatorView()
                    return
                }
                
                let urlRequest = URLRequest(url: self._url)
                
                let task = URLSession.shared.dataTask(with: urlRequest) {[weak self] (data, response, error) in
                    QIndicatorViewManager.shared.hideIndicatorView()
                    
                    guard let pdfData = data else { return }
                    
                    DispatchQueue.main.async { [weak self] in
                        let activityViewController = UIActivityViewController(activityItems: ["My test result", pdfData], applicationActivities: nil)
                        self?.present(activityViewController, animated: true, completion: nil)
                    }
                }
                task.resume()
            }
            break
            
        default:
            break
        }
    }
}
