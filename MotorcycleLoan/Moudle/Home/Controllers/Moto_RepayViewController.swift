//
//  Moto_RepayViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD

class Moto_RepayTermDataModel {
    var date: Int?
    var amount: Int?
    var num: Int?
    var overdays: Int?
    var checked: Bool = false
    var canEnable: Bool = true
}

class Moto_RepayViewController: Moto_ViewController {
    
    @IBOutlet weak var topTipsText: UILabel!
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var repaidView: UIView!
    @IBOutlet weak var repaidText: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fullPayView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomAmoutText: UILabel!
    @IBOutlet weak var fullPayViewHeight: NSLayoutConstraint!
    @IBOutlet weak var repaidViewHeight: NSLayoutConstraint!
    
    private var repayType = 3
    var product: Moto_ProductModel?
    private var terms = [Moto_RepayTermDataModel]()
    private var repayModel: Moto_HomeRepayModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadUI()
    }
    
    private func loadUI() {
        
        loadBackItem()
        title = "Bill Details"
        loadService(R.image.mo_new_service_icon())
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    private func loadData() {
        
        guard let _product = product else { return }
        guard let pid = _product.id else { return }
        var urlPath = ""
        let params: [String: Any] = [
            "pid": pid
        ]
        if _product.tadpole_loan == 0 {
            urlPath = Moto_Apis.Moto_api_old_repay_info
        }else {
            urlPath = Moto_Apis.Moto_api_repay_info
        }
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: urlPath, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_HomeRepayModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let _model = model.data else { return }
                repayModel = _model
                bindUI()
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func termViewClick(_ model: Moto_RepayTermDataModel) {
        
        guard let tadpole_loan = product?.tadpole_loan else { return }
        if tadpole_loan == 0 {
            model.checked = !model.checked
            guard let termView: Moto_RepaytermView = containerView.viewWithTag(100 + (model.num ?? 0) - 1 ) as? Moto_RepaytermView else { return }
            termView.icon.image = model.checked ? R.image.mo_repay_selected() : R.image.mo_repay_unselect()
            let money = model.checked ? (repayModel?.current_amount ?? 0) + (repayModel?.pay_data?.money ?? 0) : repayModel?.current_amount ?? 0
            amountText.text = "PHP\(Moto_Utils.formatMoney(money))"
            bottomAmoutText.text = "PHP\(Moto_Utils.formatMoney(money))"
        }else {
            model.checked = !model.checked
            guard let termView: Moto_RepaytermView = containerView.viewWithTag(100 + (model.num ?? 0)) as? Moto_RepaytermView else { return }
            termView.icon.image = model.checked ? R.image.mo_repay_selected() : R.image.mo_repay_unselect()
            let secondModel = terms[1]
            if secondModel.checked {
                repayType = 1
                amountText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
                bottomAmoutText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
            }else {
                guard let is_ins_repay = repayModel?.is_ins_repay else { return }
                if is_ins_repay == 1 {
                    repayType = 3
                    amountText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.current_amount ?? 0))"
                    bottomAmoutText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.current_amount ?? 0))"
                }else {
                    repayType = 1
                    amountText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
                    bottomAmoutText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
                }
            }
        }
    }
    
    private func layoutTermView() {
        
        var lastView: UIView?
        for idx in 0 ..< terms.count {
            let term = terms[idx]
            if term.num == -100 {
                guard let tipsView = R.nib.moto_RepayTipsView.firstView(withOwner: nil) else { return }
                containerView.addSubview(tipsView)
                tipsView.snp.makeConstraints { make in
                    make.top.equalTo(lastView!.snp.bottom)
                    make.height.equalTo(88)
                    make.left.right.equalTo(containerView)
                }
                lastView = tipsView
            }else {
                guard let termView = R.nib.moto_RepaytermView.firstView(withOwner: nil) else { return }
                termView.tag = 100 + (term.num ?? 0)
                termView.bindData(term) { [weak self] model in
                    guard let self = self else { return }
                    termViewClick(model)
                }
                containerView.addSubview(termView)
                termView.snp.makeConstraints { make in
                    if lastView == nil {
                        make.top.equalTo(containerView)
                    }else {
                        make.top.equalTo(lastView!.snp.bottom)
                    }
                    make.height.equalTo(114)
                    make.left.right.equalTo(containerView)
                }
                lastView = termView
            }
        }
        lastView?.snp.makeConstraints({ make in
            make.bottom.equalTo(containerView)
        })
    }
    
    private func bindUI() {
        
        repaidView.isHidden = repayModel?.repaid_amount == 0
        repaidViewHeight.constant = repayModel?.repaid_amount == 0 ? 0 : 44
        repaidText.text = "PHP \(Moto_Utils.formatMoney(repayModel?.repaid_amount ?? 0))"
        guard let tadpole_loan = product?.tadpole_loan else { return }
        guard let is_ins_repay = repayModel?.is_ins_repay else { return }
        guard let is_instalment = repayModel?.is_instalment else { return }
        guard let is_normal_instalment = repayModel?.is_normal_instalment else { return }
        
        if is_ins_repay == 1 {
            fullPayView.isHidden = false
            fullPayViewHeight.constant = 44
        }else {
            fullPayView.isHidden = true
            fullPayViewHeight.constant = 0
        }
        if tadpole_loan == 0 {
            // 老用户
            if is_instalment == 0 {
                // 单期
                topTipsText.text = "Total Repayment"
                let term = Moto_RepayTermDataModel()
                term.canEnable = repayModel?.overtime_day == 0
                term.overdays = repayModel?.overtime_day
                term.amount = repayModel?.final_amount
                term.date = repayModel?.repay_time
                term.num = 1
                terms.append(term)
                amountText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
                bottomAmoutText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
            }else {
                let term1 = Moto_RepayTermDataModel()
                term1.overdays = repayModel?.overtime_day
                term1.amount = is_ins_repay == 1 ? repayModel?.current_amount : repayModel?.final_amount
                term1.date = repayModel?.repay_time
                term1.canEnable = false
                term1.num = 1
                terms.append(term1)
                if is_ins_repay == 1 {
                    topTipsText.text = "Total first installment repayment"
                    amountText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.current_amount ?? 0))"
                    bottomAmoutText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.current_amount ?? 0))"
                    
                    let term2 = Moto_RepayTermDataModel()
                    term2.amount = repayModel?.pay_data?.money
                    term2.date = Int(repayModel?.pay_data?.back_time ?? "0")
                    term2.num = 2
                    terms.append(term2)
                }else {
                    if is_normal_instalment == 0 {
                        topTipsText.text = "Full Repayment"
                    }else {
                        topTipsText.text = "Total second installment repayment"
                    }
                    fullPayView.isHidden = true
                    fullPayViewHeight.constant = 0
                    
                    amountText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
                    bottomAmoutText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
                }
            }
        }else {
            // 新用户
            guard let list = repayModel?.pay_data_tadpole else { return }
            if is_ins_repay == 1 {
                repayType = 3
                amountText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.current_amount ?? 0))"
                bottomAmoutText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.current_amount ?? 0))"
            }else {
                repayType = 1
                amountText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
                bottomAmoutText.text = "PHP\(Moto_Utils.formatMoney(repayModel?.final_amount ?? 0))"
            }
            for idx in 0 ..< list.count {
                let item = list[idx]
                let term = Moto_RepayTermDataModel()
                term.amount = item.money
                term.num = Int(item.ins_num ?? 0)
                term.date = Int(item.back_time ?? 0)
                if idx == 0 {
                    term.overdays = repayModel?.overtime_day
                }
                // 默认选中第一期
                term.canEnable = (idx != 0)
                if idx == 1 {
                    if list.count == 6 {
                        // 新用户还完一期后不会显示一期数据
                        term.canEnable = is_ins_repay == 1
                    }
                }
                terms.append(term)
            }
            let term = Moto_RepayTermDataModel()
            term.num = -100
            if list.count == 6 {
                terms.insert(term, at: 2)
            }else {
                terms.insert(term, at: 1)
            }
        }
        layoutTermView()
    }
    
    @IBAction func fullPayTapAction(_ sender: UITapGestureRecognizer) {
        
        guard let popView = R.nib.moto_FullPayView.firstView(withOwner: nil) else { return }
        popView.show(repayModel) { [weak self] in
            guard let self = self else { return }
            repayType = 1
            repayment()
        }
    }
    
    // type 1: 全还 3: 分期
    @IBAction func repayAction() {
        
        guard let tadpole_loan = product?.tadpole_loan else { return }
        if tadpole_loan == 0 {
            guard let is_ins_repay = repayModel?.is_ins_repay else { return }
            repayType = is_ins_repay == 0 ? 1 : 3
            if is_ins_repay == 1 && terms.last?.checked ?? false {
                repayType = 1
            }
        }
        repayment()
    }
    
    private func repayment() {
        
        let repayment = R.storyboard.home.moto_repayment()!
        repayment.payType = repayType
        repayment.repayModel = repayModel
        navigationController?.pushViewController(repayment, animated: true)
    }
}
