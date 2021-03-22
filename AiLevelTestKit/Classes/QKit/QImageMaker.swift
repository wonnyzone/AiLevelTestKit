//
//  QImageMaker.swift
//  Wishpoke
//
//  Created by Jun-kyu Jeon on 19/03/2018.
//  Copyright © 2018 Wishpoke. All rights reserved.
//

import UIKit

import QuartzCore
import CoreGraphics

class QImageSettings: NSObject {
    var size = CGSize(width: 100, height: 100)
    
    var colour = UIColor.white
    var backgroundColour = UIColor.clear
    
    var fillColour = UIColor.clear
    
    var thickness = CGFloat(1)
}

class QImageMaker: NSObject {
    class func plusButtonImage(with settings: QImageSettings) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: settings.size)
        
        let image = renderer.image(actions: {(context) -> Void in
            context.cgContext.setStrokeColor(settings.colour.cgColor)
            context.cgContext.setLineWidth(settings.thickness)
            
            var point = CGPoint.zero
            point.x = settings.size.width * 0.5
            context.cgContext.move(to: point)
            
            point.y = settings.size.height
            context.cgContext.addLine(to: point)
            
            point.x = 0
            point.y = settings.size.height * 0.5
            context.cgContext.move(to: point)
            
            point.x = settings.size.width
            context.cgContext.addLine(to: point)
            
            context.cgContext.drawPath(using: .stroke)
        })
        
        return image
    }
    
    class func shapeButton(with settings: QImageSettings, vertexes: [CGPoint]) -> UIImage? {
        return QImageMaker.shapeButton(with: settings, vertexes: vertexes, isClosedPath: true)
    }
    
    class func shapeButton(with settings: QImageSettings, vertexes: [CGPoint], isClosedPath: Bool) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: settings.size)
        
        let image = renderer.image(actions: {(context) -> Void in
            context.cgContext.setFillColor(settings.fillColour.cgColor)
            context.cgContext.setStrokeColor(settings.colour.cgColor)
            context.cgContext.setLineWidth(settings.thickness)
            context.cgContext.setLineJoin(CGLineJoin.bevel)
            context.cgContext.setLineCap(CGLineCap.square)
            
            var point = isClosedPath ? vertexes.last! : vertexes.first!
            
            if point.x == 0 {
                point.x = 0.05
            } else if point.x == 1 {
                point.x = 0.95
            }
            point.x *= settings.size.width
            
            if point.y == 0 {
                point.y = 0.05
            } else if point.y == 1 {
                point.y = 0.95
            }
            point.y *= settings.size.height
            
            context.cgContext.move(to: point)
            
            for i in (isClosedPath ? 0 : 1) ..< vertexes.count {
                point = vertexes[i]
                
                if point.x == 0 {
                    point.x = 0.05
                } else if point.x == 1 {
                    point.x = 0.95
                }
                point.x *= settings.size.width
                
                if point.y == 0 {
                    point.y = 0.05
                } else if point.y == 1 {
                    point.y = 0.95
                }
                point.y *= settings.size.height
                
                context.cgContext.addLine(to: point)
            }
            
            context.cgContext.drawPath(using: .fillStroke)
        })
        
        return image
    }
    
    class func closeButton(with settings: QImageSettings) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: settings.size)
        
        let image = renderer.image(actions: {(context) -> Void in
            context.cgContext.setFillColor(settings.fillColour.cgColor)
            context.cgContext.setStrokeColor(settings.colour.cgColor)
            context.cgContext.setLineWidth(settings.thickness)
            
            var point = CGPoint.zero
            point.x = settings.size.width * 0.15
            point.y = settings.size.height * 0.15
            context.cgContext.move(to: point)
            
            point = CGPoint.zero
            point.x = settings.size.width * 0.85
            point.y = settings.size.height * 0.85
            context.cgContext.addLine(to: point)
            
            point = CGPoint.zero
            point.x = settings.size.width * 0.15
            point.y = settings.size.height * 0.85
            context.cgContext.move(to: point)
            
            point = CGPoint.zero
            point.x = settings.size.width * 0.85
            point.y = settings.size.height * 0.15
            context.cgContext.addLine(to: point)
            
            context.cgContext.drawPath(using: .fillStroke)
        })
        
        return image
    }
    
    class func moreButton(with settings: QImageSettings, dotSize: CGFloat, isHorizontal: Bool = true) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: settings.size)
        
        let image = renderer.image(actions: {(context) -> Void in
            context.cgContext.setFillColor(settings.fillColour.cgColor)
            context.cgContext.setStrokeColor(settings.colour.cgColor)
            context.cgContext.setLineWidth(settings.thickness)
            context.cgContext.setLineCap(.round)
            
            if isHorizontal {
                context.cgContext.addEllipse(in: CGRect(x: dotSize * 2, y: settings.size.height / 2, width: dotSize, height: dotSize))
                context.cgContext.addEllipse(in: CGRect(x: settings.size.width / 2, y: settings.size.height / 2, width: dotSize, height: dotSize))
                context.cgContext.addEllipse(in: CGRect(x: settings.size.width - dotSize * 2, y: settings.size.height / 2, width: dotSize, height: dotSize))
            } else {
                context.cgContext.addEllipse(in: CGRect(x: settings.size.width / 2, y: dotSize * 2, width: dotSize, height: dotSize))
                context.cgContext.addEllipse(in: CGRect(x: settings.size.width / 2, y: settings.size.height / 2, width: dotSize, height: dotSize))
                context.cgContext.addEllipse(in: CGRect(x: settings.size.width / 2, y: settings.size.height - dotSize * 2, width: dotSize, height: dotSize))
            }
            
            context.cgContext.drawPath(using: .fillStroke)
        })
        
        return image
    }
    
    class func checkmarkImage(with settings: QImageSettings) -> UIImage? {
        var vertexes = [CGPoint]()
        vertexes.append(CGPoint(x: 0.1, y: 0.3))
        vertexes.append(CGPoint(x: 0.45, y: 0.9))
        vertexes.append(CGPoint(x: 0.9, y: 0.1))
        
        return QImageMaker.shapeButton(with: settings, vertexes: vertexes, isClosedPath: false)
    }
    
    class func dotImage(with settings: QImageSettings, mode: CGPathDrawingMode = .fillStroke) -> UIImage? {
        let size = settings.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image(actions: {(context) -> Void in
            context.cgContext.setFillColor(settings.fillColour.cgColor)
            context.cgContext.setStrokeColor(settings.colour.cgColor)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineWidth(settings.thickness)
            
            let dotSize = size.width
            
            context.cgContext.addEllipse(in: CGRect(x: 0.05 * dotSize, y: 0.05 * dotSize, width: dotSize * 0.9, height: dotSize * 0.9))
            
            context.cgContext.drawPath(using: mode)
        })
        
        return image
    }
    
    class func noImageIcon(with size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image(actions: {(context) -> Void in
            context.cgContext.setFillColor(UIColor.clear.cgColor)
            context.cgContext.setStrokeColor(ColourKit.Code.HexCCCCCC.cgColor)
            context.cgContext.setLineWidth(1)
            
            var point = CGPoint.zero
            point.x = size.width
            point.y = size.height
            context.cgContext.move(to: point)
            
            point = CGPoint.zero
            point.x = size.width
            point.y = size.height
            context.cgContext.addLine(to: point)
            
            point = CGPoint.zero
            point.x = size.width
            point.y = size.height
            context.cgContext.move(to: point)
            
            point = CGPoint.zero
            point.x = size.width
            point.y = size.height
            context.cgContext.addLine(to: point)
            
            context.cgContext.drawPath(using: .fillStroke)
        })
        
        return image
    }
}
