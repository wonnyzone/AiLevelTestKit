//
//  LanguageData.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/10/16.
//

import Foundation

class LanguageData: NSObject {
    let mode: ALTAppStringManager.Language
    
    init(with mode: ALTAppStringManager.Language) {
        self.mode = mode
        super.init()
    }
    
    var title: String {
        get {
            var string = "English"
            
            switch mode {
            case .korean:
                string = "한국어"
                break
                
            case .japanese:
                string = "日本語"
                break
                
            case .chinese:
                string = "中文"
                break
                
            case .spanish:
                string = "Español"
                break
                
            default:break
            }
            
            return string
        }
    }
    
    var identifier: String {
        get {
            return mode.rawValue
        }
    }
}
