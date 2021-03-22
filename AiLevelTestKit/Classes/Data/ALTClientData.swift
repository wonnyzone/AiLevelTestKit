//
//  ALTClientData.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/16.
//

import UIKit

class ALTClientData: ALTBaseData {
    var srl: Int? {
        get {
            return rawData["group_srl"] as? Int
        } set {
            rawData["group_srl"] = newValue
        }
    }
    
    var code: String? {
        get {
            return rawData["group_code"] as? String
        } set {
            rawData["group_code"] = newValue
        }
    }
    
    var title: String? {
        get {
            return rawData["title"] as? String
        } set {
            rawData["title"] = newValue
        }
    }
    
    var email: String? {
        get {
            return rawData["email"] as? String
        }
    }
    
    var agreement: String? {
        get {
            return rawData["agreement"] as? String
        }
    }
}

