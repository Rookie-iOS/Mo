//
//  Moto_FeedSelectView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit

class Moto_FeedSelectView: Moto_BaseView {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tabIV: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    private var dataArray = [Moto_SelectInfoItemModel]()
    private var _selects: (([String]) -> Void)? = nil
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        
        tabIV.delegate = self
        tabIV.dataSource = self
        tabIV.separatorStyle = .none
        tabIV.register(R.nib.moto_SelectInfoCell)
        tabIV.showsVerticalScrollIndicator = false
    }
    
    @IBAction func btnsClick(_ sender: UIButton) {
        
        dismiss()
        if sender.tag == 200 {
            let list = dataArray.filter { $0.info_select }.map { $0.info_title }
            guard let select = _selects else { return }
            select(list)
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: Moto_Const.animation) {[weak self] in
            guard let self = self else { return }
            bgView.y = Moto_Const.height
        } completion: { [weak self] in
            guard let self = self else { return }
            if $0 {
                removeFromSuperview()
            }
        }
    }
    
    func show(_ text: String, _ list: [String], _ selects:@escaping(([String]) -> Void)) {
        
        _selects = selects
        guard let window = Moto_Utils.keyWindow else { return }
        frame = window.bounds
        window.addSubview(self)
        
        dataArray.removeAll()
        for title in list {
            let model = Moto_SelectInfoItemModel()
            model.info_title = title
            dataArray.append(model)
        }
        
        let _list = text.components(separatedBy: ",")
        _list.forEach { _text in
            dataArray.forEach { model in
                if model.info_title == _text {
                    model.info_select = true
                }
            }
        }
        
        let row = list.count
        bgView.y = Moto_Const.height
        tableViewHeight.constant = CGFloat(row) * 52.0
        UIView.animate(withDuration: Moto_Const.animation) { [weak self] in
            guard let self = self else { return }
            bgView.y = Moto_Const.height - tableViewHeight.constant + 52
        }
        tabIV.reloadData()
    }
}

extension Moto_FeedSelectView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        model.info_select = !model.info_select
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension Moto_FeedSelectView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_SelectInfoCell.identifier, for: indexPath) as! Moto_SelectInfoCell
        cell.bindData(true, dataArray[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
