//
//  Moto_UserAccountModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import Foundation

struct Moto_UserAccountModel: Codable {
    
    // common
    var is_default: String?
    var id: String?
    // ewallet
    var wa_id: String?
    var account_number: String?
    var title: String?
    // bank
    var name: String?
    var bank_number: String?
}
