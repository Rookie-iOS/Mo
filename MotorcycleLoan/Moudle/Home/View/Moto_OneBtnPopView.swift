//
//  Moto_OneBtnPopView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit

class Moto_OneBtnPopView: Moto_BaseView {
    
    private var _confirmAction:(()->Void)? = nil
    @IBAction func confirmAction() {
        
        removeFromSuperview()
        guard let confirmAction = _confirmAction else { return }
        confirmAction()
    }
    
    func show(_ confirmAction:@escaping(()->Void)) {
        
        guard let window = Moto_Utils.keyWindow else { return }
        _confirmAction = confirmAction
        window.addSubview(self)
    }
}
