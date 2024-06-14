//
//  Moto_DeleteAccountViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit
import WisdomHUD

class Moto_DeleteAccountViewController: Moto_ViewController {
    
    @IBOutlet weak var tipsText: UILabel!
    @IBOutlet weak var tipsBgView: UIView!
    @IBOutlet weak var mobileText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadBackItem()
        title = "Delete Account"
        loadService(R.image.mo_new_service_icon())
        
        mobileText.text = "+63 \(Moto_Utils.userInfo()?.phone ?? "")"
        tipsBgView.layer.cornerRadius = 10
        tipsBgView.layer.shadowOpacity = 0.8
        tipsBgView.layer.shadowOffset = CGSize(width: 2, height: 2)
        tipsBgView.layer.shadowColor = "#CCCCCC".hexColorString().cgColor
        
        tipsText.text = "1、No outstanding orders and services in the account\n2.The account is currently a valid and unfrozen account.\n3、Identity and account information will be cleared and cannot be recovered\n4、Transaction history will be erased and cannot be recovered"
    }
    
    private func requestDel(_ passwd: String) {
        
        WisdomHUD.showLoading(text: "")
        let params = ["moto_password": passwd]
        Moto_Networking.request(path: Moto_Apis.Moto_api_delete_account, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 || model.code == 201 {
                Moto_Utils.logout()
                let changeMobile = R.storyboard.mine.moto_change_mobile_success()!
                changeMobile.operateType = .DeteteAccount
                navigationController?.pushViewController(changeMobile, animated: true)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
                let failure = R.storyboard.mine.mo_change_mobile_failure()!
                self.navigationController?.pushViewController(failure, animated: true)
            }
        }
    }
    
    private func showInputPasswd() {
        guard let inputTextView = R.nib.moto_InputPassWordView.firstView(withOwner: nil) else { return }
        inputTextView.show { [weak self] passwd in
            guard let self = self else { return }
            requestDel(passwd)
        }
    }
    
    @IBAction func deleteAction() {
        
        guard let popView = R.nib.moto_CancelPopView.firstView(withOwner: nil) else { return }
        popView.frame = UIScreen.main.bounds
        popView.tipsText.textColor = .black
        popView.tipsText.textAlignment = .left
        popView.icon.image = R.image.mo_pop_secure()!
        popView.titleText.text = "Are you sure to delete the account?"
        popView.showText("After the account is canceled, all user data cannot be restored, please operate with caution.") { [weak self] in
            guard let self = self else { return }
            showInputPasswd()
        }
    }
}
