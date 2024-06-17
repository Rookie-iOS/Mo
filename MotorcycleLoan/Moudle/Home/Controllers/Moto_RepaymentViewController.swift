//
//  Moto_RepaymentViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit
import WisdomHUD

class Moto_RepaymentViewController: Moto_ViewController {
    
    var payType = 3
    var repayModel: Moto_HomeRepayModel?
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var containerView: UIView!
    private var method: Moto_RepaymentMethodModel?
    private var channel: Moto_RepaymentMethodNoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadUI()
        loadMethodList()
    }
    
    private func loadUI() {
        
        loadBackItem()
        title = "Repayment Method"
        loadService(R.image.mo_new_service_icon())
        
        let amount = payType == 1 ? repayModel?.final_amount : repayModel?.current_amount
        amountText.text = "PHP\(Moto_Utils.formatMoney(amount ?? 0))"
    }
    
    private func loadMethodList() {
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_repayment_list) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<[Moto_RepaymentMethodModel]>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let list = model.data else { return }
                if !list.isEmpty {
                    method = list.first
                    list.first?.selected = true
                }
                layoutUI(list)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func clickMethod(_ idx: Int, _ channelIndex: Int, _ list: [Moto_RepaymentMethodModel]) {
        
        _  = list.map { $0.selected = false }
        if idx < list.count {
            let model = list[idx]
            model.selected = true
            method = model
            channel = nil
            if let channelList = model.list {
                _ = channelList.map { $0.selected = false }
                if channelIndex < channelList.count {
                    channel = channelList[channelIndex]
                    channel?.selected = true
                }
            }
        }
        layoutUI(list)
    }
    
    private func layoutUI(_ list: [Moto_RepaymentMethodModel]) {
        
        var last: UIView? = nil
        _ = containerView.subviews.map { $0.removeFromSuperview() }
        for idx in 0 ..< list.count {
            guard let methodItemView = R.nib.moto_RepaymentMethodView.firstView(withOwner: nil) else { return }
            let item = list[idx]
            methodItemView.tag = idx
            if item.selected ?? false {
                if let channelList = item.list {
                    if !channelList.isEmpty && channel == nil {
                        channelList.first?.selected = true
                        channel = channelList.first
                    }
                }
            }
            methodItemView.bindData(item) { [weak self] selectIdx, channel in
                guard let self = self else { return }
                clickMethod(selectIdx, channel, list)
            }
            containerView.addSubview(methodItemView)
            methodItemView.snp.makeConstraints { make in
                if last == nil {
                    make.top.equalTo(containerView).offset(20)
                }else {
                    make.top.equalTo(last!.snp.bottom).offset(20)
                }
                make.height.equalTo(80).priority(749)
                make.left.right.equalTo(containerView)
            }
            last = methodItemView
        }
        last?.snp.makeConstraints({ make in
            make.bottom.equalTo(containerView)
        })
    }
    
    @IBAction func payAction() {
        
        guard let _method = method else { return }
        var payment_id: String?
        if _method.list == nil {
            payment_id = _method.id
        }else {
            payment_id = channel?.id
        }
        guard let _payment_id = payment_id else { return }
        WisdomHUD.showLoading(text: "")
        let params = ["payment_id": _payment_id]
        Moto_Networking.request(path: Moto_Apis.Moto_api_check_pay_channel, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_PayChannelCheckModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let check = model.data else { return }
                if check.payment_status == "1" {
                    startPay()
                }else {
                    WisdomHUD.showTextCenter(text: check.payment_text_title ?? "").setFocusing()
                }
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func startPay() {
        
        guard let _repayModel = repayModel else { return }
        let amount = payType == 1 ? _repayModel.final_amount : _repayModel.current_amount
        var url: String!
        var params: [String: Any] = [
            "money": amount,
            "moto_payment_type": payType,
            "moto_detail_id":_repayModel.ad_id,
        ]
        if method?.list == nil {
            // 条形码收款
            url = Moto_Apis.Moto_api_qr_code_repayment
        }else {
            // 电子钱包收款
            guard let channel_code = channel?.payment_code else { return }
            url = Moto_Apis.Moto_api_ewallet_repayment
            params["moto_channel_code"] = channel_code
        }
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: url, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_RepayUrlModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let url = model.data?.redirect_url else { return }
                guard let web = R.storyboard.main.moto_web() else { return }
                web.fromRepryment = 1
                web.title = "Repayment"
                web.loadUrlString(url)
                navigationController?.pushViewController(web, animated: true)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
}
