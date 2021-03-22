//
//  ALLTReadingViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALLTReadingViewController: ALLTBaseViewController {
    internal let _theTableView = UITableView()
    
    internal let _buttonNext = UIButton()
    
    internal var _selectedIndex: Int? {
        didSet {
            _buttonNext.isEnabled = _selectedIndex != nil
        }
    }
    
    internal var _tableData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _theTableView.translatesAutoresizingMaskIntoConstraints = false
        _theTableView.backgroundColor = .clear
        _theTableView.delegate = self
        _theTableView.dataSource = self
        _theTableView.register(ALLTAnswerTableViewCell.self, forCellReuseIdentifier: "ALLTAnswerTableViewCell")
        _theTableView.separatorStyle = .none
        _theTableView.alwaysBounceVertical = false
        self.view.addSubview(_theTableView)
        
        _theTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        _theTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        _theTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        _theTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 152.optimized))
        tableFooterView.backgroundColor = .clear
        
        _buttonNext.translatesAutoresizingMaskIntoConstraints = false
        _buttonNext.layer.cornerRadius = 36.optimized
        _buttonNext.clipsToBounds = true
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Hex222222), for: .normal)
        _buttonNext.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonNext.setTitle("다음", for: .normal)
        _buttonNext.setTitleColor(ColourKit.Code.HexFFFFFF, for: .normal)
        _buttonNext.titleLabel?.font = UIFont.systemFont(ofSize: 24.optimized, weight: .bold)
        _buttonNext.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonNext.isEnabled = _selectedIndex != nil
        tableFooterView.addSubview(_buttonNext)
        
        _buttonNext.topAnchor.constraint(equalTo: tableFooterView.topAnchor, constant: 40.optimized).isActive = true
        _buttonNext.centerXAnchor.constraint(equalTo: tableFooterView.centerXAnchor).isActive = true
        _buttonNext.widthAnchor.constraint(equalToConstant: 72.optimized).isActive = true
        _buttonNext.heightAnchor.constraint(equalToConstant: 72.optimized).isActive = true
        
        tableFooterView.layoutIfNeeded()
        
        _theTableView.tableFooterView = tableFooterView
        
        self.view.layoutIfNeeded()
        
        reloadData()
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        switch button {
        case _buttonNext:
            
            break
            
        default:
            break
        }
    }
    
    internal func reloadData() {
        let tableHeaderView = UIView()
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableHeaderView.backgroundColor = .clear
        
        tableHeaderView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
        
        let labelTitle = UILabel()
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.text = "다음 글을 읽고 올바르게\n해석한 답을 선택하세요."
        labelTitle.textAlignment = .center
        labelTitle.textColor = ColourKit.Code.Hex222222
        labelTitle.font = UIFont.systemFont(ofSize: 22.optimized, weight: .heavy)
        labelTitle.numberOfLines = 0
        tableHeaderView.addSubview(labelTitle)
        
        labelTitle.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 58.optimized).isActive = true
        labelTitle.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: 42.optimized).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor, constant: -42.optimized).isActive = true
        labelTitle.heightAnchor.constraint(equalToConstant: 56.optimized).isActive = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.HexFFFFFF
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 10.optimized
        tableHeaderView.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 30.optimized).isActive = true
        backView.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: 16.optimized).isActive = true
        backView.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor, constant: -16.optimized).isActive = true
        backView.bottomAnchor.constraint(equalTo: tableHeaderView.bottomAnchor, constant: -32.optimized).isActive = true
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 80.optimized, height: 0))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Rabbits like arrots."
        label.font = UIFont.systemFont(ofSize: 20.optimized, weight: .bold)
        label.sizeToFit()
        backView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: backView.topAnchor, constant: 32.optimized).isActive = true
        label.heightAnchor.constraint(equalToConstant: label.frame.size.height).isActive = true
        label.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant:-32.optimized).isActive = true
        label.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20.optimized).isActive = true
        label.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20.optimized).isActive = true
        
        tableHeaderView.layoutIfNeeded()
        
        _theTableView.tableHeaderView = tableHeaderView
        
        _selectedIndex = nil
        
        _tableData.append("토끼는 오렌지를 좋아한다.")
        _tableData.append("토끼는 사과를 좋아한다.")
        _tableData.append("토끼는 포도를 좋아한다.")
        _tableData.append("토끼는 당근을 좋아한다.")
        
        _theTableView.reloadData()
    }
}

extension ALLTReadingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPaths = [IndexPath]()
        
        if let selectedIndex = _selectedIndex {
            indexPaths.append(IndexPath(row: selectedIndex, section: 0))
        }
        
        _selectedIndex = indexPath.row
        indexPaths.append(indexPath)
        
        _theTableView.reloadRows(at: indexPaths, with: .none)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ALLTAnswerTableViewCell.height(with: _tableData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ALLTAnswerTableViewCell") as? ALLTAnswerTableViewCell else { return ALTBaseTableViewCell() }
        
        cell.numbering = indexPath.row + 1
        cell.answer = _tableData[indexPath.row]
        cell.isSelected = indexPath.row == _selectedIndex
        
        return cell
    }
}
