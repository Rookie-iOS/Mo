//
//  Moto_InputPassWordView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class Moto_InputPassWordView: Moto_BaseView {
    
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var codeTextBgView: UIView!
    private var _action:((String)->Void)? = nil
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        codeTF.keyboardType = .numberPad
        codeTextBgView.layer.borderWidth = 1
        codeTextBgView.layer.cornerRadius = 8
        codeTextBgView.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldHasChanged(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    deinit {
        print("set free: \(self)")
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    @objc private func textFieldHasChanged(_ not: Notification) {
        guard let tf = not.object as? UITextField else { return }
        guard let text = tf.text else { return }
        if text.count >= 6 {
            codeTF.text = String(text.prefix(6))
            codeTF.resignFirstResponder()
        }
    }
    
    @IBAction func btnsClick(_ sender: UIButton) {
        
        if sender.tag == 200 {
            guard let passwd = codeTF.text else { return }
            guard let click = _action else { return }
            if passwd.isEmpty {
                return
            }
            click(passwd)
        }
        removeFromSuperview()
    }
    
    func show(_ click:@escaping((_ passwd: String)->Void)) {
        
        _action = click
        guard let keyWindow = Moto_Utils.keyWindow else { return }
        keyWindow.addSubview(self)
    }
    
}
