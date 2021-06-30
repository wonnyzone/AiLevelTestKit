//
//  ALTMyPageViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/10/16.
//

import UIKit

import PINRemoteImage

class ALTMyPageViewController: ALTBaseViewController {
    private let _activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    private let _theTableView = UITableView()
    private var _imageViewAds: UIImageView?
    
    private var _buttonLevelTest: UIButton?
    private var _buttonExamination: UIButton?
    
    private var _tableData = [ALTLevelTestResultData]()
    
    private let _refreshControl = UIRefreshControl()
    
    private var _isLoading = false
    
    private var _selectedCategoryIndex = 0
    
    private var _hasNextPage = true
    private var _currentPage = 0
    
    private var _totalCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        _activityIndicatorView.color = ColourKit.Code.HexAAAAAA
        _activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(_activityIndicatorView)
        
        _activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        _activityIndicatorView.startAnimating()
        
        _theTableView.translatesAutoresizingMaskIntoConstraints = false
        _theTableView.backgroundColor = .clear
        _theTableView.delegate = self
        _theTableView.dataSource = self
        _theTableView.separatorStyle = .none
        _theTableView.register(ALTLoadMoreTableViewCell.self, forCellReuseIdentifier: "ALTLoadMoreTableViewCell")
        _theTableView.register(ALTMyPageTestTableViewCell.self, forCellReuseIdentifier: "ALTMyPageTestTableViewCell")
        _theTableView.register(ALTMyPageTestContinueTableViewCell.self, forCellReuseIdentifier: "ALTMyPageTestContinueTableViewCell")
        _theTableView.isHidden = true
        self.view.addSubview(_theTableView)
        
        _theTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        _theTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _theTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _theTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        _theTableView.refreshControl = _refreshControl
        
        reloadData()
    }
    
    private func reloadData() {
        _hasNextPage = true
        _currentPage = 0
        _totalCount = 0
        
        _tableData.removeAll()
        _theTableView.reloadData()
        
        _isLoading = false
        
        loadNextData()
    }
    
    private func loadNextData() {
        guard _isLoading == false, _hasNextPage else { return }
        
        _isLoading = true
        
        _currentPage += 1
        
        let httpClient = QHttpClient()
        
        var params = [String:Any]()
        params["group_code"] = UserDataManager.manager.groupCode
        params["email"] = UserDataManager.manager.userId
        params["page"] = _currentPage
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Result.GetList) {[weak self] (code, errMessage, response) in
            self?._theTableView.isHidden = false
            self?._activityIndicatorView.stopAnimating()
            
            self?._isLoading = false
            self?._refreshControl.endRefreshing()
            
            guard code == .success, let responseData = response as? [String:Any] else {
                self?._hasNextPage = false
                return
            }
            
            self?._totalCount = responseData["total_count"] as? Int ?? 0
            
            if var ad_image = responseData["ad_image"] as? String, ad_image.count > 0 {
                if ad_image.hasPrefix("./") {
                    ad_image = "\(ad_image.dropFirst(2))"
                } else if ad_image.hasPrefix("/") {
                    ad_image = "\(ad_image.dropFirst(1))"
                }
                
                PINRemoteImageManager().downloadImage(with: URL(string: RequestUrl.Image + ad_image)!, options: .downloadOptionsSkipEarlyCheck) {[weak self] (result) in
                    self?.showTableHeaderView(with: result.image)
                } completion: {[weak self] (result) in
                    self?.showTableHeaderView(with: result.image)
                }

            } else {
                self?._theTableView.tableHeaderView = nil
                self?._imageViewAds = nil
            }
            
            if let list = responseData["list"] as? [[String:Any]] {
                self?._tableData.append(contentsOf: list.map({ (item) -> ALTLevelTestResultData in
                    return ALTLevelTestResultData(with: item)
                }))
            }
            
            self?._hasNextPage = (responseData["list"] as? [[String:Any]] ?? []).count > 0
            
            self?._theTableView.reloadData()
        }
    }
    
    @objc private func pressedCellButton(_ button: UIButton) {
        guard let cell = button.superview?.superview?.superview as? ALTMyPageTestTableViewCell else { return }
        gotoResult(at: cell.tag)
    }
    
    func showTableHeaderView(with image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            let imageSize = image?.size ?? CGSize.zero
            
            if self?._imageViewAds == nil, imageSize.width > 0 {
                var frame = CGRect.zero
                frame.size.width = UIScreen.main.bounds.size.width
                frame.size.height = frame.size.width * imageSize.height / imageSize.width
                
                self?._imageViewAds = UIImageView(frame: frame)
                self?._imageViewAds!.contentMode = .scaleAspectFill
                self?._imageViewAds!.clipsToBounds = true
                self?._theTableView.tableHeaderView = self?._imageViewAds
            }
            
            self?._imageViewAds?.image = image
        }
    }
    
    private func gotoResult(at index: Int) {
        guard index < _tableData.count else { return }
        
        let item = _tableData[index]
        
        guard let testingSrl = item.testSrl else { return }
        
        guard item.isFinished == false else {
            let viewController = ALTResultWebViewController(examId: LevelTestManager.manager.examId, testSrl: testingSrl)
            viewController.modalPresentationStyle = .overFullScreen
            self.present(viewController, animated: true, completion: nil)
            return
        }
        
        guard let examId = item.examId else { return }
        
        LevelTestManager.manager.delegate = nil
        
        QIndicatorViewManager.shared.showIndicatorView {(complete) in
            LevelTestManager.manager.initialize(examId: examId) { [weak self] in
                QIndicatorViewManager.shared.hideIndicatorView()
                
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
                            
                            let navController = ALLTSeniorTestNavigationController(rootViewController: viewController!)
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
                                
                                let navController = ALLTSeniorTestNavigationController(rootViewController: viewController!)
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
}

extension ALTMyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gotoResult(at: indexPath.row)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? _tableData.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else {
            return 0
        }
        return 127.optimized
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.tableView(tableView, heightForHeaderInSection: section)))
        
        headerView.backgroundColor = self.view.backgroundColor
        
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "테스트 내역"
        label.textColor = ColourKit.Code.Hex555555
        label.font = UIFont.systemFont(ofSize: 24.optimized, weight: .bold)
        label.sizeToFit()
        headerView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 29.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 17.optimized).isActive = true
        label.heightAnchor.constraint(equalToConstant: label.bounds.size.height).isActive = true
        
        let bottomAnchor = label.bottomAnchor
        
        let attributes = QTextAttributes(withForegroundColour: ColourKit.Code.Hex727B88, font: UIFont.systemFont(ofSize: 12.optimized, weight: .regular))
        
        let format = "총 테스트 내역 %@개"
        let numbers = _totalCount.formattedString
        
        let string = String(format: format, arguments: [numbers])
        
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes.attributes)
        if let range = string.nsRange(of: numbers) {
            attributes.foregroundColour = ColourKit.Code.Static.HexFA4175
            attributedString.addAttributes(attributes.attributes, range: range)
        }
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = attributedString
        headerView.addSubview(label)
        
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15.optimized).isActive = true
        
        _buttonLevelTest = UIButton()
        _buttonLevelTest!.translatesAutoresizingMaskIntoConstraints = false
        _buttonLevelTest!.isSelected = _selectedCategoryIndex == 0
        _buttonLevelTest!.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexFFFFFF), for: .normal)
        _buttonLevelTest!.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Static.Hex2D78CD), for: .selected)
        _buttonLevelTest!.setTitle("레벨테스트", for: .normal)
        _buttonLevelTest!.setTitleColor(ColourKit.Code.Hex555555, for: .normal)
        _buttonLevelTest!.setTitleColor(.white, for: .selected)
        _buttonLevelTest!.titleLabel?.font = UIFont.systemFont(ofSize: 14.optimized, weight: .regular)
        _buttonLevelTest!.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonLevelTest!.layer.borderColor = ColourKit.Code.Hex555555.cgColor
        _buttonLevelTest!.layer.borderWidth = 1
        headerView.addSubview(_buttonLevelTest!)
        
        _buttonLevelTest!.topAnchor.constraint(equalTo: bottomAnchor, constant: 15.optimized).isActive = true
        _buttonLevelTest!.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -7.optimized).isActive = true
        _buttonLevelTest!.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15.optimized).isActive = true
        _buttonLevelTest!.trailingAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        _buttonExamination = UIButton()
        _buttonExamination!.translatesAutoresizingMaskIntoConstraints = false
        _buttonExamination!.isSelected = _selectedCategoryIndex == 1
        _buttonExamination!.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexFFFFFF), for: .normal)
        _buttonExamination!.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Static.Hex2D78CD), for: .selected)
        _buttonExamination!.setTitle("성취도 평가테스트", for: .normal)
        _buttonExamination!.setTitleColor(ColourKit.Code.Hex555555, for: .normal)
        _buttonExamination!.setTitleColor(.white, for: .selected)
        _buttonExamination!.titleLabel?.font = UIFont.systemFont(ofSize: 14.optimized, weight: .regular)
        _buttonExamination!.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonExamination!.layer.borderColor = ColourKit.Code.Hex555555.cgColor
        _buttonExamination!.layer.borderWidth = 1
        headerView.addSubview(_buttonExamination!)
        
        _buttonExamination!.topAnchor.constraint(equalTo: _buttonLevelTest!.topAnchor).isActive = true
        _buttonExamination!.bottomAnchor.constraint(equalTo: _buttonLevelTest!.bottomAnchor).isActive = true
        _buttonExamination!.leadingAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        _buttonExamination!.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15.optimized).isActive = true
        
        headerView.layoutIfNeeded()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.section == 0 else {
            return _hasNextPage ? ALTLoadMoreTableViewCell.estimatedHeight : 0
        }
        let data = _tableData[indexPath.row]
        return data.isFinished ? ALTMyPageTestTableViewCell.height : ALTMyPageTestContinueTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            guard _hasNextPage, let cell = tableView.dequeueReusableCell(withIdentifier: "ALTLoadMoreTableViewCell") as? ALTLoadMoreTableViewCell else { return ALTBaseTableViewCell() }
            return cell
        }
        
        let data = _tableData[indexPath.row]
        
        guard data.isFinished else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ALTMyPageTestContinueTableViewCell") as? ALTMyPageTestContinueTableViewCell else { return ALTBaseTableViewCell() }
            cell.tag = indexPath.row
            cell.data = data
            cell.addTarget(self, action: #selector(self.pressedCellButton(_:)), for: .touchUpInside)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ALTMyPageTestTableViewCell") as? ALTMyPageTestTableViewCell else { return ALTBaseTableViewCell() }
        cell.tag = indexPath.row
        cell.data = data
        cell.addTarget(self, action: #selector(self.pressedCellButton(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell as? ALTLoadMoreTableViewCell != nil {
            loadNextData()
        }
    }
}

extension ALTMyPageViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard _refreshControl.isRefreshing else { return }
        reloadData()
    }
}
