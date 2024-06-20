//
//  Moto_SetPasswdViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit
import YYText
import WisdomHUD
import AppsFlyerLib

class Moto_SetPasswdViewController: Moto_ViewController {
    
    var mobile: String?
    var sms_code: String?
    
    @IBOutlet weak var passwdBg: UIView!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var passwdTF: UITextField!
    @IBOutlet weak var agreeTextLabel: YYLabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textFieldAddObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textFieldRemoveObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBackItem()
        title = "Register"
        passwdTF.keyboardType = .numberPad
        
        passwdBg.layer.cornerRadius = 8
        passwdBg.layer.borderWidth = 0.5
        passwdBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        let string = "I have read and agree to the《Privacy Polincy》"
        guard let range = string.range(of: "《Privacy Polincy》") else { return }
        let n_range = NSRange(range, in: string)
        
        let attribute = NSMutableAttributedString(string: string)
        attribute.yy_font = .systemFont(ofSize: 13)
        attribute.yy_color = "#333333".hexColorString()
        attribute.yy_setTextHighlight(n_range, color: "#25603D".hexColorString(), backgroundColor: nil) { [weak self] _, _, _, _ in
            guard let self = self else { return }
            tapAgreeText(1)
        }
        agreeTextLabel.numberOfLines = 0
        agreeTextLabel.attributedText = attribute
    }
    
    private func tapAgreeText(_ type: Int) {
        
        switch type {
        case 1:
            let webvc = R.storyboard.main.moto_web()!
            webvc.title = "Privacy Policy"
            webvc.loadUrlString(Moto_Apis.Moto_h5_privacy)
            webvc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webvc, animated: true)
        default:
            break
        }
    }
    
    private func textFieldAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldHasChanged(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func textFieldRemoveObserver() {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    @objc private func textFieldHasChanged(_ not: Notification) {
        
        guard let tf = not.object as? UITextField else { return }
        guard let text = tf.text else { return }
        if tf == passwdTF{
            if text.count >= 6 {
                passwdTF.text = String(text.prefix(6))
            }
        }
    }
    
    private func register() {
        
        guard let _mobile = mobile else { return }
        guard let passwd = passwdTF.text else { return }
        if !agreeBtn.isSelected {
            WisdomHUD.showTextCenter(text: "Please read and agree to the agreement").setFocusing()
        }
        if passwd.count != 6 {
            WisdomHUD.showTextCenter(text: "Please enter a 6-digit password").setFocusing()
            return
        }
        let params = [
            "moto_type": "2",
            "moto_phone": _mobile,
            "moto_password": passwd,
            "sms_code": sms_code ?? "",
            "moto_dev_id": Moto_Utils.uuid(),
            "moto_version": Moto_Utils.versionString(),
        ]
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_register, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                login(_mobile, passwd)
                AppsFlyerLib.shared().logEvent("mo_zhuce", withValues: nil)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func login(_ mobile: String, _ passwd: String) {
        
        let params: [String: Any] = [
            "moto_type": "2",
            "moto_phone": mobile,
            "moto_password": passwd,
            "dev_id": Moto_Utils.uuid(),
            "moto_ip": Moto_Utils.ip_address(),
            "dev_vender": UIDevice.current.model,
            "ver_sion": Moto_Utils.versionString(),
            "moto_id_root": UIDevice.isJailbreak() ? "1" : "0",
            "moto_risk_data": Moto_UploadRisk.riskModelString() ?? "",
            "system_version_code": UIDevice.current.systemVersion,
        ]
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_login, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_LoginModel>.self, from: jsonData) else { return }
            if model.code != 200 {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }else {
                guard let login = model.data else { return }
                guard let userData = try? NSKeyedArchiver.archivedData(withRootObject: login, requiringSecureCoding: true) else { return }
                UserDefaults.standard.set(userData, forKey: "UserInfo")
                navigationController?.popToRootViewController(animated: true)
                Moto_UploadRisk.uploadRKData(4)
            }
        }
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            sender.isSelected = !sender.isSelected
            passwdTF.isSecureTextEntry = !sender.isSelected
        case 200:
            sender.isSelected = !sender.isSelected
        case 300:
            if !agreeBtn.isSelected  {
                WisdomHUD.showTextCenter(text: "Please read and agree to the agreement").setFocusing()
                return
            }
            register()
        default:
            break
        }
    }
}
