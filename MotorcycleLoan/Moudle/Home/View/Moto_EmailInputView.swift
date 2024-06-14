//
//  Moto_EmailInputView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_EmailInputView: Moto_BaseView {
    
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
        if !model.content.isEmpty {
            inputText.text = model.content
        }
        inputText.placeholder = model.type == 1 ? "Please fill in" : "Please select"
    }
    
}
