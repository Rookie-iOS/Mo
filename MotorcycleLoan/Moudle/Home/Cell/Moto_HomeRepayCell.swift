//
//  Moto_HomeRepayCell.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/8/24.
//

import UIKit
import YYText
import AppsFlyerLib

class Moto_HomeRepayCell: UITableViewCell {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var overDayText: YYLabel!
    @IBOutlet weak var dateTimeText: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bgView: Moto_CornerRaduisView!
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    
    private var lineTopHeight: CGFloat = 0
    private var _product: Moto_ProductModel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
        
        bgView.radius = 6
        bgView.layer.borderWidth = 1
        bgView.layer.cornerRadius = 8
        bgView.layer.borderColor = "#E6E6E6".hexColorString().cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.width = Moto_Const.width - 26
        bgView.drawRadiusWithDashLine(at: lineTopHeight, "#E6E6E6".hexColorString())
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // repayType: 0 -> 老的还款页面 1 -> 的时候走六期
    func bindData(_ product: Moto_ProductModel? = nil, _ model: Moto_HomeRepayModel? = nil) {
        
        guard let data = model else { return }
        _product = product
        
        let amount = data.is_ins_repay == 0 ? data.final_amount : data.current_amount
        amountText.text = "PHP \(Moto_Utils.formatMoney(amount))"
        dateTimeText.text = Moto_Utils.formatDateString(Date.init(timeIntervalSince1970: TimeInterval(data.repay_time)), "MM/dd/yyyy")
        
        topView.isHidden = data.overtime_day == 0
        overDayText.isHidden = data.overtime_day == 0
        lineTopHeight = data.overtime_day == 0 ? -5 : 58
        topHeight.constant = data.overtime_day == 0 ? 16 : 74
        bgView.layoutIfNeeded()
        if data.overtime_day == 0 {
            return
        }
        let string = "You have been overdue \(data.overtime_day) days"
        guard let range = string.range(of: "\(data.overtime_day)") else { return }
        let n_range = NSRange(range, in: string)
        let attribute = NSMutableAttributedString(string: string)
        attribute.yy_font = .systemFont(ofSize: 15, weight: .medium)
        attribute.yy_color = .black
        attribute.yy_alignment = .center
        attribute.yy_setColor("#EB4F39".hexColorString(), range: n_range)
        overDayText.attributedText = attribute
    }
    
    @IBAction func repayAction() {
        
        let repay = R.storyboard.home.moto_repay()!
        repay.product = _product
        repay.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(repay, animated: true)
        AppsFlyerLib.shared().logEvent("mo_fangkuan", withValues: nil)
    }
}
