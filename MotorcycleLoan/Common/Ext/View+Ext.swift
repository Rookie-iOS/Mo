//
//  View+Ext.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import UIKit

extension UIView {
    
    var y: CGFloat {
        get {
            frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var width: CGFloat {
        get {
            frame.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            frame.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    var controller : Moto_ViewController? {
        get {
            for view in sequence(first: self.superview, next: {$0?.superview}){
                if let responder = view?.next{
                    if responder.isKind(of: Moto_ViewController.self){
                        return responder as? Moto_ViewController
                    }
                }
            }
            return nil
        }
    }
    
    func addGradient(_ startColor: UIColor, _ endColor: UIColor) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    func addDashedBorder(_ lineColor: UIColor, _ fillColor: UIColor) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.fillColor = fillColor.cgColor
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 8)
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 0.5
        shapeLayer.lineDashPattern = [6, 3]
        return shapeLayer
    }
}
