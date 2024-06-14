//
//  Moto_RepayChannelView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class Moto_RepayChannelView: Moto_BaseView {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    private var _select: ((Int) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = "#CCCCCC".hexColorString().cgColor
    }
    
    @IBAction func channelViewTapAction(_ sender: UITapGestureRecognizer) {
        
        guard let select = _select else { return }
        select(tag)
    }
    
    func bindData(_ model: Moto_RepaymentMethodNoModel, _ select:@escaping((_ idx: Int) -> Void)) {
        
        _select = select
        titleText.text = model.pay_name
        if model.selected ?? false {
            backgroundColor = "#E9EFEC".hexColorString()
            layer.borderColor = "#25603D".hexColorString().cgColor
        }else {
            backgroundColor = .white
            layer.borderColor = "#CCCCCC".hexColorString().cgColor
        }
        guard let img = model.pay_img else { return }
        icon.kf.setImage(with: URL(string: img))
    }
}
