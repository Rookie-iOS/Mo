//
//  Moto_UploadRisk.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import Foundation
import DYFCryptoUtils


struct Moto_UploadRisk {
    
    private struct Moto_RKUPLoadData: Codable {
        
        var apply_id: String?
        var detail_id: String?
        var co_time: Int?
        var device_id: String?
        var jdata: String?
        var `catch`: Int?
    }
    
    private struct Moto_RiskModel: Encodable {
        let brand = "Apple"
        let uuid = Moto_Utils.uuid()
        let model = UIDevice.platformString
        let app_version = Moto_Utils.versionString()
        let system = UIDevice.current.systemName
        let ip = Moto_Utils.ip_address()
        let mac = Moto_Utils.mac_address()
        let is_root = UIDevice.isJailbreak() ? "1" : "0"
        let system_version = UIDevice.current.systemVersion
        let network_operator_name = Moto_Utils.carrierName()
        let network_type = Moto_Utils.netType()
        let screen_size = "\(UIScreen.main.bounds.size.width)_\(UIScreen.main.bounds.size.height)"
        let time_zone_id = TimeZone.current.abbreviation() ?? ""
        let imei = DYFCryptoUtils.md5EncodedString(Moto_Utils.uuid())
        let serial_number = DYFCryptoUtils.md5EncodedString(Moto_Utils.uuid())
        let timeZone = NSTimeZone.system
    }
    
    static func riskModelString() -> String? {
        
        let model = Moto_RiskModel()
        guard let data = try? JSONEncoder().encode(model) else { return nil }
        let string = String(data: data, encoding: .utf8)
        return string
    }
    
    static func uploadRKData(_ catch_stage: Int, _ apply_id: String? = nil, _ detail_id: String? = nil) {
        
        var model = Moto_RKUPLoadData()
        model.apply_id = apply_id
        model.detail_id = detail_id
        model.catch = catch_stage
        model.device_id = Moto_Utils.uuid()
        model.jdata = riskModelString()
        model.co_time = Int(Date().timeIntervalSince1970)
        guard let data = try? JSONEncoder().encode(model) else { return }
        guard let string = String(data: data, encoding: .utf8) else { return }
        let params = ["moto_risk_data": string]
        Moto_Networking.request(path: Moto_Apis.Moto_api_upload_rk_data, method: .post, params: params) { data in
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                MotoLog("Success")
            }
        }
    }
    
    static private func generateRiskEventDict() -> [String: Any]? {
        var event:Moto_EventRisk!
        if let dataString = Moto_Utils.cacheData(5) {
            if !dataString.isEmpty {
                if let data = dataString.data(using: .utf8) {
                    event = try! JSONDecoder().decode(Moto_EventRisk.self, from: data)
                }
            }else {
                event = Moto_EventRisk()
            }
        }else {
            event = Moto_EventRisk()
        }
        
        var dict = [String:Any]()
        let mirr = Mirror(reflecting: event!)
        for case let (label, value) in mirr.children {
            guard let key = label else { return nil }
            dict[key] = value
        }
        return dict
    }
    
    // 埋点时间点
    static func eventAtTime(_ name: String) {
        guard var dict = generateRiskEventDict() else { return }
        if dict.keys.contains(name) {
            dict[name] = Int(Date().timeIntervalSince1970*1000)
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return }
            guard let dataString = String(data: jsonData, encoding: .utf8) else { return }
            Moto_Utils.saveData(5, dataString)
        }
    }
    
    // update value
    static func eventUpdate(_ name: String, value: Int) {
        guard var dict = generateRiskEventDict() else { return }
        if dict.keys.contains(name) {
            dict[name] = value
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return }
            guard let dataString = String(data: jsonData, encoding: .utf8) else { return }
            Moto_Utils.saveData(5, dataString)
        }
    }
    
    // count number
    static func eventCount(_ name: String) {
        guard var dict = generateRiskEventDict() else { return }
        if dict.keys.contains(name) {
            guard var count = dict[name] as? Int else { return }
            if count == -999 {
                count = 1
            }else {
                count += 1
            }
            dict[name] = count
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return }
            guard let dataString = String(data: jsonData, encoding: .utf8) else { return }
            Moto_Utils.saveData(5, dataString)
        }
    }
    
    // event risk begin
    static func eventBegin(_ name: String, _ isToatl: Bool = false) {
        guard var dict = generateRiskEventDict() else { return }
        if dict.keys.contains(name) {
            if isToatl {
                guard let start = dict[name] as? String else { return }
                let seps = start.split(separator: "_")
                dict[name] = "\(Int(Date().timeIntervalSince1970*1000))_\(seps.last ?? "0")"
            }else {
                dict[name] = Int(Date().timeIntervalSince1970*1000)
            }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return }
            guard let dataString = String(data: jsonData, encoding: .utf8) else { return }
            Moto_Utils.saveData(5, dataString)
        }
    }
    
    // event risk end
    static func eventEnd(_ name: String, _ isTotal: Bool = false) {
        guard var dict = generateRiskEventDict() else { return }
        if dict.keys.contains(name) {
            if isTotal {
                guard let infoValue = dict[name] as? String else { return }
                let time: [String] = infoValue.split(separator: "_").map { String($0) }
                guard let start = time.first else { return }
                guard let duration = time.last else { return }
                dict[name] = "end_\(Int(Date().timeIntervalSince1970 * 1000) - (Int(start) ?? 0) + (Int(duration) ?? 0))"
            }else {
                guard let start = dict[name] as? Int else { return }
                let duration = Int(Date().timeIntervalSince1970 * 1000) - start
                dict[name] = duration
            }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return }
            guard let dataString = String(data: jsonData, encoding: .utf8) else { return }
            Moto_Utils.saveData(5, dataString)
        }
    }
}
