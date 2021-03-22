//
//  ALTLevelTestResultData.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/12/11.
//

import Foundation

class ALTLevelTestResultData: ALTBaseData {
    class Info: ALTBaseData {
        var sectionNames: [String]? {
            return rawData["section_name"] as? [String]
        }
        
        var sectionPaths: [String]? {
            return rawData["section_path"] as? [String]
        }
        
        var sectionLevels: [Int]? {
            return rawData["section_level"] as? [Int]
        }
        
        var sectionFolders: [Int]? {
            return rawData["section_folder"] as? [Int]
        }
        
        var sectionScores: [Int]? {
            return rawData["section_score"] as? [Int]
        }
        
        var sectionDispLevels: [String]? {
            return rawData["section_disp_level"] as? [String]
        }
        
        var sectionAvgLevel: [Int]? {
            return rawData["section_avg_level"] as? [Int]
        }
        
        var sectionAvgScore: [Int]? {
            return rawData["section_avg_score"] as? [Int]
        }
        
        var totalLevel: Int? {
            return rawData["total_level"] as? Int
        }
        
        var totalFolder: Int? {
            return rawData["total_folder"] as? Int
        }
        
        var totalScore: Int? {
            return rawData["total_score"] as? Int
        }
    }
    
    var testSrl: Int? {
        return rawData["test_srl"] as? Int
    }
    
    var customerSrl: Int? {
        return rawData["customer_srl"] as? Int
    }
    
    var customerCode: String? {
        return rawData["customer_code"] as? String
    }
    
    var testState: String? {
        return rawData["test_state"] as? String
    }
    
    var paidType: String? {
        return rawData["paid_type"] as? String
    }
    
    var startDate: Double? {
        get {
            guard let dateString = rawData["start_date"] as? String else { return nil }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            return formatter.date(from: dateString)?.timeIntervalSince1970
        }
    }
    
    var endDate: Double? {
        get {
            guard let dateString = rawData["end_date"] as? String else { return nil }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            return formatter.date(from: dateString)?.timeIntervalSince1970
        }
    }
    
    var resultLevel: Int? {
        return rawData["result_level"] as? Int
    }
    
    var resultFolder: Int? {
        return rawData["result_folder"] as? Int
    }
    
    var resultScore: Int? {
        return rawData["result_score"] as? Int
    }
    
    var couponCode: String? {
        return rawData["coupon_code"] as? String
    }
    
    var activeTime: Int? {
        return rawData["active_time"] as? Int
    }
    
    var isRequested: Bool {
        return (rawData["is_request"] as? String ?? "N") == "Y"
    }
    
    var refererUrl: String? {
        return rawData["referer_url"] as? String
    }
    
    var refererDevice: String? {
        return rawData["referer_device"] as? String
    }
    
    var recommendSrl: Int? {
        return rawData["recommend_srl"] as? Int
    }
    
    var examSrl: Int? {
        return rawData["exam_srl"] as? Int
    }
    
    var setupSrl: Int? {
        return rawData["setup_srl"] as? Int
    }
    
    var extra: String? {
        return rawData["extra"] as? String
    }
    
    var period: String? {
        return rawData["period"] as? String
    }
    
    var examId: String? {
        return rawData["exam_id"] as? String
    }
    
    var examTitle: String? {
        return rawData["exam_title"] as? String
    }
    
    var info: Info? {
        guard let data = rawData["result_info"] as? [String:Any] else { return nil }
        return Info(with: data)
    }
    
    var isFinished: Bool {
        return testState == "2"
    }
}
