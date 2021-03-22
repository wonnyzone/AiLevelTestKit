//
//  LevelTestManager.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/06.
//

import UIKit

private let MAXIMUM_ACTIVE_TIME = 30 * 60

class LevelTestManager: NSObject {
    public struct NotificationName {
        public static let timeUpdated = Notification.Name("LevelTestManager.timeUpdated")
        public static let timesUp = Notification.Name("LevelTestManager.timesUp")
    }
    
    enum Mode: Int {
        case unknown = -1
        case junior = 0
        case senior = 1
    }
    
    static let manager = LevelTestManager()
    
    private var quizCategories = [ALTLevelTest.Category]()
    var categories: [ALTLevelTest.Category] {
        return quizCategories
    }
    
    var mode: Mode = .unknown
    
    var totalQuizCount: Int {
        get {
            var count = 0
            for category in quizCategories {
                count += category.numberOfQuizs
            }
            return count
        }
    }
    
    private var _rawData: [String:Any]?
    var initialized: Bool {
        return _rawData != nil
    }
    
    // 고객 고유 번호
    var customerSrl: Int? {
        return _rawData?["customer_srl"] as? Int
    }
    
    // 개인 정보 동의를 했는지 여부 ("Y"일 경우 개인정보동의 페이지 비활성화)
    var needAgreement: Bool {
        return (_rawData?["is_agreement"] as? String ?? "N") == "N"
    }
    
//    // (완료 하지 않은 시험이 있을 경우) 진행된 시간 - '초'로 표시
//    var activeTime: Int? {
//        return _rawData?["active_time"] as? Int
//    }
//
//    // (완료 하지 않은 시험이 있을 경우) 완료 하지 않은 고객 시험 고유 번호
//    var testingSrl: Int? {
//        return _rawData?["testing_test_srl"] as? Int
//    }
    
    var examInfo: ALTExamData? {
        get {
            guard let dict = _rawData?["exam_info"] as? [String:Any] else { return nil }
            return ALTExamData(with: dict)
        }
    }
    
    var startNew: Bool = false              // true - 시험 재시작
    
    private var _examId: String?
    private var _connId: String?
    
    var isJunior: Bool {
        return _connId != nil
    }
    
    var examId: String? {
        return _examId
    }
    
    private var _timer: Timer?
    private var _activeTime = 0
    var activeTime: Int {
        return  _activeTime
    }
    var remainingTime: Int {
        return (examInfo?.limitTime ?? MAXIMUM_ACTIVE_TIME) - _activeTime
    }
    
    var testSrl: Int?
    
    var recogResultType: Int {
        return examInfo?.examSetup3 ?? 1
//        return 2
    }
    
    override init() {
        super.init()
        
        clear()
    }
    
    func clear() {
        quizCategories.removeAll()
        
        _rawData = nil
        _examId = nil
        _connId = nil
        
        startNew = false
        
        _activeTime = 0
        _timer?.invalidate()
        _timer = nil
    }
    
    var delegate: UIViewController?
    
    
    func initialize(examId: String, juniorConnId: String? = nil, completion: (() -> Void)? = nil) {
        clear()
        
        _connId = juniorConnId
        
        let httpClient = QHttpClient()
        httpClient.method = .Post
        
        var params = [String:Any]()
        params["group_code"] = AiLevelTestKit.shared.groupCode
        params["exam_id"] = examId
        params["email"] = AiLevelTestKit.shared.email
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Test.Initialize) { [weak self] (code, errMessage, response) in
            if let responseData = response as? [String:Any] {
                self?._rawData = responseData
                self?._examId = examId
                
                self?.testSrl = responseData["testing_test_srl"] as? Int
                
                self?._activeTime = responseData["active_time"] as? Int ?? 0
                
                self?.quizCategories.append(contentsOf: (responseData["set_list"] as? [[String:Any]] ?? []).compactMap({ (item) -> ALTLevelTest.Category? in
                    let category = ALTLevelTest.Category(with: item)
                    return category.partSrl != nil ? category : nil
                }))
            }
            
            completion?()
        }
    }
    
    func startTest(_ completion: @escaping ((_ testSrl: Int?, _ errMessage: String?) -> Void)) {
        let httpClient = QHttpClient()
        httpClient.method = .Post
        
        var params = [String:Any]()
        params["exam_srl"] =  examInfo?.examSrl
        params["setup_srl"] = examInfo?.setupSrl
        params["group_code"] = AiLevelTestKit.shared.groupCode
        params["customer_srl"] = customerSrl
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Test.Start) { [weak self] (code, errMessage, response) in
            guard let responseData = response as? [String:Any], let testSrl = responseData["test_srl"] as? Int else {
                completion(nil, errMessage ?? "알 수 없는 오류입니다.")
                return
            }
            
            self?.testSrl = testSrl
            
            completion(testSrl, nil)
        }
    }
    
    func RestartTest(testSrl: Int, completion: @escaping ((_ testSrl: Int?, _ errMessage: String?) -> Void)) {
        let httpClient = QHttpClient()
        httpClient.method = .Post
        
        var params = [String:Any]()
        params["test_srl"] =  testSrl
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Test.Restart) {[weak self] (code, errMessage, response) in
            guard code == .success else {
                completion(nil, errMessage ?? "알 수 없는 오류입니다.")
                return
            }
            
            self?._activeTime = 0
            
            self?.testSrl = testSrl
            
            completion(testSrl, nil)
        }
    }
    
    func getQuizCategory(for step: Int) -> ALTLevelTest.Category? {
        var category: ALTLevelTest.Category?
        
        var count = 0
        for i in 0 ..< quizCategories.count {
            let item = quizCategories[i]
            count += item.numberOfQuizs
            
            if step > count {
                break
            }
            
            category = item
        }
        
        return category
    }
    
    func getQuizViewController(for next: Int? = nil, isContinue: Bool, completion: @escaping ((ALTBaseViewController?, String?) -> Void)) {
        let httpClient = QHttpClient()
        httpClient.method = .Post
        
        var params = [String:Any]()
        params["test_srl"] = testSrl
        params["is_continue"] = isContinue
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Test.Quiz.GetNext) { (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any] else {
                completion(nil, errMessage)
                return
            }
            
            let data = ALTLevelTest(with: responseData)
            guard let path = data.quiz?.category?.path  else {
                completion(nil, errMessage)
                return
            }
            
            let step = next ?? (data.quiz?.order ?? 0) - 1
            
            var viewController: ALTBaseViewController?
            
            switch path {
            case "Word1", "Word2":
                viewController = self.isJunior ? ALTJuniorWordViewController(step: step, testData: data) : ALTSeniorTestWordViewController(step: step, testData: data)
                break
                
            case "Listen1", "Listen2":
                viewController = self.isJunior ? ALTJuniorListeningViewController(step: step, testData: data) : ALTSeniorListeningTestViewController(step: step, testData: data)
                break
                
            case "Reading1", "Reading2", "Pronounce1", "Pronounce2":
                viewController = self.isJunior ? ALTJuniorReadingViewController(step: step, testData: data) : ALTSeniorReadingTestViewController(step: step, testData: data)
                break
                
            case "Write1", "Write2":
                viewController = self.isJunior ? ALTJuniorWritingViewController(step: step, testData: data) : ALTSeniorWritingTestViewController(step: step, testData: data)
                break
                
            case "Speak1", "Speak2":
                viewController = self.isJunior ? ALTJuniorSpeakingViewController(step: step, testData: data) : ALTSeniorSpeakingTestViewController(step: (data.quiz?.order ?? 0) - 1, testData: data)
                break
                
            default: break
            }
            
            completion(viewController, (viewController == nil ? errMessage : nil))
        }
    }
    
    func uploadAnswer(step: Int, testData: ALTLevelTest?, answer: String?, completion: @escaping ((ALTBaseViewController?, String?) -> Void)) {
        let httpClient = QHttpClient()
        httpClient.method = .Post
        
        var params = [String:Any]()
        params["test_srl"] = testData?.testInfo?.testSrl
        params["set_srl"] = testData?.quiz?.category?.setSrl
        params["level_srl"] = testData?.quiz?.levelSrl
        params["answer"] = answer
        params["sequence"] = testData?.quiz?.sequence
        params["order"] = step + 1
        params["active_time"] = LevelTestManager.manager.activeTime
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Test.Quiz.Answer) { (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any] else {
                completion(nil, errMessage)
                return
            }
            
            let data = ALTLevelTest(with: responseData)
            guard let path = data.quiz?.category?.path else {
                completion(nil, errMessage)
                return
            }
            
            var viewController: ALTBaseViewController?
            
            
            switch path {
            case "Word1", "Word2":
                viewController = ALTSeniorTestWordViewController(step: (data.quiz?.order ?? 0) - 1, testData: data)
                break
                
            case "Listen1", "Listen2":
                viewController = ALTSeniorListeningTestViewController(step: (data.quiz?.order ?? 0) - 1, testData: data)
                break
                
            case "Reading1", "Reading2":
                viewController = ALTSeniorReadingTestViewController(step: (data.quiz?.order ?? 0) - 1, testData: data)
                break
                
            case "Write1", "Write2":
                viewController = ALTSeniorWritingTestViewController(step: (data.quiz?.order ?? 0) - 1, testData: data)
                break
                
            case "Speak1", "Speak2":
                viewController = ALTSeniorSpeakingTestViewController(step: (data.quiz?.order ?? 0) - 1, testData: data)
                break
                
            default: break
            }
            
            completion(viewController, (viewController == nil ? errMessage : nil))
        }
    }
    
    func getCouponList(for state: ALTCouponData.State, completion: @escaping (([ALTCouponData]?, String?) -> Void)) {
        let httpClient = QHttpClient()
        
        var params = [String:Any]()
        params["customer_srl"] = customerSrl
        params["exam_srl"] =  examInfo?.examSrl
        params["type"] = state == .active ? "active" : "inactive"
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Coupon.GetList) { (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any], let list = responseData["list"] as? [[String:Any]] else {
                completion(nil, errMessage)
                return
            }
            
            completion(list.map({ (item) -> ALTCouponData in
                return ALTCouponData(with: item)
            }), nil)
        }
    }
    
    func useCoupon(with data: ALTCouponData, completion: @escaping ((Bool, String?) -> Void)) {
        let httpClient = QHttpClient()
        
        var params = [String:Any]()
        params["customer_srl"] = customerSrl
        params["coupon_code"] =  data.code
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Coupon.Use) { (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any] else {
                completion(false, errMessage)
                return
            }
            
            completion(responseData["result"] as? Bool ?? false, responseData["msg"] as? String)
        }
    }
    
    func addCoupon(with code: String, completion: @escaping ((Bool, String?) -> Void)) {
        let httpClient = QHttpClient()
        
        var params = [String:Any]()
        params["customer_srl"] = customerSrl
        params["coupon_code"] =  code
        params["setup_srl"] = examInfo?.setupSrl
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Coupon.Register) { (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any] else {
                completion(false, errMessage)
                return
            }
            
            completion(responseData["result"] as? Bool ?? false, responseData["msg"] as? String)
        }
    }
    
    func getJuniorExamInfo(with connId: String, completion: @escaping ((ALTJuniorInfo?, String?) -> Void)) {
        let httpClient = QHttpClient()
        
        var params = [String:Any]()
        params["conn_id"] = connId
        params["group_code"] = AiLevelTestKit.shared.groupCode
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Test.GetJuniorInfo) { (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any], let rawData = responseData["conn_exam"] as? [String:Any] else {
                completion(nil, errMessage)
                return
            }
            
            completion(ALTJuniorInfo(with: rawData), nil)
        }
    }
    
    func startTimerIfNeed() {
        guard _timer == nil else { return }
        
        _timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {[weak self] (timer) in
            self?._activeTime += 1
            
            guard let remainingTime = self?.remainingTime, remainingTime > 0 else {
                self?._timer?.invalidate()
                self?._timer = nil
                
                NotificationCenter.default.post(Notification(name: NotificationName.timesUp))
                return
            }
            
            NotificationCenter.default.post(Notification(name: NotificationName.timeUpdated))
        })
    }
    
    func exitTest() {
        _timer?.invalidate()
        _timer = nil
    }
}
