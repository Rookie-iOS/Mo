//
//  Moto_LoginModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import Foundation

class Moto_LoginModel: NSObject, Codable, NSSecureCoding {
    
    var token: String?
    var phone: String?
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with coder: NSCoder) {
        
        coder.encode(self.token, forKey: "token")
        coder.encode(self.phone, forKey: "phone")
    }
    
    required init?(coder: NSCoder) {
        
        super.init()
        self.token = coder.decodeObject(forKey: "token") as? String
        self.phone = coder.decodeObject(forKey: "phone") as? String
    }
}
