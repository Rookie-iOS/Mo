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
        self.stage_number = try container.decodeIfPresent(String.self, forKey: .stage_number)
        self.days_number = try container.decodeIfPresent(String.self, forKey: .days_number)
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
        self.days = try container.decodeIfPresent(String.self, forKey: .days)
        self.term_id = try container.decodeIfPresent(String.self, forKey: .term_id)
        self.info = try container.decodeIfPresent(Moto_LoadUserDataInfoModel.self, forKey: .info)
    }
}

struct Moto_LoadUserDataInfoModel: Codable {
    
    var pro_id: String?
    var money: String?
    var data: [Moto_LoadUserDataInfoDataModel]?
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pro_id = try container.decodeIfPresent(String.self, forKey: .pro_id)
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
        self.rid = try container.decodeIfPresent(String.self, forKey: .rid)
        self.service_fee = try container.decodeIfPresent(Int.self, forKey: .service_fee)
        self.credit_price = try container.decodeIfPresent(Int.self, forKey: .credit_price)
        self.manage_price = try container.decodeIfPresent(Int.self, forKey: .manage_price)
        self.interest = try container.decodeIfPresent(Int.self, forKey: .interest)
        self.real_price = try container.decodeIfPresent(Int.self, forKey: .real_price)
        self.repay_price = try container.decodeIfPresent(Int.self, forKey: .repay_price)
        if let _amount = try? container.decodeIfPresent(Int.self, forKey: .amount) {
            amount = _amount
        }else {
            let _amount = try container.decodeIfPresent(String.self, forKey: .amount)
            amount = Int(_amount ?? "")
        }
        
        if let _tech_price = try? container.decodeIfPresent(Int.self, forKey: .tech_price) {
            tech_price = _tech_price
        }else {
            let _tech_price = try container.decodeIfPresent(String.self, forKey: .tech_price)
            tech_price = Int(_tech_price ?? "")
        }
    }
}
