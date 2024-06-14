//
//  Moto_LoginViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit
import WisdomHUD

class Moto_LoginViewController: Moto_ViewController {
    
    var fromChangeMobile = false
    @IBOutlet weak var codeBg: UIView!
    @IBOutlet weak var mobileBg: UIView!
    @IBOutlet weak var passwdBg: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var passwdTF: UITextField!
    @IBOutlet weak var verificationView: UIView!
    @IBOutlet weak var verificationViewHeight: NSLayoutConstraint!
    
    private var timer: DispatchSourceTimer!
    private var time = Moto_Const.sms_cut_time
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        
        // Do any additional setup after loading the view.
        
        loadUI()
    }
    
    private func textFieldAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldHasChanged(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func textFieldRemoveObserver() {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func loadUI() {
        
        loadBackItem()
        title = "Login"
        passwdTF.isSecureTextEntry = true
        navigationBarColor = "#25603D".hexColorString()
        
        mobileBg.layer.cornerRadius = 8
        mobileBg.layer.borderWidth = 0.5
        mobileBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        passwdBg.layer.cornerRadius = 8
        passwdBg.layer.borderWidth = 0.5
        passwdBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        codeBg.layer.cornerRadius = 8
        codeBg.layer.borderWidth = 0.5
        codeBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        codeTF.keyboardType = .numberPad
        mobileTF.keyboardType = .numberPad
        passwdTF.keyboardType = .numberPad
        
        loginBtn.isEnabled = false
        loginBtn.backgroundColor = "#D3DFD8".hexColorString()
    }
    
    private func showVerification(_ isShow: Bool = false) {
        
        verificationView.isHidden = !isShow
        verificationViewHeight.constant = isShow ? 102 : 0
    }
    
    override func backAction() {
        
        if fromChangeMobile {
            navigationController?.popToRootViewController(animated: true)
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func textFieldHasChanged(_ not: Notification) {
        
        guard let tf = not.object as? UITextField else { return }
        guard let text = tf.text else { return }
        if tf == mobileTF {
            if text.count >= 11 {
                mobileTF.text = String(text.prefix(11))
            }
            stopTimer()
            verificationView.isHidden = true
            verificationViewHeight.constant = 0
        }else {
            if text.count >= 6 {
                if verificationView.isHidden {
                    passwdTF.text = String(text.prefix(6))
                }else {
                    codeTF.text = String(text.prefix(6))
                }
            }
        }
        
        var verifyAccount = Moto_Utils.verifyMobile(mobileTF.text ?? "") && (passwdTF.text ?? "").count == 6
        if !verificationView.isHidden {
            verifyAccount = Moto_Utils.verifyMobile(mobileTF.text ?? "") && (passwdTF.text ?? "").count == 6 && (codeTF.text ?? "").count == 6
        }
        loginBtn.isEnabled = verifyAccount
        loginBtn.backgroundColor = verifyAccount ? "#25603D".hexColorString() : "#D3DFD8".hexColorString()
    }
    
    private func startTimer() {
        
        sendBtn.isEnabled = false
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if time == 0 {
                stopTimer()
            }else {
                sendBtn.setTitle("\(time) s", for: .normal)
                sendBtn.backgroundColor = "#D3DFD8".hexColorString()
                sendBtn.setTitleColor("#25603D".hexColorString(), for: .normal)
                time -= 1
            }
        }
        timer.resume()
    }
    
    private func stopTimer() {
        
        if timer == nil {
            return
        }
        timer.cancel()
        timer = nil
        sendBtn.isEnabled = true
        time = Moto_Const.sms_cut_time
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.setTitleColor(UIColor.white, for: .normal)
        sendBtn.backgroundColor = "#25603D".hexColorString()
    }
    
    private func checkLogin() {
        
        guard let mobile = mobileTF.text else { return }
        guard let passwd = passwdTF.text else { return }
        if !Moto_Utils.verifyMobile(mobile) {
            WisdomHUD.showTextCenter(text: "please enter a valid phone number").setFocusing()
            return
        }
        
        if passwd.count != 6 {
            WisdomHUD.showTextCenter(text: "Please enter a 6-digit password").setFocusing()
            return
        }
        
        let params = [
            "moto_phone": mobile,
            "moto_password": passwd,
            "moto_dev_id": Moto_Utils.uuid()
        ]
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_login_check, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<MO_LoginCheckModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let check = model.data else { return }
                // code_type: 0: need sms_code
                if check.code_type == 0 {
                    showVerification(true)
                }else {
                    login()
                }
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func login() {
        
        guard let mobile = mobileTF.text else { return }
        guard let passwd = passwdTF.text else { return }
        if !Moto_Utils.verifyMobile(mobile) {
            WisdomHUD.showTextCenter(text: "please enter a valid phone number").setFocusing()
            return
        }
        
        if passwd.count != 6 {
            WisdomHUD.showTextCenter(text: "Please enter a 6-digit password").setFocusing()
            return
        }
        
        let params = [
            "moto_type": "2",
            "moto_phone": mobile,
            "moto_password": passwd,
            "dev_id": Moto_Utils.uuid(),
            "sms_code": codeTF.text ?? "",
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
    
    private func sendSMS(_ mobile: String) {
        
        let params = ["moto_phone": mobile, "sms_type":"7"]
        Moto_Networking.request(path: Moto_Apis.Moto_api_register_sms, method: .post, params: params) { [weak self] data in
            guard let self = self else { WisdomHUD.dismiss(); return }
            guard let jsonData = data else { WisdomHUD.dismiss(); return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { WisdomHUD.dismiss(); return }
            WisdomHUD.dismiss()
            if model.code == 200 {
                startTimer()
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    @IBAction func eyeAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                passwdTF.isSecureTextEntry = !sender.isSelected
            }
        case 200:
            guard let mobile = mobileTF.text else { return }
            if !Moto_Utils.verifyMobile(mobile) {
                WisdomHUD.showTextCenter(text: "please enter a valid phone number").setFocusing()
                return
            }
            sendSMS(mobile)
        case 300:
            let forget = R.storyboard.register.moto_forget()!
            navigationController?.pushViewController(forget, animated: true)
            break
        case 400:
            view.endEditing(true)
            if !verificationView.isHidden {
                guard let code = codeTF.text else { return }
                if code.count != 6 {
                    WisdomHUD.showTextCenter(text: "Please enter a 6-digit verification code").setFocusing()
                    return
                }else {
                    login()
                }
            }else {
                checkLogin()
            }
        case 500:
            let register = R.storyboard.register.moto_register()!
            register.mobile = mobileTF.text
            navigationController?.pushViewController(register, animated: true)
            break
        default:
            break
        }
    }
}
