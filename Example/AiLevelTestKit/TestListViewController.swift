//
//  TestListViewController.swift
//  AiLevelTestExample
//
//  Created by Jun-kyu Jeon on 2021/03/08.
//

import UIKit

import AiLevelTestKit

class TestListViewController: UIViewController {
    private let _textFieldTestSrl = UITextField()
    private let _buttonTest = UIButton()
    
    private let _textFieldResultCode = UITextField()
    private let _buttonResult = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "테스트 리스트"
        
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "테스트"
        label.textColor = UIColor.darkText
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(equalToConstant: 89).isActive = true
        label.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        _textFieldTestSrl.translatesAutoresizingMaskIntoConstraints = false
        _textFieldTestSrl.borderStyle = .roundedRect
        _textFieldTestSrl.text = "lv_ko_en_a"
        _textFieldTestSrl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.view.addSubview(_textFieldTestSrl)
        
        _textFieldTestSrl.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        _textFieldTestSrl.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 17).isActive = true
        _textFieldTestSrl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        self.view.backgroundColor = ColourKit.Code.HexFFFFFF
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        button.setTitle("테스트 시작하기", for: .normal)
        button.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        
        button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        button.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @objc private func pressedButton(_ button: UIButton) {
//        AiLevelTestKit.shared.startTestWith(id: "lv_ko_en_a", from: self)
//        AiLevelTestKit.shared.startTest(from: self, withId: "examId")
        
    }
}
