//
//  Moto_ForgetViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit
import WisdomHUD

class Moto_ForgetViewController: Moto_ViewController {
    
    var fromLoanPage = false
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var mobileBg: UIView!
    @IBOutlet weak var mobileInput: UITextField!
    @IBOutlet weak var verificationBg: UIView!
    @IBOutlet weak var verificationInput: UITextField!
    @IBOutlet weak var passwdBg: UIView!
    @IBOutlet weak var eyeBtn: UIButton!
    @IBOutlet weak var passwdInput: UITextField!
    
    private var timer: DispatchSourceTimer!
    private var time = Moto_Const.sms_cut_time
    
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
    
    private func loadUI() {
        
        loadBackItem()
        title = "Forget Password"
        mobileBg.layer.cornerRadius = 8
        mobileBg.layer.borderWidth = 0.5
        mobileBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        verificationBg.layer.cornerRadius = 8
        verificationBg.layer.borderWidth = 0.5
        verificationBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        passwdBg.layer.cornerRadius = 8
        passwdBg.layer.borderWidth = 0.5
        passwdBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        mobileInput.keyboardType = .numberPad
        passwdInput.keyboardType = .numberPad
        verificationInput.keyboardType = .numberPad
        
        if !fromLoanPage {
            mobileInput.isEnabled = true
        }
        mobileInput.text = Moto_Utils.userInfo()?.phone ?? ""
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
        if tf == mobileInput {
            if text.count >= 11 {
                mobileInput.text = String(text.prefix(11))
            }
            stopTimer()
        }else if(tf == verificationInput) {
            if text.count >= 6 {
                verificationInput.text = String(text.prefix(6))
            }
        }else {
            if text.count >= 6 {
                passwdInput.text = String(text.prefix(6))
            }
        }
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
    
    private func sendSMS(_ mobile: String) {
        let params = ["moto_phone": mobile, "sms_type":"2"]
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
    
    private func checkSms(_ mobile: String, _ code: String, _ passwd: String) {
        let params: [String: Any] = [
            "sms_code": code,
            "moto_phone": mobile
        ]
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_check_mobile, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                savePassWord(mobile, code, passwd)
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
            "system_version_code": UIDevice.current.systemVersion,
            "moto_risk_data": Moto_UploadRisk.riskModelString() ?? ""
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
    
    private func savePassWord(_ mobile: String, _ code: String, _ passwd: String) {
        let params: [String: Any] = [
            "sms_code": code,
            "moto_phone": mobile,
            "moto_password": passwd,
            "moto_new_password": passwd
        ]
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_forget_password, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                if fromLoanPage {
                    backToViewController(Moto_LoanViewController.self)
                }else {
                    Moto_Utils.logout()
                    login(mobile, passwd)
                }
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    @IBAction func forgetBtnsClick(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            guard let mobile = mobileInput.text else { return }
            if !Moto_Utils.verifyMobile(mobile) {
                WisdomHUD.showTextCenter(text: "please enter a valid phone number").setFocusing()
                return
            }
            sendSMS(mobile)
        case 200:
            eyeBtn.isSelected = !eyeBtn.isSelected
            passwdInput.isSecureTextEntry = !sender.isSelected
        case 300:
            guard let mobile = mobileInput.text else { return }
            if !Moto_Utils.verifyMobile(mobile) {
                WisdomHUD.showTextCenter(text: "please enter a valid phone number").setFocusing()
                return
            }
            guard let code = verificationInput.text else { return }
            if code.count != 6 {
                WisdomHUD.showTextCenter(text: "Please enter a 6-digit verification code").setFocusing()
                return
            }
            
            guard let passwd = passwdInput.text else { return }
            if code.count != 6 {
                WisdomHUD.showTextCenter(text: "Please enter a 6-digit password").setFocusing()
                return
            }
            checkSms(mobile, code, passwd)
            
        default:
            break
        }
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
