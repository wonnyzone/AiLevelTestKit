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
        
        self.view.backgroundColor = ColourKit.Code.HexF0F0F0
        
        let label = UILabel()
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
        _textFieldTestSrl.backgroundColor = .white
        _textFieldTestSrl.borderStyle = .roundedRect
        _textFieldTestSrl.text = "lv_ko_en_a"
        _textFieldTestSrl.textColor = .darkText
        _textFieldTestSrl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.view.addSubview(_textFieldTestSrl)
        
        _textFieldTestSrl.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        _textFieldTestSrl.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 17).isActive = true
        _textFieldTestSrl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        self.view.backgroundColor = ColourKit.Code.HexFFFFFF
        
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
        
        
        _buttonResult.translatesAutoresizingMaskIntoConstraints = false
        _buttonResult.backgroundColor = .red
        _buttonResult.clipsToBounds = true
        _buttonResult.layer.cornerRadius = 8
        _buttonResult.setTitle("테스트 결과 보기", for: .normal)
        _buttonResult.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        self.view.addSubview(_buttonResult)
        
        _buttonResult.topAnchor.constraint(equalTo: _buttonTest.bottomAnchor, constant: 60).isActive = true
        _buttonResult.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        _buttonResult.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _buttonResult.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @objc private func pressedButton(_ button: UIButton) {
        switch button {
        case _buttonTest:
            guard let testSrl = _textFieldTestSrl.text else { break }
            AiLevelTestKit.shared.startTestWith(id: testSrl, from: self)
            break
            
        case _buttonResult:
//            AiLevelTestKit.shared.showResultList(from: self)
            break
            
        default:
            break
        }
    }
}
