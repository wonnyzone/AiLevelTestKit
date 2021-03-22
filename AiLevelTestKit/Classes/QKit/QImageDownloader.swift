//
//  QImageDownloader.swift
//  Wishpoke
//
//  Created by Jun-kyu Jeon on 28/06/2018.
//  Copyright © 2018 Wishpoke. All rights reserved.
//

import UIKit

class QImageDownloader: NSObject {
    private var _keys = [String]()
    private var _dataDict = [String:Data]()
    
    private let _maximumSize: Int64 = 8 * 1000 * 1000
    
    private var _task: URLSessionTask?
    
    func request(_ urlString: String, completion aCompletion: @escaping ((UIImage?) -> Void)) {
        _task?.cancel()
        _task = nil
        
        if let imageData = _dataDict[urlString], let image = UIImage(data: imageData) {
            aCompletion(image)
            return 
        }
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            aCompletion(nil)
            return
        }
        
        let urlRequest = NSMutableURLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        _task = URLSession.shared.dataTask(with: url) {[weak self] (data, response, error) in
            guard let self = self, data != nil, let image = UIImage(data: data!) else {
                aCompletion(nil)
                return
            }
            
            var currentSize = Int64(0)
            
            for (_, value) in self._dataDict {
                currentSize += Int64(value.count)
            }
            
            var keys = Array(self._keys).reversed() as [String]
            
            if currentSize + Int64(data!.count) > self._maximumSize {
                let totalSize = keys.count
                for i in 0 ..< keys.count {
                    let key = self._keys[i]
                    
                    keys.remove(at: totalSize - i - 1)
                    let itemSize = Int64(self._dataDict[key]?.count ?? 0)
                    self._dataDict[key] = nil
                    
                    currentSize -= itemSize
                    
                    if currentSize + Int64(data!.count) < self._maximumSize {
                        break
                    }
                }
            }
            
            self._keys.removeAll()
            self._keys.append(contentsOf: keys.reversed())
            
            self._keys.append(urlString)
            self._dataDict[urlString] = data!
            
            aCompletion(image)
        }
        _ = resume()
    }
    
    func cancel() -> Bool {
        guard _task != nil else {return false}
        
        _task?.cancel()
        _task = nil
        return true
    }
    
    func resume() -> Bool {
        guard let state = _task?.state, state != .running else {return false}
        _task?.resume()
        return true
    }
}
