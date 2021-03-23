//
//  AELevelTestKit.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/24.
//

import UIKit

import AVFoundation

public class AiLevelTestKit {
    public static let shared = AiLevelTestKit()
    
    public var themeColour: UIColor = #colorLiteral(red: 0.9294117647, green: 0.07843137255, blue: 0.3568627451, alpha: 1)
    
    public var groupCode: String? {
        return UserDataManager.manager.groupCode
    }
    
    public var email: String? {
        return UserDataManager.manager.userId
    }
    
    public var userGroupTitle: String? {
        get {
            return UserDataManager.manager.groupTitle
        }
    }
    
    public var isLoggedIn: Bool {
        get {
            return UserDataManager.manager.isLoggedIn
        }
    }
    
    public func initialize() {
        AVAudioSession.sharedInstance().requestRecordPermission { (succeed) in }
        
        var image: UIImage?
        let bundle = Bundle(for: AiLevelTestKit.self)
        if #available(iOS 13.0, *) {
            image = UIImage(named: "img_close_blk", in: bundle, with: nil)
        } else {
            image = UIImage(named: "img_close_blk", in: bundle, compatibleWith: nil)
        }
        print(image)
        
        print(UIImage(named: "img_close_blk"))
    }
    
    public func activate(groupCode: String, email: String? = nil, themeColour: UIColor = #colorLiteral(red: 0.9294117647, green: 0.07843137255, blue: 0.3568627451, alpha: 1), completion: @escaping ((_ code: ALTResponseCode, _ errorMessage: String?) -> Void)) {
        UserDataManager.manager.validate(groupCode: groupCode, email: email) { (code, errMessage, info) in
            guard code == .success, let data = info else {
                completion(.Failed, errMessage ?? "등록 정보를 찾을 수 없습니다.")
                return
            }
            
            completion(.Succeed, nil)
//            UserDataManager.manager.login(org: data, userId: email) { (code, errMessage) in
//                guard code == .success else {
//                    completion(.Failed, errMessage ?? "로그인에 실패했습니다.")
//                    return
//                }
//
//                completion(.Succeed, nil)
//            }
        }
    }
    
//    public func getExamList(_ completion: @escaping ((_ code: ALTResponseCode, _ errorMessage: String?, _ exams: [ALTExamData]?) -> Void)) {
//        guard groupCode != nil else {
//            completion(.Failed, "groupCode 가 없습니다.", nil)
//            return
//        }
//
//        let httpClient = QHttpClient()
//        httpClient.method = .Post
//
//        var params = [String:Any]()
//        params["group_code"] = groupCode
//        httpClient.parameters = QHttpClient.Parameter(dict: params)
//
//        httpClient.sendRequest(to: RequestUrl.Test.GetList) { (code, errMessage, response) in
//            guard code == .success, let responseData = response as? [String:Any], let examList = responseData["exam_list"] as? [[String:Any]] else {
//                completion(.Failed, errMessage ?? "exam 목록을 가져올 수 없습니다.", nil)
//                return
//            }
//
//            completion(.Succeed, nil, examList.map({ (item) -> ALTExamData in
//                return ALTExamData(with: item)
//            }))
//        }
//    }
    
    public func startTestWith(id examId: String, from viewController: UIViewController) {
//        guard let examId = exam.identifier else {
//            print("**** exam id 가 존재하지 않습니다.")
//            return
//        }
        
        QIndicatorViewManager.shared.showIndicatorView { (complete) in
            LevelTestManager.manager.initialize(examId: examId) { [weak self] in
                QIndicatorViewManager.shared.hideIndicatorView()
                
                guard let testingSrl = LevelTestManager.manager.testSrl else {
                    self?.startIntitializedTest(from: viewController)
                    return
                }
                
                let alertController = UIAlertController(title: "기존에 완료하지 않은 시험이 있습니다.", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "이어하기", style: .cancel, handler: {(action) in
                    QIndicatorViewManager.shared.showIndicatorView { (complete) in
                        LevelTestManager.manager.getQuizViewController(isContinue: true) { (nextVC, errMessage) in
                            QIndicatorViewManager.shared.hideIndicatorView()
                            
                            guard nextVC != nil else {
                                let alertController = UIAlertController(title: errMessage ?? ALTAppString.Error.Unknown.Message, message: nil, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: ALTAppString.General.Confirm, style: .cancel, handler: nil))
                                viewController.present(alertController, animated: true, completion: nil)
                                return
                            }
                            
                            var navController: ALTNavigationController!
                            if LevelTestManager.manager.isJunior {
                                navController = ALTJuniorTestNavigationController(rootViewController: nextVC!)
                            } else {
                                navController = ALLTSeniorTestNavigationController(rootViewController: nextVC!)
                            }
                            navController.modalPresentationStyle = .overFullScreen
                            viewController.present(navController, animated: true, completion: nil)
                        }
                    }
                }))
                alertController.addAction(UIAlertAction(title: "처음부터 시작", style: .default, handler: { (action) in
                    QIndicatorViewManager.shared.showIndicatorView { (complete) in
                        LevelTestManager.manager.RestartTest(testSrl: testingSrl) { (testSrl, errMessage) in
                            guard testSrl != nil, errMessage == nil else {
                                QIndicatorViewManager.shared.hideIndicatorView()
                                let alertController = UIAlertController(title: errMessage, message: nil, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: ALTAppString.General.Confirm, style: .cancel, handler: nil))
                                viewController.present(alertController, animated: true, completion: nil)
                                return
                            }
                            LevelTestManager.manager.getQuizViewController(isContinue: false) { (nextVC, errMessage) in
                                QIndicatorViewManager.shared.hideIndicatorView()
                                
                                guard nextVC != nil else {
                                    let alertController = UIAlertController(title: errMessage ?? ALTAppString.Error.Unknown.Message, message: nil, preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: ALTAppString.General.Confirm, style: .cancel, handler: nil))
                                    viewController.present(alertController, animated: true, completion: nil)
                                    return
                                }
                                
                                var navController: ALTNavigationController!
                                if LevelTestManager.manager.isJunior {
                                    navController = ALTJuniorTestNavigationController(rootViewController: nextVC!)
                                } else {
                                    navController = ALLTSeniorTestNavigationController(rootViewController: nextVC!)
                                }
                                navController.modalPresentationStyle = .overFullScreen
                                viewController.present(navController, animated: true, completion: nil)
                            }
                        }
                    }
                }))
                viewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func startIntitializedTest(from viewController: UIViewController) {
        LevelTestManager.manager.delegate = viewController
        
        if LevelTestManager.manager.needAgreement {
            let childViewController = ALTPrivacyPoliciesViewController()
            var navController: ALTNavigationController!
            if LevelTestManager.manager.isJunior {
                navController = ALTJuniorTestNavigationController(rootViewController: childViewController)
            } else {
                navController = ALLTSeniorTestNavigationController(rootViewController: childViewController)
            }
            navController.modalPresentationStyle = .fullScreen
            viewController.present(navController, animated: true, completion: nil)
//        } else if (LevelTestManager.manager.examInfo?.isCouponActivated ?? false) == true {
//            let viewController = ALTCouponListViewController()
//            let navController = ALTNavigationController(rootViewController: viewController)
//            navController.modalPresentationStyle = .fullScreen
//            viewController.present(navController, animated: true, completion: nil)
        } else {
            let childViewController = ALTTutorialViewController()
            var navController: ALTNavigationController!
            if LevelTestManager.manager.isJunior {
                navController = ALTJuniorTestNavigationController(rootViewController: childViewController)
            } else {
                navController = ALLTSeniorTestNavigationController(rootViewController: childViewController)
            }
            navController.modalPresentationStyle = .fullScreen
            viewController.present(navController, animated: true, completion: nil)
        }
    }
    
    private func getResultList(for page: Int, completion: @escaping ([String:Any]?) -> Void) {
        let httpClient = QHttpClient()
        
        var params = [String:Any]()
        params["group_code"] = UserDataManager.manager.groupCode
        params["email"] = UserDataManager.manager.userId
        params["page"] = page
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.Result.GetList) { (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any] else {
                completion(nil)
                return
            }
            
            var retData = [String:Any]()
            retData["page"] = page
            retData["total_count"] = responseData["total_count"] as? Int ?? 0
            
//            if var ad_image = responseData["ad_image"] as? String, ad_image.count > 0 {
//                if ad_image.hasPrefix("./") {
//                    ad_image = "\(ad_image.dropFirst(2))"
//                } else if ad_image.hasPrefix("/") {
//                    ad_image = "\(ad_image.dropFirst(1))"
//                }
//
//                PINRemoteImageManager().downloadImage(with: URL(string: RequestUrl.Image + ad_image)!, options: .downloadOptionsSkipEarlyCheck) {[weak self] (result) in
//                    self?.showTableHeaderView(with: result.image)
//                } completion: {[weak self] (result) in
//                    self?.showTableHeaderView(with: result.image)
//                }
//
//            } else {
//                self?._theTableView.tableHeaderView = nil
//                self?._imageViewAds = nil
//            }
            
            var array = [ALTLevelTestResultData]()
            if let list = responseData["list"] as? [[String:Any]] {
                array.append(contentsOf: list.map({ (item) -> ALTLevelTestResultData in
                    return ALTLevelTestResultData(with: item)
                }))
            }
            retData["has_next_page"] = array.count > 0
            retData["results"] = array
            
            completion(retData)
        }
    }
    
//    public func showResultList(from viewController: UIViewController) {
//        let vc = ALTMyPageViewController()
//        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .overFullScreen
//        viewController.present(navController, animated: true, completion: nil)
//    }
    
    public func showResult(from viewController: UIViewController) {
        let vc = ALTResultWebViewController(testSrl: nil)
        vc.modalPresentationStyle = .overFullScreen
        viewController.present(vc, animated: true, completion: nil)
    }
}
