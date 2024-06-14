//
//  Moto_LoanRecordCell.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class Moto_LoanRecordCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var amountText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 8
        bgView.layer.borderWidth = 0.5
        bgView.layer.borderColor = "#cccccc".hexColorString().cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(_ model: Moto_LoanRecordModel) {
        
        statusText.text = model.status
        dateText.text = model.apply_time
        guard let money = Int(model.money ?? "0") else { return }
        amountText.text = "PHP\(Moto_Utils.formatMoney(money))"
    }
}
