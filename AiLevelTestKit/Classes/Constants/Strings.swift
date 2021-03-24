//
//  Strings.swift
//  BaseProject
//
//  Created by Jun-kyu Jeon on 23/10/2018.
//  Copyright © 2018 Wishpoke. All rights reserved.
//

import Foundation

internal class ALTAppStringManager: NSObject {
    public struct NotificationName {
        public static let LanguageChanged = Notification.Name("ALTAppString.Manager.LanguageChanged")
    }
    
    enum Language: String {
        case english = "en"
        case korean = "ko"
        case japanese = "ja"
        case chinese = "zh-Hans"
        case spanish = "es"
    }
    
    static let manager = ALTAppStringManager()
    
    var code: Language = .korean {
        didSet {
            NotificationCenter.default.post(name: ALTAppStringManager.NotificationName.LanguageChanged, object: nil)
        }
    }
    
    var localizedBundle: Bundle {
        get {
            guard let path = Bundle.main.path(forResource: code.rawValue, ofType: "lproj") else { return Bundle.main }
            return Bundle(path: path) ?? Bundle.main
        }
    }
}

internal struct ALTAppString {
    public static let Localizable = false
    
    public struct Alert {
        public struct UnknownError {
            public static let Title =  ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.UnknownError.Title", value: Localizable == false ? "알 수 없는 오류" : "Unknown error", table: nil)
            public static let Message = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.UnknownError.Message", value: Localizable == false ? "알 수 없는 오류가 발생하였습니다.\n잠시 후 다시 시도해 주세요." : "Unknown error occurred.\nPlease try again.", table: nil)
        }
        
        public struct Login {
            public struct Succeed {
                public static let Title =  ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.Succeed.Title", value: Localizable == false ? "로그인" : "Logged in", table: nil)
                public static let Message = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.Succeed.Message", value: Localizable == false ? "정상적으로 로그인되었습니다." : "You've successfully logged in", table: nil)
            }
            
            public struct AlreadyLoggedIn {
                public static let Title =  ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.AlreadyLoggedIn.Title", value: Localizable == false ? "로그인." : "Logged in", table: nil)
                public static let Message = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.AlreadyLoggedIn.Message", value: Localizable == false ? "정상적으로 로그인되었습니다." : "You've successfully logged in", table: nil)
            }
            
            public struct WrongInfo {       // group_title / email 이 반환이 안된 경우
                public static let Title =  ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.WrongInfo.Title", value: Localizable == false ? "로그인 실패" : "Login failed", table: nil)
                public static let Message = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.WrongInfo.Message", value: Localizable == false ? "로그인에 실패하였습니다.\n잠시 후 다시 시도해 주세요." : "There is a problem with user information.\nPlease try again.", table: nil)
            }
            
            public struct NoOrganisation {
                public static let Title =  ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.NoOrganisation.Title", value: Localizable == false ? "로그인 실패" : "No organization", table: nil)
                public static let Message = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.NoOrganisation.Message", value: Localizable == false ? "업체명을 선택해주세요." : "Please enter your organization", table: nil)
            }
            
            public struct NoUserId {
                public static let Title =  ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.NoUserId.Title", value: Localizable == false ? "로그인 실패" : "No user ID", table: nil)
                public static let Message = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.NoUserId.Message", value: Localizable == false ? "아이디를 입력하세요." : "Please enter your user ID.", table: nil)
            }
            
            public struct UnregisteredOrganisation {
                public static let Title =  ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.UnregisteredOrganisation.Title", value: Localizable == false ? "업체명 오류" : "No organization found", table: nil)
                public static let Message = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.UnregisteredOrganisation.Message", value: Localizable == false ? "등록되어 있지 않은 업체명입니다.\n다시 시도해주세요." : "You've entered unregistered organization.\nPlease try again.", table: nil)
            }
            
            public struct NoUserFound {
                public static let Title =  ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.NoUserFound.Title", value: Localizable == false ? "계정 오류" : "No user found", table: nil)
                public static let Message = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.NoUserFound.Message", value: Localizable == false ? "계정 정보를 찾을 수 없습니다." : "Cannot find the user information.\nPlease try again.", table: nil)
            }
            
            public static let LoginNeeded = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.LoginNeeded", value: Localizable == false ? "계속 진행하시려면 로그인해주세요." : "Please sign in first, to continue.", table: nil)
            
            public static let ServiceNotAvailable = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Alert.Login.ServiceNotAvailable", value: Localizable == false ? "준비 중인 서비스입니다." : "Sorry, This service is unavailable now.", table: nil)
        }
    }
    
    public struct Home {
        public static let Title = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Title", value: Localizable == false ? "홈" : "Home", table: nil)
        
        public struct Navigation {
            public static let SignIn = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Navigation.SignIn", value: Localizable == false ? "로그인" : "Sign In", table: nil)
            public static let SignOut = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Navigation.SignOut", value: Localizable == false ? "로그아웃" : "Sign Out", table: nil)
            public static let MyPage = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Navigation.SignOut", value: Localizable == false ? "테스트 내역" : "My Page", table: nil)
        }
        
        public static let Notice = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Notice", value: "Using wireless\nheadphones might cause a problem,\nso please use normal head(ear)phones.", table: nil)
        
        public struct Table {
            public struct Action {
                public static let SelectTest = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Table.Action.SelectTest", value: Localizable == false ? "시작하기" : "Select Test", table: nil)
                public static let StartTest = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Table.Action.StartTest", value: Localizable == false ? "시작하기" : "Start Test", table: nil)
            }
            
            public static let Placement = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Table.Placement", value: "Level Test\n(Placement Test)", table: nil)
            public static let Achievement = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Table.Achievement", value: "Achievement Test", table: nil)
            public static let Junior = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Table.Junior", value: "Junior English", table: nil)
            public static let English = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Table.English", value: "English", table: nil)
            public static let Japanese = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Table.Japanese", value: "Japanese", table: nil)
            public static let Chinese = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Home.Table.Chinese", value: "Chinese", table: nil)
        }
    }
    
    public struct Login {
        public static let Title = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Login.Title", value: Localizable == false ? "어서오세요" : "Hi, there.", table: nil)
        
        public struct Placeholder {
            public static let Organisation = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Login.Placeholder.Title", value: Localizable == false ? "업체명을 검색해 주세요." : "Search organization name", table: nil)
            public static let UserId = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Login.Placeholder.UserId", value: "아이디", table: nil)
        }
        
        public struct Button {
            public static let Login = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Login.Button.Login", value: "로그인", table: nil)
            public static let GotoHome = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Login.Button.GotoHome", value: "홈으로", table: nil)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public struct General {
        public static let Yes = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Yes", value: ALTAppString.Localizable ? "Yes" : "예", table: nil)
        public static let No = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.No", value: ALTAppString.Localizable ? "No" : "아니오", table: nil)
        public static let Ok = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Ok", value: ALTAppString.Localizable ? "Ok" : "예", table: nil)
        public static let Save = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Save", value: ALTAppString.Localizable ? "Save" : "저장", table: nil)
        public static let Confirm = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Confirm", value: ALTAppString.Localizable ? "Confirm" : "확인", table: nil)
        public static let Cancel = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Cancel", value: ALTAppString.Localizable ? "Cancel" : "취소", table: nil)
        public static let Close = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Close", value: ALTAppString.Localizable ? "Close" : "닫기", table: nil)
        public static let Clear = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Clear", value: ALTAppString.Localizable ? "Clear" : "지우기", table: nil)
        public static let Apply = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Apply", value: ALTAppString.Localizable ? "Apply" : "적용", table: nil)
        public static let Select = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Select", value: ALTAppString.Localizable ? "Select" : "선택", table: nil)
        public static let Edit = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Edit", value: ALTAppString.Localizable ? "Edit" : "편집", table: nil)
        public static let Delete = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Delete", value: ALTAppString.Localizable ? "Delete" : "삭제", table: nil)
        public static let Back = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Back", value: ALTAppString.Localizable ? "Back" : "뒤로", table: nil)
        public static let Next = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Next", value: ALTAppString.Localizable ? "Next" : "다음", table: nil)
        public static let Done = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Done", value: ALTAppString.Localizable ? "Done" : "완료", table: nil)
        public static let Send = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Send", value: ALTAppString.Localizable ? "Send" : "전송", table: nil)
        public static let Skip = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Skip", value: ALTAppString.Localizable ? "Skip" : "넘어가기", table: nil)
        public static let SeeMore = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.SeeMore", value: ALTAppString.Localizable ? "See More" : "더보기", table: nil)
        public static let Nevermind = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Nevermind", value: ALTAppString.Localizable ? "Nevermind" : "취소", table: nil)
        public static let Show = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Show", value: ALTAppString.Localizable ? "Show" : "보기", table: nil)
        public static let Hide = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Hide", value: ALTAppString.Localizable ? "Hide" : "숨기기", table: nil)
        public static let Retry = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Retry", value: ALTAppString.Localizable ? "Retry" : "다시 시도", table: nil)
        public static let Required = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Required", value: ALTAppString.Localizable ? "Required" : "필수", table: nil)
        public static let Report = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Report", value: ALTAppString.Localizable ? "Report" : "신고", table: nil)

        public static let Filter = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Filter", value: ALTAppString.Localizable ? "Filter" : "필터", table: nil)

        public static let Optional = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Optional", value: ALTAppString.Localizable ? "Optional" : "선택사항", table: nil)

        public static let Today = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Today", value: ALTAppString.Localizable ? "Today" : "오늘", table: nil)
        public static let Yesterday = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Yesterday", value: ALTAppString.Localizable ? "Yesterday" : "어제", table: nil)

        public static let Exit = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Exit", value: ALTAppString.Localizable ? "Exit" : "앱 종료", table: nil)
        public static let GotoSettings = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.GotoSettings", value: ALTAppString.Localizable ? "Settings" : "설정", table: nil)

        public struct Month {
            public static let January = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.January", value: ALTAppString.Localizable ? "January" : "1월", table: nil)
            public static let February = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.February", value: ALTAppString.Localizable ? "February" : "2월", table: nil)
            public static let March = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.March", value: ALTAppString.Localizable ? "March" : "3월", table: nil)
            public static let April = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.April", value: ALTAppString.Localizable ? "April" : "4월", table: nil)
            public static let May = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.May", value: ALTAppString.Localizable ? "May" : "5월", table: nil)
            public static let June = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.June", value: ALTAppString.Localizable ? "June" : "6월", table: nil)
            public static let July = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.July", value: ALTAppString.Localizable ? "July" : "7월", table: nil)
            public static let August = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.August", value: ALTAppString.Localizable ? "August" : "8월", table: nil)
            public static let September = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.September", value: ALTAppString.Localizable ? "September" : "9월", table: nil)
            public static let October = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.October", value: ALTAppString.Localizable ? "October" : "10월", table: nil)
            public static let November = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.November", value: ALTAppString.Localizable ? "November" : "11월", table: nil)
            public static let December = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Month.December", value: ALTAppString.Localizable ? "December" : "12월", table: nil)
        }

        public struct Unit {
            public static let Day = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Unit.Day", value: ALTAppString.Localizable ? "day" : "일", table: nil)
            public static let Days = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Unit.Days", value: ALTAppString.Localizable ? "days" : "일", table: nil)

            public static let Month = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Unit.Month", value: ALTAppString.Localizable ? "month" : "개월", table: nil)
            public static let Months = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Unit.Months", value: ALTAppString.Localizable ? "months" : "개월", table: nil)
        }

        public struct Gender {
            public static let Male = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Gender.Male", value: ALTAppString.Localizable ? "Male" : "남성", table: nil)
            public static let Female = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Gender.Female", value: ALTAppString.Localizable ? "Female" : "여성", table: nil)
        }

        public struct Ordinal {
            public static let First = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Ordinal.First", value: ALTAppString.Localizable ? "st" : "", table: nil)
            public static let Second = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Ordinal.Second", value: ALTAppString.Localizable ? "nd" : "", table: nil)
            public static let Third = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Ordinal.Third", value: ALTAppString.Localizable ? "rd" : "", table: nil)
            public static let Others = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "General.Ordinal.Others", value: ALTAppString.Localizable ? "th" : "", table: nil)
        }
    }

    public struct Error {
        public struct Unknown {
            public static let Title = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Error.Unknown.Title", value: ALTAppString.Localizable ? "Error" : "오류", table: nil)
            public static let Message = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Error.Unknown.Message", value: ALTAppString.Localizable ? "Something going wrong :( Please try again." : "알 수 없는 오류가 발생하였습니다.\n잠시 후 다시 시도해 주세요.", table: nil)
        }
    }
    
    public struct ImagePicker {
        public static let Camera = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "ImagePicker.Camera", value: ALTAppString.Localizable ? "Take a picture with camera" : "카메라로 촬영하기", table: nil)
        public static let Library = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "ImagePicker.Library", value: ALTAppString.Localizable ? "Choose a picture from the library" : "사진에서 가져오기", table: nil)
        public static let Delete = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "ImagePicker.Delete", value: ALTAppString.Localizable ? "Delete" : "삭제", table: nil)
    }
    
    public struct NoConnection {
        public static let Title = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "NoConnection.Title", value: ALTAppString.Localizable ? "No internet connection" : "네트워크가 불안정 합니다.", table: nil)
        public static let Subtitle = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "NoConnection.Subtitle", value: ALTAppString.Localizable ? "Please check your internet connection.\nThen try again." : "Wi-Fi 연결 및 데이터 상태 확인 후\n다시 시도해주세요..", table: nil)
    }
    
    public struct Maintenance {
        public static let Title = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Maintenance.Title", value: ALTAppString.Localizable ? "Sorry, the service currently unavailable\ndue to maintanence now." : "죄송합니다.\n서버 점검 중입니다.", table: nil)
        public static let Subtitle = ALTAppStringManager.manager.localizedBundle.localizedString(forKey: "Maintenance.Subtitle", value: ALTAppString.Localizable ? "Please try again later." : "잠시 후 다시 시도해주십시오.", table: nil)
    }
    
}










