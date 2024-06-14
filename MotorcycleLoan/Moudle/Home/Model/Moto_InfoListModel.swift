//
//  Moto_InfoListModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import Foundation

struct Moto_InfoListModel: Codable {
    
    var useredu:[Moto_InfoItemModel]?
    var merry:[Moto_InfoItemModel]?
    var kids:[Moto_InfoItemModel]?
    var working:[Moto_InfoItemModel]?
    var sal:[Moto_InfoItemModel]?
    var religion:[Moto_InfoItemModel]?
    var branch:[Moto_BranchInfoItemModel]?
    var getLivebelong:[Moto_InfoItemModel]?
    var idtype:[Moto_InfoItemModel]?
    var purpose:[Moto_InfoItemModel]?
    var rel:Moto_RelationInfoItemModel?
}

struct Moto_InfoItemModel: Codable {
    
    var id: String = ""
    var title: String = ""
}

struct Moto_BranchInfoItemModel: Codable {
    
    var type = "0"
    var id: String = ""
    var title: String = ""
}

struct Moto_RelationInfoItemModel: Codable {
    
    var t1: [String]?
    var t2: [String]?
    var t3: [String]?
}
