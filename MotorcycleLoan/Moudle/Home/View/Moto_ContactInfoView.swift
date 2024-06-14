//
//  Moto_ContactInfoView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_ContactInfoView: Moto_BaseView {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var relationView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mobileText: UITextField!
    @IBOutlet weak var relationText: UITextField!
    var tapAction:((_ tag: Int) -> Void)? = nil
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        bgView.layer.borderWidth = 1
        bgView.layer.cornerRadius = 10
        bgView.layer.borderColor = "#CCCCCC".hexColorString(0.5).cgColor
        
        let tapGes1 = UITapGestureRecognizer(target: self, action: #selector(viewTapAction(_:)))
        let tapGes2 = UITapGestureRecognizer(target: self, action: #selector(viewTapAction(_:)))
        let tapGes3 = UITapGestureRecognizer(target: self, action: #selector(viewTapAction(_:)))
        
        relationView.addGestureRecognizer(tapGes1)
        nameView.addGestureRecognizer(tapGes2)
        phoneView.addGestureRecognizer(tapGes3)
    }
    
    @objc private func viewTapAction(_ sender: UITapGestureRecognizer) {
        
        guard let tag = sender.view?.tag else { return }
        guard let _tap = tapAction else { return }
        _tap(tag)
    }
    
    func bindData(_ model: Moto_ContactCacheModel) {
        
        titleText.text = model.title
        nameText.text = model.name
        mobileText.text = model.mobile
        relationText.text = model.relation
    }
}
