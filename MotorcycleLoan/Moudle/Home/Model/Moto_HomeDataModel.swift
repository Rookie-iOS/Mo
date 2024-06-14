//
//  Moto_HomeDataModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import Foundation

struct Moto_HomeDataModel: Codable {
    
    var code: Int
    var service_one: String
    var service_two: String
    var data:[Moto_ProductModel]
    var auth_state: Moto_HomeAuthStatusModel?
    var carousel_text: [Moto_HomeMarqueeModel]
}

struct Moto_HomeMarqueeModel: Codable {
    
    var id: String
    var name: String
}

struct Moto_HomeAuthStatusModel: Codable {
    
    var state_one: Int?
    var state_two: Int?
}

struct Moto_ProductModel: Codable {
    
    var status: Int
    var id: String?
    var forbid_days: Int?
    // 0 old repay 1 six term
    var tadpole_loan: Int? = 0
    var min_money: String
    var max_money: String
    var interest: String
    var loan_term: String
    var loan_time: String
    var count_down: Int = 0
    var binding_cards_status: Int?
}
