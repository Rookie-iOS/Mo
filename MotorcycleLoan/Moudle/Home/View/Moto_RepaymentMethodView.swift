//
//  Moto_RepaymentMethodView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class Moto_RepaymentMethodView: Moto_BaseView {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var methodText: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var methodIcon: UIImageView!
    @IBOutlet weak var selectIcon: UIImageView!
    
    private var _select:((Int, Int) -> Void)? = nil
    private var channelList: [Moto_RepaymentMethodNoModel]?
    override func awakeFromNib() {
        super.awakeFromNib()
        selectIcon.layer.cornerRadius = 11
        selectIcon.layer.maskedCorners = .layerMinXMaxYCorner
    }
    
    @IBAction func tapViewAction(_ sender: UITapGestureRecognizer) {
        guard let select = _select else { return }
        select(tag, 0)
    }
    
    private func channelViewClick(_ index: Int) {
        
        guard let list = channelList else { return }
        _ = list.map { $0.selected = false }
        if index < list.count {
            let model = list[index]
            model.selected = true
        }
        layoutChannelView(list)
        guard let select = _select else { return }
        select(tag, index)
    }
    
    func bindData(_ model: Moto_RepaymentMethodModel, _ select:@escaping((_ selectIdx: Int, _ channel: Int) -> Void)) {
        
        _select = select
        channelList = model.list
        methodText.text = model.title
        if !(model.selected ?? false) {
            selectIcon.isHidden = true
            bgView.layer.borderWidth = 0
            methodText.textColor = .black
            bgView.backgroundColor = "#F3F5F7".hexColorString()
            if (model.title ?? "").lowercased().range(of: "code") == nil {
                methodIcon.image = R.image.mo_repayment_method_no()
            }else {
                methodIcon.image = R.image.mo_repayment_method_qr()
            }
            containerView.snp.makeConstraints { make in
                make.height.equalTo(0)
            }
        }else {
            selectIcon.isHidden = false
            bgView.layer.borderWidth = 0.5
            methodText.textColor = "#25603D".hexColorString()
            bgView.backgroundColor = "#E9EFEC".hexColorString()
            bgView.layer.borderColor = "#25603D".hexColorString().cgColor
            if (model.title ?? "").lowercased().range(of: "code") == nil {
                methodIcon.image = R.image.mo_repayment_method_no_s()
            }else {
                methodIcon.image = R.image.mo_repayment_method_qr_s()
            }
            layoutChannelView(model.list)
        }
    }
    
    private func layoutChannelView(_ list: [Moto_RepaymentMethodNoModel]?) {
        
        _ = containerView.subviews.map { $0.removeFromSuperview() }
        guard let _list = list else { return }
        let titleText = UILabel()
        titleText.text = "Please select a repayment channel :"
        titleText.font = .systemFont(ofSize: 15)
        containerView.addSubview(titleText)
        titleText.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(20)
            make.left.equalTo(containerView)
            make.height.equalTo(18)
        }
        let channel_height: CGFloat = 44
        let channel_width = (Moto_Const.width - 23 * 2 - 29) / 2
        for idx in 0 ..< _list.count {
            let item = _list[idx]
            guard let channelView = R.nib.moto_RepayChannelView.firstView(withOwner: nil) else { return }
            channelView.tag = idx
            channelView.bindData(item) { [weak self] idx in
                guard let self = self else { return }
                channelViewClick(idx)
            }
            containerView.addSubview(channelView)
            channelView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: channel_width, height: channel_height))
                make.left.equalTo(containerView).offset((idx % 2) * (Int(channel_width) + 29))
                make.top.equalTo(titleText.snp.bottom).offset(15 + (idx / 2) * (Int(channel_height) + 15))
                if idx == _list.count - 1 {
                    make.bottom.equalTo(containerView)
                }
            }
        }
    }
}
