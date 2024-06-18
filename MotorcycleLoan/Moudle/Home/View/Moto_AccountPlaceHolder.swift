//
//  Moto_AccountPlaceHolder.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit

class Moto_AccountPlaceHolder: Moto_BaseView {
    
    @IBOutlet weak var tipsText: UILabel!
    @IBOutlet weak var addText: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    
    private var shapeLayer: CAShapeLayer? = nil
    private var _callback: ((Int) -> Void)? = nil
    var type: Int = 1 {
        didSet {
            if type == 1 {
                iconWidth.constant = 146
                iconHeight.constant = 149
                addText.text = "Add E-Wallet"
                tipsText.text = "Please bind a E-Wallet first"
                icon.image = R.image.mo_account_ew_empty_icon()!
                
            }else {
                iconWidth.constant = 170
                iconHeight.constant = 174
                addText.text = "Add BankCard"
                tipsText.text = "Please bind a bank card first"
                icon.image = R.image.mo_account_bc_empty_icon()!
            }
        }
    }
    
    func addAction(_ callback:@escaping((_ type: Int) -> Void)) {
        
        _callback = callback
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        
        guard let callback = _callback else { return }
        callback(type)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        if shapeLayer == nil {
            shapeLayer = addView.addDashedBorder("#25603D".hexColorString(), "#25603D".hexColorString(0.1))
        }
        addView.layer.addSublayer(shapeLayer!)
    }
}
