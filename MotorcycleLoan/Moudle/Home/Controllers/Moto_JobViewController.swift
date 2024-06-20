//
//  Moto_JobViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD

class Moto_JobViewController: Moto_ViewController {
    
    @IBOutlet weak var scrollIV: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    private var infoModel: Moto_InfoListModel?
    
    private var cacheModel: Moto_CacheModel!
    private var items = [Moto_SelectInputModel]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textFieldRemoveObserver()
    }
    
    private func textFieldRemoveObserver() {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadUI()
        fillData()
        layoutUI()
        loadInfoList()
    }
    
    private func loadUI() {
        
        loadBackItem()
        title =  "Job Information"
        navigationBarColor = "#0E623A".hexColorString()
    }
    
    private func loadCacheData() {
        
        if let dataString = Moto_Utils.cacheData(1) {
            if let data = dataString.data(using: .utf8) {
                if let model = try? JSONDecoder().decode(Moto_CacheModel.self, from: data) {
                    cacheModel = model
                }else {
                    cacheModel = Moto_CacheModel()
                }
            }else {
                cacheModel = Moto_CacheModel()
            }
        }else {
            cacheModel = Moto_CacheModel()
        }
    }
    
    private func fillData() {
        
        loadCacheData()
        let titles = ["Industry Category", "Company Name", "Working Experience", "Payday1", "Payday2", "Monthly Income", "Company Address", "Detailed Address"]
        for idx in 0 ..< titles.count {
            let model = Moto_SelectInputModel()
            switch idx {
            case 0:
                model.content = cacheModel.branch ?? ""
            case 1:
                model.content = cacheModel.company_name ?? ""
            case 2:
                model.content = cacheModel.work_time_long ?? ""
            case 3:
                model.content = cacheModel.pay_date_one ?? ""
            case 4:
                model.content = cacheModel.pay_date_two ?? ""
            case 5:
                model.content = cacheModel.client_salary ?? ""
            case 6:
                model.content = cacheModel.wk_pro ?? ""
            case 7:
                model.content = cacheModel.wk_addr ?? ""
            default:
                break
            }
            
            model.type = 2
            model.idx = 20 + idx
            model.title = titles[idx]
            if idx == 1 || idx == 7 {
                model.type = 1
            }
            items.append(model)
        }
    }
    
    private func layoutUI() {
        
        var temps = [Moto_SelectInputModel]()
        let jobType = UserDefaults.standard.string(forKey: "\(Moto_Utils.userInfo()?.phone ?? "")_job_type")
        if jobType == "1" {
            guard let item = items.first else { return }
            temps.append(item)
            Moto_UploadRisk.eventUpdate("Industry_category_add_type", value: 2)
        }else {
            temps.append(contentsOf: items)
            Moto_UploadRisk.eventUpdate("Industry_category_add_type", value: 1)
        }
        var lastItemView:Moto_SelectInputView? = nil
        _ = containerView.subviews.map { $0.removeFromSuperview() }
        for item in temps {
            let titleView = R.nib.moto_SelectInputView.firstView(withOwner: nil)!
            titleView.bindData(item) { [weak self] model in
                guard let self = self else { return }
                itemViewClick(model)
            }
            titleView.tag = item.idx
            containerView.addSubview(titleView)
            
            titleView.textLabel.text = item.content
            let height = titleView.textLabel.sizeThatFits(CGSize(width: Moto_Const.width - 64, height: CGFLOAT_MAX)).height
            let _height = height > 18 ? item.height + Int(height) - 18 : item.height
            titleView.inputText.isHidden = height > 18
            titleView.textLabel.isHidden = !(height > 18)
            titleView.snp.makeConstraints { make in
                if lastItemView == nil {
                    make.top.equalTo(containerView)
                }else {
                    make.top.equalTo(lastItemView!.snp.bottom)
                }
                make.height.equalTo(_height)
                make.left.right.equalTo(containerView)
            }
            lastItemView = titleView
        }
        lastItemView?.snp.makeConstraints({ make in
            make.bottom.equalTo(containerView)
        })
    }
    
    private func loadInfoList() {
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_info_list) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_InfoListModel.self, from: jsonData) else { return }
            infoModel = model
        }
    }
    
    private func generateSelectDays() -> [Moto_InfoItemModel] {
        
        var list = [Moto_InfoItemModel]()
        for idx in 1 ..< 32 {
            var model = Moto_InfoItemModel()
            model.title = "\(idx)th"
            model.id = "\(idx)"
            list.append(model)
        }
        return list
    }
    
    @objc private func textInputHasChange(_ noti: Notification) {
        
        guard let textField = noti.object as? UITextField else { return }
        guard let row = textField.superview?.superview?.tag else { return }
        guard let text = textField.text else { return }
        let model = items[row - 20]
        model.content = text
        switch row {
        case 21:
            cacheModel.company_name = text
        case 27:
            cacheModel.wk_addr = text
        default:
            break
        }
        guard let data = try? JSONEncoder().encode(self.cacheModel) else { return }
        Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
    }
    
    private func itemViewClick(_ model: Moto_SelectInputModel) {
        
        guard let titleView: Moto_SelectInputView = containerView.viewWithTag(model.idx) as? Moto_SelectInputView else { return }
        titleView.inputText.isEnabled = false
        if model.type == 1 {
            titleView.inputText.isEnabled = true
            titleView.inputText.becomeFirstResponder()
            // 添加邮箱输入监听
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(textInputHasChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        }else {
            view.endEditing(true)
            var selectModel = Moto_SelectInfoModel()
            switch model.idx {
            case 20:
                guard let list = infoModel?.branch else { return }
                selectModel.title = model.title
                for branch in list {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = branch.title
                    selectInfoItemModel.info_id = branch.id
                    selectInfoItemModel.info_type = branch.type
                    selectInfoItemModel.info_select = branch.title == titleView.inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                Moto_UploadRisk.eventBegin("Industry_category_duration")
                Moto_UploadRisk.eventCount("Industry_category_updatecount")
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    if let _select = select {
                        titleView.inputText.text = _select.info_title
                        model.content = _select.info_title
                        cacheModel.branch = _select.info_title
                        UserDefaults.standard.setValue(_select.info_type, forKey: "\(Moto_Utils.userInfo()?.phone ?? "")_job_type")
                        layoutUI()
                    }
                    Moto_UploadRisk.eventEnd("Industry_category_duration")
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                    
                }
            case 22:
                guard let list = infoModel?.working else { return }
                selectModel.title = model.title
                for working in list {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = working.title
                    selectInfoItemModel.info_id = working.id
                    selectInfoItemModel.info_select = working.title == titleView.inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    if let _select = select {
                        titleView.inputText.text = _select.info_title
                        model.content = _select.info_title
                        cacheModel.work_time_long = _select.info_title
                    }
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                    let index = model.idx - 20
                    if (index + 1) < self.items.count {
                        let model = self.items[index + 1]
                        if model.content.isEmpty {
                            itemViewClick(model)
                        }
                    }
                }
                
            case 23:
                selectModel.title = model.title
                for day in generateSelectDays() {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = day.title
                    selectInfoItemModel.info_id = day.id
                    selectInfoItemModel.info_select = day.title == titleView.inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    if let _select = select {
                        titleView.inputText.text = _select.info_title
                        model.content = _select.info_title
                        cacheModel.pay_date_one = _select.info_title
                    }
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                    
                    let index = model.idx - 20
                    if (index + 1) < self.items.count {
                        let model = self.items[index + 1]
                        if model.content.isEmpty {
                            itemViewClick(model)
                        }
                    }
                }
            case 24:
                selectModel.title = model.title
                for day in generateSelectDays() {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = day.title
                    selectInfoItemModel.info_id = day.id
                    selectInfoItemModel.info_select = day.title == titleView.inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    if let _select = select {
                        titleView.inputText.text = _select.info_title
                        model.content = _select.info_title
                        cacheModel.pay_date_two = _select.info_title
                    }
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                    
                    let index = model.idx - 20
                    if (index + 1) < self.items.count {
                        let model = self.items[index + 1]
                        if model.content.isEmpty {
                            itemViewClick(model)
                        }
                    }
                }
            case 25:
                guard let list = infoModel?.sal else { return }
                selectModel.title = model.title
                for salary in list {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = salary.title
                    selectInfoItemModel.info_id = salary.id
                    selectInfoItemModel.info_select = salary.title == titleView.inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    if let _select = select {
                        titleView.inputText.text = _select.info_title
                        model.content = _select.info_title
                        cacheModel.client_salary = _select.info_title
                    }
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                }
            case 26:
                let addressSelect = R.storyboard.home.moto_address_select()!
                addressSelect.from = .job
                navigationController?.pushViewController(addressSelect, animated: true)
                addressSelect.addressFinishSelectAction { [weak self] (provice, city, street) in
                    guard let self = self else { return }
                    model.content = "\(provice.name) \(city.name) \(street.name)"
                    cacheModel.wk_pro = "\(provice.name) \(city.name) \(street.name)"
                    titleView.textLabel.isHidden = false
                    titleView.inputText.isHidden = true
                    titleView.textLabel.text = cacheModel.wk_pro
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                    let height = titleView.textLabel.sizeThatFits(CGSize(width: Moto_Const.width - 64, height: CGFLOAT_MAX)).height
                    let _height = height > 18 ? 87 + height - 18 : 87
                    titleView.snp.updateConstraints { make in
                        make.height.equalTo(_height)
                    }
                }
            default:
                break
            }
        }
    }
    
    @IBAction func nextAction() {
        
        let jobType = UserDefaults.standard.string(forKey: "\(Moto_Utils.userInfo()?.phone ?? "")_job_type")
        if jobType == "1" {
            Moto_UploadRisk.uploadRKData(6)
            let address = R.storyboard.home.moto_address_info()!
            navigationController?.pushViewController(address, animated: true)
        }else {
            let model = items.filter { $0.content.isEmpty }.first
            if model == nil {
                let address = R.storyboard.home.moto_address_info()!
                navigationController?.pushViewController(address, animated: true)
            }else {
                let msg = model?.type == 1 ? "Please fil in \(model?.title ?? "")" : "Please select \(model?.title ?? "")"
                WisdomHUD.showTextCenter(text: msg).setFocusing()
                
                guard let row = model?.idx else { return }
                if (row - 20) < 1 {
                    scrollIV.setContentOffset(CGPoint(x: 0, y: (row - 20) * 87), animated: true)
                }else {
                    scrollIV.setContentOffset(CGPoint(x: 0, y: scrollIV.contentSize.height + view.safeAreaInsets.top + view.safeAreaInsets.bottom + 52 - Moto_Const.height), animated: true)
                }
                
                guard let titleView: Moto_SelectInputView = containerView.viewWithTag(row) as? Moto_SelectInputView else { return }
                let title = model?.type ?? 1 == 1 ? "Please fill in" : "Please select"
                titleView.inputText.attributedPlaceholder = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.red])
            }
        }
    }
}
