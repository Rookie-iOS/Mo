//
//  Device+Ext.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import UIKit


extension UIDevice {
    
    static let platformString = UIDevice.current.name
    fileprivate static let fileManager = FileManager.default
    fileprivate static let USER_APP_PATH = "/User/Applications/"
    fileprivate static let jailBreakDir = [
        "/Applications/Cydia.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/bin/bash",
        "/var/lib/cydia",
        "var/Lib/apt",
        "/var/cache/apt",
        "/etc/apt",
        "/bin/bash",
        "/bin/sh",
        "/usr/sbin/sshd",
        "/user/libexec/ssh-keysig",
        "/etc/ssh/sshd config"
    ]
    
    fileprivate static func detectJailBreakByAppPathExisted() -> Bool {
        
        var jailbreak = false
        if fileManager.fileExists(atPath: USER_APP_PATH) {
            jailbreak = true
        }
        return jailbreak
    }
    
    fileprivate static func exitJailBreakDir() -> Bool {
        
        var jailbreak = false
        for path in jailBreakDir {
            jailbreak = fileManager.fileExists(atPath: path)
            break
        }
        return jailbreak
    }
    
    fileprivate static func detectJailBreakByCydiaPathExisted() -> Bool {
        
        var jailbreak = false
        guard let url = URL(string: "cydia://") else { return jailbreak }
        if UIApplication.shared.canOpenURL(url) {
            jailbreak = true
        }
        return jailbreak
    }
    
    static func isJailbreak() -> Bool {
        
        var jailbreak = false
        if detectJailBreakByCydiaPathExisted() {
            jailbreak = true
        }
        
        if detectJailBreakByAppPathExisted() {
            jailbreak = true
        }
        
        if exitJailBreakDir() {
            jailbreak = true
        }
        return jailbreak
    }
    
    private var name: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPhone5,1":                                       return "iPhone 5 (GSM)"
        case "iPhone5,2":                                       return "iPhone 5 (CDMA)"
        case "iPhone5,3", "iPhone5,4":                          return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                          return "iPhone 5s"
        case "iPhone7,1":                                       return "iPhone 6 Plus"
        case "iPhone7,2":                                       return "iPhone 6"
        case "iPhone8,1":                                       return "iPhone 6s"
        case "iPhone8,2":                                       return "iPhone 6s Plus"
        case "iPhone8,4":                                       return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                          return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                          return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                        return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                        return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                        return "iPhone X"
        case "iPhone11,2":                                      return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                        return "iPhone XS Max"
        case "iPhone11,8":                                      return "iPhone XR"
        case "iPhone12,1":                                      return "iPhone 11"
        case "iPhone12,3":                                      return "iPhone 11 Pro"
        case "iPhone12,5":                                      return "iPhone 11 Pro Max"
        case "iPhone12,8":                                      return "iPhone SE 2"
        case "iPhone13,1":                                      return "iPhone 12 mini"
        case "iPhone13,2":                                      return "iPhone 12"
        case "iPhone13,3":                                      return "iPhone 12 Pro"
        case "iPhone13,4":                                      return "iPhone 12 Pro Max"
        case "iPhone14,2":                                      return "iPhone 13 Pro"
        case "iPhone14,3":                                      return "iPhone 13 Pro Max"
        case "iPhone14,4":                                      return "iPhone 13 mini"
        case "iPhone14,5":                                      return "iPhone 13"
        case "iPhone14,6":                                      return "iPhone SE"
        case "iPhone14,7":                                      return "iPhone 14"
        case "iPhone14,8":                                      return "iPhone 14 Plus"
        case "iPhone15,2":                                      return "iPhone 14 Pro"
        case "iPhone15,3":                                      return "iPhone 14 Pro Max"
        case "iPhone15,4":                                      return "iPhone 15"
        case "iPhone15,5":                                      return "iPhone 15 Plus"
        case "iPhone16,1":                                      return "iPhone 15 Pro"
        case "iPhone16,2":                                      return "iPhone 15 Pro Max"
            // ... 添加其他iPhone型号
        default:
            return identifier
        }
    }
}
