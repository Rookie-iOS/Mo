//
//  Moto_HomeStatusCell.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit

class Moto_HomeStatusCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tipsText: UILabel!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var bgView: Moto_CornerRaduisView!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    @IBOutlet weak var iconTopHeight: NSLayoutConstraint!
    @IBOutlet weak var tipsTextHeight: NSLayoutConstraint!
    @IBOutlet weak var statusTextHeight: NSLayoutConstraint!
    
    private var lineTopHeight: CGFloat = 180
    private var product: Moto_ProductModel?
    private var _callback:((Int) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView.radius = 6
        bgView.width = Moto_Const.width - 26
        
        bgView.layer.borderWidth = 1
        bgView.layer.cornerRadius = 8
        bgView.layer.borderColor = "#E6E6E6".hexColorString().cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.drawRadiusWithDashLine(at: lineTopHeight, "#E6E6E6".hexColorString())
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func apply() {
        
        guard let pro = product else { return }
        guard let callback = _callback else { return }
        callback(pro.status)
    }
    
    func bindData(_ model: Moto_HomeDataModel? = nil, _ callback:((_ status: Int) -> Void)? = nil) {
        guard let _product = model?.data.first else { return }
        _callback = callback
        product = _product
        lineTopHeight = 180
        iconWidth.constant = 140
        iconHeight.constant = 140
        iconTopHeight.constant = 0
        switch _product.status {
        case 3:
            tipsTextHeight.constant = 84
            statusTextHeight.constant = 20
            statusText.text = "Congrats!"
            statusText.textAlignment = .center
            icon.image = R.image.mo_home_loan_status_icon()
            statusText.textColor = "#59C339".hexColorString()
            applyBtn.setTitle("Apply for withdrawal", for: .normal)
            tipsText.text = "Your application has been approved, please confirm your loan amount and repayment deadline, and get your loan immediately!"
        case 4:
            tipsTextHeight.constant = 102
            statusTextHeight.constant = 20
            statusText.textAlignment = .center
            statusText.text = "Application Rollback!"
            icon.image = R.image.mo_home_reject_status_icon()
            statusText.textColor = "#EB4F39".hexColorString()
            applyBtn.setTitle("Complete Information", for: .normal)
            tipsText.text = "Please make sure that the photo you submit is clear and the ID is within the validity period. After submitted you will have the change to get a loan immediately!"
        case 6:
            
            iconWidth.constant = 80
            iconHeight.constant = 80
            iconTopHeight.constant = 20
            tipsTextHeight.constant = 84
            statusTextHeight.constant = 20
            statusText.textAlignment = .center
            statusText.text = "Repayment successful!"
            icon.image = R.image.mo_home_loan_success()
            statusText.textColor = "#69C343".hexColorString()
            applyBtn.setTitle("Reloan Now", for: .normal)
            tipsText.text = "Keep your credit good and you can get a higher loan amount and a longer loan term if you borrow again."
        case 8:
            lineTopHeight = 205
            tipsTextHeight.constant = 48
            statusTextHeight.constant = 45
            statusText.textAlignment = .left
            applyBtn.setTitle("FeedBack", for: .normal)
            icon.image = R.image.mo_home_reject_status_icon()
            statusText.textColor = "#EB4F39".hexColorString()
            tipsText.text = "Please try again after \(_product.forbid_days ?? 0) days"
            statusText.text = "Sorry, you application has not been approved!"
        case 10:
            tipsTextHeight.constant = 102
            statusTextHeight.constant = 20
            statusText.text = "Warning Sign!"
            statusText.textAlignment = .center
            applyBtn.setTitle("Redraw", for: .normal)
            statusText.textColor = "#EB4F39".hexColorString()
            icon.image = R.image.mo_home_paid_failure_status_icon()
            tipsText.text = "The payment system appears the unusual, you may choose the withdrawal way to carry on the withdrawal, very sorry brings the inconvenience you!"
        default:
            break
        }
        bgView.layoutIfNeeded()
    }    
}
