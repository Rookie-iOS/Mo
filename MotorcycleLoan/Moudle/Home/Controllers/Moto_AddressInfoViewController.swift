//
//  Moto_AddressInfoViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD

class Moto_AddressInfoViewController: Moto_ViewController {
    
    @IBOutlet weak var containerView: UIView!
    private var cacheModel: Moto_CacheModel!
    private var infoModel: Moto_InfoListModel?
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
        title =  "Address Information"
        navigationBarColor = "#0E623A".hexColorString()
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
        let titles = ["Residence", "Detailed Address", "Residential Owenrship"]
        for idx in 0 ..< titles.count {
            let model = Moto_SelectInputModel()
            switch idx {
            case 0:
                if let provice = cacheModel.lv_pro, let city = cacheModel.lv_city, let street = cacheModel.lv_stre {
                    model.content = "\(provice) \(city) \(street)"
                }else {
                    model.content = ""
                }
            case 1:
                model.content = cacheModel.lv_addr ?? ""
            case 2:
                model.content = cacheModel.hbl ?? ""
            default:
                break
            }
            model.title = titles[idx]
            model.idx = 30 + idx
            model.type = 2
            if idx == 1 {
                model.type = 1
            }
            items.append(model)
        }
    }
    
    private func layoutUI() {
        
        var lastItemView:Moto_SelectInputView? = nil
        for item in items {
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
    
    @objc private func textInputHasChange(_ noti: Notification) {
        
        guard let textField = noti.object as? UITextField else { return }
        guard let row = textField.superview?.superview?.tag else { return }
        guard let text = textField.text else { return }
        let model = items[row - 30]
        model.content = text
        switch row {
        case 31:
            cacheModel.lv_addr = text
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
            case 30:
                let addressSelect = R.storyboard.home.moto_address_select()!
                addressSelect.from = .address
                navigationController?.pushViewController(addressSelect, animated: true)
                addressSelect.addressFinishSelectAction { [weak self] (provice, city, street) in
                    guard let self = self else { return }
                    cacheModel.lv_pro = provice.name
                    cacheModel.lv_city = city.name
                    cacheModel.lv_stre = street.name
                    titleView.textLabel.isHidden = false
                    titleView.inputText.isHidden = true
                    model.content = "\(cacheModel.lv_pro ?? "") \(cacheModel.lv_city ?? "") \(cacheModel.lv_stre ?? "")"
                    titleView.textLabel.text = "\(cacheModel.lv_pro ?? "") \(cacheModel.lv_city ?? "") \(cacheModel.lv_stre ?? "")"
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                    let height = titleView.textLabel.sizeThatFits(CGSize(width: Moto_Const.width - 64, height: CGFLOAT_MAX)).height
                    let _height = height > 18 ? 87 + height - 18 : 87
                    titleView.snp.updateConstraints { make in
                        make.height.equalTo(_height)
                    }
                }
            case 32:
                guard let list = infoModel?.getLivebelong else { return }
                selectModel.title = model.title
                for livebelong in list {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = livebelong.title
                    selectInfoItemModel.info_id = livebelong.id
                    selectInfoItemModel.info_select = livebelong.title == titleView.inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    titleView.inputText.text = select.info_title
                    model.content = select.info_title
                    cacheModel.hbl = select.info_title
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                }
            default:
                break
            }
        }
    }
    
    @IBAction func nextAction() {
        
        let model = items.filter { $0.content.isEmpty }.first
        if model == nil {
            Moto_UploadRisk.uploadRKData(7)
            let contact = R.storyboard.home.moto_contact_info()!
            navigationController?.pushViewController(contact, animated: true)
        }else {
            
            let msg = model?.type == 1 ? "Please fil in \(model?.title ?? "")" : "Please select \(model?.title ?? "")"
            WisdomHUD.showTextCenter(text: msg).setFocusing()
            
            guard let row = model?.idx else { return }
            guard let titleView: Moto_SelectInputView = containerView.viewWithTag(row) as? Moto_SelectInputView else { return }
            let title = model?.type ?? 1 == 1 ? "Please fill in" : "Please select"
            titleView.inputText.attributedPlaceholder = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.red])
        }
    }
    
}
