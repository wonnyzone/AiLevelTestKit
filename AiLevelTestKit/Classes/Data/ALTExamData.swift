//
//  ALTExamData.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/24.
//

import Foundation

public class ALTExamData: ALTBaseData {
    public var identifier: String? {
        return rawData["exam_id"] as? String
    }
    
    public var title: String? {
        return rawData["exam_title"] as? String
    }
    
    // 시험 설정 고유 번호
    public var setupSrl: Int? {
        return rawData["setup_srl"] as? Int
    }
    
    // 시험 고유 번호
    public var examSrl: Int? {
        return rawData["exam_srl"] as? Int
    }
    
    public var groupSrl: Int? {
        return rawData["group_srl"] as? Int
    }
    
    // 시험 제한 시간
    public var limitTime: Int? {
        get {
            guard let value = rawData["limit_time"] as? Int else { return nil }
            return value * 60
        }
    }
    
    // 개인정보동의 페이지 활성화 여부
    public var isPrivacyActivated: Bool {
        return (rawData["exam_view1"] as? String ?? "N") == "Y"
    }
    
    // 쿠폰 페이지 활성화 여부
    public var isCouponActivated: Bool {
        return (rawData["exam_view2"] as? String ?? "N") == "Y"
//        return false
    }
    
    // 튜토리얼 페이지 활성화 여부
    public var isTutorialActivated: Bool {
        return (rawData["exam_view3"] as? String ?? "N") == "Y"
    }
    
    // 마이크테스트 페이지 활성화 여부
    public var isMicTestActivated: Bool {
        return (rawData["exam_view4"] as? String ?? "N") == "Y"
    }
    
    public var isMyPageView1: Bool {
        return (rawData["mypage_view1"] as? String ?? "N") == "Y"
    }
    
    public var isMyPageView2: Bool {
        return (rawData["mypage_view2"] as? String ?? "N") == "Y"
    }
    
    public var isMyPageView3: Bool {
        return (rawData["mypage_view3"] as? String ?? "N") == "Y"
    }
    
    public var isMyPageView4: Bool {
        return (rawData["mypage_view4"] as? String ?? "N") == "Y"
    }
    
    // 1 - 쿠폰 사용, 2 - 포인트 차감(쿠폰 페이지 비활성화)
    public var examSetup1: Int? {
        get {
            guard let value = rawData["exam_setup1"] as? String else { return nil }
            return Int(value)
        }
    }
    
    // 1 - 시험 완료 시 결과 바로 확인, 2 - 시험 완료 시 팝업 안내 후 결과 확인, 3 - 시험 완료 시 팝업 안내 후 결과 확인 안함
    public var examSetup2: Int? {
        get {
            guard let value = rawData["exam_setup2"] as? String else { return nil }
            return Int(value)
        }
    }
    
    // 1 - 음성 인식 후 인식 문장 표시, 2 - 음성 인식 후 그래프 표시, 3 - 음성 인식 후 인식 문장 및 그래프 표시
    public var examSetup3: Int? {
        get {
            guard let value = rawData["exam_setup3"] as? String else { return nil }
            return Int(value)
        }
    }
    
    public var myPageSetup1: Int? {
        get {
            guard let value = rawData["mypage_setup1"] as? String else { return nil }
            return Int(value)
        }
    }
    
    // 'default' - 성인 레벨테스트, 'kids' - 키즈 레벨테스트
    public var theme: String? {
        return rawData["exam_theme"] as? String
    }
    
    public var userLanguage: String? {
        return rawData["main_lang"] as? String
    }
    
    public var testLanguage: String? {
        return rawData["problem_lang"] as? String
    }
    
    //          "mypage_theme": "default",
    //          "exam_type": "2",
    //          "exam_status": "2",
    
}
