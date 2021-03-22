//
//  QDataManager.swift
//  QKit
//
//  Created by Jun-kyu Jeon on 02/03/2017.
//  Copyright © 2018 Wishpoke. All rights reserved.
//

import Foundation
import SQLite3

private let kFileName = "settingsV1"
private let kFileExtension = "dat"
private let kFile = kFileName + "." + kFileExtension

private let kDirectory = FileManager.SearchPathDirectory.documentDirectory
private let kDomainMask = FileManager.SearchPathDomainMask.userDomainMask

class QDataManager : NSObject {
    static let shared = QDataManager.loadDatabase
    
    var version = Int32(1)
    
    var uuid: String?
    
    var preferredLanguage: String?
    
    var clientData: ALTClientData?
    var userId: String?
    
    var isSkipTerms: Bool = false
    
    required override init() {
        super.init()
        self.clear()
    }
    
    required init(_ manager: QDataManager) {
        super.init()
        self.version = manager.version
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as? String
        self.preferredLanguage = aDecoder.decodeObject(forKey: "preferredLanguage") as? String
        
        self.isSkipTerms = (aDecoder.decodeObject(forKey: "isSkipTerms") as? NSNumber)?.boolValue ?? false
        
        if let rawData = aDecoder.decodeObject(forKey: "clientData") as? [String:Any] {
            self.clientData = ALTClientData(with: rawData)
        } else {
            self.clientData = nil
        }
        
        self.userId = aDecoder.decodeObject(forKey: "userId") as? String
    }
    
    func commit() {
        let paths = NSSearchPathForDirectoriesInDomains(kDirectory, kDomainMask, true)
        
        let documentsDirectory = paths[0] as NSString
        let filePath = documentsDirectory.appendingPathComponent(kFile)
        
        NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    }
    
    func clear() {
        clientData = nil
        userId = nil
        
        isSkipTerms = false
        
        commit()
    }
}

extension QDataManager {
    class var loadDatabase: QDataManager {
        get {
            guard let thePath = NSSearchPathForDirectoriesInDomains(kDirectory, kDomainMask, true).first as NSString? else  {
                return QDataManager()
            }
            
            let filePath = thePath.appendingPathComponent(kFile)
            
            guard let dataManager = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? QDataManager else {
                return QDataManager()
            }
            
            _ = dataManager.sqlite()
            
            return dataManager
        }
    }
    
    func sqlite() -> Bool {
        do {
            var database: OpaquePointer?
            
            let manager = FileManager.default
            let documentUrl = try manager.url(for: kDirectory, in: kDomainMask, appropriateFor: nil, create: false).appendingPathComponent(kFile)
            
            if sqlite3_open(documentUrl.path, &database) == SQLITE_OK {
                var statement: OpaquePointer?
                
                var userVersion = Int32(0)
                var query = "PRAGMA user_version;"
                
                if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
                    if sqlite3_step(statement) == SQLITE_ROW {
                        userVersion = sqlite3_column_int(statement, 0)
                    }
                }
                
                sqlite3_finalize(statement)
                
                if version > userVersion {
                    query = "CREATE TABLE IF NOT EXISTS statuses (id INTEGER PRIMARY KEY, hit_date REAL)"
                    sqlite3_exec(database, query, nil, nil, nil)
                    
                    query = "PRAGMA user_version=\(version);"
                    sqlite3_exec(database, query, nil, nil, nil)
                }
            }
        } catch {
            return false
        }
        
        return true
    }
}

extension QDataManager: NSCopying, NSCoding {
    func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(self)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(preferredLanguage, forKey: "preferredLanguage")
        aCoder.encode(clientData?.rawData, forKey: "clientData")
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(NSNumber(booleanLiteral: isSkipTerms), forKey: "isSkipTerms")
    }
}
