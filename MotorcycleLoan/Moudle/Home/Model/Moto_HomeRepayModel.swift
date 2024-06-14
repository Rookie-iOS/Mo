//
//  Moto_HomeRepayModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import Foundation

struct Moto_HomeRepayModel: Codable {
    
    var oid: String = ""
    var ad_id: String = ""
    var repay_time: Int = 0
    var money: String = ""
    var final_amount: Int = 0
    var current_amount: Int = 0
    var repaid_amount: Int?
    var ins_amount: String? = ""
    var interest: Int = 0
    var all_interest: Int = 0
    var overtime_day: Int = 0
    var overtime_price: Int = 0
    
    var is_ins_repay: Int = 0
    var is_instalment: Int = 0
    var is_normal_instalment: Int = 0
    var pay_data: Moto_HomeOldRepayDataModel?
    var pay_data_tadpole: [Moto_HomeRepayDataModel]?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.oid = try container.decode(String.self, forKey: .oid)
        self.ad_id = try container.decode(String.self, forKey: .ad_id)
        self.repay_time = try container.decode(Int.self, forKey: .repay_time)
        self.money = try container.decode(String.self, forKey: .money)
        self.final_amount = try container.decode(Int.self, forKey: .final_amount)
        self.current_amount = try container.decode(Int.self, forKey: .current_amount)
        self.ins_amount = try container.decodeIfPresent(String.self, forKey: .ins_amount)
        self.interest = try container.decode(Int.self, forKey: .interest)
        self.all_interest = try container.decode(Int.self, forKey: .all_interest)
        self.overtime_day = try container.decode(Int.self, forKey: .overtime_day)
        self.overtime_price = try container.decode(Int.self, forKey: .overtime_price)
        self.is_ins_repay = try container.decode(Int.self, forKey: .is_ins_repay)
        self.is_instalment = try container.decode(Int.self, forKey: .is_instalment)
        self.is_normal_instalment = try container.decode(Int.self, forKey: .is_normal_instalment)
        self.pay_data = try container.decodeIfPresent(Moto_HomeOldRepayDataModel.self, forKey: .pay_data)
        self.pay_data_tadpole = try container.decodeIfPresent([Moto_HomeRepayDataModel].self, forKey: .pay_data_tadpole)
        if let _repaid_amount = try? container.decodeIfPresent(Int.self, forKey: .repaid_amount) {
            repaid_amount = _repaid_amount
        }else {
            let _repaid_amount = try container.decodeIfPresent(String.self, forKey: .repaid_amount)
            repaid_amount = Int(_repaid_amount ?? "0")
        }
    }
}

struct Moto_HomeRepayDataModel: Codable {
    
    var money: Int?
    var ins_num: Int?
    var back_time: Int?
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.money = try container.decodeIfPresent(Int.self, forKey: .money)
        
        if let _back_time = try? container.decode(Int.self, forKey: .back_time) {
            back_time = _back_time
        }else {
            let _back_time = try container.decode(String.self, forKey: .back_time)
            back_time = Int(_back_time) ?? 0
        }
        
        if let _ins_num = try? container.decode(Int.self, forKey: .ins_num) {
            ins_num = _ins_num
        }else {
            let _ins_num = try container.decode(String.self, forKey: .ins_num)
            ins_num = Int(_ins_num) ?? 0
        }
    }
}


struct Moto_HomeOldRepayDataModel: Codable {
    
    var id: String?
    var money: Int?
    var principal: String?
    var interest: Int?
    var back_time: String?
}
