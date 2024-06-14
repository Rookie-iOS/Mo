//
//  Moto_MineViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/6/24.
//

import UIKit

class Moto_MineViewController: Moto_ViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 登录状态显示
        loadLoginStatus()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        topView.layer.cornerRadius = 10
        topView.layer.shadowOpacity = 0.5
        topView.layer.shadowOffset = CGSize(width: 2, height: 2)
        topView.layer.shadowColor = "#CCCCCC".hexColorString(0.5).cgColor
    }
    
    private func loadLoginStatus (){
        
        if let mobile = Moto_Utils.userInfo()?.phone {
            if mobile.isEmpty {
                loginBtn.setTitle("Login / Register", for: .normal)
            }else {
                let range = mobile.index(mobile.startIndex, offsetBy: 3) ..< mobile.index(mobile.endIndex, offsetBy: -4)
                let encry = mobile.replacingCharacters(in: range, with: "****")
                loginBtn.setTitle(encry, for: .normal)
            }
        }else {
            loginBtn.setTitle("Login / Register", for: .normal)
        }
    }
    
    @IBAction func loginAction() {
        
        if !(Moto_Utils.userInfo()?.token ?? "").isEmpty {
            return
        }
        let login = R.storyboard.register.moto_login()!
        login.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(login, animated: true)
    }
    
    @IBAction func mineTapAction(_ sender: UITapGestureRecognizer) {
        
        if Moto_Utils.userInfo()?.token == nil {
            loginAction()
            return
        }
        guard let tag = sender.view?.tag else { return }
        switch tag {
        case 100:
            let feedBack = R.storyboard.mine.moto_feed()!
            feedBack.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(feedBack, animated: true)
        case 200:
            let record = R.storyboard.mine.moto_loan_record()!
            record.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(record, animated: true)
        case 300:
            let webvc = R.storyboard.main.moto_web()!
            webvc.title = "Custom Service"
            webvc.loadUrlString(Moto_Apis.Moto_h5_help)
            webvc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webvc, animated: true)
        case 400:
            let webvc = R.storyboard.main.moto_web()!
            webvc.title = "Privacy Policy"
            webvc.loadUrlString(Moto_Apis.Moto_h5_privacy)
            webvc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webvc, animated: true)
        case 500:
            guard let setVC = R.storyboard.mine.moto_setup() else { return }
            setVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(setVC, animated: true)
        default:
            break
        }
    }
    
}
