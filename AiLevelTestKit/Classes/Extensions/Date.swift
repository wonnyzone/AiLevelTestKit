//
//  Date.swift
//  Wishpoke
//
//  Created by Jun-kyu Jeon on 01/06/2018.
//  Copyright © 2018 QUtils. All rights reserved.
//

import Foundation

internal extension Date {
    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year ?? 0
    }
    
    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month ?? 0
    }
    
    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear ?? 0
    }
    
    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day ?? 0
    }
    
    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour ?? 0
    }
    
    func minutesFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute ?? 0
    }
    
    func secondsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second ?? 0
    }
    
    func daysFrom(_ date: Date, absolute: Bool = false) -> Int {
        var fromDate = date
        var toDate = self
        
        if absolute {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            fromDate = formatter.date(from: formatter.string(from: date))!
            toDate = formatter.date(from: formatter.string(from: self))!
        }
        return (Calendar.current as NSCalendar).components(.day, from: fromDate, to: toDate, options: []).day ?? 0
    }
    
//    var relativeTime: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        
//        let now = Date()
//        if now.daysFrom(self) > 0 {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy년 M월 d일"
//            return dateFormatter.string(from: self)
//        }
//        if now.hoursFrom(self) > 0 {
//            return "\(now.hoursFrom(self)) 시간전"
//        }
//        if now.minutesFrom(self) > 0 {
//            return "\(now.minutesFrom(self)) 분전"
//        }
//        return "방금전"
//    }
//    
//    
//    
//    var relativeDate: String {
//        let now = Date()
//        
//        let daysFrom = now.daysFrom(self, absolute: true)
//        
//        if daysFrom == 0 {
//            return ALTAppString.General.Today
//        } else if daysFrom == 1 {
//            return ALTAppString.General.Yesterday
//        }
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.string(from: self)
//    }
    
    var absDate: Date {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter.date(from: formatter.string(from: self)) ?? self
        }
    }
    
    var string: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
