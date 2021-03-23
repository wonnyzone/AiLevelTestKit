//
//  ALTTutorialViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/16.
//

import UIKit

class ALTTutorialViewController: ALTBaseViewController {
    lazy private var _barButtonItemClose: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "img_close_blk", in:Bundle(for: type(of: self)), compatibleWith:nil)?.resize(maxWidth: 32.optimized).withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.pressedNavigationItem(_:)))
        return item
    }()
    
    private let _scrollView = UIScrollView()
    
    private let _buttonNext = UIButton()
    private let _labelNext = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "튜토리얼"
        
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
        
        let getAttributedTitle = { (normalStr: String, boldStrs: [String]) -> NSAttributedString in
            let norAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex222222, font: UIFont.systemFont(ofSize: 24 * heightRatio, weight: .regular)).attributes
            let boldAttr = QTextAttributes(withForegroundColour: ColourKit.Code.Hex222222, font: UIFont.systemFont(ofSize: 24 * heightRatio, weight: .bold)).attributes
            
            var string = ""
            
            if boldStrs.count > 1 {
                string = String(format: normalStr, arguments: [boldStrs[0], boldStrs[1]])
            } else {
                string = String(format: normalStr, arguments: [boldStrs[0]])
            }
            
            let attributedString = NSMutableAttributedString(string: string, attributes: norAttr)
            for item in boldStrs {
//                guard let subString = item else { continue }
                if let range = string.nsRange(of: item) {
                    attributedString.addAttributes(boldAttr, range: range)
                }
            }
            
            return attributedString
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            titles.append(getAttributedTitle("%@는\n%@으로 진행됩니다.", ["레벨테스트", "총 30문항"]))
            titles.append(getAttributedTitle("정확한 음성 인식을 위해\n%@ 진행해주세요!", ["테스트는 조용한 환경에서"]))
            titles.append(getAttributedTitle("외부 소음으로 인해 자동으로 종료가 안 될 경우\n%@ 녹음이 종료됩니다.", ["종료 버튼을 터치하면"]))
            titles.append(getAttributedTitle("답을 모른 경우 %@ 문제 풀이 및 녹음을 완료한 후\n%@ 다음 문항으로 넘어갑니다.", ["SKIP 버튼을", "NEXT 버튼을 터치하면"]))
            titles.append(getAttributedTitle("테스트 중간에 페이지에서 나가게 되면%@", ["\n재접속시 종료 시점부터 ‘이어하기’가 가능합니다."]))
        } else {
            titles.append(getAttributedTitle("%@는\n%@으로 진행됩니다.", ["레벨테스트", "총 30문항"]))
            titles.append(getAttributedTitle("테스트 문항은\n%@\n모든 문항을 풀어야\n테스트가 완료됩니다.", ["Skip 할 수 없으며,"]))
            titles.append(getAttributedTitle("정확한 음성 인식을 위해\n%@\n진행해주세요!", ["테스트는 조용한 환경에서"]))
            titles.append(getAttributedTitle("문제 풀이 및 녹음을 완료한 후\n%@\n다음 문항으로 넘어갑니다.", ["NEXT 버튼을 클릭하면"]))
            titles.append(getAttributedTitle("테스트 중간에\n페이지에서 나가게 되면%@", ["\n재접속시 종료 시점부터\n‘이어하기’가 가능합니다."]))
        }
        
        var leadingAnchor = stdView.leadingAnchor
        
        for i in 0 ..< 5 {
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            _scrollView.addSubview(contentView)
            
            contentView.topAnchor.constraint(equalTo: stdView.topAnchor).isActive = true
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            contentView.widthAnchor.constraint(equalTo: _scrollView.widthAnchor).isActive = true
            contentView.heightAnchor.constraint(equalTo: _scrollView.heightAnchor).isActive = true
            
            let prefix = UIDevice.current.userInterfaceIdiom == .pad ? "img_tutorial_pad" : "img_tutorial"
            let image = UIImage(named: prefix + "\(i + 1)", in:Bundle(for: type(of: self)), compatibleWith:nil)
            
            var margin = (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) > 20 ? CGFloat(10) : CGFloat(25)
            if UIScreen.main.bounds.size.width < 400 {
                margin += 10
            }
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            contentView.addSubview(imageView)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                let ratio = UIScreen.main.bounds.size.width / 1024
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 772 * ratio).isActive = true
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: (image?.size.height ?? 0) / (image?.size.width ?? 1)).isActive = true
            } else {
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin * 1.optimized).isActive = true
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: margin * -1.optimized).isActive = true
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: (image?.size.height ?? 0) / (image?.size.width ?? 1)).isActive = true
            }
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.attributedText = titles[i]
            label.numberOfLines = 0
            contentView.addSubview(label)
            
            label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.optimized).isActive = true
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.optimized).isActive = true
            
            leadingAnchor = contentView.trailingAnchor
        }
        
        self.view.layoutIfNeeded()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.leftBarButtonItems = []
        self.navigationItem.rightBarButtonItems = [_barButtonItemClose]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex3E3A39), for: .default)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = ColourKit.Code.Hex3E3A39
        
        let label = UILabel()
        label.text = self.title
        label.textColor = ColourKit.Code.HexFFFFFF
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.sizeToFit()
        self.navigationItem.titleView = label
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var contentSize = _scrollView.contentSize
        contentSize.width = _scrollView.bounds.size.width * 5
        _scrollView.contentSize = contentSize
    }
    
    override func pressedNavigationItem(_ item: UIBarButtonItem) {
        super.pressedNavigationItem(item)
        
        switch item {
        case _barButtonItemClose:
            self.dismiss(animated: true)
            break
            
        default:
            break
        }
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        switch button {
        case _buttonNext:
            let page = ((_scrollView.contentOffset.x + _scrollView.bounds.size.width / 2) / _scrollView.bounds.size.width).rounded(.down)
            
            guard page < 4 else {
                let isMicTestActivated = LevelTestManager.manager.examInfo?.isMicTestActivated ?? false
                
                if isMicTestActivated {
                    let viewController = ALTMicTestViewController()
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

extension ALTTutorialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = ((scrollView.contentOffset.x + scrollView.bounds.size.width / 2) / scrollView.bounds.size.width).rounded(.down)
        
        if page > 3 {
            _labelNext.text = (LevelTestManager.manager.examInfo?.isMicTestActivated ?? false) == true ? "마이크 테스트 시작하기 >" : "시작하기 >"
        } else {
            _labelNext.text = "다음 >"
        }
    }
}
