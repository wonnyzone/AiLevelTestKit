# AiLevelTestKitExample 

[![CI Status](https://img.shields.io/travis/jk-gna/AiLevelTestSFKit.svg?style=flat)](https://travis-ci.org/jk-gna/AiLevelTestSFKit)
[![Version](https://img.shields.io/cocoapods/v/AiLevelTestSFKit.svg?style=flat)](https://cocoapods.org/pods/AiLevelTestSFKit)
[![Platform](https://img.shields.io/cocoapods/p/AiLevelTestSFKit.svg?style=flat)](https://cocoapods.org/pods/AiLevelTestSFKit)

README
This README would normally document whatever steps are necessary to get your application up and running.

## What is this repository for?
An example app for AiLevelTestKit iOS framework. 
Built based on Swift 5 with Xcode 12.3.

## System Requirements
iOS 12.1 or above

## Requirements:
<details>
1. Requires iOS 12.1 or later. The sample project is optimized for iOS 13.
2. Requires Automatic Reference Counting (ARC).
3. Optimized for ARM64 Architecture.
</details>

## Framework Version 0.9.55

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Please make sure that your Cocoapods is up to version of 1.7.0


## Getting Started

AiLevelTestKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AiLevelTestKit'
```


### Swift Version issue

만약 Pod 설치 후 앱 빌드시 Swift version 이슈로  오류가 발생되어 빌드가 되지 않는다면
AiLevelTestKit 프레임웍의 Swift version을 5로 변경하여 주십시오.

    1. Pods 프로젝트 Build Settings - Swift Language Version 을 Swift 5 로 선택
     

## Basic Implementation

info.plist에서 다음의 항목을 반드시 추가해주세요.
```
    <key>NSMicrophoneUsageDescription</key>
    <string>Access to Mic for STT</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>Access to Speech Recogniser</string>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>    
```

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
// id = 시험 아이디 (String)
```


테스트 결과 보기 
```swift
AiLevelTestKit.shared.showResult(examId: "exam1", from: self)
// examId = 시험 아이디 (String)
```



Copyrights 2020 - present 올인원에듀테크, Co, Ltd. All rights reserved.
