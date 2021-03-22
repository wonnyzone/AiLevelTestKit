//
//  ALLTSelectGradeViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/05.
//

import UIKit

class ALLTSelectGradeViewController: ALTBaseViewController {
    lazy internal var _collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = ALLTSelectGradeCollectionViewCell.sectionInset
        flowLayout.minimumInteritemSpacing = ALLTSelectGradeCollectionViewCell.interItemSpacing
        flowLayout.itemSize = ALLTSelectGradeCollectionViewCell.itemSize
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    internal var _collectionData = [ALTJuniorInfo.Exam]()
    
    internal var _selectedIndex: Int?
    
    internal let _connId: String
    
    internal let _labelTitle = UILabel()
    
    init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, with connId: String) {
        _connId = connId
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.additionalSafeAreaInsets = ALTJuniorTestNavigationController.additionalSafeAreaInsets
        
        _labelTitle.translatesAutoresizingMaskIntoConstraints = false
        _labelTitle.textAlignment = .center
        _labelTitle.textColor = ColourKit.Code.Hex222222
        _labelTitle.font = UIFont.systemFont(ofSize: 18.optimized, weight: .semibold)
        _labelTitle.numberOfLines = 0
        self.view.addSubview(_labelTitle)
        
        _labelTitle.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant:  -ALTJuniorTestNavigationController.additionalSafeAreaInsets.top / 2).isActive = true
        _labelTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _labelTitle.widthAnchor.constraint(equalToConstant: 200.optimized).isActive = true
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        _collectionView.backgroundColor = self.view.backgroundColor
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.register(ALLTSelectGradeCollectionViewCell.self, forCellWithReuseIdentifier: "ALLTSelectGradeCollectionViewCell")
        _collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0).optimized
        self.view.addSubview(_collectionView)
        
        _collectionView.topAnchor.constraint(equalTo: _labelTitle.bottomAnchor, constant: 20.optimized).isActive = true
        _collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        LevelTestManager.manager.getJuniorExamInfo(with: _connId) { (info, errMessage) in
            DispatchQueue.main.async {[weak self] in
                self?.title = info?.title
                self?._labelTitle.text = info?.title
                
                self?.view.layoutIfNeeded()
                
                self?._collectionData.removeAll()
                
                let array = info?.examList ?? []
                
                for i in 0 ..< array.count {
                    self?._collectionData.append(array[i])
                }
                
                self?._collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        (self.navigationController as? ALTJuniorTestNavigationController)?.isComponentHidden = true
        
        self.navigationItem.leftBarButtonItems = []
    }
    
    private func startIntitializedTest() {
        LevelTestManager.manager.delegate = self
        
        if LevelTestManager.manager.needAgreement && QDataManager.shared.isSkipTerms == false {
            let viewController = ALTPrivacyPoliciesViewController()
            let navController = ALTJuniorTestNavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        } else if (LevelTestManager.manager.examInfo?.isCouponActivated ?? false) == true {
            let viewController = ALTCouponListViewController()
            let navController = ALTJuniorTestNavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        } else {
            let viewController = ALTJuniorTutorialViewController()
            let navController = ALTJuniorTestNavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
    }
}

extension ALLTSelectGradeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let examId = _collectionData[indexPath.row].exam else { return }
        
//        var indexPaths = [indexPath]
//        
//        if _selectedIndex != nil {
//            indexPaths.append(IndexPath(row: _selectedIndex!, section: 0))
//        }
//        
//        _selectedIndex = indexPath.row
//        
//        collectionView.reloadItems(at: indexPaths)
        
        LevelTestManager.manager.delegate = nil
        
        QIndicatorViewManager.shared.showIndicatorView {[weak self] (complete) in
            LevelTestManager.manager.initialize(examId: examId, juniorConnId: self?._connId) { [weak self] in
                QIndicatorViewManager.shared.hideIndicatorView()
                
                guard let testingSrl = LevelTestManager.manager.testSrl else {
                    self?.startIntitializedTest()
                    return
                }
                
                let alertController = UIAlertController(title: "기존에 완료하지 않은 시험이 있습니다.", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "이어하기", style: .cancel, handler: {[weak self] (action) in
                    QIndicatorViewManager.shared.showIndicatorView { [weak self] (complete) in
                        LevelTestManager.manager.getQuizViewController(isContinue: true) { (viewController, errMessage) in
                            QIndicatorViewManager.shared.hideIndicatorView()
                            
                            guard viewController != nil else {
                                let alertController = UIAlertController(title: errMessage ?? ALTAppString.Error.Unknown.Message, message: nil, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: ALTAppString.General.Confirm, style: .cancel, handler: nil))
                                self?.present(alertController, animated: true, completion: nil)
                                return
                            }
                            
                            let navController = ALTJuniorTestNavigationController(rootViewController: viewController!)
                            navController.modalPresentationStyle = .overFullScreen
                            self?.present(navController, animated: true, completion: nil)
                        }
                    }
                }))
                alertController.addAction(UIAlertAction(title: "처음부터 시작", style: .default, handler: {[weak self] (action) in
                    QIndicatorViewManager.shared.showIndicatorView { [weak self] (complete) in
                        LevelTestManager.manager.RestartTest(testSrl: testingSrl) {[weak self] (testSrl, errMessage) in
                            guard testSrl != nil, errMessage == nil else {
                                QIndicatorViewManager.shared.hideIndicatorView()
                                let alertController = UIAlertController(title: errMessage, message: nil, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: ALTAppString.General.Confirm, style: .cancel, handler: nil))
                                self?.present(alertController, animated: true, completion: nil)
                                return
                            }
                            LevelTestManager.manager.getQuizViewController(isContinue: false) { (viewController, errMessage) in
                                QIndicatorViewManager.shared.hideIndicatorView()
                                
                                guard viewController != nil else {
                                    let alertController = UIAlertController(title: errMessage ?? ALTAppString.Error.Unknown.Message, message: nil, preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: ALTAppString.General.Confirm, style: .cancel, handler: nil))
                                    self?.present(alertController, animated: true, completion: nil)
                                    return
                                }
                                
                                let navController = ALTJuniorTestNavigationController(rootViewController: viewController!)
                                navController.modalPresentationStyle = .overFullScreen
                                self?.present(navController, animated: true, completion: nil)
                            }
                        }
                    }
                }))
                self?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = _collectionView.dequeueReusableCell(withReuseIdentifier: "ALLTSelectGradeCollectionViewCell", for: indexPath) as? ALLTSelectGradeCollectionViewCell else { return UICollectionViewCell() }
        
        cell.data = _collectionData[indexPath.row]
        cell.isSelected = _selectedIndex == indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ALLTSelectGradeCollectionViewCell)?.reloadData()
    }
}
