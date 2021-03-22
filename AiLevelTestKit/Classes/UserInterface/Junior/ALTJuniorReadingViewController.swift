//
//  ALTJuniorReadingViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/25.
//

import UIKit

class ALTJuniorReadingViewController: ALTJuniorTestBaseViewController {
    internal let _theTableView = UITableView()
    
    internal var _selectedIndex: Int? {
        didSet {
            _buttonNext.isEnabled = _selectedIndex != nil
        }
    }
    
    internal var _tableData = [ALTLevelTest.Quiz.Answer]()
    
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
        
        _footerView.layoutIfNeeded()
        _theTableView.tableFooterView = _footerView
        
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
        
        let labelTitle = UILabel()
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.text = testData.quiz?.quizDesc
        labelTitle.textAlignment = .center
        labelTitle.textColor = ColourKit.Code.Hex222222
        labelTitle.font = UIFont.systemFont(ofSize: 22.optimizedWithHeight, weight: .heavy)
        labelTitle.numberOfLines = 0
        tableHeaderView.addSubview(labelTitle)
        
        labelTitle.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 5.optimizedWithHeight).isActive = true
        labelTitle.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: 42.optimized).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor, constant: -42.optimized).isActive = true
        labelTitle.heightAnchor.constraint(equalToConstant: 90.optimizedWithHeight).isActive = true
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = ColourKit.Code.HexFFFFFF
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 10.optimized
        tableHeaderView.addSubview(backView)
        
        backView.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 5.optimizedWithHeight).isActive = true
        backView.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: 16.optimized).isActive = true
        backView.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor, constant: -16.optimized).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = testData.quiz?.quiz
        label.textColor = ColourKit.Code.Hex222222
        label.font = UIFont.systemFont(ofSize: 20.optimizedWithHeight, weight: .heavy)
        label.numberOfLines = 0
        backView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: backView.topAnchor, constant: 10.optimizedWithHeight).isActive = true
        label.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -10.optimizedWithHeight).isActive = true
        label.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 19.optimized).isActive = true
        label.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -19.optimized).isActive = true
        label.bottomAnchor.constraint(equalTo: tableHeaderView.bottomAnchor, constant: -20.optimizedWithHeight).isActive = true
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 70.optimizedWithHeight).isActive = true
        
        tableHeaderView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true

        tableHeaderView.layoutIfNeeded()
        
        _theTableView.tableHeaderView = tableHeaderView
        
        _selectedIndex = nil
        
        _tableData.removeAll()
        _tableData.append(contentsOf: testData.quiz?.answerList ?? [])
        _theTableView.reloadData()
    }
}

extension ALTJuniorReadingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _selectedIndex = indexPath.row
        
        _answer = _tableData[_selectedIndex!].answer
        
        _buttonNext.isEnabled = _answer != nil
        
        _theTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ALLTAnswerTableViewCell.height(with: _tableData[indexPath.row].answer)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ALLTAnswerTableViewCell") as? ALLTAnswerTableViewCell else { return ALTBaseTableViewCell() }
        
        cell.numbering = indexPath.row + 1
        cell.answer = _tableData[indexPath.row].answer
        cell.isSelected = indexPath.row == _selectedIndex
        
        return cell
    }
}
