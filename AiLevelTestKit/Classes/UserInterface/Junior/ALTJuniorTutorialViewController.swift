//
//  ALTJuniorTutorialViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/24.
//

import UIKit

class ALTJuniorTutorialViewController: ALTBaseViewController {
    private let _scrollView = UIScrollView()
    
    private let _buttonNext = UIButton()
    private let _labelNext = UILabel()
    
    private let _labelTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var additionalSafeAreaInsets = ALTJuniorTestNavigationController.additionalSafeAreaInsets
        additionalSafeAreaInsets.bottom = 0
        self.additionalSafeAreaInsets = additionalSafeAreaInsets
        
        _labelTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle.text = "레벨테스트 방법"
        _labelTitle.textAlignment = .center
        _labelTitle.textColor = ColourKit.Code.Hex222222
        _labelTitle.font = UIFont.systemFont(ofSize: 18.optimized, weight: .semibold)
        _labelTitle.numberOfLines = 0
        self.view.addSubview(_labelTitle)
        
        _labelTitle.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant:  -ALTJuniorTestNavigationController.additionalSafeAreaInsets.top / 2).isActive = true
        _labelTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _labelTitle.widthAnchor.constraint(equalToConstant: 200.optimized).isActive = true
        
        let heightRatio = UIScreen.main.bounds.size.width < 400 ? UIScreen.main.bounds.size.height / 812 : QUtils.optimizeRatio()
        
        _buttonNext.translatesAutoresizingMaskIntoConstraints = false
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex3E3A39), for: .normal)
        _buttonNext.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonNext)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            _buttonNext.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        } else {
            _buttonNext.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80 * heightRatio).isActive = true
        }
        _buttonNext.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _buttonNext.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _buttonNext.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        _labelNext.translatesAutoresizingMaskIntoConstraints = false
        _labelNext.isUserInteractionEnabled = false
        _labelNext.text = "다음 >"
        _labelNext.textColor = ColourKit.Code.HexFFFFFF
        _labelNext.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 24 * heightRatio, weight: .semibold)
        _buttonNext.addSubview(_labelNext)
        
        _labelNext.topAnchor.constraint(equalTo: _buttonNext.topAnchor).isActive = true
        _labelNext.centerXAnchor.constraint(equalTo: _buttonNext.centerXAnchor).isActive = true
        _labelNext.heightAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 80 * heightRatio).isActive = true
        
        _scrollView.translatesAutoresizingMaskIntoConstraints = false
        _scrollView.isPagingEnabled = true
        _scrollView.delegate = self
        self.view.addSubview(_scrollView)
        
        _scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        _scrollView.bottomAnchor.constraint(equalTo: _buttonNext.topAnchor).isActive = true
        _scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        let stdView = UIView()
        _scrollView.addSubview(stdView)
        
        var titles = [NSAttributedString]()
        
        let getAttributedTitle = { (normalStr: String, boldStrs: [String], underlined: Bool) -> NSAttributedString in
            let norAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex222222, font: UIFont.systemFont(ofSize: 24 * heightRatio, weight: .regular)).attributes
            var boldAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex222222, font: UIFont.systemFont(ofSize: 24 * heightRatio, weight: .bold)).attributes
            
            if underlined {
                boldAttr[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
                boldAttr[.underlineColor] = ColourKit.Code.Hex222222.cgColor
            }
            
            var string = ""
            
            if boldStrs.count > 1 {
                string = String(format: normalStr, arguments: [boldStrs[0], boldStrs[1]])
            } else {
                string = String(format: normalStr, arguments: [boldStrs[0]])
            }
            
            let attributedString = NSMutableAttributedString(string: string, attributes: norAttr)
            for item in boldStrs {
                if let range = string.nsRange(of: item) {
                    attributedString.addAttributes(boldAttr, range: range)
                }
            }
            
            return attributedString
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titles.append(getAttributedTitle("%@에서 진행해주세요.", ["조용한 장소"], false))
            titles.append(getAttributedTitle("소리가 안들린다면 %@해주세요.", ["볼륨과 음소거를 확인"], false))
            titles.append(getAttributedTitle("정답을 모르는 문제는 %@를 선택해주세요.", ["‘모르겠어요’"], true))
            titles.append(getAttributedTitle("음성 녹음 중에는 %@", ["소리를 지르지 말고 큰 소리로 말해주세요."], false))
        } else {
            titles.append(getAttributedTitle("%@에서 진행해주세요.", ["조용한 장소"], false))
            titles.append(getAttributedTitle("소리가 안들린다면\n%@해주세요.", ["볼륨과 음소거를 확인"], false))
            titles.append(getAttributedTitle("정답을 모르는 문제는\n%@를 선택해주세요.", ["‘모르겠어요’"], (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) > 20))
            titles.append(getAttributedTitle("음성 녹음 중에는\n%@", ["소리를 지르지 말고\n큰 소리로 말해주세요."], false))
        }
        
        var leadingAnchor = stdView.leadingAnchor
        
        for i in 0 ..< titles.count {
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            _scrollView.addSubview(contentView)
            
            contentView.topAnchor.constraint(equalTo: stdView.topAnchor).isActive = true
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            contentView.widthAnchor.constraint(equalTo: _scrollView.widthAnchor).isActive = true
            contentView.heightAnchor.constraint(equalTo: _scrollView.heightAnchor).isActive = true
            
            let prefix = UIDevice.current.userInterfaceIdiom == .pad ? "img_jtutorial_pad" : "img_jtutorial"
            let image = UIImage(named: prefix + "\(i + 1)", in:Bundle(for: type(of: self)), compatibleWith:nil)
            
            var margin = (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) > 20 ? CGFloat(10) : CGFloat(25)
            if UIScreen.main.bounds.size.width < 400 {
                margin += 10
            }
            
            let backView = UIView()
            backView.translatesAutoresizingMaskIntoConstraints = false
            let bezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 32.optimized, height: 140 * heightRatio), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10).optimized)
            let layer = CAShapeLayer()
            layer.path = bezierPath.cgPath
            backView.layer.mask = layer
            backView.backgroundColor = ColourKit.Code.HexFFFFFF
            backView.clipsToBounds = true
            contentView.addSubview(backView)
            backView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.optimized).isActive = true
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.optimized).isActive = true
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.optimized).isActive = true
            backView.heightAnchor.constraint(equalToConstant: 140 * heightRatio).isActive = true
            
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = #colorLiteral(red: 0, green: 0.2784313725, blue: 0.6156862745, alpha: 1)
            backView.addSubview(separator)
            
            separator.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
            separator.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
            separator.trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 3.optimized).isActive = true
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.attributedText = titles[i]
            label.numberOfLines = 0
            backView.addSubview(label)
            
            label.topAnchor.constraint(equalTo: backView.topAnchor, constant: 6.optimized).isActive = true
            label.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -6.optimized).isActive = true
            label.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20.optimized).isActive = true
            label.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20.optimized).isActive = true
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = image?.resize(maxWidth: (image?.size.width ?? 0) * heightRatio)
            imageView.contentMode = .center
            contentView.addSubview(imageView)
            
            imageView.topAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            
            leadingAnchor = contentView.trailingAnchor
        }
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ALTJuniorTestNavigationController)?.isComponentHidden = true
        
        self.navigationItem.leftBarButtonItems = []
        self.navigationItem.rightBarButtonItems = []
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = ColourKit.Code.HexF0F0F0
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var contentSize = _scrollView.contentSize
        contentSize.width = _scrollView.bounds.size.width * 4
        _scrollView.contentSize = contentSize
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        switch button {
        case _buttonNext:
            let page = ((_scrollView.contentOffset.x + _scrollView.bounds.size.width / 2) / _scrollView.bounds.size.width).rounded(.down)
            
            guard page < 3 else {
                let isMicTestActivated = LevelTestManager.manager.examInfo?.isMicTestActivated ?? false
                
                if isMicTestActivated {
                    let viewController = ALTJuniorMicTestViewController()
                    self.navigationController?.setViewControllers([viewController], animated: true)
                    break
                }
                
                QIndicatorViewManager.shared.showIndicatorView {(complete) in
                    LevelTestManager.manager.startTest {[weak self] (testSrl, errMessage) in
                        QIndicatorViewManager.shared.hideIndicatorView()
                        
                        guard testSrl != nil, errMessage == nil else {
                            QIndicatorViewManager.shared.hideIndicatorView()
                            let alertController = UIAlertController(title: errMessage, message: nil, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                            self?.present(alertController, animated: true, completion: nil)
                            return
                        }
                        LevelTestManager.manager.getQuizViewController(isContinue: false) { (viewController, errMessage) in
                            guard viewController != nil else {
                                QIndicatorViewManager.shared.hideIndicatorView()
                                let alertController = UIAlertController(title: errMessage ?? "알 수 없는 오류입니다.", message: nil, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                                self?.present(alertController, animated: true, completion: nil)
                                return
                            }
                            
                            self?.navigationController?.setViewControllers([viewController!], animated: true)
                        }
                    }
                }
                break
            }
            
            var contentOffset = _scrollView.contentOffset
            contentOffset.x = UIScreen.main.bounds.size.width * CGFloat(page + 1)
            _scrollView.setContentOffset(contentOffset, animated: true)
            break
            
        default:
            break
        }
    }
}

extension ALTJuniorTutorialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = ((scrollView.contentOffset.x + scrollView.bounds.size.width / 2) / scrollView.bounds.size.width).rounded(.down)
        
        if page > 2 {
            _labelNext.text = (LevelTestManager.manager.examInfo?.isMicTestActivated ?? false) == true ? "마이크 테스트 시작하기 >" : "시작하기 >"
        } else {
            _labelNext.text = "다음 >"
        }
    }
}
