# AiLevelTestKitExample 

[![CI Status](https://img.shields.io/travis/jk-gna/AiLevelTestSFKit.svg?style=flat)](https://travis-ci.org/jk-gna/AiLevelTestSFKit)
[![Version](https://img.shields.io/cocoapods/v/AiLevelTestSFKit.svg?style=flat)](https://cocoapods.org/pods/AiLevelTestSFKit)
[![Platform](https://img.shields.io/cocoapods/p/AiLevelTestSFKit.svg?style=flat)](https://cocoapods.org/pods/AiLevelTestSFKit)

README
This README would normally document whatever steps are necessary to get your application up and running.

## What is this repository for?
An example app for AiLevelTestKit iOS framework. 
Built based on Swift 4 with Xcode 12.3.

## System Requirements
iOS 12.1 or above

## Requirements:
<details>
1. Requires iOS 12.1 or later. The sample project is optimized for iOS 13.
2. Requires Automatic Reference Counting (ARC).
3. Optimized for ARM64 Architecture.
</details>

## Framework Version 0.9.15

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Getting Started

AiLevelTestKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AiLevelTestKit'
```

### 프레임웍 사용시 필수 사항
info.plist에서 다음의 항목을 반드시 추가해주세요.
```
    <key>NSMicrophoneUsageDescription</key>
    <string>음성 인식을 위해 마이크를 사용합니다.</string>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>    
```

## Basic Implementation

다음의 순서대로 사용하여 주세요.

그룹코드 및 이메일로 프레임웍 활성화 및 인증
```swift
AiLevelTestKit.shared.activate(groupCode: "allinone07834", email: "evan", themeColour: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)) { [weak self] (code, errMessage) in
            guard code == .Succeed else {
                // 홯성화 실패시 실패 사유를 alert으로 보여준다
                
                let alertController = UIAlertController(title: errMessage, message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
                
                return
            }

            // 활성화 및 인증 성공
        }
```


테스트 시작하기
```swift
AiLevelTestKit.shared.startTestWith(id: "exam1", from: self)
// data = 시험 아이디 (String)
```

테스트 결과 리스트 보기
```swift
AiLevelTestKit.shared.getResultList(for: 0) { (retData) in
    // 현재 페이지
    let currentPage = retData?["page"] as? Int
    // 전체 결과 개수
    let totalCount = retData?["total_count"] as? Int
    // 다음 페이지에 데이터가 있는지 여부
    let hasNextPage = retData?["has_next_page"] as? Bool
    // 현재 페이지의 데이터
    let results = retData?["results"] as? [ALTLevelTestResultData]
}
// data = 현재 페이지 (0부터 시작)
// 
// response: retData.results => ALTLevelTestResultData->testSrl :  시험 고유번호 (Int)
```

테스트 결과 상세 보기 
```swift
AiLevelTestKit.shared.showResult(testSrl: 1234, from: self)
// testSrl = 시험 고유 번호 (Int) (상기 테스트 결과 리스트 조회의 결과 값 참조)
```


Copyrights 2020 - present 올인원에듀테크, Co, Ltd. All rights reserved.
