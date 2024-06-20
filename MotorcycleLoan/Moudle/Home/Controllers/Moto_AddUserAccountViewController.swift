//
//  Moto_AddUserAccountViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD

class Moto_AddUserAccountViewController: Moto_ViewController {
    
    var accountType = 1
    @IBOutlet weak var tipsText: UILabel!
    @IBOutlet weak var topTipsText: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    private var account_id: String?
    private var group = DispatchGroup()
    private var items = [Moto_SelectInputModel]()
    private var orgList = [Moto_AccountOrgNameModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadUI()
        fillData()
        layoutUI()
        loadData()
    }
    
    private func loadUI() {
        
        loadBackItem()
        loadService(R.image.mo_new_service_icon())
        title = accountType == 1 ? "Add E-Wallet" : "Add BankCard"
        
        let topText = accountType == 1 ? "Kindly reminder: The name filled in the the loan application is inconsistent with the name of the bound e-wallet account, which may lead to the withdrawal failure." : "Kindly reminder: The name filled in the the loan application is inconsistent with the name of the bound bank card account, which may lead to the withdrawal failure."
        topTipsText.text = topText
        
        let tipText = accountType == 1 ? "1. This wallet is for recerving transaction. \n2. Please ensure that the account information you entered is accurate and available. the user shall be take whole responsibility for incorrect information filled in by the themselves." : "1.This bank card is for recerving transaction \n2. Please ensure that the account information you entered is accurate and available. the user shall be take whole responsibility for incorrect information filled in by the themselves."
        tipsText.text = tipText
        
        let riskTag = accountType == 1 ? 13 : 11
        Moto_UploadRisk.uploadRKData(riskTag)
    }
    private func loadUserName() {
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_user_name) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { WisdomHUD.dismiss(); self?.group.leave(); return }
            guard let jsonData = data else { WisdomHUD.dismiss(); group.leave(); return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_UserNameModel>.self, from: jsonData) else { WisdomHUD.dismiss(); group.leave(); return }
            if model.code == 200 {
                guard let titleView: Moto_SelectInputView = containerView.viewWithTag(60) as? Moto_SelectInputView else { WisdomHUD.dismiss(); group.leave(); return }
                guard let userName = model.data else { WisdomHUD.dismiss(); group.leave(); return }
                titleView.inputText.text = "\(userName.n_one ?? "")\(userName.n_two == nil ? " " : " \(userName.n_two!) ")\(userName.n_three ?? "")"
                group.leave()
            }else {
                group.leave()
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func loadOrganizationNameList() {
        
        let path = accountType == 1 ? Moto_Apis.Moto_api_ewallet_name_list : Moto_Apis.Moto_api_bank_name_list
        Moto_Networking.request(path: path) { [weak self] data in
            guard let self = self else { WisdomHUD.dismiss(); self?.group.leave(); return }
            guard let jsonData = data else { WisdomHUD.dismiss(); group.leave(); return}
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<[Moto_AccountOrgNameModel]>.self, from: jsonData) else { WisdomHUD.dismiss(); group.leave(); return }
            if model.code == 200 {
                guard let list = model.data else { WisdomHUD.dismiss(); group.leave(); return }
                for org in list {
                    orgList.append(org)
                }
                group.leave()
            }else {
                group.leave()
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func loadData() {
        
        group.enter()
        loadUserName()
        
        group.enter()
        loadOrganizationNameList()
        
        WisdomHUD.showLoading(text: "")
        group.notify(queue: .main) {
            WisdomHUD.dismiss()
        }
    }
    
    private func fillData() {
        
        let titles = accountType == 1 ? ["Full Name", "E-Wallet Name", "E-Wallet Account No.", "Same E-wallet Account No."] : ["Full Name", "Bank Name", "Bank Account No.", "Same Bank Account No.", "Call phone No."]
        for idx in 0 ..< titles.count {
            let model = Moto_SelectInputModel()
            model.title = titles[idx]
            model.idx = idx + 60
            model.type = 1
            if idx == 1 {
                model.type = 2
            }
            items.append(model)
        }
    }
    
    @objc private func textInputHasChange(_ noti: Notification) {
        
        guard let textField = noti.object as? UITextField else { return }
        guard let row = textField.superview?.superview?.tag else { return }
        guard let text = textField.text else { return }
        let length = accountType == 1 ? 11 : 16
        textField.textColor = .black
        switch row {
        case 62:
            if text.count > length {
                textField.text = String(text.prefix(length))
            }
        case 63:
            if text.count > length {
                textField.text = String(text.prefix(length))
            }
        case 64:
            if text.count >= 11 {
                textField.text = String(text.prefix(11))
            }
        default:
            break
        }
    }
    
    @objc private func beginInputText(_ noti: Notification) {
        
        guard let textField = noti.object as? UITextField else { return }
        guard let row = textField.superview?.superview?.tag else { return }
        switch row {
        case 62:
            textField.keyboardType = accountType == 1 ? .phonePad : .numberPad
        case 63:
            textField.keyboardType = accountType == 1 ? .phonePad : .numberPad
        case 64:
            textField.keyboardType = accountType == 1 ? .phonePad : .numberPad
        default:
            break
        }
    }
    
    private func itemViewClick(_ model: Moto_SelectInputModel) {
        guard let titleView: Moto_SelectInputView = containerView.viewWithTag(model.idx) as? Moto_SelectInputView else { return }
        titleView.inputText.isEnabled = false
        if model.type == 1 {
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(textInputHasChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
            // 监听输入框开始输入
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidBeginEditingNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(beginInputText(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
            titleView.inputText.isEnabled = true
            titleView.inputText.becomeFirstResponder()
        }else {
            view.endEditing(true)
            switch model.idx {
            case 61:
                var selectModel = Moto_SelectInfoModel()
                selectModel.title = model.title
                for org in orgList {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_id = accountType == 1 ? org.id ?? "" : org.bankid ?? ""
                    selectInfoItemModel.info_title = accountType == 1 ? org.title ?? "" : org.bankname ?? ""
                    selectInfoItemModel.info_select = selectInfoItemModel.info_title == titleView.inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    if let _select = select {
                        account_id = _select.info_id
                        titleView.inputText.text = _select.info_title
                    }
                }
            default:
                break
            }
        }
    }
    
    private func layoutUI() {
        var lastItemView: Moto_SelectInputView? = nil
        _ = containerView.subviews.map { $0.removeFromSuperview() }
        for item in items {
            let titleView = R.nib.moto_SelectInputView.firstView(withOwner: nil)!
            titleView.bindData(item) { [weak self] model in
                guard let self = self else { return }
                itemViewClick(model)
            }
            titleView.tag = item.idx
            containerView.addSubview(titleView)
            titleView.snp.makeConstraints { make in
                if lastItemView == nil {
                    make.top.equalTo(containerView)
                }else {
                    make.top.equalTo(lastItemView!.snp.bottom)
                }
                make.height.equalTo(item.height)
                make.left.right.equalTo(containerView)
            }
            lastItemView = titleView
        }
        lastItemView?.snp.makeConstraints({ make in
            make.bottom.equalTo(containerView)
        })
    }
    
    @IBAction func confirmAction() {
        
        guard let nameTextView: Moto_SelectInputView = containerView.viewWithTag(60) as? Moto_SelectInputView else { return }
        guard let orgNameTextView: Moto_SelectInputView = containerView.viewWithTag(61) as? Moto_SelectInputView else { return }
        guard let accountNoTextView: Moto_SelectInputView = containerView.viewWithTag(62) as? Moto_SelectInputView else { return }
        guard let sameAccountNoTextView: Moto_SelectInputView = containerView.viewWithTag(63) as? Moto_SelectInputView else { return }
        
        guard let name = nameTextView.inputText.text else { return }
        guard let orgName = orgNameTextView.inputText.text else { return }
        guard let accountNo = accountNoTextView.inputText.text else { return }
        guard let sameAccountNo = sameAccountNoTextView.inputText.text else { return }
        
        if !Moto_Utils.verifyName(name) {
            if !name.isEmpty {
                nameTextView.inputText.textColor = .red
            }else {
                nameTextView.inputText.attributedPlaceholder = NSAttributedString(string: "Please fill in", attributes: [.foregroundColor: UIColor.red])
            }
            WisdomHUD.showTextCenter(text: "Please input your name in the correct format!").setFocusing()
            return
        }
        
        if orgName.isEmpty {
            if !orgName.isEmpty {
                orgNameTextView.inputText.textColor = .red
            }else {
                orgNameTextView.inputText.attributedPlaceholder = NSAttributedString(string: "Please fill in", attributes: [.foregroundColor: UIColor.red])
            }
            let msg = accountType == 1 ? "Please select a e-wallet name" : "Please select a bank name"
            WisdomHUD.showTextCenter(text: msg).setFocusing()
            return
        }
        
        if accountNo.isEmpty {
            if !accountNo.isEmpty {
                accountNoTextView.inputText.textColor = .red
            }else {
                accountNoTextView.inputText.attributedPlaceholder = NSAttributedString(string: "Please fill in", attributes: [.foregroundColor: UIColor.red])
            }
            let msg = accountType == 1 ? "Please enter your wallet account" : "Please enter your bank account"
            WisdomHUD.showTextCenter(text: msg).setFocusing()
            return
        }
        
        if accountType == 1 {
            if !Moto_Utils.verifyMobile(accountNo) {
                accountNoTextView.inputText.textColor = .red
                WisdomHUD.showTextCenter(text: "Please enter your wallet account in the correct format!").setFocusing()
                return
            }
        }
        
        if sameAccountNo.isEmpty {
            sameAccountNoTextView.inputText.textColor = .red
            sameAccountNoTextView.inputText.attributedPlaceholder = NSAttributedString(string: "Please fill in", attributes: [.foregroundColor: UIColor.red])
            let msg = accountType == 1 ? "Please enter your wallet account again" : "Please enter your bank account again"
            WisdomHUD.showTextCenter(text: msg).setFocusing()
            return
        }
        
        if sameAccountNo != accountNo {
            WisdomHUD.showTextCenter(text: "The accounts filled in twice are different. Please check again").setFocusing()
            return
        }
        
        var path: String!
        var params = [String: Any]()
        if accountType == 1 {
            path = Moto_Apis.Moto_api_add_ewallet
            params["moto_wallet_data"] = "{\"account_number\":\"\(accountNo)\", \"channel_id\":\"\(account_id ?? "")\"}"
        }else {
            guard let phoneTextView: Moto_SelectInputView = containerView.viewWithTag(64) as? Moto_SelectInputView else { return }
            guard let phone = phoneTextView.inputText.text else { return }
            if !Moto_Utils.verifyMobile(phone) {
                if !phone.isEmpty {
                    phoneTextView.inputText.textColor = .red
                    WisdomHUD.showTextCenter(text: "Please enter your phone number!").setFocusing()
                }else {
                    phoneTextView.inputText.attributedPlaceholder = NSAttributedString(string: "Please fill in", attributes: [.foregroundColor: UIColor.red])
                    WisdomHUD.showTextCenter(text: "Please enter your phone number in the correct format!").setFocusing()
                }
                return
            }
            path = Moto_Apis.Moto_api_add_bank
            params["moto_data"] = "{\"bank_number\":\"\(accountNo)\", \"bid\":\"\(account_id ?? "")\", \"phone\":\"\(phone)\", \"username\":\"\(name)\"}"
        }
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: path, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                let riskTag = accountType == 1 ? 14 : 12
                Moto_UploadRisk.uploadRKData(riskTag)
                navigationController?.popViewController(animated: true)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
}
