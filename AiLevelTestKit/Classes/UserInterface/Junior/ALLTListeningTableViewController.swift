//
//  ALLTListeningTableViewController.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/08.
//

import UIKit

import AVFoundation

class ALLTListeningTableViewController: ALLTBaseViewController {
    internal let _theTableView = UITableView()
    
    internal let _buttonPlay = UIButton()
    internal let _buttonNext = UIButton()
    
    internal var _selectedIndex: Int? {
        didSet {
            _buttonNext.isEnabled = _selectedIndex != nil
        }
    }
    
    internal var _tableData = [String]()
    
    internal var _remainingPlayCount = 2
    
    internal var _player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item = AVPlayerItem(url: URL(string: "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_1MG.mp3")!)

        _player = AVPlayer(playerItem: item)
//        _player?.delegate = self
//        _player?.prepareToPlay()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _player?.pause()
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func pressedButton(_ button: UIButton) {
        super.pressedButton(button)
        
        switch button {
        case _buttonNext:
            
            break
            
        case _buttonPlay:
            guard _remainingPlayCount > 0 else { break }
            
            _buttonPlay.isEnabled = false
            _player?.play()
            break
            
        default:
            break
        }
    }
    
    internal func reloadData() {
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 267.optimized))
        tableHeaderView.backgroundColor = .clear
        
        let labelTitle = UILabel()
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.text = "다음을 듣고 주인공의 심정으로\n적절한 것을 고르세요."
        labelTitle.textAlignment = .center
        labelTitle.textColor = ColourKit.Code.Hex222222
        labelTitle.font = UIFont.systemFont(ofSize: 22.optimized, weight: .heavy)
        labelTitle.numberOfLines = 0
        tableHeaderView.addSubview(labelTitle)
        
        labelTitle.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 58.optimized).isActive = true
        labelTitle.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: 42.optimized).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor, constant: -42.optimized).isActive = true
        labelTitle.heightAnchor.constraint(equalToConstant: 56.optimized).isActive = true
        
        _buttonPlay.translatesAutoresizingMaskIntoConstraints = false
        _buttonPlay.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.Static.Hex00C9B7), for: .normal)
        _buttonPlay.setBackgroundImage(UIImage.withSolid(colour: ColourKit.Code.HexCCCCCC), for: .disabled)
        _buttonPlay.setImage(UIImage(named: "img_volume", in:Bundle(for: type(of: self)), compatibleWith:nil)?.withRenderingMode(.alwaysOriginal), for: .normal)
        _buttonPlay.addTarget(self, action: #selector(self.pressedButton(_:)), for: .touchUpInside)
        _buttonPlay.clipsToBounds = true
        _buttonPlay.layer.cornerRadius = 10.optimized
        _buttonPlay.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8).optimized
        _buttonPlay.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0).optimized
        tableHeaderView.addSubview(_buttonPlay)
        
        _buttonPlay.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 40.optimized).isActive = true
        _buttonPlay.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: 48.optimized).isActive = true
        _buttonPlay.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor, constant: -48.optimized).isActive = true
        _buttonPlay.heightAnchor.constraint(equalTo: _buttonPlay.widthAnchor, multiplier: 60 / 280).isActive = true
        
        _remainingPlayCount = 2
        reloadPlayButton()
        
        tableHeaderView.layoutIfNeeded()
        
        _theTableView.tableHeaderView = tableHeaderView
        
        _selectedIndex = nil
        
        _tableData.append("기쁨")
        _tableData.append("슬픔")
        _tableData.append("외로움")
        _tableData.append("분노")
        _tableData.append("희망찬")
        
        _theTableView.reloadData()
    }
    
    internal func reloadPlayButton() {
        var attributes = QTextAttributes(withForegroundColour: .white, font: UIFont.systemFont(ofSize: 20.optimized, weight: .bold)).attributes
        
        let countString = "\(_remainingPlayCount)회"
        let string = String(format: "문제듣기 %@ 가능", arguments: [countString])
        
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        if _remainingPlayCount > 0, let range = string.nsRange(of: countString) {
            attributes = QTextAttributes(withForegroundColour: #colorLiteral(red: 0.9137254902, green: 0.968627451, blue: 0.2117647059, alpha: 1), font: UIFont.systemFont(ofSize: 20.optimized, weight: .bold)).attributes
            attributedString.addAttributes(attributes, range: range)
        }
        _buttonPlay.setAttributedTitle(attributedString, for: .normal)
        
        _buttonPlay.isEnabled =  _remainingPlayCount > 0
    }
    
    @objc private func playerDidFinishPlaying(note: NSNotification) {
        _remainingPlayCount -= 1
        reloadPlayButton()
    }
}

extension ALLTListeningTableViewController: UITableViewDelegate, UITableViewDataSource {
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
