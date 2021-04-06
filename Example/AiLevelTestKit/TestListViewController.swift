//
//  TestListViewController.swift
//  AiLevelTestExample
//
//  Created by Jun-kyu Jeon on 2021/03/08.
//

import UIKit

import AiLevelTestKit

class TestListViewController: UIViewController {
    private let _textFieldExamId = UITextField()
    private let _buttonTest = UIButton()
    
    private let _textFieldResultExamId = UITextField()
    private let _textFieldResultCode = UITextField()
    private let _buttonResult = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "테스트 리스트"
        
        self.view.backgroundColor = ColourKit.Code.HexF0F0F0
        
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "테스트할 시험 아이디:"
        label.textAlignment = .right
        label.textColor = UIColor.darkText
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        self.view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(equalToConstant: 89).isActive = true
        label.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        _textFieldExamId.translatesAutoresizingMaskIntoConstraints = false
        _textFieldExamId.backgroundColor = .white
        _textFieldExamId.borderStyle = .roundedRect
        _textFieldExamId.text = "lv_ko_en_a"
        _textFieldExamId.textColor = .darkText
        _textFieldExamId.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.view.addSubview(_textFieldExamId)
        
        _textFieldExamId.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        _textFieldExamId.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 17).isActive = true
        _textFieldExamId.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        _buttonTest.translatesAutoresizingMaskIntoConstraints = false
        _buttonTest.backgroundColor = .red
        _buttonTest.clipsToBounds = true
        _buttonTest.layer.cornerRadius = 8
        _buttonTest.setTitle("테스트 시작하기", for: .normal)
        _buttonTest.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonTest)
        
        _buttonTest.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 24).isActive = true
        _buttonTest.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        _buttonTest.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _buttonTest.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "결과 조회할 시험 아이디:"
        label.textAlignment = .right
        label.textColor = UIColor.darkText
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        self.view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: _buttonTest.bottomAnchor, constant: 40).isActive = true
        label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(equalToConstant: 89).isActive = true
        label.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        _textFieldResultExamId.translatesAutoresizingMaskIntoConstraints = false
        _textFieldResultExamId.backgroundColor = .white
        _textFieldResultExamId.borderStyle = .roundedRect
        _textFieldResultExamId.text = "lv_ko_en_a"
        _textFieldResultExamId.textColor = .darkText
        _textFieldResultExamId.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.view.addSubview(_textFieldResultExamId)
        
        _textFieldResultExamId.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        _textFieldResultExamId.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 17).isActive = true
        _textFieldResultExamId.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        _buttonResult.translatesAutoresizingMaskIntoConstraints = false
        _buttonResult.backgroundColor = .red
        _buttonResult.clipsToBounds = true
        _buttonResult.layer.cornerRadius = 8
        _buttonResult.setTitle("테스트 결과보기", for: .normal)
        _buttonResult.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonResult)
        
        _buttonResult.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 24).isActive = true
        _buttonResult.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        _buttonResult.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _buttonResult.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @objc private func pressedButton(_ button: UIButton) {
        switch button {
        case _buttonTest:
            guard let examId = _textFieldExamId.text else { break }
            AiLevelTestKit.shared.startTestWith(id: examId, from: self)
            break
            
        case _buttonResult:
            guard let examId = _textFieldResultExamId.text else { break }
            AiLevelTestKit.shared.showResult(examId: examId, from: self)
            break
            
        default:
            break
        }
    }
}
