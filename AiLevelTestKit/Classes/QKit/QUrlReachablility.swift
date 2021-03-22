//
//  QUrlReachablility.swift
//  WebImageDownloader
//
//  Created by Jun-kyu Jeon on 11/10/2018.
//  Copyright © 2018 Wishpoke. All rights reserved.
//

import Foundation

class QUrlReachability: NSObject {
    class func check(_ urlString: String, completion: ((Bool, String?) -> Void)? = nil) {
        var text = urlString
        
        if text.hasPrefix("http://") == false && text.hasPrefix("https://") == false && text.hasPrefix("ftp://") == false {
            text = "http://" + text
        }
        
        let formattedString = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        guard let url = URL(string: formattedString ?? "") else {
            completion?(false, nil)
            return
        }
        
        var timer: Timer?
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                timer?.invalidate()
                
                let succeed = data != nil && error == nil
                completion?(succeed, succeed ? formattedString : nil)
            }
        }
        
        task.resume()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: { (theTimer) in
            task.cancel()
            completion?(false, nil)
        })
    }
}
