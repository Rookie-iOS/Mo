//
//  Moto_SelectInfoModel.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import Foundation

struct Moto_SelectInfoModel {
    var title: String = ""
    var list = [Moto_SelectInfoItemModel]()
}

class Moto_SelectInfoItemModel {
    var info_id = ""
    var info_type = ""
    var info_title = ""
    var info_select = false
}
