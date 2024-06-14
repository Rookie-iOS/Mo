//
//  Moto_Networking.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import Alamofire
import SwiftyRSA
import WisdomHUD
import Foundation
import DYFCryptoUtils


struct Moto_Networking {
    
    static var host: String {
        return "https://api.motorcyclesloan.com"
    }
    
    static private var mo_publicKey: String {
        return "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7haXSHgX12jWFylF37T1oDQ2k9dOh8NEY1Ozr4VuMhECMRpwBwJPp8OfHX8geVfy56EAYkTLZtLFERY+nCrQ7KmFRLiduI2TH/voJkFIhL3WzsthvRedn23UZ15B4NsoTHJGYGwWgNqOaMI93VYZ7KxJK5sgt6PtC14zFWyN54wIDAQAB"
    }
    
    static private func generateKey() -> String? {
        
        guard let _publicKey = try? PublicKey(pemEncoded: mo_publicKey) else { return nil }
        let clear = try? ClearMessage(string: Moto_Utils.uuid(), using: .utf8)
        guard let encrypted = try? clear?.encrypted(with: _publicKey, padding: .PKCS1) else { return nil }
        let keyString = encrypted.base64String
        guard let data = keyString.data(using: .utf8) else { return nil }
        return data.base64EncodedString()
    }
    
    static private func encryptionParams(_ encrypt: Bool, _ params: Parameters?) -> Parameters? {
        
        guard let key = generateKey() else { return nil }
        var defaultParams: [String: Any] = ["key": key]
        if Moto_Utils.userInfo()?.token != nil {
            defaultParams["token"] = Moto_Utils.userInfo()?.token ?? ""
        }
        ["pkid": "5"].forEach { (key: String, value: Any) in
            if !encrypt {
                defaultParams[key] = "\(value)"
            }else {
                let encryValue = Moto_Utils.aes("\(value)", Moto_Utils.uuid())
                defaultParams[key] = DYFCryptoUtils.base64EncodedString(encryValue)
            }
        }
        guard let _params = params else { return defaultParams }
        _params.forEach { (key: String, value: Any) in
            if !encrypt {
                defaultParams[key] = "\(value)"
            }else {
                let encryValue = Moto_Utils.aes("\(value)", Moto_Utils.uuid())
                defaultParams[key] = DYFCryptoUtils.base64EncodedString(encryValue)
            }
        }
        return defaultParams
    }
    
    static func request(path: String, method: HTTPMethod = .get, encrypt: Bool = true, params: Parameters? = nil, result: @escaping((Data?) -> Void)) {
        
        var base = path
        if !path.hasPrefix(host) {
            base = host + path
        }
        guard let url = URL(string: base) else { return }
        AF.request(url, method: method, parameters: encryptionParams(encrypt, params)){
            $0.timeoutInterval = 30
        }.response {
            switch $0.result {
            case .success(let success):
                guard let data = success else {
                    result(success)
                    return
                }
                guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: data)  else {
                    result(success)
                    return
                }
                
                if [101, 103, 1003, 2001, 2003].contains(model.code) {
                    Moto_Utils.logout()
                    Moto_Utils.goHome()
                }
                result(success)
            case .failure(let failure):
                if (failure.underlyingError != nil) {
                    switch failure {
                    case .sessionTaskFailed(let err):
                        let e = err as NSError
                        if(e.code == -1001) {
                            WisdomHUD.showTextCenter(text: "The server connection timed out, please try again later").setFocusing()
                        }else {
                            WisdomHUD.showTextCenter(text: "Network connection failed, please switch network and try again").setFocusing()
                        }
                    default:
                        WisdomHUD.showTextCenter(text: "Network connection failed, please switch network and try again").setFocusing()
                    }
                }else {
                    WisdomHUD.showTextCenter(text: "Network connection failed, please switch network and try again").setFocusing()
                }
            }
        }
    }
}
