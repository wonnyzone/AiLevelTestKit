//
//  Font.swift
//  LovePropose
//
//  Created by Jun-kyu Jeon on 10/05/2019.
//  Copyright © 2019 DonutsKorea. All rights reserved.
//

import UIKit

internal extension UIFont {
    class func nanumSquare(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        var name = "NanumSquareRoundOTFR"
        
        switch weight {
        case .light:
            name = "NanumSquareRoundOTFL"
            break
            
        case .bold:
            name = "NanumSquareRoundOTFB"
            break
            
        case .heavy:
            name = "NanumSquareRoundOTFEB"
            break
            
        default: break
        }
        
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}
