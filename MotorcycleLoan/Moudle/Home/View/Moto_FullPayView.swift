//
//  Moto_FullPayView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class Moto_FullPayView: Moto_BaseView {
    
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var totalAmounText: UILabel!
    @IBOutlet weak var repaidAmountText: UILabel!
    @IBOutlet weak var repayDateText: UILabel!
    
    private var _click:(()->Void)? = nil
    @IBAction func payAction(_ sender: UIButton) {
        
        removeFromSuperview()
        if sender.tag == 100 {
            guard let click = _click else { return }
            click()
        }
    }
    
    func show(_ model: Moto_HomeRepayModel?, _ click:@escaping(()->Void)) {
        
        guard let window = Moto_Utils.keyWindow else { return }
        _click = click
        
        frame = window.bounds
        window.addSubview(self)
        
        amountText.text = "PHP \(Moto_Utils.formatMoney(model?.final_amount ?? 0))"
        totalAmounText.text = "PHP \(Moto_Utils.formatMoney(model?.final_amount ?? 0))"
        repaidAmountText.text = "PHP \(Moto_Utils.formatMoney(model?.repaid_amount ?? 0))"
        guard let timeInterval = model?.repay_time else { return }
        let date = Date(timeIntervalSince1970: TimeInterval(timeInterval))
        repayDateText.text = "\(Moto_Utils.formatDateString(date, "MM/dd/yyyy"))"
    }
}
