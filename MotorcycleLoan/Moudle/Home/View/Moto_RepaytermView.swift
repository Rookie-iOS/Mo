//
//  Moto_RepaytermView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_RepaytermView: Moto_BaseView {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var termText: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var overdaysText: UILabel!
    @IBOutlet weak var overdayWidth: NSLayoutConstraint!
    
    private var _model: Moto_RepayTermDataModel? = nil
    private var _selected: ((Moto_RepayTermDataModel) -> Void)? = nil
    @IBAction func termViewTapAction(_ sender: UITapGestureRecognizer) {
        
        guard let model = _model else { return }
        guard let select = _selected else { return }
        if !model.canEnable {
            return
        }
        select(model)
    }
    
    func bindData(_ model: Moto_RepayTermDataModel, _ select:@escaping((_ model: Moto_RepayTermDataModel) -> Void)) {
        
        _model = model
        _selected = select
        termText.text = "Term \(model.num ?? 0)"
        amountText.text = "Repayment Amount: PHP\(Moto_Utils.formatMoney(model.amount ?? 0))"
        let date = Date(timeIntervalSince1970: TimeInterval(model.date ?? 0))
        dateText.text = "Repayment Date: \(Moto_Utils.formatDateString(date, "MM/dd/yyyy"))"
        
        if !model.canEnable {
            icon.image = R.image.mo_repay_no_unselect()
        }
        
        guard let overdays = model.overdays else { return }
        overdaysText.isHidden = overdays == 0
        overdaysText.text = "Overdue \(overdays) days"
        let size = overdaysText.sizeThatFits(CGSize(width: CGFLOAT_MAX, height: 20))
        overdayWidth.constant = size.width + 20
    }
}
