//
//  Moto_AddressCell.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_AddressCell: UITableViewCell {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var checkIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindProviceData(_ model: Moto_Provice) {
        
        checkIcon.isHidden = true
        titleText.text = model.name
        titleText.textColor = "#000000".hexColorString()
        if model.selected {
            checkIcon.isHidden = false
            titleText.textColor = "#25603D".hexColorString()
        }
    }
    
    func bindCityData(_ model: Moto_City) {
        
        checkIcon.isHidden = true
        titleText.text = model.name
        titleText.textColor = "#000000".hexColorString()
        if model.selected {
            checkIcon.isHidden = false
            titleText.textColor = "#25603D".hexColorString()
        }
    }
    
    func bindBarangayData(_ model: Moto_Barangay) {
        
        checkIcon.isHidden = true
        titleText.text = model.name
        titleText.textColor = "#000000".hexColorString()
        if model.selected {
            checkIcon.isHidden = false
            titleText.textColor = "#25603D".hexColorString()
        }
    }
}
