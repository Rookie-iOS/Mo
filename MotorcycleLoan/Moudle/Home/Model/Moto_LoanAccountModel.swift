//
//  Moto_LoanAccountModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import Foundation

struct Moto_LoanAccountModel: Codable {
    
    var account_no: String?
    var bank_name: String?
    var wcid: String?
    var type: Int?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bank_name = try container.decodeIfPresent(String.self, forKey: .bank_name)
        
        if let _account_no = try? container.decodeIfPresent(Int.self, forKey: .account_no) {
            account_no = "\(_account_no)"
        }else {
            let _account_no = try container.decodeIfPresent(String.self, forKey: .account_no)
            account_no = _account_no
        }
        
        if let _wcid = try? container.decodeIfPresent(Int.self, forKey: .wcid) {
            wcid = "\(_wcid)"
        }else {
            let _wcid = try container.decodeIfPresent(String.self, forKey: .wcid)
            wcid = _wcid
        }
        
        if let _type = try? container.decodeIfPresent(String.self, forKey: .type) {
            type = Int(_type)
        }else {
            let _type = try container.decodeIfPresent(Int.self, forKey: .type)
            type = _type
        }
    }
}
