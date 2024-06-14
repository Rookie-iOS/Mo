//
//  Moto_ContactViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD
import ContactsUI

class Moto_ContactViewController: Moto_ViewController {
    
    @IBOutlet weak var scrollIV: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    private var cacheModel: Moto_CacheModel!
    private var infoModel: Moto_InfoListModel?
    private var items = [Moto_ContactCacheModel]()
    private var contactInfoDic = [Int:String]()
    
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
        title = "Emergency Contact"
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
        let titles = ["Personal Reference Contact 1", "Personal Reference Contact 2", "Personal Reference Contact 3", "Personal Reference Contact 4", "Personal Reference Contact 5"]
        for idx in 0 ..< titles.count {
            let model = Moto_ContactCacheModel()
            switch idx {
            case 0:
                model.relation = cacheModel.gx_one
                model.name = cacheModel.gx_name
                model.mobile = cacheModel.gx_phone
            case 1:
                model.relation = cacheModel.gx_two
                model.name = cacheModel.gx_name_two
                model.mobile = cacheModel.gx_phone_two
            case 2:
                model.relation = cacheModel.gx_three
                model.name = cacheModel.gx_name_three
                model.mobile = cacheModel.gx_phone_three
            case 3:
                model.relation = cacheModel.gx_four
                model.name = cacheModel.gx_name_four
                model.mobile = cacheModel.gx_phone_four
            case 4:
                model.relation = cacheModel.gx_five
                model.name = cacheModel.gx_name_five
                model.mobile = cacheModel.gx_phone_five
            default:
                break
            }
            model.title = titles[idx]
            model.idx = 40 + idx
            items.append(model)
        }
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
    
    private func layoutUI() {
        var lastView: Moto_ContactInfoView? = nil
        for item in items {
            let contactInfoView = R.nib.moto_ContactInfoView.firstView(withOwner: nil)!
            contactInfoView.bindData(item)
            contactInfoView.tag = item.idx
            containerView.addSubview(contactInfoView)
            contactInfoView.tapAction = { [weak self] tag in
                guard let self = self else { return }
                tapViewAtRow(item, tag)
            }
            contactInfoView.snp.makeConstraints { make in
                if lastView == nil {
                    make.top.equalTo(containerView)
                }else {
                    make.top.equalTo(lastView!.snp.bottom)
                }
                make.height.equalTo(183)
                make.left.right.equalTo(containerView)
            }
            lastView = contactInfoView
        }
        lastView?.snp.makeConstraints({ make in
            make.bottom.equalTo(containerView)
        })
    }
    
    private func isExistMobile(_ phone: String) -> (Bool, Int) {
        var isContain = false
        var index = 0
        contactInfoDic.forEach { (key: Int, value: String) in
            if value == phone{
                isContain = true
                index = key
            }
        }
        return (isContain, index)
    }
    
    // opem contact list
    private func openCaontactList(_ at: Int) {
        
        let contactVC = CNContactPickerViewController()
        contactVC.modalPresentationStyle = .fullScreen
        contactVC.delegate = self
        contactVC.view.tag = at
        present(contactVC, animated: true)
    }
    
    private func tapViewAtRow(_ item: Moto_ContactCacheModel, _ row: Int) {
        
        // 获取对应的联系人信息view
        guard let contactInfoView = containerView.viewWithTag(item.idx) as? Moto_ContactInfoView else { return }
        // 获取联系人信息view中的信息view
        guard let rowView = contactInfoView.viewWithTag(row) else { return }
        // 获取对应的TF
        guard let inputText = rowView.viewWithTag(400) as? UITextField else { return }
        view.endEditing(true)
        if row != 100 {
            openCaontactList(item.idx)
        }else {
            var selectModel = Moto_SelectInfoModel()
            switch item.idx {
            case 40:
                selectModel.title = "Relation one"
                guard var relations = infoModel?.rel?.t1 else { return }
                if let gx_two = cacheModel.gx_two {
                    guard let idx = relations.firstIndex(of: gx_two) else { return }
                    relations.remove(at: idx)
                }
                for relation in relations {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = relation
                    selectInfoItemModel.info_id = "\(item.idx)"
                    selectInfoItemModel.info_select = relation == inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    inputText.text = select.info_title
                    item.relation = select.info_title
                    cacheModel.gx_one = select.info_title
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                }
            case 41:
                selectModel.title = "Relation two"
                guard var relations = infoModel?.rel?.t2 else { return }
                if let gx_one = cacheModel.gx_one {
                    guard let idx = relations.firstIndex(of: gx_one) else { return }
                    relations.remove(at: idx)
                }
                for relation in relations {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = relation
                    selectInfoItemModel.info_id = "\(item.idx)"
                    selectInfoItemModel.info_select = relation == inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    inputText.text = select.info_title
                    item.relation = select.info_title
                    cacheModel.gx_two = select.info_title
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                }
            case 42:
                selectModel.title = "Relation three"
                guard let relations = infoModel?.rel?.t3 else { return }
                for relation in relations {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = relation
                    selectInfoItemModel.info_id = "\(item.idx)"
                    selectInfoItemModel.info_select = relation == inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    inputText.text = select.info_title
                    item.relation = select.info_title
                    cacheModel.gx_three = select.info_title
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                }
            case 43:
                selectModel.title = "Relation four"
                guard let relations = infoModel?.rel?.t3 else { return }
                for relation in relations {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = relation
                    selectInfoItemModel.info_id = "\(item.idx)"
                    selectInfoItemModel.info_select = relation == inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    inputText.text = select.info_title
                    item.relation = select.info_title
                    cacheModel.gx_four = select.info_title
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                }
            case 44:
                selectModel.title = "Relation five"
                guard let relations = infoModel?.rel?.t3 else { return }
                for relation in relations {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = relation
                    selectInfoItemModel.info_id = "\(item.idx)"
                    selectInfoItemModel.info_select = relation == inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    inputText.text = select.info_title
                    item.relation = select.info_title
                    cacheModel.gx_five = select.info_title
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
                }
            default:
                break
            }
        }
    }
    
    private func submit() {
        
        guard let jsonData = try? JSONEncoder().encode(cacheModel) else { return }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        let params = [
            "moto_data_list":jsonString
        ]
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_basic_info_upload, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode( Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200  {
                Moto_UploadRisk.uploadRKData(8)
                let face = R.storyboard.home.moto_identify()!
                navigationController?.pushViewController(face, animated: true)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    @IBAction func nextAction() {
        
        let model = items.filter { $0.relation?.isEmpty ?? true || $0.name?.isEmpty ?? true || $0.mobile?.isEmpty ?? true }.first
        if model == nil {
            submit()
        }else {
            guard let idx = model?.idx else { return }
            // 获取对应的联系人信息view
            guard let contactInfoView = containerView.viewWithTag(idx) as? Moto_ContactInfoView else { return }
            // 获取联系人信息view中的信息view
            guard let relationView = contactInfoView.viewWithTag(100) else { return }
            guard let nameView = contactInfoView.viewWithTag(200) else { return }
            guard let mobileView = contactInfoView.viewWithTag(300) else { return }
            // 获取对应的TF
            guard let relationInputText = relationView.viewWithTag(400) as? UITextField else { return }
            guard let nameInputText = nameView.viewWithTag(400) as? UITextField else { return }
            guard let mobileInputText = mobileView.viewWithTag(400) as? UITextField else { return }
            
            // 定位到相应的
            let row = idx - 40
            if row < 2 {
                scrollIV.setContentOffset(CGPoint(x: 0, y: row*(model?.height ?? 0)), animated: true)
            }else {
                scrollIV.setContentOffset(CGPoint(x: 0, y: scrollIV.contentSize.height + view.safeAreaInsets.top + view.safeAreaInsets.bottom + 52 - Moto_Const.height), animated: true)
            }
            // 标记错误
            if relationInputText.text?.isEmpty ?? true {
                let localtion = row == 0 ? "First" : row == 1 ? "Second" : "Other"
                let msg = "Please Select Relationship With \(localtion) Contact"
                WisdomHUD.showTextCenter(text: msg).setFocusing()
                relationInputText.attributedPlaceholder = NSAttributedString(string: "Please select", attributes: [.foregroundColor: UIColor.red])
                return
            }
            
            if nameInputText.text?.isEmpty ?? true {
                let localtion = row == 0 ? "First" : row == 1 ? "Second" : "Other"
                let msg = row < 2 ? "Please Select the \(localtion) Name of Contact" : "Please Select the Name of \(localtion) Contact"
                WisdomHUD.showTextCenter(text: msg).setFocusing()
                nameInputText.attributedPlaceholder = NSAttributedString(string: "Please select", attributes: [.foregroundColor: UIColor.red])
                return
            }
            
            if mobileInputText.text?.isEmpty ?? true {
                let msg = "Please enter a valid phone number"
                WisdomHUD.showTextCenter(text: msg).setFocusing()
                mobileInputText.attributedPlaceholder = NSAttributedString(string: "Please select", attributes: [.foregroundColor: UIColor.red])
                return
            }
        }
    }
    
}

extension Moto_ContactViewController: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        guard let number = contact.phoneNumbers.first else { return }
        let charSet = CharacterSet.decimalDigits.inverted
        var mobile = number.value.stringValue.components(separatedBy: charSet).joined(separator: "")
        if mobile.hasPrefix("063") {
            mobile = String(mobile.suffix(mobile.count - 3))
        }
        if mobile.hasPrefix("63") {
            mobile = String(mobile.suffix(mobile.count - 2))
        }
        if mobile.hasPrefix("0") {
            mobile = String(mobile.suffix(mobile.count - 1))
        }
        
        if !Moto_Utils.verifyMobile(mobile) {
            WisdomHUD.showTextCenter(text: "Please fill in the valid emergency contact information,we will contact them randomly for verification !").setFocusing()
            return
        }
        
        if mobile == Moto_Utils.userInfo()?.phone {
            WisdomHUD.showTextCenter(text: "Your registering phone number not allows add here anymore!").setFocusing()
            return
        }
        
        let (contain, idx) = isExistMobile(mobile)
        if contain {
            let localtion = idx == 0 ? "1st" : idx == 1 ? "2nd" : "\(idx)th"
            WisdomHUD.showTextCenter(text: "Tel No. should not be the same as the \(localtion) contact\'s").setFocusing()
            return
        }else {
            let row = picker.view.tag - 40
            contactInfoDic[row] = mobile
            
            guard let contactInfoView = containerView.viewWithTag(picker.view.tag) as? Moto_ContactInfoView else { return }
            // 获取联系人信息view中的信息view
            guard let rowNameView = contactInfoView.viewWithTag(200) else { return }
            guard let rowMobileView = contactInfoView.viewWithTag(300) else { return }
            // 获取对应的TF
            guard let inputNameText = rowNameView.viewWithTag(400) as? UITextField else { return }
            guard let inputMobileText = rowMobileView.viewWithTag(400) as? UITextField else { return }
            
            let name = "\(contact.familyName)\(contact.middleName)\(contact.givenName)"
            inputNameText.text = name
            inputMobileText.text = mobile
            
            let model = items[row]
            switch row {
            case 0:
                model.name = name
                model.mobile = mobile
                cacheModel.gx_name = name
                cacheModel.gx_phone = mobile
            case 1:
                model.name = name
                model.mobile = mobile
                cacheModel.gx_name_two = name
                cacheModel.gx_phone_two = mobile
            case 2:
                model.name = name
                model.mobile = mobile
                cacheModel.gx_name_three = name
                cacheModel.gx_phone_three = mobile
            case 3:
                model.name = name
                model.mobile = mobile
                cacheModel.gx_name_four = name
                cacheModel.gx_phone_four = mobile
            case 4:
                model.name = name
                model.mobile = mobile
                cacheModel.gx_name_five = name
                cacheModel.gx_phone_five = mobile
            default:
                break
            }
            guard let data = try? JSONEncoder().encode(cacheModel) else { return }
            Moto_Utils.saveData(1, String(data: data, encoding: .utf8))
        }
    }
}

