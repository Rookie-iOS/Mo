//
//  Moto_IdentityView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_IdentityView: Moto_BaseView {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var iconRight: NSLayoutConstraint!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    
    private var tap:(() -> Void)? = nil
    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.borderWidth = 1
        layer.cornerRadius = 8
        layer.borderColor = "#CCCCCC".hexColorString().cgColor
        
        icon.layer.cornerRadius = 8
        icon.layer.masksToBounds = true
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(ges)
    }
    
    @objc private func tapAction() {
        
        guard let _tap = tap else { return }
        _tap()
    }
    
    func bindData(_ model: Moto_SelectInputModel, andTapAction:@escaping(()->Void)) {
        
        tap = andTapAction
        titleText.text = model.title
        let base64String = model.content
        switch model.idx {
        case 51:
            iconRight.constant = 47
            iconWidth.constant = 85
            iconHeight.constant = 71
            icon.image = R.image.mo_identity_profile()
            if !base64String.isEmpty {
                guard let imageData = Data(base64Encoded: base64String) else { return }
                icon.image = UIImage(data: imageData)
                iconHeight.constant = 85
                icon.layer.cornerRadius = 42.5
                icon.layer.masksToBounds = true
            }
        case 52:
            iconRight.constant = 30
            iconWidth.constant = 120
            iconHeight.constant = 80
            icon.image = R.image.mo_identity_card()
            if !base64String.isEmpty {
                guard let imageData = Data(base64Encoded: base64String) else { return }
                icon.image = UIImage(data: imageData)
            }
        default:
            break
        }
    }
}
