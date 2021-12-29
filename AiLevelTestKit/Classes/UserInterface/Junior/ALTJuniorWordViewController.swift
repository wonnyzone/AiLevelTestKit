//
//  ALTJuniorWordViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/25.
//

import UIKit

class ALTJuniorWordViewController: ALTJuniorTestBaseViewController {
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
        
        labelTitle.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 15.optimizedWithHeight).isActive = true
        labelTitle.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: 42.optimized).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor, constant: -42.optimized).isActive = true
        
        var bottomAnchor = labelTitle.bottomAnchor
        
//    {question_list.question.level}-{question_list.question.folder}/{question_list.question.problem_order}.png
        
        let imageUrl = RequestUrl.AWS + "/image/leveltest/\(testData.testInfo?.examSrl ?? 0)/Word2/level\(testData.quiz?.level ?? 0)-\(testData.quiz?.folder ?? 0)/\(testData.quiz?.quizOrder ?? 0).png"
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = ColourKit.Code.HexF0F0F0
        imageView.clipsToBounds = true
//        imageView.pin_setImage(from: URL(string: imageUrl))
        _imageDownloader.request(imageUrl) { (image) in
            DispatchQueue.main.async { 
                imageView.image = image
            }
        }
        tableHeaderView.addSubview(imageView)

        imageView.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 20.optimizedWithHeight).isActive = true
        imageView.centerXAnchor.constraint(equalTo: tableHeaderView.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 175.optimizedWithHeight).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        bottomAnchor = imageView.bottomAnchor
        
        if testData.quiz?.wordClass != nil {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            tableHeaderView.addSubview(containerView)
            
            containerView.topAnchor.constraint(equalTo: bottomAnchor, constant: 12.optimizedWithHeight).isActive = true
            containerView.centerXAnchor.constraint(equalTo: tableHeaderView.centerXAnchor).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 24.optimizedWithHeight).isActive = true
            
            let backView = UIView()
            backView.translatesAutoresizingMaskIntoConstraints = false
            backView.layer.cornerRadius = 12.optimizedWithHeight
            backView.layer.borderWidth = 1
            backView.layer.borderColor = ColourKit.Code.Hex888888.cgColor
            containerView.addSubview(backView)

            backView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            backView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            backView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true

            var label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = testData.quiz?.wordClass
            label.textColor = ColourKit.Code.Hex555555
            label.font = UIFont.systemFont(ofSize: 15.optimizedWithHeight, weight: .regular)
            backView.addSubview(label)

            label.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 10.optimized).isActive = true
            label.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10.optimized).isActive = true

            label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = testData.quiz?.quiz
            label.textColor = ColourKit.Code.Hex222222
            label.font = UIFont.systemFont(ofSize: 20.optimizedWithHeight, weight: .regular)
            containerView.addSubview(label)

            label.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: backView.trailingAnchor, constant: 8.optimized).isActive = true
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            
            bottomAnchor = backView.bottomAnchor
        }
        
        tableHeaderView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
        tableHeaderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20.optimizedWithHeight).isActive = true

        tableHeaderView.layoutIfNeeded()
        
        _theTableView.tableHeaderView = tableHeaderView
        
        _selectedIndex = nil
        
        _tableData.removeAll()
        _tableData.append(contentsOf: testData.quiz?.answerList ?? [])
        _theTableView.reloadData()
    }
}

extension ALTJuniorWordViewController: UITableViewDelegate, UITableViewDataSource {
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
