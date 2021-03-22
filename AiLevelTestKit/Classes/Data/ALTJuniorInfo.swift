//
//  ALTJuniorInfo.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2021/02/24.
//

import Foundation

class ALTJuniorInfo: ALTBaseData {
    class Exam: ALTBaseData {
        var name: String? {
            return rawData["name"] as? String
        }
        
        var exam: String? {
            return rawData["exam"] as? String
        }
        
        var imageUrl: String? {
            get {
                guard let value = rawData["image"] as? String else { return nil }
                return RequestUrl.Base + value.dropFirst()
            }
        }
    }
    
    var connSrl: Int? {
        return rawData["conn_srl"] as? Int
    }
    
    var groupSrl: Int? {
        return rawData["group_srl"] as? Int
    }
    
    var conn_id: String? {
        return rawData["conn_id"] as? String
    }
    
    var title: String? {
        return rawData["title"] as? String
    }
    
    var examList: [Exam] {
        get {
            guard let items = rawData["conn_info"] as? [[String:Any]] else { return [] }
            return items.map { (item) -> Exam in
                return Exam(with: item)
            }
        }
    }
    
    var theme: String? {
        return rawData["theme"] as? String
    }
    
    var type: String? {
        return rawData["type"] as? String
    }
    
    var isLoaded: Bool {
        return rawData["is_load"] as? String == "Y"
    }
}
