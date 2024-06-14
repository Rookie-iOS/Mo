//
//  String+Ext.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import UIKit

extension String {
    
    func hexColorString( _ alpha: CGFloat = 1.0) -> UIColor {
        var hexSanitized = trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return .clear
        }
        return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: alpha)
    }
}
