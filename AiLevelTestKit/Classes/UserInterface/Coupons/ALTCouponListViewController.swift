//
//  ALTCouponListViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/16.
//

import UIKit

public class ALTCouponData: ALTBaseData {
    public enum State: Int {
        case active = 1
        case inactive = 2
    }
    
    var srl: Int? {
        return rawData["coupon_srl"] as? Int
    }
    
    var customerSrl: Int? {
        return rawData["customer_srl"] as? Int
    }
    
    var code: String? {
        return rawData["coupon_code"] as? String
    }
    
    var count: Int {
        return rawData["count"] as? Int ?? 0
    }
    
    var regDate: Date? {
        get {
            guard let dateString = rawData["reg_date"] as? String else { return nil }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            return formatter.date(from: dateString)
        }
    }
    
    var repeatCouponSrl: Int? {
        return rawData["repeat_coupon_srl"] as? Int
    }
    
    var groupSrl: Int? {
        return rawData["group_srl"] as? Int
    }
    
    var title: String? {
        return rawData["title"] as? String
    }
    
    var userCount: Int {
        return rawData["user_count"] as? Int ?? 0
    }
    
    var perCount: Int {
        return rawData["per_count"] as? Int ?? 0
    }
    
    var startDate: Date? {
        get {
            guard let dateString = rawData["start_date"] as? String else { return nil }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            return formatter.date(from: dateString)
        }
    }
    
    var endDate: Date? {
        get {
            guard let dateString = rawData["end_date"] as? String else { return nil }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            return formatter.date(from: dateString)
        }
    }
    
    var state: String? {
        return rawData["coupon_state"] as? String
    }
    
    var setupSrl: Int? {
        return rawData["setup_srl"] as? Int
    }
}

class ALTCouponListViewController: ALTBaseViewController {
    private let _buttonClose = UIButton()
    
    private let _tableView = UITableView()
    private let _tableHeaderView = ALTCouponListHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: ALTCouponListHeaderView.height))
    
    private var _tableData = [ALTCouponData]()
    
    private var _selectedIndex: Int?
    
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
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "쿠폰"
        label.textColor = ColourKit.Code.HexFFFFFF
        label.font = UIFont.systemFont(ofSize: 20.optimized, weight: .regular)
        self.view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.optimized).isActive = true
        
        _buttonClose.translatesAutoresizingMaskIntoConstraints = false
        _buttonClose.setImage(UIImage(named: "img_close_blk")?.resize(maxWidth: 32.optimized), for: .normal)
        _buttonClose.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonClose)
        
        _buttonClose.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        _buttonClose.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        _buttonClose.widthAnchor.constraint(equalToConstant: 52.optimized).isActive = true
        _buttonClose.heightAnchor.constraint(equalToConstant: 52.optimized).isActive = true
        
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        _tableView.backgroundColor = .clear
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.separatorStyle = .none
        _tableView.register(ALTCouponTableViewCell.self, forCellReuseIdentifier: "ALTCouponTableViewCell")
        _tableView.register(ALTCouponListNoTableViewCell.self, forCellReuseIdentifier: "ALTCouponListNoTableViewCell")
        self.view.addSubview(_tableView)
        
        _tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20.optimized).isActive = true
        _tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        _tableHeaderView.delegate = self
        _tableView.tableHeaderView = _tableHeaderView
        
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30.optimized))
        tableFooterView.backgroundColor = ColourKit.Code.Hex121212
        _tableView.tableFooterView = tableFooterView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        (self.navigationController as? ALTJuniorTestNavigationController)?.isComponentHidden = true
        
        reloadData()
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        _ = (_tableView.tableHeaderView as? ALTCouponListHeaderView)?.textfieldCoupon.resignFirstResponder()
        
        switch button {
        case _buttonClose:
            self.dismiss(animated: true)
            break
            
        default:
            break
        }
    }
    
    private func reloadData() {
        LevelTestManager.manager.getCouponList(for: _tableHeaderView.selectedCategory == .available ? .active : .inactive) {[weak self] (array, errMessage) in
            self?._tableData.removeAll()
            guard let items = array, items.count > 0 else {
                self?._tableView.reloadData()
                return
            }
            self?._tableData.append(contentsOf: items)
            self?._tableView.reloadData()
        }
    }
    
    @objc private func pressedCellButton(_ button: UIButton) {
        guard let cell = button.superview?.superview?.superview?.superview as? ALTCouponTableViewCell, let data = cell.data else { return }
        
        QIndicatorViewManager.shared.showIndicatorView { (complete) in
            LevelTestManager.manager.useCoupon(with: data) { (isSucceed, message) in
                QIndicatorViewManager.shared.hideIndicatorView()
                
                DispatchQueue.main.async { [weak self] in
                    self?.reloadData()
                    
                    guard message != nil else { return }
                    
                    let alertController = UIAlertController(title: message!, message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: ALTAppString.General.Confirm, style: .cancel, handler: {[weak self] (action) in
                        self?.startTest()
                    }))
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func startTest() {
        if (LevelTestManager.manager.examInfo?.isTutorialActivated ?? false) == true {
            let viewController = ALTTutorialViewController()
            self.navigationController?.setViewControllers([viewController], animated: true)
            return
        }
        if (LevelTestManager.manager.examInfo?.isMicTestActivated ?? false) == true {
            let viewController = ALTMicTestViewController()
            self.navigationController?.setViewControllers([viewController], animated: true)
            return
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
    }
}

extension ALTCouponListViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _tableHeaderView.textfieldCoupon.resignFirstResponder()
    }
}

extension ALTCouponListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _tableHeaderView.textfieldCoupon.resignFirstResponder()
        
        guard indexPath.row != _selectedIndex else {
            _selectedIndex = nil
            (tableView.cellForRow(at: indexPath) as? ALTCouponTableViewCell)?.isActive = false
            return
        }
        
        _selectedIndex = indexPath.row
        (tableView.cellForRow(at: indexPath) as? ALTCouponTableViewCell)?.isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableData.count == 0 ? 1 : _tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return _tableData.count == 0 ? ALTCouponListNoTableViewCell.height : ALTCouponTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard _tableData.count > 0 else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ALTCouponListNoTableViewCell") as? ALTCouponListNoTableViewCell else { return ALTBaseTableViewCell() }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ALTCouponTableViewCell") as? ALTCouponTableViewCell else { return ALTBaseTableViewCell() }
        cell.tag = indexPath.row
        cell.data = _tableData[indexPath.row]
        cell.isEnabled = _tableHeaderView.selectedCategory == .available
        cell.addTarget(self, action: #selector(self.pressedCellButton(_:)), for: .touchUpInside)
        return cell
    }
}

extension ALTCouponListViewController: ALTCouponListHeaderViewDelegate {
    func couponListHeaderView(_ headerView: ALTCouponListHeaderView, didChange segment: ALTCouponListHeaderView.Segment) {
        reloadData()
    }
    
    func couponListHeaderView(_ headerView: ALTCouponListHeaderView, didRequestToRegister coupon: String) -> Bool {
        QIndicatorViewManager.shared.showIndicatorView { (complete) in
            LevelTestManager.manager.addCoupon(with: coupon) { (isSucceed, message) in
                QIndicatorViewManager.shared.hideIndicatorView()
                
                DispatchQueue.main.async { [weak self] in
                    self?.reloadData()
                    
                    guard message != nil else { return }
                    
                    let alertController = UIAlertController(title: message!, message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: ALTAppString.General.Confirm, style: .cancel, handler: nil))
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        }
        return true
    }
}
