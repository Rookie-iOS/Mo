//
//  Moto_SelectInfoView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_SelectInfoView: Moto_BaseView {

    @IBOutlet weak var bgView: UIView!
        @IBOutlet weak var titleText: UILabel!
        @IBOutlet weak var tabIV: UITableView!
        @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
        
        private let defaultRow = 6
        private var dataArray = [Moto_SelectInfoItemModel]()
        private var _selected: ((Moto_SelectInfoItemModel) -> Void)? = nil
        override func awakeFromNib() {
            super.awakeFromNib()
            
            bgView.layer.cornerRadius = 20
            bgView.layer.masksToBounds = true
            bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            
            tabIV.delegate = self
            tabIV.dataSource = self
            tabIV.separatorStyle = .none
            tabIV.register(R.nib.moto_SelectInfoCell)
            tabIV.showsVerticalScrollIndicator = false
        }
        
        @IBAction func cancelAction() {
            dismiss()
        }
        
        func dismiss() {
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
        
        func show(_ model: Moto_SelectInfoModel, _ selected:@escaping((_ select: Moto_SelectInfoItemModel) -> Void)) {
            
            guard let window = Moto_Utils.keyWindow else { return }
            window.addSubview(self)
            
            dataArray.removeAll()
            _selected = selected
            titleText.text = model.title
            dataArray.append(contentsOf: model.list)
            tabIV.reloadData()
            
            let row = model.list.count > defaultRow ? defaultRow : model.list.count
            tableViewHeight.constant = CGFloat(row) * 52.0
            bgView.y = Moto_Const.height
            
            UIView.animate(withDuration: Moto_Const.animation) { [weak self] in
                guard let self = self else { return }
                bgView.y = Moto_Const.height - tableViewHeight.constant + 52
            }
        }

}

extension Moto_SelectInfoView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let select = _selected else { return }
        select(dataArray[indexPath.row])
        dismiss()
    }
}

extension Moto_SelectInfoView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_SelectInfoCell.identifier, for: indexPath) as! Moto_SelectInfoCell
        cell.bindData(false,dataArray[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
