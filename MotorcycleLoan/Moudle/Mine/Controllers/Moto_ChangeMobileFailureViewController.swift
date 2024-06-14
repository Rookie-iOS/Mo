//
//  Moto_ChangeMobileFailureViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class MO_ServiceOnlineModel: Codable {
    var fbu: String = ""
}

class Moto_ChangeMobileFailureViewController: Moto_ViewController {
    
    @IBOutlet weak var num1Text: UILabel!
    @IBOutlet weak var num2Text: UILabel!
    private var service: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadBackItem()
        guard let one = UserDefaults.standard.string(forKey: "service_one") else { return }
        guard let two = UserDefaults.standard.string(forKey: "service_two") else { return }
        
        num1Text.text = one
        num2Text.text = two
        
        loadOnlineService()
    }
    
    private func loadOnlineService() {
        
        Moto_Networking.request(path: Moto_Apis.Moto_api_online_service, method: .post) { [weak self] data in
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<MO_ServiceOnlineModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let link = model.data?.fbu else { return }
                service = link
            }
        }
    }
    
    @IBAction func mobileTapAction(_ sender: UITapGestureRecognizer) {
        
        guard let tag = sender.view?.tag else { return }
        switch tag {
        case 100:
            if service.isEmpty {
                loadOnlineService()
                return
            }else {
                let webvc = R.storyboard.main.moto_web()!
                webvc.loadUrlString(service)
                navigationController?.pushViewController(webvc, animated: true)
            }
            
        case 200:
            guard var no1 = UserDefaults.standard.string(forKey: "service_one") else { return }
            if no1.hasPrefix("0") {
                no1 = String(no1.suffix(no1.count - 1))
            }
            guard let url = URL(string: "tel:+63\(no1)") else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        case 300:
            guard var no2 = UserDefaults.standard.string(forKey: "service_two") else { return }
            if no2.hasPrefix("0") {
                no2 = String(no2.suffix(no2.count - 1))
            }
            guard let url = URL(string: "tel:+63\(no2)") else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
    
    @IBAction func okAction() {
        
        navigationController?.popToRootViewController(animated: true)
    }
}
