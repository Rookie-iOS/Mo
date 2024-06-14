//
//  Moto_Utils.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import Alamofire
import Foundation
import CryptoSwift
import CoreTelephony
import KeychainAccess


/// 自定义输出
func MotoLog(tag:String = "", file:String = #file, line:Int = #line, _ items:Any?...) {
    
#if DEBUG
    var description = ""
    let fileName = URL(fileURLWithPath: file).lastPathComponent
    for item in items {
        description += (item as AnyObject).description
    }
    let date = Date()
    let formater = DateFormatter()
    formater.dateFormat = "HH:mm:ss.SSSSS"
    guard (!tag.isEmpty) else {
        print("\(formater.string(from: date)):\(fileName):\(line):",description)
        return
    }
    print("\(formater.string(from: date)):\(tag):\(fileName):\(line):",description)
#endif
}

struct Moto_Utils {
    
    static func netType() -> String {
        var networkTypeString = ""
        guard let network = NetworkReachabilityManager(host: "https://www.bing.com/") else { return networkTypeString }
        switch network.status {
        case .notReachable:
            networkTypeString = "UNREACHABLE"
        case .reachable(.ethernetOrWiFi):
            networkTypeString = "WIFT"
        case .reachable(.cellular):
            networkTypeString = "CELLULAR"
        default:
            break
        }
        return networkTypeString
    }
    
    static func carrierName() -> String {
        var name = ""
        guard #available(iOS 16, *) else {
            if let provider = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders {
                for item in provider.values {
                    if item.mobileNetworkCode != nil {
                        if let carrier = item.carrierName {
                            name = carrier
                            break;
                        }
                    }
                }
            }
            return name
        }
        return name
    }
    
    static func ip_address() -> String {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first ?? ""
    }
    
    static func uuid() -> String {
        do {
            if let uuid = try Keychain(service: "mo_key_chain_uuid_service").get("mo_uuid_key") {
                return uuid
            }else {
                if let uuid = UIDevice.current.identifierForVendor {
                    let _uuid = uuid.uuidString.replacingOccurrences(of: "-", with: "")
                    try Keychain(service: "mo_key_chain_uuid_service").set(_uuid, key: "mo_uuid_key")
                    return _uuid
                }
                return ""
            }
        } catch {
            print(error)
            return ""
        }
    }
    
    static func mac_address() -> String {
        let index  = Int32(if_nametoindex("en0"))
        let bsdData = "en0".data(using: .utf8)!
        var mib : [Int32] = [CTL_NET,AF_ROUTE,0,AF_LINK,NET_RT_IFLIST,index]
        var len = 0;
        if sysctl(&mib,UInt32(mib.count), nil, &len,nil,0) < 0 { return "" }
        var buffer = [CChar].init(repeating: 0, count: len)
        if sysctl(&mib, UInt32(mib.count), &buffer, &len, nil, 0) < 0 { return "" }
        let infoData = NSData(bytes: buffer, length: len)
        var interfaceMsgStruct = if_msghdr()
        infoData.getBytes(&interfaceMsgStruct, length: MemoryLayout.size(ofValue: if_msghdr()))
        let socketStructStart = MemoryLayout.size(ofValue: if_msghdr()) + 1
        let socketStructData = infoData.subdata(with: NSMakeRange(socketStructStart, len - socketStructStart))
        let rangeOfToken = socketStructData.range(of: bsdData, options: NSData.SearchOptions(rawValue: 0), in: Range.init(uncheckedBounds: (0, socketStructData.count)))
        let start = rangeOfToken?.count ?? 0 + 3
        let end = start + 6
        let range1 = start..<end
        var macAddressData = socketStructData.subdata(in: range1)
        let macAddressDataBytes: [UInt8] = [UInt8](repeating: 0, count: 6)
        macAddressData.append(macAddressDataBytes, count: 6)
        let macaddress = String.init(format: "%02X:%02X:%02X:%02X:%02X:%02X", macAddressData[0], macAddressData[1], macAddressData[2], macAddressData[3], macAddressData[4], macAddressData[5])
        return macaddress
    }
    
}

extension Moto_Utils {
    
    static func aes(_ string: String, _ secretKey: String) -> String? {
        guard let plainTextData = string.data(using: .utf8) else { return nil }
        let keyData = secretKey.data(using: .utf8)?.sha256()
        do {
            let iv:[UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            let aes = try AES(key:keyData!.bytes , blockMode: CBC(iv: iv), padding: .pkcs5)
            let data = Data(try aes.encrypt(plainTextData.bytes))
            return data.base64EncodedString()
        } catch  {
            return ""
        }
    }
    
    static func verifyMobile(_ mobile: String) -> Bool {
        let pattern = "(^[8,9]\\d{9}$)|(^[08,09]\\d{10}$)"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: mobile)
    }
    
    static func verifyEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: email)
    }
    
    static func verifyName(_ name: String) -> Bool {
        for ch in name {
            if(ch >= "\u{4e00}" && ch <= "\u{9fff}") {
                return false
            }
        }
        let pattern = "^([\\p{L}][\\p{L}\\s.'-]{1,50})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: name)
    }
    
    static func formatMoney(_ money: Int) -> String {
        let formatter = NumberFormatter()
        formatter.positiveFormat = ",###.##"
        guard let moneyString = formatter.string(from: NSNumber(integerLiteral: money)) else { return "" }
        return moneyString
    }
    
    static func formatDateString(_ date: Date, _ pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }
    
    static func transformDateFromString(_ dateString: String, _ pattern: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: dateString)
    }
    
    static func generateRandomTimeString() -> String {
        
        let time = Int((NSDate().timeIntervalSince1970) * 1000)
        return "\(Moto_Utils.userInfo()?.phone ?? "")_\(time)"
    }
}

extension Moto_Utils {
    
    static var keyWindow: UIWindow? {
        get {
            if #available(iOS 15.0, *) {
                for scene in UIApplication.shared.connectedScenes {
                    if scene.activationState == .foregroundActive {
                        let windowScene: UIWindowScene = scene as! UIWindowScene
                        for window in windowScene.windows {
                            if window.isKeyWindow {
                                return window
                            }
                        }
                    }
                }
            }else {
                if #available(iOS 13.0, *) {
                    for window in UIApplication.shared.windows {
                        if window.isKeyWindow {
                            return window
                        }
                    }
                }
            }
            return nil
        }
    }
    
    static func versionString() -> String {
        if let info = Bundle.main.infoDictionary {
            return "\(info["CFBundleShortVersionString"] ?? "unknown_version")"
        }
        return "unknown_version"
    }
    
    static func goHome() {
        
        guard let window = keyWindow else { return }
        guard let tabBar = window.rootViewController as? Moto_TabBarController else { return }
        guard let navigationController = tabBar.selectedViewController as? Moto_NavigatonController else { return }
        navigationController.popToRootViewController(animated: true)
        tabBar.selectedIndex = 0
    }
    
}

extension Moto_Utils {
    
    static func logout() {
        UserDefaults.standard.removeObject(forKey: "UserInfo")
    }
    
    static func userInfo() -> Moto_LoginModel? {
        
        guard let userData = UserDefaults.standard.data(forKey: "UserInfo") else { return nil }
        do {
            guard let login = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [Moto_LoginModel.self, NSString.self], from: userData) as? Moto_LoginModel else { return nil }
            return login
        }
    }
}


extension Moto_Utils {
    
    static func saveData(_ type: Int, _ dataString: String?) {
        
        guard let _dataString = dataString else { return }
        guard let mobile = Moto_Utils.userInfo()?.phone else { return }
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        let dataDir = path.appendingFormat("/%@", mobile)
        if !FileManager.default.fileExists(atPath: dataDir) {
            try? FileManager.default.createDirectory(atPath: dataDir, withIntermediateDirectories: true)
        }
        let fileName = "\(Moto_Utils.userInfo()?.phone ?? "")_\(type).data"
        try? _dataString.write(toFile: dataDir.appendingFormat("/%@", fileName), atomically: true, encoding: .utf8)
    }
    
    static func cacheData(_ type: Int) -> String? {
        
        guard let mobile = Moto_Utils.userInfo()?.phone else { return nil }
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
        let fileName = "\(Moto_Utils.userInfo()?.phone ?? "")_\(type).data"
        let filePath = path.appendingFormat("/%@/%@", mobile, fileName)
        if !FileManager.default.fileExists(atPath: filePath) {
            return nil
        }
        guard let dataString = try? String(contentsOfFile: filePath) else { return nil }
        return dataString
    }
}
