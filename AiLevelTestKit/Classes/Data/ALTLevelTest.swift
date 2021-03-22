//
//  ALTLevelTest.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/24.
//

import Foundation

class ALTLevelTest: ALTBaseData {
    class Category: ALTBaseData {
        // 영역 고유 번호
        var partSrl: Int? {
            return rawData["part_srl"] as? Int
        }
        
        // 영역 세트 고유 번호
        var setSrl: Int? {
            return rawData["set_srl"] as? Int
        }
        
        // 영역 문제 수
        var numberOfQuizs: Int {
            return rawData["exam_count"] as? Int ?? 0
//            return rawData["problem_count"] as? Int ?? 0
        }
        
        // 영역명
        var name: String? {
            return rawData["name"] as? String
        }
        
        // 영역 영어 명칭(웹에서는 영역 method를 동적 호출를 위한 용도로 사용)
        var path: String? {
            return rawData["path"] as? String
        }
        
        var order: Int? {
            return rawData["order"] as? Int
        }
        
        var needMicrophone: Bool {
            return rawData["connect_mic"] as? Bool ?? false
        }
        
//        "type": "1",
//        "folder_count": 50,
//        "problem_count": 10,
//        "exam_count": 10,
//        "jump": {
//            "correct_combo": [
//                "17",
//                "31",
//                "53",
//                "53",
//                "31"
//            ],
//            "incorrect_combo": [
//                "12",
//                "33",
//                "71",
//                "71",
//                "28"
//            ]
//        },
    }
    
    class Data: ALTBaseData {
        var testSrl: Int? {
            return rawData["test_srl"] as? Int
        }
        
        var customerSrl: Int? {
            return rawData["customer_srl"] as? Int
        }
        
        var customerCode: Int? {
            return rawData["customer_code"] as? Int
        }
        
        var testState: Int? {
            get {
                guard let value = rawData["test_state"] as? String else { return nil }
                return Int(value)
            }
        }
        
        var paidType: Int? {
            get {
                guard let value = rawData["paid_type"] as? String else { return nil }
                return Int(value)
            }
        }
        
        var startDate: Date? {
            get {
                guard let dateString = rawData["start_date"] as? String else { return nil }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                return formatter.date(from: dateString)
            }
        }
        
        var endDate: Date? {
            get {
                guard let dateString = rawData["end_date"] as? String else { return nil }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                return formatter.date(from: dateString)
            }
        }
        
        var activatedTime: Int? {
            return rawData["active_time"] as? Int
        }
        
        var isRequested: Bool {
            get {
                guard let value = rawData["is_request"] as? String else { return false }
                return value == "Y"
            }
        }
        
        var refererUrl: String? {
            get {
                return rawData["referer_url"] as? String
            }
        }
        
        var refererDevice: String? {
            get {
                return rawData["referer_device"] as? String
            }
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
        
        var examInfo: ALTExamData? {
            get {
                guard let value = rawData["exam_info"] as? [String:Any] else { return nil }
                return ALTExamData(with: value)
            }
        }
        
        var categories: [Category]? {
            get{
                guard let value = rawData["set_list"] as? [[String:Any]] else { return nil }
                return value.map { (item) -> Category in
                    return Category(with: item)
                }
            }
        }
    }
    
    class Quiz: ALTBaseData {
        struct Answer {
            let number: Int
            let answer: String
        }
        
        var category: Category? {
            guard let info = rawData["set_info"] as? [String:Any] else { return nil }
            return Category(with: info)
        }
        
        internal var details: [String:Any]? {
            return rawData["question"] as? [String:Any]
        }
        
        var order: Int? {
            return details?["order"] as? Int
        }
        
        var sequence: Int? {
            return details?["sequence"] as? Int
        }
        
        var quizSrl: Int? {
            return details?["problem_srl"] as? Int
        }
        
        var partSrl: Int? {
            return details?["part_srl"] as? Int
        }
        
        var quiz: String? {
            return details?["problem"] as? String
        }
        
        var quizDesc: String? {
            return details?["text"] as? String
        }
        
        var exam: String? {
            return details?["exam"] as? String
        }
        
        var answer: String? {
            return details?["answer"] as? String
        }
        
        var comm: String? {
            return details?["comm"] as? String
        }
        
        var extra_comm: String? {
            return details?["extra_comm"] as? String
        }
        
        var levelSrl: Int? {
            return details?["level_srl"] as? Int
        }
        
        var repeatQuizSrl: Int? {
            return details?["repeat_problem_srl"] as? Int
        }
        
        var repeatPartSrl: Int? {
            return details?["repeat_part_srl"] as? Int
        }
        
        var step: Int? {
            return details?["step"] as? Int
        }
        
        var folderStep: Int? {
            return details?["folder_step"] as? Int
        }
        
        var level: Int? {
            return details?["level"] as? Int
        }
        
        var folder: Int? {
            return details?["folder"] as? Int
        }
        
        var quizOrder: Int? {
            return details?["problem_order"] as? Int
        }
        
        var answerList: [Answer]? {
            get {
                guard let value = rawData["exam_list"] as? [[String:Any]] else { return nil }
                
                return value.compactMap { (item) -> Answer? in
                    guard let number = item["problem_srl"] as? Int ?? (item["num"] as? Int),
                          let answer = item["answer"] as? String else { return nil }
                    return Answer(number: number, answer: answer)
                }
            }
        }
        
        var wordClass: String? {
            return details?["word_class"] as? String
        }
        
        var form: String? {
            return details?["form"] as? String
        }
    }
    
    var testInfo: Data? {
        get {
            guard let value = rawData["test_info"] as? [String:Any] else { return nil }
            return Data(with: value)
        }
    }
    
    var quiz: Quiz? {
        get {
            guard let value = rawData["question_list"] as? [String:Any] else { return nil }
            return Quiz(with: value)
        }
    }
}
