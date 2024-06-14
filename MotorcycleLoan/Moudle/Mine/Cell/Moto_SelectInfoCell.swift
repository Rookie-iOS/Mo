//
//  Moto_SelectInfoCell.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit

class Moto_SelectInfoCell: UITableViewCell {
    
    @IBOutlet weak var titleText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(_ feedback: Bool = false, _ model: Moto_SelectInfoItemModel) {
        
        titleText.text = model.info_title
        if !model.info_select {
            backgroundColor = .white
            if feedback {
                titleText.textColor = .black
            }
        }else {
            backgroundColor = "#E9EFEC".hexColorString()
            if feedback {
                titleText.textColor = "#25603D".hexColorString()
            }
        }
    }
}
