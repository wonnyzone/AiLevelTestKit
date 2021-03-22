//
//  Others.swift
//  Wishpoke
//
//  Created by Jun-kyu Jeon on 11/03/2018.
//  Copyright © 2018 Wishpoke. All rights reserved.
//

import UIKit

extension UnicodeScalar {
    var isEmoji: Bool {
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x2600...0x26FF,   // Misc symbols
        0x2700...0x27BF,   // Dingbats
        0xFE00...0xFE0F,   // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
        65024...65039, // Variation selector
        8400...8447: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        return value == 8205
    }
}

extension UIWindow {
    class var keyedWindow: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    /// Fix for http://stackoverflow.com/a/27153956/849645
    func setRootViewController(_ newRootViewController: UIViewController, transition: CATransition? = nil) {
        
        let previousViewController = rootViewController
        
        if let transition = transition {
            // Add the transition
            layer.add(transition, forKey: kCATransition)
        }
        
        rootViewController = newRootViewController
        
        // Update status bar appearance using the new view controllers appearance - animate if needed
        if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
                newRootViewController.setNeedsStatusBarAppearanceUpdate()
            })
        } else {
            newRootViewController.setNeedsStatusBarAppearanceUpdate()
        }
        
        /// The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
        if let transitionViewClass = NSClassFromString("UITransitionView") {
            for subview in subviews where subview.isKind(of: transitionViewClass) {
                subview.removeFromSuperview()
            }
        }
        if let previousViewController = previousViewController {
            // Allow the view controller to be deallocated
            previousViewController.dismiss(animated: false) {
                // Remove the root view in case its still showing
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}

extension UIView {
    func takeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        return nil
    }
}

extension UINavigationController {
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}

import CommonCrypto

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
    func removeHTMLTags() -> String {
//        return self.replacingOccurrences(of: "<[^>]+>", with: "", options:
//        .regularExpression, range: nil).replacingOccurrences(of: "&[^;]+;", with:
//        "", options:.regularExpression, range: nil)
        guard let data = self.data(using: .utf8) else {
            return self
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        return attributedString.string
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        var result = emailTest.evaluate(with: self)
        
        let comps = self.components(separatedBy: "@")
        
        guard result, comps.count == 2, let provider = comps.last else {return false}
        
        result = provider.range(of: ".") != nil
        
        return result
    }
    
    func nsRange(of string: String) -> NSRange? {
        guard let range = self.range(of: string) else {return nil}
        
        let upperbound = range.upperBound
        let lowerBound = range.lowerBound
        
        let location = self.distance(from: self.startIndex, to: lowerBound)
        let length = self.distance(from: lowerBound, to: upperbound)
        
        return NSMakeRange(location, length)
    }
    
    var absUrlString: String {
        var urlString = self.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
        urlString = urlString.replacingOccurrences(of: "%3A", with: ":").replacingOccurrences(of: "%2F", with: "/")
        urlString = urlString.replacingOccurrences(of: "+", with: "%2B")
        return urlString
    }
    
    var chosung: [String] {
        var output = [String]()
        
        let hanguls = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
        
        for char in self {
            let unicodeScalars = char.unicodeScalars
            let value = unicodeScalars[unicodeScalars.startIndex].value
            
            if value >= 0xAC00, value <= 0xD7A3 {
                let index = Int((value - 0xAC00) / (28 * 21))
                output.append(hanguls[index])
            } else {
                output.append(String(char))
            }
        }
        
        return output
    }
    
    var chosungString: String {
        var outputString = ""
        
        let hanguls = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
        
        for char in self {
            let unicodeScalars = char.unicodeScalars
            let value = unicodeScalars[unicodeScalars.startIndex].value
            
            if value >= 0xAC00, value <= 0xD7A3 {
                let index = Int((value - 0xAC00) / (28 * 21))
                outputString += hanguls[index]
            } else {
                outputString += String(char)
            }
        }
        return outputString
    }
    
    func decodeUnicode() -> String {
        guard let data = self.replacingOccurrences(of: "%u", with: "\\u").data(using: .utf8) else { return self }
        return String(data: data, encoding: .nonLossyASCII)?.removingPercentEncoding ?? self
    }
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }

    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }

    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }

        return hexString
    }
    
    func rangesForUrlStrings() -> [Range<String.Index>] {
        var ranges = [Range<String.Index>]()
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for i in 0 ..< matches.count {
            guard let range = Range(matches[i].range, in: self) else { continue }
            ranges.append(range)
        }
        
        return ranges
    }
    
    func urlStrings() -> [String] {
        let ranges = self.rangesForUrlStrings()
        
        return ranges.map { (range) -> String in
            return "\(self[range])"
        }
    }
}

extension Character {
    func isAlphabet() -> Bool {
        return ((self >= "a" && self <= "z") || (self >= "A" && self <= "Z"))
    }
    
    func isDigit() -> Bool {
        let s = String(self).unicodeScalars
        let uni = s[s.startIndex]
        
        let digits = CharacterSet.decimalDigits
        return digits.contains(UnicodeScalar(uni.value)!)
    }
}

extension CALayer {
    func addGradienBorder(colors: [UIColor], width: CGFloat = 1) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = colors.map({$0.cgColor})
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(rect: self.bounds).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        self.addSublayer(gradientLayer)
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension UILabel {
    func boundingRect(for range: NSRange) -> CGRect? {
        guard let attributedText = self.attributedText else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let container = NSTextContainer(size: self.bounds.size)
        container.lineFragmentPadding = 0
        layoutManager.addTextContainer(container)
        
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: container)
    }
}



extension Int {
    var metricString: String {
        get {
            let number = CGFloat(self)
            
            if number >= 1000000000 {
                return String(format: "%.1f", arguments: [number / 1000000000]) + "G"
            } else if number >= 1000000 {
                return String(format: "%.1f", arguments: [number / 1000000]) + "M"
            } else if number >= 1000 {
                return String(format: "%.1f", arguments: [number / 1000]) + "k"
            }
            
            return "\(self)"
        }
    }
    
    var formattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    var optimized: CGFloat {
        return CGFloat(self) * QUtils.optimizeRatio()
    }
    
    var optimizedWithHeight: CGFloat {
        return CGFloat(self) * QUtils.optimizeHeightRatio()
    }
}

extension Double {
    var optimized: CGFloat {
        return CGFloat(self) * QUtils.optimizeRatio()
    }
    
    var optimizedWithHeight: CGFloat {
        return CGFloat(self) * QUtils.optimizeHeightRatio()
    }
}

extension CGFloat {
    var optimized: CGFloat {
        return self * QUtils.optimizeRatio()
    }
    
    var optimizedWithHeight: CGFloat {
        return self * QUtils.optimizeHeightRatio()
    }
    
    var aosTargeted: CGFloat {
        return self * QUtils.aosTargetedZeplinRatio()
    }
}

extension UIEdgeInsets {
    var optimized: UIEdgeInsets {
        get {
            var newInsets = UIEdgeInsets.zero
            newInsets.top = self.top * QUtils.optimizeRatio()
            newInsets.bottom = self.bottom * QUtils.optimizeRatio()
            newInsets.left = self.left * QUtils.optimizeRatio()
            newInsets.right = self.right * QUtils.optimizeRatio()
            return newInsets
        }
    }
    
    var optimizedWithHeight: UIEdgeInsets {
        get {
            var newInsets = UIEdgeInsets.zero
            newInsets.top = self.top * QUtils.optimizeHeightRatio()
            newInsets.bottom = self.bottom * QUtils.optimizeHeightRatio()
            newInsets.left = self.left * QUtils.optimizeHeightRatio()
            newInsets.right = self.right * QUtils.optimizeHeightRatio()
            return newInsets
        }
    }
    
    var aosTargeted: UIEdgeInsets {
        get {
            var newInsets = UIEdgeInsets.zero
            newInsets.top = self.top * QUtils.aosTargetedZeplinRatio()
            newInsets.bottom = self.bottom * QUtils.aosTargetedZeplinRatio()
            newInsets.left = self.left * QUtils.aosTargetedZeplinRatio()
            newInsets.right = self.right * QUtils.aosTargetedZeplinRatio()
            return newInsets
        }
    }
}

extension CGPoint {
    var optimized: CGPoint {
        get {
            var newPoint = CGPoint.zero
            newPoint.x = self.x * QUtils.optimizeRatio()
            newPoint.y = self.y * QUtils.optimizeRatio()
            return newPoint
        }
    }
    
    var optimizedWithHeight: CGPoint {
        get {
            var newPoint = CGPoint.zero
            newPoint.x = self.x * QUtils.optimizeHeightRatio()
            newPoint.y = self.y * QUtils.optimizeHeightRatio()
            return newPoint
        }
    }
    
    var aosTargeted: CGPoint {
        get {
            var newPoint = CGPoint.zero
            newPoint.x = self.x * QUtils.aosTargetedZeplinRatio()
            newPoint.y = self.y * QUtils.aosTargetedZeplinRatio()
            return newPoint
        }
    }
}

extension CGSize {
    var optimized: CGSize {
        get {
            var newSize = CGSize.zero
            newSize.width = self.width * QUtils.optimizeRatio()
            newSize.height = self.height * QUtils.optimizeRatio()
            return newSize
        }
    }
    
    var optimizedWithHeight: CGSize {
        get {
            var newSize = CGSize.zero
            newSize.width = self.width * QUtils.optimizeHeightRatio()
            newSize.height = self.height * QUtils.optimizeHeightRatio()
            return newSize
        }
    }
    
    var aosTargeted: CGSize {
        get {
            var newSize = CGSize.zero
            newSize.width = self.width * QUtils.aosTargetedZeplinRatio()
            newSize.height = self.height * QUtils.aosTargetedZeplinRatio()
            return newSize
        }
    }
}

extension CGRect {
    var optimized: CGRect {
        get {
            var newRect = CGRect.zero
            newRect.origin = self.origin.optimized
            newRect.size = self.size.optimized
            return newRect
        }
    }
    
    var optimizedWithHeight: CGRect {
        get {
            var newRect = CGRect.zero
            newRect.origin = self.origin.optimizedWithHeight
            newRect.size = self.size.optimizedWithHeight
            return newRect
        }
    }
    
    var aosTargeted: CGRect {
        get {
            var newRect = CGRect.zero
            newRect.origin = self.origin.aosTargeted
            newRect.size = self.size.aosTargeted
            return newRect
        }
    }
}

extension UIColor {
    var inverted: UIColor {
        get {
            var fRed = CGFloat(0), fGreen = CGFloat(0), fBlue : CGFloat = CGFloat(0), fAlpha = CGFloat(0)
            
            guard self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) else { return self }
            
            return UIColor(red: 1 - fRed, green: 1 - fGreen, blue: 1 - fBlue, alpha: fAlpha)
        }
    }
}

public extension Sequence where Element: Hashable {
    func removeDuplicated() -> [Element] {
        var seen = Set<Element>()
        return self.filter { seen.insert($0).inserted }
    }
}
