//
//  Moto_GenderView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_GenderView: Moto_BaseView {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var male: UIButton!
    @IBOutlet weak var female: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    private var _isRollBack = false
    private var _select:((String) ->Void)? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        
        male.layer.cornerRadius = 8
        male.layer.masksToBounds = true
    }
    
    
    func bindData(_ isRollBack: Bool = false, _ model: Moto_SelectInputModel, _ select:@escaping((_ gender: String)-> Void)) {
        
        _select = select
        _isRollBack = isRollBack
        titleText.text = model.title
        if ["w", "female", "woman"].contains(model.content.lowercased()) {
            male.isSelected = false
            female.isSelected = true
            male.backgroundColor = .clear
            female.layer.cornerRadius = 8
            female.layer.masksToBounds = true
            female.backgroundColor = "#25603D".hexColorString()
        }else {
            male.isSelected = true
            female.isSelected = false
            female.backgroundColor = .clear
            male.layer.cornerRadius = 8
            male.layer.masksToBounds = true
            male.backgroundColor = "#25603D".hexColorString()
        }
    }
    
    @IBAction func genderBtnsClick(_ sender: UIButton) {
        
        if _isRollBack {
            return
        }
        _ = containerView.subviews.map {
            $0.layer.cornerRadius = 0
            $0.backgroundColor = .clear
            ($0 as! UIButton).isSelected = false
        }
        
        sender.isSelected = true
        sender.layer.cornerRadius = 8
        sender.layer.masksToBounds = true
        sender.backgroundColor = "#25603D".hexColorString()
        
        guard let title = sender.title(for: .normal) else { return }
        guard let select = _select else { return }
        select(title)
    }
}
