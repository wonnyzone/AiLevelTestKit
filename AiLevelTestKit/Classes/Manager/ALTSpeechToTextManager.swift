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

import ExtAudioConverter_Wrapper

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
    
    private var _isListening = false
    
    internal var _audioFile: AVAudioFile?
    private var _filterError = false
    
    func initialize(languageCode code: String, forcing: Bool = false) {
        guard _speechRecognizer == nil || forcing else { return }
        
        var codeString = "en-US"
        if code == "ja" {
            codeString = "ja-JP"
        } else if code == "zh" {
            codeString = "zh-CN"
        } else if code == "es" {
            codeString = "es-ES"
        }
        
        _speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: codeString))
        
        _speechRecognizer?.delegate = self
        
        _recogRequest = SFSpeechAudioBufferRecognitionRequest()
        _recogRequest?.shouldReportPartialResults = true
    }
    
    func deinitialize() {
        _speechRecognizer = nil
        _recogRequest =  nil
    }
    
    func start(languageCode code: String) {
        DispatchQueue.main.async { [weak self] in
            self?.internalStart(languageCode: code)
        }
    }
    
    private func internalStart(languageCode code: String) {
        if _recogTask != nil {
            _recogTask?.cancel()
            _recogTask = nil
        }
        
        _recogRequest?.endAudio()
        _recogRequest = nil
        
        if _audioEngine.isRunning {
//            DispatchQueue.main.async { [weak self] in
                _timerThreshold?.invalidate()
                _timerThreshold = nil

                _timerDuration?.invalidate()
                _timerDuration = nil

                _audioEngine.inputNode.removeTap(onBus: 0)
                _audioEngine.stop()

                _recogTask?.cancel()
                _recogTask = nil

                
//                _speechRecognizer = nil

                _audioFile = nil
//            }
        }
        
        _resultString = nil
        
        let audioSession = AVAudioSession.sharedInstance()
                
        do {
            try audioSession.setCategory(.record)
            try audioSession.setMode(.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        var codeString = "en-US"
        if code == "ja" {
            codeString = "ja-JP"
        } else if code == "zh" {
            codeString = "zh-CN"
        } else if code == "es" {
            codeString = "es-ES"
        }
        
        if _speechRecognizer == nil {
            print("SF: Initialize")
            print("SF: \(_speechRecognizer?.locale.identifier ?? "") - \(codeString)")
            _speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: codeString))
            
            _speechRecognizer?.delegate = self
        }
        
        _recogRequest = SFSpeechAudioBufferRecognitionRequest()
        _recogRequest?.shouldReportPartialResults = true
        if #available(iOS 13.0, *) {
//            _recogRequest?.requiresOnDeviceRecognition = true
        }
        
        _recogTask = _speechRecognizer?.recognitionTask(with: _recogRequest!, resultHandler: {[weak self] (result, error) in
            guard result != nil else { return }
            
            #if DEBUG_ENABLED
            print("********* STT - RECOG \(result?.bestTranscription.formattedString)")
            #endif
            guard error == nil else {
                print("!!!!!ERROR!!!!!")
                print(error?.localizedDescription ?? "")
                return
            }
            guard result != nil || self?._resultString != nil else {
                return
            }
            
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
//            self?.stop()
        })
        
        let inputNode = _audioEngine.inputNode
        let recordingFormat = inputNode.inputFormat(forBus: 0)
        
        let settings = _audioEngine.inputNode.outputFormat(forBus: 0).settings
        
        
        if let fileUrl = getFileUrl() {
            _audioFile = try? AVAudioFile(forWriting: fileUrl, settings: settings)
        } else {
            _audioFile = nil
        }
        
        _audioEngine.prepare()
        
        _filterError = true
        
        
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {[weak self] (buffer, when) in
            self?.audioMetering(with: buffer)
            self?._recogRequest?.append(buffer)
            try? self?._audioFile?.write(from: buffer)
        }
        
        
        _timerDuration?.invalidate()
        _timerDuration = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { [weak self] (timer) in
            #if DEBUG_ENABLED
            print("********* STT - DURATION")
            #endif
            self?.stop(immdiately: true)
        })
        
        self.delegate?.speechToTextManager(didStart: self)
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: {[weak self] (timer) in
            let reset = {[weak self] in
                self?._audioEngine.inputNode.removeTap(onBus: 0)
                self?._timerDuration?.invalidate()
                self?._audioFile = nil
                
                self?.start(languageCode: code)
            }
            
            let isRecognizable = self?._speechRecognizer?.isAvailable ?? false
            if isRecognizable == false {
                reset()
                return
            }
            
            guard (self?._speechRecognizer?.isAvailable ?? false) == true else {
                self?.start(languageCode: code)
                return
            }
            
            do {
                try self?._audioEngine.start()
            } catch {
                print("************************** audio engine failed *********************")
                
                reset()
                return
            }
            
            self?._isListening = true
        })
    }
    
    func stop(immdiately: Bool = false) {
        _filterError = false
        
        guard _isListening else { return }
        
        _isListening = false
        
        _ = Timer.scheduledTimer(withTimeInterval: immdiately ? 0.0 : 1.0, repeats: false, block: { (timer) in
            DispatchQueue.main.async { [weak self] in
                self?._timerThreshold?.invalidate()
                self?._timerThreshold = nil
                
                self?._timerDuration?.invalidate()
                self?._timerDuration = nil
                
                self?._recogTask?.finish()
                self?._recogTask = nil
                
                self?._recogRequest?.endAudio()
                self?._audioEngine.stop()
                self?._audioEngine.inputNode.removeTap(onBus: 0)
                
                self?._audioFile = nil
                
                self?._recogRequest = nil
                
                let audioSession = AVAudioSession.sharedInstance()
                        
                do {
                    try audioSession.setCategory(.playback)
                    try audioSession.setMode(.default)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    print("audioSession properties weren't set because of an error.")
                    return
                }
                
                if let self = self {
                    self.delegate?.speechToTextManager(didStop: self, withResult: self._resultString)
                }
            }
        })
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
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
              else { return nil }
        
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
        
        let inputPath = fileUrl.path
        let outputURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("output.mp3")
        guard let outputPath = outputURL?.path else {
            print("Error to set input or output path")
            return
        }
        
        print("Input Path: \(inputPath)")
        print("Output Path: \(outputPath)")
        
        let converter = ExtAudioConverter()
        converter.inputFilePath = inputPath
        converter.outputFilePath = outputPath
        converter.outputFormatID = kAudioFormatMPEGLayer3
        if converter.convert() {
            guard let aData = try? Data(contentsOf: outputURL!) else {
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
                "src": outputPath,
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
                    body += "; filename=\"ios_\(customerSrl)_\(testSrl)_\(Date().timeIntervalSince1970).mp3\"\r\n".data(using: .utf8)!
                    body += "Content-Type: \"content-type header\"\r\n\r\n".data(using: .utf8)!
                    body += aData
                    body += "\r\n".data(using: .utf8)!
                }
              }
            }
            body += "--\(boundary)--\r\n".data(using: .utf8)!
            

            var request = URLRequest(url: URL(string: RequestUrl.Base)!,timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            request.httpMethod = "POST"
            request.httpBody = body

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let rawData = data, let responseData = try? JSONSerialization.jsonObject(with: rawData, options: []) as? [String:Any] else {
                    completion?(nil)
                    return
                }
                completion?(responseData["response"] as? [String:Any])
            }

            task.resume()
        }
    }
}

extension ALTSpeechToTextManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("available : \(available)")
    }
}
