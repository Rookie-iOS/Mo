//
//  Moto_RepaymentMethodModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import Foundation

class Moto_RepaymentMethodModel: Codable {
    
    var title: String?
    var id: String?
    var list: [Moto_RepaymentMethodNoModel]?
    var selected: Bool? = false
}

class Moto_RepaymentMethodNoModel: Codable {
    var id: String?
    var pay_name: String?
    var payment_type: String?
    var pay_img: String?
    var payment_code: String?
    var selected: Bool? = false
}
