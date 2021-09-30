//
//  Urls.swift
//  BaseProject
//
//  Created by Jun-kyu Jeon on 26/11/2018.
//  Copyright © 2018 WishpokeZxcvb356. All rights reserved.
//

import Foundation

internal struct RequestUrl {
//    static let Base = "https://aileveltest.co.kr/index.php"
    static let Base = "https://aileveltest.com/"
    
    static let AWS = "https://leveltest-data.s3.ap-northeast-2.amazonaws.com"
    
    struct Terms {
        static let Agree = RequestUrl.Base + "index.php?module=y1member&act=apiAgreementCheck"
    }
    
    struct User {
        static let ClientList = RequestUrl.Base + "plugin/api/group.php"
        static let Validate = RequestUrl.Base + "index.php?module=y1member&act=apiClientCheck"
        static let Login = RequestUrl.Base + "plugin/api/login.php"
        static let GetDetails = RequestUrl.Base + "index.php?module=y1member&act=apiClientCheck"
    }
    
    struct Test {
        static let GetList = RequestUrl.Base + "plugin/api/exam/leveltest.php"
        static let Initialize = RequestUrl.Base + "?module=y1test&act=apiLevelTestStart"
        
        static let GetJuniorInfo = RequestUrl.Base + "plugin/api/exam/conn.php"
        
        static let Start = RequestUrl.Base + "index.php?module=y1test&act=apiTestStart"
        static let Restart = RequestUrl.Base + "index.php?module=y1test&act=apiTestRestart"
        
        struct Quiz {
            static let GetNext = RequestUrl.Base + "index.php?module=y1test&act=apiTestQuestion"
            static let Answer = RequestUrl.Base + "index.php?module=y1test&act=apiTestAnswer"
            static let Finalize = RequestUrl.Base + "index.php?module=y1test&act=apiLevelTestFinish"
//            static let Result = RequestUrl.Base + "plugin/api/init.php?email=Evan&code=allinone07834&api_type=ios"
        }
        
        static let UploadSTT = RequestUrl.Base + "index.php?module=y1test&act=apiSpeechToText"
    }
    
    struct Result {
        static let GetList = RequestUrl.Base + "plugin/api/customer/test_list.php"
        static let GetDetails = RequestUrl.Base + "plugin/api/init.php"
    }
    
    struct Coupon {
        static let GetList = RequestUrl.Base + "index.php?module=y1coupon&act=apiCouponList"
        static let Register = RequestUrl.Base + "index.php?module=y1coupon&act=apiCouponReg"
        static let Use = RequestUrl.Base + "index.php?module=y1coupon&act=apiCouponUse"
    }
    
    static let Image = RequestUrl.Base
}

