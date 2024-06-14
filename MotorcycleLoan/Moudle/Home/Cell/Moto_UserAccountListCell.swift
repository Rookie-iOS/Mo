//
//  Moto_UserAccountListCell.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit

class Moto_UserAccountListCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var accountNoText: UILabel!
    @IBOutlet weak var nameTextLeft: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView.layer.borderWidth = 0.5
        bgView.layer.cornerRadius = 10
        bgView.layer.borderColor = "#CCCCCC".hexColorString().cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(_ type: Int, _ model: Moto_UserAccountModel) {
        
        nameText.text = type == 1 ? model.title : model.name
        bgView.backgroundColor = .white
        bgView.layer.borderColor = "#CCCCCC".hexColorString().cgColor
        if model.is_default == "1" {
            bgView.backgroundColor = "#25603D".hexColorString(0.04)
            bgView.layer.borderColor = "#25603D".hexColorString().cgColor
        }
        if type == 1 {
            nameTextLeft.constant = 52
            icon.image = UIImage(named: "mo_account_\(model.title?.lowercased() ?? "")_icon")
            guard let account_number = model.account_number else { return }
            let range = account_number.index(account_number.startIndex, offsetBy: 3) ..< account_number.index(account_number.endIndex, offsetBy: -4)
            let encry = account_number.replacingCharacters(in: range, with: "****")
            accountNoText.text = encry
        }else {
            nameTextLeft.constant = 12
            guard let account_number = model.bank_number else { return }
            let range = account_number.index(account_number.startIndex, offsetBy: 3) ..< account_number.index(account_number.endIndex, offsetBy: -4)
            let encry = account_number.replacingCharacters(in: range, with: "****")
            accountNoText.text = encry
        }
    }
    
}
