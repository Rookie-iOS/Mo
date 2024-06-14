//
//  Moto_LoanRepayItemView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit

class Moto_LoanRepayItemView: Moto_BaseView {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var repaymentDateText: UILabel!
    
    func bindData(_ model: Moto_LoanRepayDatModel) {
        titleText.text = "\(model.install ?? 0) installment"
        repaymentDateText.text = "Repayment Date \(model.back_time ?? "")"
        amountText.text = "PHP \(Moto_Utils.formatMoney(model.repay_price ?? 0))"
    }
    
}
