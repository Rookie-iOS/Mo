//
//  Moto_PreAuthViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_PreAuthViewController: Moto_ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Tips"
        loadBackItem()
    }
    
    
    // Continue Action
    @IBAction func continueAction() {
        
        guard let mobile = Moto_Utils.userInfo()?.phone else { return }
        UserDefaults.standard.setValue(true, forKey: "\(Moto_Const.show_pre_authentication_key)_\(mobile)")
        
        let list = R.storyboard.home.moto_auth_center()!
        navigationController?.pushViewController(list, animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
