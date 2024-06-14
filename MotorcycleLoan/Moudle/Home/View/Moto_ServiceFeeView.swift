//
//  Moto_ServiceFeeView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_ServiceFeeView: Moto_BaseView {
    
    @IBOutlet weak var techText: UILabel!
    @IBOutlet weak var manText: UILabel!
    @IBOutlet weak var creditText: UILabel!
    
    @IBAction func okAction() {
        
        removeFromSuperview()
    }
    
    func show(_ model: Moto_LoanDetailModel) {
        
        guard let window = Moto_Utils.keyWindow else { return }
        frame = window.bounds
        window.addSubview(self)
        
        techText.text = "PHP \(Moto_Utils.formatMoney(model.tech_price ?? 0))"
        manText.text = "PHP \(Moto_Utils.formatMoney(model.manage_price ?? 0))"
        creditText.text = "PHP \(Moto_Utils.formatMoney(model.credit_price ?? 0))"
    }
    
}
