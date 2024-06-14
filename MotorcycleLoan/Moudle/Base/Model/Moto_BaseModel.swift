//
//  Moto_BaseModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import Foundation

struct Moto_DataModel: Codable {}
struct Moto_BaseModel<T: Codable>: Codable {
    
    var code: Int?
        var error: String?
        var data: T?
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Moto_BaseModel<T>.CodingKeys> = try decoder.container(keyedBy: Moto_BaseModel<T>.CodingKeys.self)
            if let _code = try? container.decode(Int.self, forKey: Moto_BaseModel<T>.CodingKeys.code) {
                code = _code
            }else {
                let codeString = try container.decode(String.self, forKey: Moto_BaseModel<T>.CodingKeys.code)
                code = Int(codeString)
            }
            self.error = try container.decodeIfPresent(String.self, forKey: Moto_BaseModel<T>.CodingKeys.error)
            self.data = try container.decodeIfPresent(T.self, forKey: Moto_BaseModel<T>.CodingKeys.data)
        }
}
