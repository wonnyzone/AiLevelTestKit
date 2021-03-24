//
//  UserDataManager.swift
//  AOAudioInput
//
//  Created by Jun-kyu Jeon on 2020/10/16.
//

import Foundation

class UserDataManager: NSObject {
    public struct NotificationName {
        public static let LoggedIn = Notification.Name("UserDataManager.LoggedIn")
        public static let LoggedOut = Notification.Name("UserDataManager.LoggedOut")
    }
    
    static let manager = UserDataManager()
    
    var isLoggedIn: Bool {
//        return _groupCode != nil && _userId != nil
        return groupCode != nil && _groupTitle != nil
    }
    
    var targetLanguage: ALTAppStringManager.Language = .english
    
    private var _isTest: Bool = false
//    var isTest: Bool {
//        return _isTest
//    }
    
    private var _groupCode: String?
    var groupCode: String? {
        return _groupCode
    }
    
    private var _userId: String?
    var userId: String? {
        return _userId
    }
    
    private var _name: String?
//    var name: String? {
//        return _name
//    }
    
    private var _phone: String?
//    var phone: String? {
//        return _phone
//    }
    
    private var _groupTitle: String?
    var groupTitle: String? {
        return _groupTitle
    }
    
    private var _groupInfo: ALTClientData?
    var groupInfo: ALTClientData? {
        return _groupInfo
    }
    
    func getOrganisationList(_ completion: ((_ code: QHttpClient.Code, _ errMessage: String?, _ orgList: [ALTClientData]?) -> Void)?) {
        let httpClient = QHttpClient()
        httpClient.method = .Get
        httpClient.sendRequest(to: RequestUrl.User.ClientList) { (code, errMessage, response) in
            var orgs: [ALTClientData]?

            if code == .success, let responseData = response as? [[String:Any]]  {
                orgs = []
                orgs?.append(contentsOf: responseData.map({ (item) -> ALTClientData in
                    return ALTClientData(with: item)
                }))
            }
            completion?(code, errMessage, orgs)
        }
    }
    
    func validate(groupCode: String, examId: String? = nil, email: String? = nil, completion: ((_ code: QHttpClient.Code, _ errMessage: String?, _ groupInfo: ALTClientData?) -> Void)? = nil) {
        let httpClient = QHttpClient()
        httpClient.method = .Post
        
        var params = [String:Any]()
        params["group_code"] = groupCode
        params["examId"] = examId
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.User.Validate) {[weak self] (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any], let rawData = responseData["group_info"] as? [String:Any] else {
                completion?(QHttpClient.Code.fail, errMessage, nil)
                return
            }
            
            let data = ALTClientData(with: rawData)
            self?._groupInfo = data
                    
            let groupTitle = data.title
            
            self?._groupCode = groupCode
            self?._groupTitle = groupTitle
            self?._userId = email ?? responseData["email"] as? String
            
            QDataManager.shared.clientData = data
            QDataManager.shared.commit()
            
            completion?((groupTitle != nil ? .success : .fail), (groupTitle != nil ? nil : "업체정보를 찾을 수 없습니다."), data)
        }
    }
    
    func login(org: ALTClientData?, userId: String?, completion: ((_ code: QHttpClient.Code, _ errMessage: String?) -> Void)? = nil) {
        guard isLoggedIn == false else {
            completion?(QHttpClient.Code.fail, ALTAppString.Alert.Login.AlreadyLoggedIn.Message)
            return
        }
        
        guard (org?.title ?? "").count > 0 else {
            completion?(QHttpClient.Code.fail, ALTAppString.Alert.Login.NoOrganisation.Message)
            return
        }
        
        guard (userId ?? "").count > 0 else {
            completion?(QHttpClient.Code.fail, ALTAppString.Alert.Login.NoUserId.Message)
            return
        }
        
        let httpClient = QHttpClient()
        httpClient.method = .Post
        
        var params = [String:Any]()
        params["group_title"] = org?.title
        params["email"] = userId
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.User.Login) {[weak self] (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any] else {
                completion?(QHttpClient.Code.fail, errMessage)
                self?.logout()
                return
            }
            
            self?._groupCode = org?.code
            self?._groupTitle = org?.title
            
            self?._isTest = responseData["is_test"] as? Bool ?? false
            self?._userId = responseData["email"] as? String
            self?._name = responseData["name"] as? String
            self?._phone = responseData["phone"] as? String
            
            let isSucceed = responseData["success"] as? Bool ?? false
            let isLoggedIn = self?.isLoggedIn ?? false
            
            if isLoggedIn {
                QDataManager.shared.clientData = org
                QDataManager.shared.userId = userId
                QDataManager.shared.commit()
            } else {
                QDataManager.shared.clientData = nil
                QDataManager.shared.userId = nil
                QDataManager.shared.commit()
            }
            
            let code: QHttpClient.Code = (isSucceed && isLoggedIn) == true ? .success : .fail
            
            let messageFromServer = responseData["msg"] as? String ?? ALTAppString.Alert.UnknownError.Message
            
            NotificationCenter.default.post(name: UserDataManager.NotificationName.LoggedIn, object: nil)
            
            self?.loadGroupInfo { (_, _) in
                completion?(code, messageFromServer)
            }
        }
    }
    
    func logout(_ completion: ((Bool) -> Void)? = nil) {
//        _isTest = false
        _groupCode = nil
        _userId = nil
        _name = nil
        _phone = nil
        _groupTitle = nil
        
        _groupInfo = nil
        
        NotificationCenter.default.post(name: UserDataManager.NotificationName.LoggedOut, object: nil)
        
        QDataManager.shared.clientData = nil
        QDataManager.shared.userId = nil
        QDataManager.shared.commit()
        
        completion?(true)
    }
    
    func loadGroupInfo(with examId: String? = nil, completion: ((QHttpClient.Code, String) -> Void)? = nil) {
        let httpClient = QHttpClient()
        httpClient.method = .Post
        
        var params = [String:Any]()
        params["group_code"] = UserDataManager.manager.groupCode
        params["exam_id"] = examId
        httpClient.parameters = QHttpClient.Parameter(dict: params)
        
        httpClient.sendRequest(to: RequestUrl.User.GetDetails) { [weak self] (code, errMessage, response) in
            guard code == .success, let responseData = response as? [String:Any] else {
                completion?(QHttpClient.Code.fail, errMessage ?? ALTAppString.Alert.UnknownError.Message)
                self?.logout()
                return
            }
            
            let isSucceed = responseData["result"] as? Bool ?? false
            let message = responseData["message"] as? String ?? ALTAppString.Alert.UnknownError.Message
            
            if isSucceed {
                if let data = responseData["group_info"] as? [String:Any] {
                    self?._groupInfo = ALTClientData(with: data)
                }
            }
            
            completion?(code, message)
        }
    }
}
