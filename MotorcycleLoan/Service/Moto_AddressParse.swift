//
//  Moto_AddressParse.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import Foundation

class Moto_Barangay {
    var name = ""
    var selected = false
}

class Moto_City {
    
    var name = ""
    var selected = false
    var barangaies = [[Moto_Barangay]]()
}

class Moto_Provice {
    
    var name = ""
    var selected = false
    var cities = [[Moto_City]]()
}


struct Moto_AddressParse {
 
    private static func parse(_ address: String) -> [[Moto_Provice]]? {
            guard let data = address.data(using: .utf8) else { return nil }
            do {
                guard let root: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return nil }
                guard let p_dict: [String: Any] = root["data"] as? [String: Any]  else { return nil }
                
                var p_pre_key = ""
                var provicies = [[Moto_Provice]]()
                let p_keys = p_dict.keys.sorted { $0 < $1 }
                var _p_dict = [String: [Moto_Provice]]()
                for p_index in 0 ..< p_keys.count {
                    let provice = Moto_Provice()
                    provice.name = p_keys[p_index]
                    if p_pre_key != String(provice.name.prefix(1)) {
                        p_pre_key = String(provice.name.prefix(1))
                        let p_list = [Moto_Provice]()
                        _p_dict[p_pre_key] = p_list
                    }
                    guard var p_list = _p_dict[p_pre_key] else { return nil }
                    p_list.append(provice)
                    _p_dict[p_pre_key] = p_list
                    guard let c_dict: [String: Any] = p_dict[provice.name] as? [String: Any]  else { return nil }
                    var c_pre_key = ""
                    var cities = [[Moto_City]]()
                    let c_keys = c_dict.keys.sorted { $0 < $1 }
                    var _c_dict = [String: [Moto_City]]()
                    for c_index in 0 ..< c_keys.count {
                        let city = Moto_City()
                        city.name = c_keys[c_index]
                        if c_pre_key != String(city.name.prefix(1)) {
                            c_pre_key = String(city.name.prefix(1))
                            let c_list = [Moto_City]()
                            _c_dict[c_pre_key] = c_list
                        }
                        guard var c_list = _c_dict[c_pre_key] else { return nil }
                        c_list.append(city)
                        _c_dict[c_pre_key] = c_list
                        guard let s_dict: [String: Any] = c_dict[city.name] as? [String: Any]  else { return nil }
                        var s_pre_key = ""
                        var barangaies = [[Moto_Barangay]]()
                        let s_keys = s_dict.keys.sorted { $0 < $1 }
                        var _s_dict = [String: [Moto_Barangay]]()
                        for s_index in 0 ..< s_keys.count {
                            let barangay = Moto_Barangay()
                            barangay.name = s_keys[s_index]
                            if s_pre_key != String(barangay.name.prefix(1)) {
                                s_pre_key = String(barangay.name.prefix(1))
                                let s_list = [Moto_Barangay]()
                                _s_dict[s_pre_key] = s_list
                            }
                            guard var s_list = _s_dict[s_pre_key] else { return nil }
                            s_list.append(barangay)
                            _s_dict[s_pre_key] = s_list
                        }
                        
                        let _s_keys = _s_dict.keys.sorted { $0 < $1 }
                        for key in _s_keys {
                            guard let list =  _s_dict[key] else { return nil }
                            barangaies.append(list)
                        }
                        city.barangaies.append(contentsOf: barangaies)
                    }
                    let _c_keys = _c_dict.keys.sorted { $0 < $1 }
                    for key in _c_keys {
                        guard let list =  _c_dict[key] else { return nil }
                        cities.append(list)
                    }
                    provice.cities.append(contentsOf: cities)
                }
                let _p_keys = _p_dict.keys.sorted { $0 < $1 }
                for key in _p_keys {
                    guard let list =  _p_dict[key] else { return nil }
                    provicies.append(list)
                }
                return provicies
            } catch {
                print(error)
                return nil
            }
        }
        
        private static func readAddressFile() -> String {
            guard let path = Bundle.main.path(forResource: "mo_address_data", ofType: nil) else { return "" }
            guard let addressString = try? String(contentsOfFile: path) else { return "" }
            return addressString
        }
        
        static func parseAddress(_ completion:@escaping([[Moto_Provice]]) -> Void) {
            DispatchQueue.global().async {
                let addressString = readAddressFile()
                guard let proviciesList = parse(addressString) else { return }
                DispatchQueue.main.async {
                    completion(proviciesList)
                }
            }
        }
}
