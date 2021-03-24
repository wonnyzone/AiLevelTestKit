//
//  ALTPrivacyPolciesViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/16.
//

import UIKit

import WebKit

import BEMCheckBox

class ALTPrivacyPoliciesViewController: ALTBaseViewController {
    private let _buttonClose = UIButton()
    
    private let _htmlView = WKWebView()
    
    private let _buttonAgree = UIButton()
    private let _checkBoxAgree = BEMCheckBox(frame: CGRect(x: 0, y: 0, width: 18, height: 18).optimized)
    private let _buttonNext = UIButton()
    
    private var _isAgreed = false {
        didSet {
            _checkBoxAgree.setOn(_isAgreed, animated: true)
            _buttonNext.isEnabled = _isAgreed
        }
    }
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColourKit.Code.Hex27272C
        
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "개인정보 제3자 활용 동의서"
        label.textColor = ColourKit.Code.HexFFFFFF
        label.font = UIFont.systemFont(ofSize: 20.optimized, weight: .regular)
        self.view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.optimized).isActive = true
        
        _buttonClose.translatesAutoresizingMaskIntoConstraints = false
        _buttonClose.setImage(UIImage(named: "img_close_blk", in:Bundle(for: type(of: self)), compatibleWith:nil)?.resize(maxWidth: 32.optimized), for: .normal)
        _buttonClose.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonClose)
        
        _buttonClose.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        _buttonClose.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        _buttonClose.widthAnchor.constraint(equalToConstant: 52.optimized).isActive = true
        _buttonClose.heightAnchor.constraint(equalToConstant: 52.optimized).isActive = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.Hex121212
        self.view.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20.optimized).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        backView.heightAnchor.constraint(equalToConstant: 300.optimized).isActive = true
        
        _htmlView.translatesAutoresizingMaskIntoConstraints = false
//        _htmlView.delegate = self
        _htmlView.isOpaque = false
        _htmlView.backgroundColor = .clear
        backView.addSubview(_htmlView)
        
        _htmlView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 20.optimized).isActive = true
        _htmlView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -20.optimized).isActive = true
        _htmlView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20.optimized).isActive = true
        _htmlView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20.optimized).isActive = true
        
        _buttonAgree.translatesAutoresizingMaskIntoConstraints = false
        _buttonAgree.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonAgree)
        
        _buttonAgree.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 21.optimized).isActive = true
        _buttonAgree.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _buttonAgree.heightAnchor.constraint(equalToConstant: 38.optimized).isActive = true
        
        _checkBoxAgree.translatesAutoresizingMaskIntoConstraints = false
        _checkBoxAgree.boxType = .square
        _checkBoxAgree.on = _isAgreed
        _checkBoxAgree.isUserInteractionEnabled = false
        _checkBoxAgree.tintColor = ColourKit.Code.Static.Hex2D78CD
        _checkBoxAgree.offFillColor = .clear
        _checkBoxAgree.onTintColor = ColourKit.Code.Static.Hex2D78CD
        _checkBoxAgree.onFillColor = ColourKit.Code.Static.Hex2D78CD
        _checkBoxAgree.onCheckColor = .white
        _checkBoxAgree.lineWidth = 2.optimized
        _checkBoxAgree.onAnimationType = .bounce
        _checkBoxAgree.offAnimationType = .flat
        _checkBoxAgree.animationDuration = 0.25
        self.view.addSubview(_checkBoxAgree)
        
        _checkBoxAgree.widthAnchor.constraint(equalToConstant: 18.optimized).isActive = true
        _checkBoxAgree.heightAnchor.constraint(equalToConstant: 18.optimized).isActive = true
        _checkBoxAgree.leadingAnchor.constraint(equalTo: _buttonAgree.leadingAnchor, constant: 20.optimized).isActive = true
        _checkBoxAgree.centerYAnchor.constraint(equalTo: _buttonAgree.centerYAnchor).isActive = true
        
        let bold = "(필수)"
        let string = String(format: "개인정보 제3자 활동 동의 %@", arguments: [bold])
        
        var attributes = QTextAttributes(withForegroundColour: ColourKit.Code.HexFFFFFF, font: UIFont.systemFont(ofSize: 16.optimized, weight: .regular))
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes.attributes)
        if let range = string.nsRange(of: bold) {
//            attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Static.HexFA4175, font: UIFont.systemFont(ofSize: 16.optimized, weight: .regular))
            attributes = QTextAttributes(withForegroundColour: AiLevelTestKit.shared.themeColour, font: UIFont.systemFont(ofSize: 16.optimized, weight: .regular))
            attributedString.addAttributes(attributes.attributes, range: range)
        }
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.attributedText = attributedString
        _buttonAgree.addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: _buttonAgree.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: _checkBoxAgree.trailingAnchor, constant: 8.optimized).isActive = true
        label.trailingAnchor.constraint(equalTo: _buttonAgree.trailingAnchor, constant: -20.optimized).isActive = true
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "미동의 시 레벨테스트 서비스가 제공되지 않습니다."
        label.textColor = ColourKit.Code.Hex888888
        label.font = UIFont.systemFont(ofSize: 13.optimized, weight: .regular)
        self.view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: _buttonAgree.bottomAnchor, constant: 2.optimized).isActive = true
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        _buttonNext.translatesAutoresizingMaskIntoConstraints = false
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Static.Hex2D78CD), for: .normal)
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexAAAAAA), for: .disabled)
        _buttonNext.setTitle("다음", for: .normal)
        _buttonNext.setTitleColor(.white, for: .normal)
        _buttonNext.setTitleColor(.white, for: .disabled)
        _buttonNext.titleLabel?.font = UIFont.systemFont(ofSize: 16.optimized, weight: .regular)
        _buttonNext.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonNext.isEnabled = _isAgreed
        self.view.addSubview(_buttonNext)
        
        _buttonNext.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 39.optimized).isActive = true
        _buttonNext.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.optimized).isActive = true
        _buttonNext.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.optimized).isActive = true
        _buttonNext.heightAnchor.constraint(equalToConstant: 52.optimized).isActive = true
        
        if let htmlString = UserDataManager.manager.groupInfo?.agreement {
            _htmlView.loadHTMLString("<span style=\"font-size: \(36)px; color: rgb(230, 230, 230);\">" + htmlString + "</span>", baseURL: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        switch button {
        case _buttonClose:
            self.dismiss(animated: true)
            break
        
        case _buttonAgree:
            _isAgreed = !_isAgreed
            break
            
        case _buttonNext:
            guard _isAgreed else {
                let alertController = UIAlertController(title: "개인정보 동의를 눌러야 테스트가 가능합니다.", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return 
            }
            
            QIndicatorViewManager.shared.showIndicatorView {[weak self] (complete) in
                let httpClient = QHttpClient()
                
                var params = [String:Any]()
                params["customer_srl"] = LevelTestManager.manager.customerSrl
                params["agreement"] = (self?._isAgreed ?? false) ? "Y" : "N"
                httpClient.parameters = QHttpClient.Parameter(dict: params)
                
                httpClient.sendRequest(to: RequestUrl.Terms.Agree) {[weak self] (code, errMessage, response) in
                    QIndicatorViewManager.shared.hideIndicatorView()
                    
                    if LevelTestManager.manager.examInfo?.isCouponActivated ?? false == true {
                        let viewController = ALTCouponListViewController()
                        self?.navigationController?.pushViewController(viewController, animated: true)
                        return
                    }
                    
                    QDataManager.shared.isSkipTerms = true
                    QDataManager.shared.commit()
                    
                    let viewController = ALTTutorialViewController()
                    self?.navigationController?.setViewControllers([viewController], animated: true)
                    return
                }
            }
            
        default:
            break
        }
    }
}

extension ALTPrivacyPoliciesViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard scrollView == _textViewContent else { return }
//
//        for subview in scrollView.subviews {
//            (subview as? UIImageView)?.backgroundColor = ColourKit.Code.Static.Hex2D78CD
//        }
//    }
}

extension ALTPrivacyPoliciesViewController: UITextViewDelegate {
    
}
