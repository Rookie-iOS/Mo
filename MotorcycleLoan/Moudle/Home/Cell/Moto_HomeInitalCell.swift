//
//  Moto_HomeInitalCell.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit

class Moto_HomeInitalCell: UITableViewCell {
    
    private var homeData: Moto_HomeDataModel?
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var loanInsText: UILabel!
    @IBOutlet weak var loanTimeText: UILabel!
    @IBOutlet weak var loanTermText: UILabel!
    @IBOutlet weak var bgView: Moto_CornerRaduisView!
    
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
        bgView.drawRadiusWithDashLine(at: 124, "#E6E6E6".hexColorString())
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(_ model: Moto_HomeDataModel?) {
        
        guard let _model = model else { return }
        homeData = _model
        guard let data = _model.data.first else { return }
        loanTimeText.text = "Fast Loan: \(data.loan_time)"
        loanTermText.text = "Loan Term: \(data.loan_term)"
        
        guard let min = Int(data.min_money) else { return }
        guard let max = Int(data.max_money) else { return }
        UserDefaults.standard.setValue(max, forKey: Moto_Const.home_max_moeny_key)
        amountText.text = "PHP \(Moto_Utils.formatMoney(min)) - \(Moto_Utils.formatMoney(max))"
        
        guard let rate = Float(data.interest) else { return }
        loanInsText.text = "Daily  Rate: \(String(format: "%.2f%%", rate * 100))"
    }
    
    @IBAction func initalAppyAction() {
        
        guard let model = homeData else { return }
        guard let product = model.data.first else { return }
        Moto_UploadRisk.eventAtTime("apply_now_time")
        Moto_UploadRisk.eventBegin("basic_confirm_duration")
        
        if product.status == 0 || Moto_Utils.userInfo()?.token == nil {
            let login = R.storyboard.register.moto_login()!
            login.hidesBottomBarWhenPushed = true
            controller?.navigationController?.pushViewController(login, animated: true)
        }else if(product.status == 12) {
            guard let binding_cards_status = model.data.first?.binding_cards_status else { return }
            switch binding_cards_status {
            case 0:
                let reliminary = R.storyboard.home.moto_preliminary()!
                reliminary.hidesBottomBarWhenPushed = true
                controller?.navigationController?.pushViewController(reliminary, animated: true)
            case 1:
                let loan = R.storyboard.home.moto_loan()!
                loan.hidesBottomBarWhenPushed = true
                loan.product = product
                loan.bingingStatus = binding_cards_status
                controller?.navigationController?.pushViewController(loan, animated: true)
            case 2:
                let loan = R.storyboard.home.moto_loan()!
                loan.hidesBottomBarWhenPushed = true
                loan.product = product
                loan.bingingStatus = binding_cards_status
                controller?.navigationController?.pushViewController(loan, animated: true)
            default:
                break
            }
        }else{
            // 认证列表
            guard let authStatus = homeData?.auth_state else { return }
            // 身份
            if authStatus.state_two != 1 {
                let basic = R.storyboard.home.moto_basic()!
                basic.hidesBottomBarWhenPushed = true
                controller?.navigationController?.pushViewController(basic, animated: true)
            }else if(authStatus.state_one != 1) {
                let face = R.storyboard.home.moto_identify()!
                face.hidesBottomBarWhenPushed = true
                controller?.navigationController?.pushViewController(face, animated: true)
            }else {
                let list = R.storyboard.home.moto_auth_center()!
                list.hidesBottomBarWhenPushed = true
                controller?.navigationController?.pushViewController(list, animated: true)
            }
        }
    }
}
