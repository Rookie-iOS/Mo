//
//  Moto_LoanModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import Foundation

struct Moto_LoanModel: Codable {
    
    var user_data: [Moto_UserDataModel]?
    var user_days: [Moto_LoadTermModel]?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_days = try container.decodeIfPresent([Moto_LoadTermModel].self, forKey: .user_days)
        self.user_data = try container.decodeIfPresent([Moto_UserDataModel].self, forKey: .user_data)
    }
}

struct Moto_LoadTermModel: Codable {
    var stage_number: String?
    var days_number: String?
    var status: Int?
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let _stage_number = try? container.decodeIfPresent(String.self, forKey: .stage_number) {
            stage_number = _stage_number
        }else {
            let _stage_number = try container.decodeIfPresent(Int.self, forKey: .stage_number)
            stage_number = "\(_stage_number ?? 0)"
        }
        
        if let _days_number = try? container.decodeIfPresent(String.self, forKey: .days_number) {
            days_number = _days_number
        }else {
            let _days_number = try container.decodeIfPresent(Int.self, forKey: .days_number)
            days_number = "\(_days_number ?? 0)"
        }
        
        if let _status = try? container.decodeIfPresent(Int.self, forKey: .status) {
            status = _status
        }else {
            let _status = try container.decodeIfPresent(String.self, forKey: .status)
            status = Int(_status ?? "")
        }
    }
}

struct Moto_UserDataModel: Codable {
    var days: String?
    var term_id: String?
    var info: Moto_LoadUserDataInfoModel?
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let _term_id = try? container.decodeIfPresent(String.self, forKey: .term_id) {
            term_id = _term_id
        }else {
            let _term_id = try container.decodeIfPresent(Int.self, forKey: .term_id)
            term_id = "\(_term_id ?? 0)"
        }
        
        if let _days = try? container.decodeIfPresent(String.self, forKey: .days) {
            days = _days
        }else {
            let _days = try container.decodeIfPresent(Int.self, forKey: .days)
            days = "\(_days ?? 0)"
        }
        self.info = try container.decodeIfPresent(Moto_LoadUserDataInfoModel.self, forKey: .info)
    }
}

struct Moto_LoadUserDataInfoModel: Codable {
    
    var pro_id: String?
    var money: String?
    var data: [Moto_LoadUserDataInfoDataModel]?
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let _pro_id = try? container.decodeIfPresent(String.self, forKey: .pro_id) {
            pro_id = _pro_id
        }else {
            let _pro_id = try container.decodeIfPresent(Int.self, forKey: .pro_id)
            pro_id = "\(_pro_id ?? 0)"
        }
        
        if let _money = try? container.decodeIfPresent(String.self, forKey: .money) {
            money = _money
        }else {
            let _money = try container.decodeIfPresent(Int.self, forKey: .money)
            money = "\(_money ?? 0)"
        }
        
        self.data = try container.decodeIfPresent([Moto_LoadUserDataInfoDataModel].self, forKey: .data)
    }
}

struct Moto_LoadUserDataInfoDataModel: Codable {
    var rid: String?
    var amount: Int?
    var service_fee: Int?
    var credit_price: Int?
    var manage_price: Int?
    var interest: Int?
    var tech_price: Int?
    var real_price: Int?
    var repay_price: Int?
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let _rid = try? container.decodeIfPresent(String.self, forKey: .rid) {
            rid = _rid
        }else {
            let _rid = try container.decodeIfPresent(Int.self, forKey: .rid)
            rid = "\(_rid ?? 0)"
        }
        
        if let _amount = try? container.decodeIfPresent(Int.self, forKey: .amount) {
            amount = _amount
        }else {
            let _amount = try container.decodeIfPresent(String.self, forKey: .amount)
            amount = Int(_amount ?? "")
        }
        
        if let _service_fee = try? container.decodeIfPresent(Int.self, forKey: .service_fee) {
            service_fee = _service_fee
        }else {
            let _service_fee = try container.decodeIfPresent(String.self, forKey: .service_fee)
            service_fee = Int(_service_fee ?? "")
        }
        
        if let _credit_price = try? container.decodeIfPresent(Int.self, forKey: .credit_price) {
            credit_price = _credit_price
        }else {
            let _credit_price = try container.decodeIfPresent(String.self, forKey: .credit_price)
            credit_price = Int(_credit_price ?? "")
        }
        
        if let _manage_price = try? container.decodeIfPresent(Int.self, forKey: .manage_price) {
            manage_price = _manage_price
        }else {
            let _manage_price = try container.decodeIfPresent(String.self, forKey: .manage_price)
            manage_price = Int(_manage_price ?? "")
        }
        
        if let _interest = try? container.decodeIfPresent(Int.self, forKey: .interest) {
            interest = _interest
        }else {
            let _interest = try container.decodeIfPresent(String.self, forKey: .interest)
            interest = Int(_interest ?? "")
        }
        
        if let _real_price = try? container.decodeIfPresent(Int.self, forKey: .real_price) {
            real_price = _real_price
        }else {
            let _real_price = try container.decodeIfPresent(String.self, forKey: .real_price)
            real_price = Int(_real_price ?? "")
        }
        
        if let _repay_price = try? container.decodeIfPresent(Int.self, forKey: .repay_price) {
            repay_price = _repay_price
        }else {
            let _repay_price = try container.decodeIfPresent(String.self, forKey: .repay_price)
            repay_price = Int(_repay_price ?? "")
        }
        
        if let _tech_price = try? container.decodeIfPresent(Int.self, forKey: .tech_price) {
            tech_price = _tech_price
        }else {
            let _tech_price = try container.decodeIfPresent(String.self, forKey: .tech_price)
            tech_price = Int(_tech_price ?? "")
        }
    }
}
