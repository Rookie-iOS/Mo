//
//  Moto_RegisterViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit
import WisdomHUD

class Moto_RegisterViewController: Moto_ViewController {
    
    var mobile: String?
    @IBOutlet weak var mobileBg: UIView!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var verificationBg: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tipsText: UILabel!
    private var time = Moto_Const.sms_cut_time
    private var timer: DispatchSourceTimer!
    
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
        
        loadBackItem()
        title = "Register"
        
        codeTF.keyboardType = .numberPad
        mobileTF.keyboardType = .numberPad
        
        mobileBg.layer.cornerRadius = 8
        mobileBg.layer.borderWidth = 0.5
        mobileBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        verificationBg.layer.cornerRadius = 8
        verificationBg.layer.borderWidth = 0.5
        verificationBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        let money = Moto_Utils.formatMoney(UserDefaults.standard.integer(forKey: Moto_Const.home_max_moeny_key))
        tipsText.text = "Enter your phone number now and enjoy a maximum loan limit of PHP\(money)"
        
        guard let _mobile = mobile else { return }
        mobileTF.text = _mobile
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
        if tf == mobileTF {
            if text.count >= 11 {
                mobileTF.text = String(text.prefix(11))
            }
            // stop timer
            stopTimer()
        }else {
            if text.count >= 6 {
                codeTF.text = String(text.prefix(6))
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
    
    private func checkMobile() {
        
        guard let mobile = mobileTF.text else { return }
        if !Moto_Utils.verifyMobile(mobile) {
            WisdomHUD.showTextCenter(text: "please enter a valid phone number").setFocusing()
            return
        }
        WisdomHUD.showLoading(text: "")
        let params = ["moto_phone": mobile]
        Moto_Networking.request(path: Moto_Apis.Moto_api_register_check, params: params) { [weak self] data in
            guard let self = self else { WisdomHUD.dismiss(); return }
            guard let jsonData = data else { WisdomHUD.dismiss(); return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { WisdomHUD.dismiss(); return }
            if model.code == 201 {
                sendSMS(mobile)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func sendSMS(_ mobile: String) {
        
        let params = ["moto_phone": mobile, "sms_type":"1"]
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
    
    private func checkSmsCode() {
        
        guard let code = codeTF.text else { return }
        guard let mobile = mobileTF.text else { return }
        if !Moto_Utils.verifyMobile(mobile) {
            WisdomHUD.showTextCenter(text: "please enter a valid phone number").setFocusing()
            return
        }
        
        if code.count != 6 {
            WisdomHUD.showTextCenter(text: "Please enter verification code").setFocusing()
            return
        }
        
        WisdomHUD.showLoading(text: "")
        let params = ["sms_code": code, "moto_phone": mobile]
        Moto_Networking.request(path: Moto_Apis.Moto_api_check_register_code, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                let passwd = R.storyboard.register.moto_set_passwd()!
                passwd.sms_code = code
                passwd.mobile = mobile
                navigationController?.pushViewController(passwd, animated: true)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    @IBAction func registerBtnsAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            checkMobile()
        case 200:
            checkSmsCode()
        case 300:
            navigationController?.popViewController(animated: true)
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
