//
//  Moto_LoanDetailModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import Foundation

struct Moto_LoanDetailModel: Codable {
    
    var loan_amount: Int?
    var issued_amount: Int?
    var service_fee: Int?
    var credit_price: Int?
    var manage_price: Int?
    var tech_price: Int?
    var interest: Int?
    var repay_data: [Moto_LoanRepayDatModel]?
}

struct Moto_LoanRepayDatModel: Codable {
    
    var back_time: String?
    var repay_price: Int?
    var install: Int?
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.back_time = try container.decodeIfPresent(String.self, forKey: .back_time)
        self.repay_price = try container.decodeIfPresent(Int.self, forKey: .repay_price)
        if let _install = try? container.decodeIfPresent(Int.self, forKey: .install) {
            install = _install
        }else {
            let _install = try container.decodeIfPresent(String.self, forKey: .install)
            install = Int(_install ?? "")
        }
    }
}
