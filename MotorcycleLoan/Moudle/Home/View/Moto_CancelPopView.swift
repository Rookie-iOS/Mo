//
//  Moto_CancelPopView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_CancelPopView: Moto_BaseView {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var tipsText: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tipsTopHeight: NSLayoutConstraint!
    private var _sure: (()->Void)? = nil
    
    @IBAction func popViewBtnsAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            removeFromSuperview()
        case 200:
            removeFromSuperview()
            guard let sure = _sure else { return }
            sure()
        default:
            break
        }
    }
    
    func showText(_ text: String, _ sure:@escaping(()->Void)) {
        guard let window = Moto_Utils.keyWindow else { return }
        _sure = sure
        tipsText.text = text
        window.addSubview(self)
    }
}
