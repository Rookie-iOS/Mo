//
//  Moto_LoanSmsCodeView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD

class Moto_LoanSmsCodeView: Moto_BaseView {
    
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var mobileBg: UIView!
    @IBOutlet weak var codeBg: UIView!
    @IBOutlet weak var bgView: UIView!
    private var _click:((String) -> Void)? = nil
    private var timer: DispatchSourceTimer!
    private var time = Moto_Const.sms_cut_time
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sendSMS()
        codeTF.keyboardType = .numberPad
        phoneTf.text = Moto_Utils.userInfo()?.phone ?? ""
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldHasChanged(_:)), name: UITextField.textDidChangeNotification, object: nil)
        
        let ctl = UIControl(frame: bounds)
        ctl.addTarget(self, action: #selector(bgViewClick), for: .touchUpInside)
        bgView.addSubview(ctl)
        bgView.sendSubviewToBack(ctl)
        
        mobileBg.layer.cornerRadius = 8
        mobileBg.layer.borderWidth = 0.5
        mobileBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        codeBg.layer.cornerRadius = 8
        codeBg.layer.borderWidth = 0.5
        codeBg.layer.borderColor = "#CCCCCC".hexColorString().cgColor
    }
    
    @objc private func bgViewClick() {
        
        codeTF.resignFirstResponder()
    }
    
    deinit {
        stopTimer()
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    @objc private func textFieldHasChanged(_ not: Notification) {
        guard let tf = not.object as? UITextField else { return }
        guard let text = tf.text else { return }
        if tf == codeTF {
            if text.count >= 6 {
                codeTF.text = String(text.prefix(6))
            }
        }
    }
    
    @IBAction func btnsClick(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            sendSMS()
        case 200:
            guard let click = _click else { return }
            guard let code = codeTF.text else { return }
            if code.count != 6 {
                return
            }
            removeFromSuperview()
            click(code)
        default:
            break
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
    
    private func sendSMS(){
        
        guard let mobile = Moto_Utils.userInfo()?.phone else { return }
        let params = ["moto_phone": mobile, "sms_type":"6"]
        Moto_Networking.request(path: Moto_Apis.Moto_api_register_sms, method: .post, params: params) { [weak self] data in
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
    
    func show(_ click:@escaping((_ code: String) -> Void)) {
        
        guard let window = Moto_Utils.keyWindow else { return }
        frame = window.bounds
        window.addSubview(self)
        _click = click
    }
}
