//
//  ALTSpeechToTextManager.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/09.
//

import Foundation

import AVFoundation
import Accelerate

import Speech

@objc protocol ALTSpeechToTextManagerDelegate {
    func speechToTextManager(didStart manager: ALTSpeechToTextManager)
    func speechToTextManager(didStop manager: ALTSpeechToTextManager, withResult text: String?)
    func speechToTextManager(_ manager: ALTSpeechToTextManager, didRecognizeAudio power: CGFloat)
    @objc optional func speechToTextManager(_ manager: ALTSpeechToTextManager?, didRecognizeText text: String?)
}

class ALTSpeechToTextManager: NSObject {
    static let manager = ALTSpeechToTextManager()
    
    private var _averagePowerForChannel0 = Float(0)
    private var _averagePowerForChannel1 = Float(0)
    private let LEVEL_LOWPASS_TRIG = Float32(0.3)
    
    private var _speechRecognizer: SFSpeechRecognizer?
    
    private var _recogRequest: SFSpeechAudioBufferRecognitionRequest?
    private var _recogTask: SFSpeechRecognitionTask?
    
    var thresholdTime: Double = 3
    var duration: Double = 15
    internal var _timerThreshold: Timer?
    internal var _timerDuration: Timer?
    
    var delegate: ALTSpeechToTextManagerDelegate?
    
    private let _audioEngine = AVAudioEngine()
    
    private var _resultString: String?
    
    var isRecording: Bool {
        return _audioEngine.isRunning
    }
    
    internal var _audioFile: AVAudioFile?
    
    func start(languageCode code: String) {
        if _recogTask != nil {
            _recogTask?.cancel()
            _recogTask = nil
        }
        
        guard _audioEngine.isRunning == false, _speechRecognizer == nil else { return }
        
        _resultString = nil
        
        let audioSession = AVAudioSession.sharedInstance()
                
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        _speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: code))
        _speechRecognizer?.delegate = self
        
        _recogRequest = SFSpeechAudioBufferRecognitionRequest()
        _recogRequest?.shouldReportPartialResults = true
        if #available(iOS 13.0, *) {
            _recogRequest?.requiresOnDeviceRecognition = true
        }
        
        _recogTask = _speechRecognizer?.recognitionTask(with: _recogRequest!, resultHandler: {[weak self] (result, error) in
            #if DEBUG_ENABLED
            print("********* STT - RECOG \(result?.bestTranscription.formattedString)")
            #endif
            guard result != nil || self?._resultString != nil else { return }
            
            if let resultString = result?.bestTranscription.formattedString {
                self?._resultString = resultString
            }
            
            self?.delegate?.speechToTextManager?(self, didRecognizeText: self?._resultString)
            
            self?._timerThreshold?.invalidate()
            if (self?.isRecording ?? false) == true {
                self?._timerThreshold = Timer.scheduledTimer(withTimeInterval: self?.thresholdTime ?? 10, repeats: false, block: {[weak self] (timer) in
                    if ((self?.isRecording ?? false) == false) { return }
                    
                    #if DEBUG_ENABLED
                    print("********* STT - NO INPUT")
                    #endif
                    self?.stop()
                })
            }
            
            guard result?.isFinal == true else { return }
            #if DEBUG_ENABLED
            print("********* STT - IS FINAL")
            #endif
            self?.stop()
        })
        
        let inputNode = _audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {[weak self] (buffer, when) in
            self?.audioMetering(with: buffer)
            self?._recogRequest?.append(buffer)
            try? self?._audioFile?.write(from: buffer)
        }
        
//        _timerThreshold = Timer.scheduledTimer(withTimeInterval: thresholdTime, repeats: false, block: {[weak self] (timer) in
//            #if DEBUG_ENABLED
//            print("********* STT - THRESHHOLD")
//            #endif
//            self?.stop()
//        })
        
        _timerDuration?.invalidate()
        _timerDuration = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { [weak self] (timer) in
            #if DEBUG_ENABLED
            print("********* STT - DURATION")
            #endif
            self?.stop()
        })
        
        
        if let fileUrl = getFileUrl() {
            _audioFile = try? AVAudioFile(forWriting: fileUrl, settings: _audioEngine.inputNode.outputFormat(forBus: 0).settings)
        } else {
            _audioFile = nil
        }
        
        try? _audioEngine.start()
        
        delegate?.speechToTextManager(didStart: self)
    }
    
    func stop() {
        guard _audioEngine.isRunning else {
            DispatchQueue.main.async { [weak self] in
                self?._recogTask?.cancel()
                self?._recogTask = nil
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?._timerThreshold?.invalidate()
            self?._timerThreshold = nil
            
            self?._timerDuration?.invalidate()
            self?._timerDuration = nil
            
            self?._audioEngine.inputNode.removeTap(onBus: 0)
            self?._audioEngine.stop()
            
            self?._recogTask?.cancel()
            self?._recogTask = nil
            
            self?._recogRequest = nil
            
            self?._speechRecognizer = nil
            
            self?._audioFile = nil
            
            let audioSession = AVAudioSession.sharedInstance()
                    
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setMode(AVAudioSessionModeDefault)
                try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            
            if let self = self {
                self.delegate?.speechToTextManager(didStop: self, withResult: self._resultString)
            }
        }
    }
    
    
    internal func audioMetering(with buffer: AVAudioPCMBuffer) {
        buffer.frameLength = 1024
                   
        let inNumberFrames = UInt(buffer.frameLength)
                    
        if buffer.format.channelCount > 0 {
            let samples = (buffer.floatChannelData![0])
            
            var avgValue = Float32(0)
            vDSP_meamgv(samples,1 , &avgValue, inNumberFrames)
                        
            var v = Float(-100)
            
            if avgValue != 0 {
                v = 20.0 * log10f(avgValue)
            }
            
            _averagePowerForChannel0 = (LEVEL_LOWPASS_TRIG * v) + ((1 - LEVEL_LOWPASS_TRIG) * _averagePowerForChannel0)
            _averagePowerForChannel1 = _averagePowerForChannel0
        }
        
        if buffer.format.channelCount > 1 {
            let samples = buffer.floatChannelData![1]
            
            var avgValue = Float32(0)
            vDSP_meamgv(samples, 1, &avgValue, inNumberFrames)
            
            var v = Float(-100)
            if avgValue != 0 {
                v = 20.0 * log10f(avgValue)
            }
            
            _averagePowerForChannel1 = (LEVEL_LOWPASS_TRIG * v) + ((1 - LEVEL_LOWPASS_TRIG) * _averagePowerForChannel1)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            var value = (CGFloat(self._averagePowerForChannel1) + 60) * 15 + 300
            if abs(value) < 75 {
                value = 10
            }
            
            self.delegate?.speechToTextManager(self, didRecognizeAudio: value)
//            self?._waveView.value = (CGFloat(self?._averagePowerForChannel1 ?? 0) + 60) * 15
//            self?._labelPower.text = "Ave. Power: " + String(format: "%.3f", arguments: [self?._averagePowerForChannel1 ?? 0]) + " db"
//
//            self?.view.layoutIfNeeded()
        }
    }
    
    internal func getFileUrl() -> URL? {
        guard let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
              var url = URL(string: directory) else { return nil }
        
        url.appendPathComponent("record.wav")
        return url
    }
    
    internal func getMp3Url() -> URL? {
        guard let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
              var url = URL(string: directory) else { return nil }
        
        url.appendPathComponent("record.mp3")
        return url
    }
    
    func uploadFile(isMicTest: Bool, levelSrl: Int?, order: Int?, path: String?, userLanguage: String?, testLanguage: String?, answerText: String, completion: (([String:Any]?) -> Void)? = nil) {
        guard let fileUrl = getFileUrl(),
              let audioFile = try? AVAudioFile(forReading: fileUrl),
              let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: 1, interleaved: false),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024),
              let customerSrl = LevelTestManager.manager.customerSrl,
              let groupCode = UserDataManager.manager.groupCode,
              let testSrl = LevelTestManager.manager.testSrl else {
            completion?(nil)
            return
        }
        
        print(audioFile.fileFormat.sampleRate)
        
        var audioData = Data()
        
        do {
            try audioFile.read(into: buffer)
            let floatArray = UnsafeBufferPointer(start: buffer.floatChannelData![0], count:Int(buffer.frameLength))
            
            for buf in floatArray {
                audioData.append(withUnsafeBytes(of: buf) { Data($0) })
            }
        } catch {
            #if DEBUG_ENABLED
            #endif
            completion?(nil)
            return
        }
        
        
        
        let parameters = [
          [
            "key": "customer_srl",
            "value": "\(customerSrl)",
            "type": "text"
          ],
          [
            "key": "stt_type",
            "value": "none",
            "type": "text"
          ],
          [
            "key": "is_mictest",
            "value": isMicTest ? "true" : "false",
            "type": "text"
          ],
          [
            "key": "group_code",
            "value": "\(groupCode)",
            "type": "text"
          ],
          [
            "key": "test_srl",
            "value": "\(testSrl)",
            "type": "text"
          ],
          [
            "key": "level_srl",
            "value": "\(levelSrl ?? -1)",
            "type": "text"
          ],
          [
            "key": "order",
            "value": "\(order ?? -1)",
            "type": "text"
          ],
          [
            "key": "section_path",
            "value": path ?? "",
            "type": "text"
          ],
          [
            "key": "main_lang",
            "value": userLanguage ?? "",
            "type": "text"
          ],
          [
            "key": "problem_lang",
            "value": testLanguage ?? "",
            "type": "text"
          ],
          [
            "key": "record_file",
            "src": fileUrl.absoluteString,
            "type": "file"
          ],
          [
            "key": "act",
            "value": "apiSpeechToText",
            "type": "text"
          ],
          [
            "key": "module",
            "value": "y1test",
            "type": "text"
          ],
          [
            "key": "answer_text",
            "value": answerText,
            "type": "text"
          ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
//        var error: Error? = nil
        for param in parameters {
          if param["disabled"] == nil {
            let paramName = param["key"]!
            body += "--\(boundary)\r\n".data(using: .utf8)!
            body += "Content-Disposition:form-data; name=\"\(paramName)\"".data(using: .utf8)!
            if param["contentType"] != nil {
              body += "\r\nContent-Type: \(param["contentType"] as! String)".data(using: .utf8)!
            }
            let paramType = param["type"] as! String
            if paramType == "text" {
              let paramValue = param["value"] as! String
              body += "\r\n\r\n\(paramValue)\r\n".data(using: .utf8)!
            } else  {
//              let fileContent = String(data: data, encoding: .utf8)!
                body += "; filename=\"ios_\(customerSrl)_\(testSrl)_\(Date().timeIntervalSince1970).wav\"\r\n".data(using: .utf8)!
                body += "Content-Type: \"content-type header\"\r\n\r\n".data(using: .utf8)!
                body += audioData
                body += "\r\n".data(using: .utf8)!
            }
          }
        }
        body += "--\(boundary)--\r\n".data(using: .utf8)!
        

        var request = URLRequest(url: URL(string: "https://aileveltest.co.kr/index.php")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let rawData = data, let responseData = try? JSONSerialization.jsonObject(with: rawData, options: []) as? [String:Any] else {
                completion?(nil)
                return
            }
            completion?(responseData?["response"] as? [String:Any])
        }

        task.resume()
        
//        guard let fileUrlString = getFileUrl()?.absoluteString,
//              let mp3FileUrl = getMp3Url(),
//              let mp3UrlString = getMp3Url()?.absoluteString,
//              let customerSrl = LevelTestManager.manager.customerSrl,
//              let groupCode = UserDataManager.manager.groupCode,
//              let testSrl = LevelTestManager.manager.testSrl else { return }
//        ALTAudioConverterManager.encodeToMp3(inPcmPath: fileUrlString, outMp3Path: mp3UrlString) { (progress) -> (Void) in
//
//        } onComplete: { () -> (Void) in
//            guard let audioData = try? Data(contentsOf: mp3FileUrl) else {
//                completion?(nil)
//                return
//            }
//
//            let parameters = [
//              [
//                "key": "customer_srl",
//                "value": "\(customerSrl)",
//                "type": "text"
//              ],
//              [
//                "key": "stt_type",
//                "value": "none",
//                "type": "text"
//              ],
//              [
//                "key": "is_mictest",
//                "value": isMicTest ? "true" : "false",
//                "type": "text"
//              ],
//              [
//                "key": "group_code",
//                "value": "\(groupCode)",
//                "type": "text"
//              ],
//              [
//                "key": "test_srl",
//                "value": "\(testSrl)",
//                "type": "text"
//              ],
//              [
//                "key": "level_srl",
//                "value": "\(levelSrl ?? -1)",
//                "type": "text"
//              ],
//              [
//                "key": "order",
//                "value": "\(order ?? -1)",
//                "type": "text"
//              ],
//              [
//                "key": "section_path",
//                "value": path ?? "",
//                "type": "text"
//              ],
//              [
//                "key": "main_lang",
//                "value": userLanguage ?? "",
//                "type": "text"
//              ],
//              [
//                "key": "problem_lang",
//                "value": testLanguage ?? "",
//                "type": "text"
//              ],
//              [
//                "key": "record_file",
//                "src": fileUrlString,
//                "type": "file"
//              ],
//              [
//                "key": "act",
//                "value": "apiSpeechToText",
//                "type": "text"
//              ],
//              [
//                "key": "module",
//                "value": "y1test",
//                "type": "text"
//              ],
//              [
//                "key": "answer_text",
//                "value": answerText,
//                "type": "text"
//              ]] as [[String : Any]]
//
//            let boundary = "Boundary-\(UUID().uuidString)"
//            var body = Data()
//    //        var error: Error? = nil
//            for param in parameters {
//              if param["disabled"] == nil {
//                let paramName = param["key"]!
//                body += "--\(boundary)\r\n".data(using: .utf8)!
//                body += "Content-Disposition:form-data; name=\"\(paramName)\"".data(using: .utf8)!
//                if param["contentType"] != nil {
//                  body += "\r\nContent-Type: \(param["contentType"] as! String)".data(using: .utf8)!
//                }
//                let paramType = param["type"] as! String
//                if paramType == "text" {
//                  let paramValue = param["value"] as! String
//                  body += "\r\n\r\n\(paramValue)\r\n".data(using: .utf8)!
//                } else  {
//    //              let fileContent = String(data: data, encoding: .utf8)!
//                    body += "; filename=\"ios_\(customerSrl)_\(testSrl)_\(Date().timeIntervalSince1970).wav\"\r\n".data(using: .utf8)!
//                    body += "Content-Type: \"content-type header\"\r\n\r\n".data(using: .utf8)!
//                    body += audioData
//                    body += "\r\n".data(using: .utf8)!
//                }
//              }
//            }
//            body += "--\(boundary)--\r\n".data(using: .utf8)!
//
//
//            var request = URLRequest(url: URL(string: "https://aileveltest.co.kr/index.php")!,timeoutInterval: Double.infinity)
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//            request.httpMethod = "POST"
//            request.httpBody = body
//
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let rawData = data, let responseData = try? JSONSerialization.jsonObject(with: rawData, options: []) as? [String:Any] else {
//                    completion?(nil)
//                    return
//                }
//                completion?(responseData?["response"] as? [String:Any])
//            }
//
//            task.resume()
//        }
    }
}

extension ALTSpeechToTextManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("available : \(available)")
    }
}
