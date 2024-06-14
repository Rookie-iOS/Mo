//
//  Moto_SelectInputView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_SelectInputView: Moto_BaseView {
    
    @IBOutlet weak var more: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var inputBgView: UIView!
    @IBOutlet weak var inputText: UITextField!
    
    private var _model: Moto_SelectInputModel? = nil
    private var _tap:((Moto_SelectInputModel)->Void)? = nil
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        inputText.isEnabled = false
        
        inputBgView.layer.cornerRadius = 8
        inputBgView.layer.borderWidth = 0.5
        inputBgView.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tapGes)
    }
    
    @objc private func tapAction() {
        
        guard let tap = _tap else { return }
        guard let model = _model else { return }
        tap(model)
    }
    
    func bindData(_ model: Moto_SelectInputModel, _ tap:@escaping((_ model: Moto_SelectInputModel) -> Void)) {
        
        _tap = tap
        _model = model
        titleText.text = model.title
        more.isHidden = model.type == 1
        inputText.placeholder = model.type == 1 ? "Please fill in" : "Please select"
        
        if model.idx == 13 || model.idx == 14 || model.idx == 64 {
            inputText.keyboardType = .phonePad
        }
        
        if model.idx == 62 || model.idx == 63 {
            inputText.keyboardType = .numberPad
        }
        
        if !model.content.isEmpty {
            if inputText.isHidden {
                textLabel.text = model.content
            }else {
                inputText.text = model.content
            }
        }
        
        if let dataString = Moto_Utils.cacheData(2) {
            if let data = dataString.data(using: .utf8) {
                if let model = try? JSONDecoder().decode(Moto_IdentityCacheModel.self, from: data) {
                    switch model.type_id {
                    case "1":
                        // UMID
                        inputText.keyboardType = .numberPad
                    case "2":
                        // PASSPORT
                        inputText.keyboardType = .namePhonePad
                    case "3":
                        // DRIVINGLICENSE
                        inputText.keyboardType = .namePhonePad
                    case "4":
                        // SSS
                        inputText.keyboardType = .numberPad
                    case "13":
                        // PRC
                        inputText.keyboardType = .numberPad
                    case "22":
                        // POSTALTD
                        inputText.keyboardType = .namePhonePad
                    case "23":
                        // NATIONALTD
                        inputText.keyboardType = .numberPad
                    default:
                        break
                    }
                }
            }
        }
    }
}
