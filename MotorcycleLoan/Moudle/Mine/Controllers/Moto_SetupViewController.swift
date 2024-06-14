//
//  Moto_SetupViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class Moto_SetupViewController: Moto_ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadBackItem()
        title = "Set Up"
    }
    
    @IBAction func setviewTapAction(_ sender: UITapGestureRecognizer) {
        
        guard let tag = sender.view?.tag else { return }
        switch tag {
        case 100:
            let changeMobile = R.storyboard.mine.moto_change_mobile()!
            navigationController?.pushViewController(changeMobile, animated: true)
        case 200:
            let about = R.storyboard.mine.moto_about()!
            navigationController?.pushViewController(about, animated: true)
        case 300:
            let delete = R.storyboard.mine.moto_delete()!
            navigationController?.pushViewController(delete, animated: true)
        default:
            break
        }
    }
    
    @IBAction func logoutAction() {
        
        Moto_Utils.logout()
        navigationController?.popViewController(animated: true)
    }
}
