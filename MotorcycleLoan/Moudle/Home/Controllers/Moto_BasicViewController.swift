//
//  Moto_BasicViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD

class Moto_BasicViewController: Moto_ViewController {
    
    private var _lastBasicRow: Int = 0
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollIV: UIScrollView!
    private var cacheModel: Moto_CacheModel!
    private var infoModel: Moto_InfoListModel?
    private var items = [Moto_SelectInputModel]()
    private var fillEmialsArray = [String]()
    private let emailSuffix = ["@gmail.com", "@hotmail.com", "@yahoo.com", "@aol.com", "@outlook.com"]
    
    lazy var autoFillEmailView: Moto_AutoFillEmailView = {
        let autoView = R.nib.moto_AutoFillEmailView.firstView(withOwner: nil)!
        return autoView
    }()
    
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
        
        autoFillEmailView.isHidden = true
        containerView.addSubview(autoFillEmailView)
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
    
    private func fillData() {
        
        loadCacheData()
        let itemTitles = ["Usage of Loan", "E-mail（e.g: xxxxx@gmail.com）", "Facebook/Messengr Link", "Viber Phone Number", "Backup Phone Number（e.g: 09xxxxxxxxx）", "Religion", "Marital Status", "Number of Children", "Education Background"]
        for idx in 0 ..< itemTitles.count {
            let model = Moto_SelectInputModel()
            switch idx {
            case 0:
                model.content = cacheModel.usage_type ?? ""
            case 1:
                model.content = cacheModel.email ?? ""
            case 2:
                model.content = cacheModel.fbk_name ?? ""
            case 3:
                model.content = cacheModel.whatsapp ?? ""
            case 4:
                model.content = cacheModel.second_mobile ?? ""
            case 5:
                model.content = cacheModel.client_religion ?? ""
            case 6:
                model.content = cacheModel.merry_state ?? ""
            case 7:
                model.content = cacheModel.kid_number ?? ""
            case 8:
                model.content = cacheModel.eschool ?? ""
            default:
                break
            }
            model.type = 2
            model.idx = 10 + idx
            model.title = itemTitles[idx]
            if idx == 1 || idx == 2 || idx == 3 || idx == 4 {
                model.height = idx == 1 ? 142 : 87
                model.type = 1
            }
            items.append(model)
        }
    }
    
    private func loadUI() {
        
        loadBackItem()
        title =  "Basic Information"
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
    
    private func bindAutoFillData(_ textField: UITextField) {
        
        let model = items[1]
        guard let text = textField.text else { return }
        cacheModel.email = text
        model.content = text
        guard let data = try? JSONEncoder().encode(cacheModel) else { return }
        Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
        
        fillEmialsArray.removeAll()
        if text.range(of: "@") != nil {
            let range = text.range(of: "@")!
            let suffix = text[range.lowerBound ..< text.endIndex]
            let prefix = text[text.startIndex ..< range.lowerBound]
            fillEmialsArray.append(contentsOf: emailSuffix.filter({ $0.range(of: suffix) != nil }).map { "\(prefix)\($0)" })
        }else {
            fillEmialsArray.append(contentsOf: emailSuffix.map { "\(text)\($0)" })
        }
        
        autoFillEmailView.isHidden = text.isEmpty || (fillEmialsArray.count == 1 && fillEmialsArray.first == text)
        if (fillEmialsArray.count == 1 && fillEmialsArray.first == text) {
            Moto_UploadRisk.eventEnd("email_duration")
        }
        autoFillEmailView.bindData(fillEmialsArray) { [weak self] email in
            guard let self = self else { return }
            autoFillEmailView.isHidden = true
            textField.text = email
            model.content = email
            cacheModel.email = email
            Moto_UploadRisk.eventEnd("email_duration")
            guard let data = try? JSONEncoder().encode(cacheModel) else { return }
            Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
        }
        let height: CGFloat = (fillEmialsArray.count == 1 && fillEmialsArray.first == text) ? 0 : CGFloat(45 * fillEmialsArray.count)
        autoFillEmailView.snp.remakeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.left.equalTo(containerView).offset(16)
            make.centerX.equalTo(containerView)
            make.height.equalTo(height)
        }
    }
    
    @objc private func beginInputText(_ noti: Notification) {
        
        guard let textField = noti.object as? UITextField else { return }
        guard let row = textField.superview?.superview?.tag else { return }
        switch row {
        case 12:
            textField.keyboardType = .namePhonePad
        case 13:
            textField.keyboardType = .phonePad
        case 14:
            textField.keyboardType = .phonePad
        default:
            break
        }
    }
    
    @objc private func textInputHasChange(_ noti: Notification) {
        guard let textField = noti.object as? UITextField else { return }
        guard let row = textField.superview?.superview?.tag else { return }
        guard let text = textField.text else { return }
        switch row {
        case 11:
            Moto_UploadRisk.eventBegin("email_duration")
            Moto_UploadRisk.eventCount("emai_updatecount")
            textField.autocorrectionType = .no
            bindAutoFillData(textField)
        case 12:
            Moto_UploadRisk.eventBegin("facebook_name_duration")
            Moto_UploadRisk.eventCount("facebook_name_updatecount")
            let model = items[row - 10]
            cacheModel.fbk_name = text
            model.content = text
        case 13:
            if text.count >= 11 {
                textField.text = String(text.prefix(11))
            }
            let model = items[row - 10]
            model.content = text
            cacheModel.whatsapp = text
            Moto_UploadRisk.eventBegin("messenger_viber_duration")
            Moto_UploadRisk.eventCount("messenger_viber_updatecount")
        case 14:
            if text.count >= 11 {
                textField.text = String(text.prefix(11))
            }
            let model = items[row - 10]
            model.content = text
            cacheModel.second_mobile = text
            Moto_UploadRisk.eventBegin("backup_phone_duration")
            Moto_UploadRisk.eventCount("backup_phone_updatecount")
        default:
            break
        }
        
        // Risk data
        if _lastBasicRow != 0 {
            if _lastBasicRow != 11 {
                Moto_UploadRisk.eventEnd("email_duration")
            }
            if _lastBasicRow != 12 {
                Moto_UploadRisk.eventEnd("facebook_name_duration")
            }
            if _lastBasicRow != 13 {
                Moto_UploadRisk.eventEnd("messenger_viber_duration")
            }
            if _lastBasicRow != 14 {
                Moto_UploadRisk.eventEnd("backup_phone_duration")
            }
        }
        _lastBasicRow = row
        guard let data = try? JSONEncoder().encode(self.cacheModel) else { return }
        Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
    }
    
    private func itemViewClick(_ model: Moto_SelectInputModel) {
        
        autoFillEmailView.isHidden = true
        if model.idx == 11 {
            guard let emailView: Moto_EmailInputView = containerView.viewWithTag(model.idx) as? Moto_EmailInputView else { return }
            emailView.inputText.isEnabled = true
            emailView.inputText.becomeFirstResponder()
            emailView.inputText.keyboardType = .emailAddress
            // 添加邮箱输入监听
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(textInputHasChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        }else {
            guard let titleView: Moto_SelectInputView = containerView.viewWithTag(model.idx) as? Moto_SelectInputView else { return }
            titleView.inputText.isEnabled = false
            if model.type == 1 {
                titleView.inputText.isEnabled = true
                titleView.inputText.becomeFirstResponder()
                // 添加邮箱输入监听
                NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(textInputHasChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
                // 监听输入框开始输入
                NotificationCenter.default.removeObserver(self, name: UITextField.textDidBeginEditingNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(beginInputText(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
            }else {
                view.endEditing(true)
                var selectModel = Moto_SelectInfoModel()
                switch model.idx {
                case 10:
                    guard let list = infoModel?.purpose else { return }
                    selectModel.title = model.title
                    for purpose in list {
                        let selectInfoItemModel = Moto_SelectInfoItemModel()
                        selectInfoItemModel.info_title = purpose.title
                        selectInfoItemModel.info_id = purpose.id
                        selectInfoItemModel.info_select = purpose.title == titleView.inputText.text
                        selectModel.list.append(selectInfoItemModel)
                    }
                    guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                    selectView.frame = UIScreen.main.bounds
                    Moto_UploadRisk.eventBegin("purpose_last_duration")
                    Moto_UploadRisk.eventBegin("purpose_all_duration", true)
                    selectView.show(selectModel) { [weak self] select in
                        guard let self = self else { return }
                        if let _select = select {
                            titleView.inputText.text = _select.info_title
                            cacheModel.usage_type = _select.info_title
                            model.content = _select.info_title
                        }
                        Moto_UploadRisk.eventEnd("purpose_last_duration")
                        Moto_UploadRisk.eventCount("purpose_updatecount")
                        Moto_UploadRisk.eventEnd("purpose_all_duration", true)
                        guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                        Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                    }
                case 15:
                    guard let list = infoModel?.religion else { return }
                    selectModel.title = model.title
                    for religion in list {
                        let selectInfoItemModel = Moto_SelectInfoItemModel()
                        selectInfoItemModel.info_title = religion.title
                        selectInfoItemModel.info_id = religion.id
                        selectInfoItemModel.info_select = religion.title == titleView.inputText.text
                        selectModel.list.append(selectInfoItemModel)
                    }
                    guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                    selectView.frame = UIScreen.main.bounds
                    Moto_UploadRisk.eventBegin("religion_duration")
                    Moto_UploadRisk.eventCount("religion_updatecount")
                    selectView.show(selectModel) { [weak self] select in
                        guard let self = self else { return }
                        if let _select = select {
                            titleView.inputText.text = _select.info_title
                            model.content = _select.info_title
                            cacheModel.client_religion = _select.info_title
                        }
                        Moto_UploadRisk.eventEnd("religion_duration")
                        guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                        Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                        let index = model.idx - 10
                        if (index + 1) < self.items.count {
                            let model = self.items[index + 1]
                            if model.content.isEmpty {
                                self.itemViewClick(model)
                            }
                        }
                    }
                case 16:
                    guard let list = infoModel?.merry else { return }
                    selectModel.title = model.title
                    for merry in list {
                        let selectInfoItemModel = Moto_SelectInfoItemModel()
                        selectInfoItemModel.info_title = merry.title
                        selectInfoItemModel.info_id = merry.id
                        selectInfoItemModel.info_select = merry.title == titleView.inputText.text
                        selectModel.list.append(selectInfoItemModel)
                    }
                    guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                    selectView.frame = UIScreen.main.bounds
                    Moto_UploadRisk.eventBegin("marry_status_duration")
                    Moto_UploadRisk.eventCount("marry_status_updatecount")
                    selectView.show(selectModel) { [weak self] select in
                        guard let self = self else { return }
                        if let _select = select {
                            titleView.inputText.text = _select.info_title
                            model.content = _select.info_title
                            cacheModel.merry_state = _select.info_title
                        }
                        Moto_UploadRisk.eventEnd("marry_status_duration")
                        guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                        Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                        let index = model.idx - 10
                        if (index + 1) < self.items.count {
                            let model = self.items[index + 1]
                            if model.content.isEmpty {
                                self.itemViewClick(model)
                            }
                        }
                    }
                case 17:
                    guard let list = infoModel?.kids else { return }
                    selectModel.title = model.title
                    for kid in list {
                        let selectInfoItemModel = Moto_SelectInfoItemModel()
                        selectInfoItemModel.info_title = kid.title
                        selectInfoItemModel.info_id = kid.id
                        selectInfoItemModel.info_select = kid.title == titleView.inputText.text
                        selectModel.list.append(selectInfoItemModel)
                    }
                    guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                    selectView.frame = UIScreen.main.bounds
                    Moto_UploadRisk.eventBegin("kids_num_duration")
                    Moto_UploadRisk.eventCount("kids_num_update_count")
                    selectView.show(selectModel) { [weak self] select in
                        guard let self = self else { return }
                        if let _select = select {
                            titleView.inputText.text = _select.info_title
                            model.content = _select.info_title
                            cacheModel.kid_number = _select.info_title
                        }
                        Moto_UploadRisk.eventEnd("kids_num_duration")
                        guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                        Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                        
                        let index = model.idx - 10
                        if (index + 1) < self.items.count {
                            let model = self.items[index + 1]
                            if model.content.isEmpty {
                                self.itemViewClick(model)
                            }
                        }
                    }
                case 18:
                    guard let list = infoModel?.useredu else { return }
                    selectModel.title = model.title
                    for edu in list {
                        let selectInfoItemModel = Moto_SelectInfoItemModel()
                        selectInfoItemModel.info_title = edu.title
                        selectInfoItemModel.info_id = edu.id
                        selectInfoItemModel.info_select = edu.title == titleView.inputText.text
                        selectModel.list.append(selectInfoItemModel)
                    }
                    guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                    selectView.frame = UIScreen.main.bounds
                    Moto_UploadRisk.eventBegin("education_duration")
                    Moto_UploadRisk.eventCount("education_updatecount")
                    selectView.show(selectModel) { [weak self] select in
                        guard let self = self else { return }
                        if let _select = select {
                            titleView.inputText.text = _select.info_title
                            model.content = _select.info_title
                            cacheModel.eschool = _select.info_title
                        }
                        Moto_UploadRisk.eventEnd("education_duration")
                        guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                        Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                    }
                default:
                    break
                }
            }
        }
    }
    
    private func layoutUI() {
        
        var lastItemView:UIView? = nil
        for item in items {
            var itemView: UIView!
            if item.idx == 11 {
                let emailView = R.nib.moto_EmailInputView.firstView(withOwner: nil)!
                emailView.bindData(item) { [weak self] model in
                    guard let self = self else { return }
                    itemViewClick(model)
                }
                itemView = emailView
            }else {
                let titleView = R.nib.moto_SelectInputView.firstView(withOwner: nil)!
                titleView.bindData(item) { [weak self] model in
                    guard let self = self else { return }
                    itemViewClick(model)
                }
                itemView = titleView
            }
            itemView.tag = item.idx
            containerView.addSubview(itemView)
            itemView.snp.makeConstraints { make in
                if lastItemView == nil {
                    make.top.equalTo(containerView)
                }else {
                    make.top.equalTo(lastItemView!.snp.bottom)
                }
                make.height.equalTo(item.height)
                make.left.right.equalTo(containerView)
            }
            lastItemView = itemView
        }
        lastItemView?.snp.makeConstraints({ make in
            make.bottom.equalTo(containerView)
        })
    }
    
    override func backAction() {
        
        guard let popView = R.nib.moto_CancelPopView.firstView(withOwner: nil) else { return }
        popView.frame = UIScreen.main.bounds
        popView.titleText.text = "Warm Reminder"
        popView.tipsText.textAlignment = .center
        popView.icon.image = R.image.mo_pop_secure()!
        popView.showText("You have not finished filling in the authentication information. Still return it?") { [weak self] in
            guard let self = self else { return }
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func nextAction() {
        
        let model = items.filter { $0.content.isEmpty }.first
        if model == nil {
            guard let whatsapp = cacheModel.whatsapp else { return  }
            guard let second_mobile = cacheModel.second_mobile else { return  }
            let msg = "Please enter a valid phone number"
            if !Moto_Utils.verifyMobile(whatsapp) {
                guard let titleView: Moto_SelectInputView = containerView.viewWithTag(13) as? Moto_SelectInputView else { return }
                WisdomHUD.showTextCenter(text: msg).setFocusing()
                titleView.inputText.textColor = .red
                return
            }
            if !Moto_Utils.verifyMobile(second_mobile) {
                guard let titleView: Moto_SelectInputView = containerView.viewWithTag(14) as? Moto_SelectInputView else { return }
                WisdomHUD.showTextCenter(text: msg).setFocusing()
                titleView.inputText.textColor = .red
                return
            }
            
            if second_mobile == Moto_Utils.userInfo()?.phone {
                guard let titleView: Moto_SelectInputView = containerView.viewWithTag(14) as? Moto_SelectInputView else { return }
                WisdomHUD.showTextCenter(text: "The register mobile phone number cannot be used as an alternate number").setFocusing()
                titleView.inputText.textColor = .red
                return
            }
            
            Moto_UploadRisk.uploadRKData(5)
            let job = R.storyboard.home.moto_jon_info()!
            navigationController?.pushViewController(job, animated: true)
        }else {
            
            var msg = model?.type == 1 ? "Please fill in \(model?.title ?? "")" : "Please select \(model?.title ?? "")"
            if model?.idx == 11 {
                msg = "Please fill in email"
            }
            if model?.idx == 12 {
                msg = "Please fill in Facebook Name"
            }
            if model?.idx == 14 {
                msg = "Please fill in backup phone number"
            }
            if model?.idx == 15 {
                msg = "Please select your religion"
            }
            WisdomHUD.showTextCenter(text: msg).setFocusing()
            
            guard let row = model?.idx else { return }
            if (row - 10) < 2 {
                scrollIV.setContentOffset(CGPoint(x: 0, y: (row - 10) * 87), animated: true)
            }else {
                scrollIV.setContentOffset(CGPoint(x: 0, y: scrollIV.contentSize.height + view.safeAreaInsets.top + view.safeAreaInsets.bottom + 52 - Moto_Const.height), animated: true)
            }
            if row == 1 {
                guard let emailView: Moto_EmailInputView = containerView.viewWithTag(model?.idx ?? 11) as? Moto_EmailInputView else { return }
                emailView.inputText.attributedPlaceholder = NSAttributedString(string: "Please fill in", attributes: [.foregroundColor: UIColor.red])
            }else {
                guard let titleView: Moto_SelectInputView = containerView.viewWithTag(model?.idx ?? 10) as? Moto_SelectInputView else { return }
                let title = model?.type ?? 1 == 1 ? "Please fill in" : "Please select"
                titleView.inputText.attributedPlaceholder = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.red])
            }
        }
    }
}
