//
//  Moto_ReLoanPopView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit
import WisdomHUD

class Moto_ReLoanPopView: Moto_BaseView {
    
    @IBOutlet weak var bgView: Moto_CornerRaduisView!
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var termText: UILabel!
    @IBOutlet weak var accountNameText: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountNoText: UILabel!
    @IBOutlet weak var accountNo: UILabel!
    @IBOutlet weak var passwordBg: UIView!
    @IBOutlet weak var passwdTF: UITextField!
    
    private var isSecureTextEntry = true
    private var _confirm:((Int, String) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.radius = 6
        passwdTF.keyboardType = .numberPad
        passwordBg.layer.cornerRadius = 8
        passwordBg.layer.borderWidth = 0.5
        passwordBg.layer.borderColor = "#cccccc".hexColorString().cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(passwdInput), name: UITextField.textDidChangeNotification, object: nil)
        
        let ctl = UIControl(frame: bgView.bounds)
        ctl.addTarget(self, action: #selector(bgViewClick), for: .touchUpInside)
        bgView.addSubview(ctl)
        bgView.sendSubviewToBack(ctl)
    }
    
    @objc private func bgViewClick() {
        passwdTF.resignFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.drawRadiusWithDashLine(at: 213, "#E6E6E6".hexColorString())
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    @objc private func passwdInput() {
        
        guard let text = passwdTF.text else { return }
        if text.count >= 6 {
            passwdTF.text = String(text.prefix(6))
        }
    }
    
    @IBAction func btnsClick(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            passwdTF.isSecureTextEntry = !isSecureTextEntry
            sender.isSelected = isSecureTextEntry
            isSecureTextEntry = !isSecureTextEntry
        case 200, 300, 400:
            if sender.tag == 300 {
                removeFromSuperview()
                return
            }
            guard let click = _confirm else { return }
            if sender.tag == 400 {
                guard let passwd = passwdTF.text else { return }
                if passwd.isEmpty {
                    WisdomHUD.showTextCenter(text: "Please enter a 6-digit password").setFocusing()
                    return
                }
                removeFromSuperview()
                click(sender.tag, passwd)
            }else {
                removeFromSuperview()
                click(sender.tag, "")
            }
        default:
            break
        }
    }
    
    func show(_ loadType: Int, _ account: Moto_LoanAccountModel, _ loanMoney: Moto_LoanDetailModel, _ confirm:@escaping((_ tag: Int, _ passwd: String)-> Void)) {
        
        guard let window = Moto_Utils.keyWindow else { return }
        frame = window.bounds
        window.addSubview(self)
        _confirm = confirm
        amountText.text = "PHP \(Moto_Utils.formatMoney(loanMoney.loan_amount ?? 0))"
        termText.text = "90days"
        
        accountName.text = account.bank_name
        accountNameText.text = loadType == 2 ? "E-Wallet" : "Bank Name"
        accountNoText.text = loadType == 2 ? "E-Wallet Account No." : "Bank Account No."
        
        guard let accountNum = account.account_no else { return }
        accountNo.text = accountNum
    }
}
