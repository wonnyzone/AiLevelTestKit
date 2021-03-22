//
//  ALTBaseData.swift
//  AILevelTest
//
//  Created by Jun-kyu Jeon on 2020/11/16.
//

import Foundation

public class ALTBaseData: NSObject {
    internal var rawData: [String:Any]
    
    init(with raw: [String:Any] = [:]) {
        rawData = raw
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.rawData = aDecoder.decodeObject(forKey: "rawData") as? [String:Any] ?? [:]
        super.init()
    }
    
    required public init(_ data: ALTBaseData) {
        rawData = data.rawData
        super.init()
    }
}

extension ALTBaseData: NSCopying, NSCoding {
    public func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(self)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(rawData, forKey: "rawData")
    }
}
