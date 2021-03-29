//
//  ALTSeniorTestWordViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import UIKit

class ALTSeniorTestWordViewController: ALLTSeniorTestBaseViewController {
    internal let _tableView = UITableView()
    
    internal var _tableData = [ALTLevelTest.Quiz.Answer]()
    
    internal var _selectedIndex: Int? {
        didSet {
            _buttonNext.isEnabled = _selectedIndex != nil
            _isSkippable = true
            
            _guideString = _selectedIndex != nil ? "‘NEXT’ 버튼을 누르면 다음 문제로 넘어갑니다." : "한글 뜻에 맞는 \(LevelTestManager.manager.examInfo?.testLanguageString ?? "영어") 단어를 선택하세요.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _guideString = "한글 뜻에 맞는 \(LevelTestManager.manager.examInfo?.testLanguageString ?? "영어") 단어를 선택하세요.\n정확한 정답을 모를 경우 'SKIP' 버튼을 눌러주세요."
        
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        _tableView.backgroundColor = .clear
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.separatorStyle = .none
        _tableView.register(ALTSeniorTestWordTableViewCell.self, forCellReuseIdentifier: "ALTSeniorTestWordTableViewCell")
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.view.backgroundColor = ColourKit.Code.HexF0F0F0
            
            let leftView = UIView()
            leftView.translatesAutoresizingMaskIntoConstraints = false
            leftView.clipsToBounds = true
            leftView.backgroundColor = ColourKit.Code.HexFFFFFF
            leftView.layer.cornerRadius = 10
            self.view.addSubview(leftView)
            
            leftView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26.optimized).isActive = true
            leftView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -26.optimized).isActive = true
            leftView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 26.optimized).isActive = true
            leftView.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -6.optimized).isActive = true
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            leftView.addSubview(containerView)
            
            containerView.topAnchor.constraint(equalTo: leftView.topAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: leftView.bottomAnchor).isActive = true
            containerView.centerXAnchor.constraint(equalTo: leftView.centerXAnchor).isActive = true
            containerView.widthAnchor.constraint(lessThanOrEqualTo: leftView.widthAnchor, multiplier: 1.0, constant: -40.optimized).isActive = true
            
            var label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = AiLevelTestKit.shared.themeColour
            label.text = testData.quiz?.wordClass
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 11.optimized, weight: .regular)
            label.layer.cornerRadius = 22.optimized
            label.clipsToBounds = true
            containerView.addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: 44.optimized).isActive = true
            label.heightAnchor.constraint(equalToConstant: 44.optimized).isActive = true
            
            let leadingAnchor = label.trailingAnchor
            
            label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = testData.quiz?.quiz
            label.textColor = ColourKit.Code.Hex888888
            label.font = UIFont.systemFont(ofSize: 24.optimized, weight: .bold)
            label.numberOfLines = 2
            containerView.addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7.optimized).isActive = true
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            
            let rightView = UIView()
            rightView.translatesAutoresizingMaskIntoConstraints = false
            rightView.clipsToBounds = true
            rightView.backgroundColor = ColourKit.Code.HexD0D0D0
            rightView.layer.cornerRadius = 10
            self.view.addSubview(rightView)
            
            rightView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26.optimized).isActive = true
            rightView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -26.optimized).isActive = true
            rightView.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 6.optimized).isActive = true
            rightView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -26.optimized).isActive = true
            
            _tableView.contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 0).optimized
            rightView.addSubview(_tableView)
                
            _tableView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
            _tableView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
            _tableView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor).isActive = true
            _tableView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor).isActive = true
        } else {
            _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0).optimized
            self.view.addSubview(_tableView)
            
            _tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            _tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            _tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            _tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
        
        self.view.layoutSubviews()
        
        reloadData()
    }
    
    private func reloadData() {
        if UIDevice.current.userInterfaceIdiom != .pad {
            var hratio = (UIScreen.main.bounds.size.height - 667) / (812 - 667)
            if hratio < 0 { hratio = 0 }
            else if hratio > 1 { hratio = 1 }
            let height = 84.optimized + (54.optimized * hratio)
            
            let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height))
            tableHeaderView.backgroundColor = .clear
            
            var label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = AiLevelTestKit.shared.themeColour
            label.text = testData.quiz?.wordClass
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 11.optimized, weight: .regular)
            label.layer.cornerRadius = 22.optimized
            label.clipsToBounds = true
            tableHeaderView.addSubview(label)
            
            label.bottomAnchor.constraint(equalTo: tableHeaderView.bottomAnchor, constant: -20.optimized).isActive = true
            label.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: 20.optimized).isActive = true
            label.widthAnchor.constraint(equalToConstant: 44.optimized).isActive = true
            label.heightAnchor.constraint(equalToConstant: 44.optimized).isActive = true
            
            let leadingAnchor = label.trailingAnchor
            let centerYAnchor = label.centerYAnchor
            
            label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = testData.quiz?.quiz
            label.textColor = ColourKit.Code.Hex888888
            label.font = UIFont.systemFont(ofSize: 24.optimized, weight: .bold)
            label.numberOfLines = 2
            tableHeaderView.addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7.optimized).isActive = true
            label.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor, constant: -20.optimized).isActive = true
            
            tableHeaderView.layoutIfNeeded()
            
            _tableView.tableHeaderView = tableHeaderView
        }
        
        _tableData.removeAll()
        
        _tableData.append(contentsOf: testData.quiz?.answerList ?? [])
        
        _tableView.reloadData()
    }
}

extension ALTSeniorTestWordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPaths = [indexPath]
        
        guard _selectedIndex != indexPath.row else { return }
        
        _selectedIndex = indexPath.row
        
        _answer = _tableData[_selectedIndex!].answer
        
        _tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return (tableView.bounds.size.height - tableView.contentInset.top - tableView.contentInset.bottom) / 5
        }
        
        let maximumHeight = (tableView.bounds.size.height - (tableView.tableHeaderView?.bounds.size.height ?? 0)) / 5
        return min(maximumHeight, ALTSeniorTestWordTableViewCell.height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ALTSeniorTestWordTableViewCell") as? ALTSeniorTestWordTableViewCell else { return UITableViewCell() }
        cell.title = _tableData[indexPath.row].answer
        cell.isSelected = _selectedIndex == indexPath.row
        return cell
    }
}
