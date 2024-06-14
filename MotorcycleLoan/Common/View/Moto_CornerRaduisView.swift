//
//  Moto_CornerRaduisView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit

class Moto_CornerRaduisView: Moto_BaseView {
    
    var radius: CGFloat = 10
    private var lineLayer: CAShapeLayer?
    func drawRadiusWithDashLine(at: CGFloat, _ color: UIColor? = nil) {
        
        let radiusBezier = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
        radiusBezier.move(to: CGPoint(x: 0, y: at))
        radiusBezier.addArc(withCenter: CGPoint(x: 0, y: at), radius: radius, startAngle: Double.pi/2, endAngle: 3*Double.pi/2, clockwise: false)
        radiusBezier.move(to: CGPoint(x: bounds.size.width, y: at))
        radiusBezier.addArc(withCenter: CGPoint(x: bounds.size.width, y: at), radius: radius, startAngle: 3*Double.pi/2, endAngle: Double.pi/2, clockwise: false)
        
        let radiusLayer = CAShapeLayer()
        radiusLayer.frame = bounds
        radiusLayer.path = radiusBezier.cgPath
        layer.mask = radiusLayer
        
        // draw dash line
        let lineBezier = UIBezierPath()
        lineBezier.move(to: CGPoint(x: 0, y: at))
        lineBezier.addLine(to: CGPoint(x: bounds.size.width, y: at))
        if lineLayer == nil {
            lineLayer = CAShapeLayer()
        }
        lineLayer?.path = lineBezier.cgPath
        lineLayer?.lineWidth = 1
        lineLayer?.lineDashPattern = [5, 5]
        if color != nil {
            lineLayer?.strokeColor = color?.cgColor
        }
        layer.addSublayer(lineLayer!)
    }
    
}
