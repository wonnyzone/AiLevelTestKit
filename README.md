# AiLevelTestKitExample 

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

## Framework Version 0.9.10

## Getting Started

Downloads에서 <b>framework.zip</b> 다운 받으시면 framework 폴더 안에 각각 device 용 simulator 용 AiLevelTestKit 이 있는지 확인하십시오.
빌드하시는 타깃에 따라 각각의 프레임웍을 사용하셔야 합니다.
기본으로 내장되어 있는 프레임웍은 시뮬레이터 용입니다.

만약, 프레임웍을 교체하신 후 빌드시 "Library not loaded" 오류가 발생하실 때는 다음의 작업을 진행하세요:
1. 프로젝트 파일 선택
2. Build phases 탭 선택
3. Copy Files 섹션 (없을 경우 +를 눌러 추가) 에서 
    Destination : Framework 으로 설정
    Subpath : 공란으로 남겨둠
    Copy only when installing : 미선택
    "AiLevelTestKit.framework" 파일을 추가한 후 Code sign on copy 를 체크
4. 프로젝트 clean 후 빌드

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

프레임웍 초기화, 마이크 접근 권한 확인 
```swift
AiLevelTestKit.shared.initialize()
```
    
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

테스트 목록 가져오기
```swift
AiLevelTestKit.shared.getExamList {[weak self] (code, errMessage, examList) in
            guard code == .Succeed, examList != nil else {
                // 리스트 가져오기 실패
                return
            }
            // 성공
        }
```

테스트 시작하기
```swift
AiLevelTestKit.shared.startTest(from: self, with: data)
// data = 테스트 목록 가져오기에서 examList 의 item 중 선택
```

Copyrights 2020 - present 올인원에듀테크, Co, Ltd. All rights reserved.
