//
//  Moto_ChangeMobileViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit
import WisdomHUD

class Moto_ChangeMobileViewController: Moto_ViewController {
    
    var oldPage = true
    @IBOutlet weak var codeBg: UIView!
    @IBOutlet weak var mobileBg: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    
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
        
        loadBackItem()
        title = "Change phone number"
        
        mobileTF.keyboardType = .numberPad
        mobileBg.layer.cornerRadius = 8
        mobileBg.layer.borderWidth = 0.5
        mobileBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        codeTF.keyboardType = .numberPad
        codeBg.layer.cornerRadius = 8
        codeBg.layer.borderWidth = 0.5
        codeBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        
        mobileTF.isEnabled = true
        if oldPage {
            mobileTF.isEnabled = false
            mobileTF.text = Moto_Utils.userInfo()?.phone
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
        if tf == mobileTF {
            if oldPage {
                return
            }
            if text.count >= 11 {
                mobileTF.text = String(text.prefix(11))
            }
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
    
    private func sendSMS(_ type: Int, _ mobile: String) {
        let params: [String: Any] = [
            "sms_type": type,
            "moto_phone": mobile
        ]
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_register_sms, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                startTimer()
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func checkSms() {
        guard let code = codeTF.text else { return }
        let params: [String: Any] = [
            "sms_code": code,
            "moto_phone": Moto_Utils.userInfo()?.phone ?? ""
        ]
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_check_mobile, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                let changeMobile = R.storyboard.mine.moto_change_mobile()!
                changeMobile.oldPage = false
                navigationController?.pushViewController(changeMobile, animated: true)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func changeSubmit() {
        
        guard let code = codeTF.text else { return }
        guard let mobile = mobileTF.text else { return }
        let params = [
            "moto_phone": mobile,
            "moto_sms_code": code
        ]
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_save_change_mobile, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                Moto_Utils.logout()
                let success = R.storyboard.mine.moto_change_mobile_success()!
                navigationController?.pushViewController(success, animated: true)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    @IBAction func btnsClick(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            if oldPage {
                guard let mobile = Moto_Utils.userInfo()?.phone else { return }
                sendSMS(3, mobile)
            }else {
                guard let mobile = mobileTF.text else { return }
                if !Moto_Utils.verifyMobile(mobile) {
                    WisdomHUD.showTextCenter(text: "please enter a valid phone number").setFocusing()
                    return
                }
                sendSMS(4, mobile)
            }
        case 200:
            if oldPage {
                guard let code = codeTF.text else { return }
                if code.isEmpty {
                    WisdomHUD.showTextCenter(text: "please enter 6-bit code").setFocusing()
                    return
                }
                checkSms()
            }else {
                guard let code = codeTF.text else { return }
                guard let mobile = mobileTF.text else { return }
                if !Moto_Utils.verifyMobile(mobile) {
                    WisdomHUD.showTextCenter(text: "please enter a valid phone number").setFocusing()
                    return
                }
                if code.isEmpty {
                    WisdomHUD.showTextCenter(text: "please enter 6-bit code").setFocusing()
                    return
                }
                changeSubmit()
            }
        default:
            break
        }
    }
    
}
