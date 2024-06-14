//
//  Moto_ChangeMobileSuccessViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class Moto_ChangeMobileSuccessViewController: Moto_ViewController {
    
    @IBOutlet weak var operateBtn: UIButton!
    @IBOutlet weak var loginTipsView: UIView!
    @IBOutlet weak var btnTopHeight: NSLayoutConstraint!
    enum MO_OperateAccountType {
        case ChangeMobile
        case DeteteAccount
    }
    
    var operateType: MO_OperateAccountType = .ChangeMobile
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadBackItem()
        switch operateType {
        case .ChangeMobile:
            btnTopHeight.constant = 130
            loginTipsView.isHidden = false
            operateBtn.setTitle("Login", for: .normal)
        case .DeteteAccount:
            btnTopHeight.constant = 52
            loginTipsView.isHidden = true
            operateBtn.setTitle("OK", for: .normal)
        }
    }
    
    override func backAction() {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func loginAction() {
        
        switch operateType {
        case .ChangeMobile:
            let login = R.storyboard.register.moto_login()!
            login.fromChangeMobile = true
            navigationController?.pushViewController(login, animated: true)
        case .DeteteAccount:
            backAction()
        }
    }
}
