//
//  Moto_IdentityViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD
import Kingfisher
import AAILiveness

class Moto_IdentityViewController: Moto_ViewController {
    
    var rollback = false
    @IBOutlet weak var containerView: UIView!
    private var infoModel: Moto_InfoListModel?
    private var items = [Moto_SelectInputModel]()
    private var cacheModel: Moto_IdentityCacheModel!
    private var group = DispatchGroup()
    private var faceData: Moto_FaceDataModel?
    private var liscense_id: String?
    private var rollbackCardImageName: String?
    
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
        loadData()
        addExtraAuthenticationListPage()
    }
    
    private func addExtraAuthenticationListPage() {
        guard var vcs = navigationController?.viewControllers else { return }
        if vcs.filter({ $0.isKind(of: Moto_AuthCenterViewController.self )}).isEmpty {
            let list = R.storyboard.home.moto_auth_center()!
            list.hidesBottomBarWhenPushed = true
            vcs.insert(list, at: vcs.count - 1)
            navigationController?.viewControllers = vcs
        }
    }
    
    private func loadUI() {
        
        loadBackItem()
        title = "Identity Authentification"
        
        AAILivenessSDK.initWith(.philippines)
        AAILivenessSDK.configActionTimeoutSeconds(10)
    }
    
    private func loadInfoList() {
        Moto_Networking.request(path: Moto_Apis.Moto_api_info_list) { [weak self] data in
            guard let self = self else { WisdomHUD.dismiss(); self?.group.leave(); return }
            guard let jsonData = data else { WisdomHUD.dismiss(); group.leave(); return }
            guard let model = try? JSONDecoder().decode(Moto_InfoListModel.self, from: jsonData) else { WisdomHUD.dismiss(); group.leave(); return }
            infoModel = model
            group.leave()
        }
    }
    
    private func loadFaceData() {
        Moto_Networking.request(path: Moto_Apis.Moto_api_face_data, method: .post) { [weak self] data in
            guard let self = self else { WisdomHUD.dismiss(); self?.group.leave(); return }
            guard let jsonData = data else { WisdomHUD.dismiss(); group.leave(); return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_FaceDataModel>.self, from: jsonData) else { WisdomHUD.dismiss(); group.leave(); return }
            guard let data = model.data else { WisdomHUD.dismiss(); group.leave(); return }
            faceData = data
            group.leave()
        }
    }
    
    private func rollbackData() {
        Moto_Networking.request(path: Moto_Apis.Moto_api_back_fill, method: .post) { [weak self] data in
            guard let self = self else { WisdomHUD.dismiss(); self?.group.leave(); return }
            guard let jsonData = data else { WisdomHUD.dismiss(); group.leave(); return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_RollBackFillModel>.self, from: jsonData) else { WisdomHUD.dismiss(); group.leave(); return }
            WisdomHUD.dismiss()
            group.leave()
            if model.code == 200 {
                guard let fillModel = model.data else { return }
                var ocr = Moto_CardOcrModel()
                ocr.birthday = fillModel.birthday
                ocr.gender = fillModel.gender
                ocr.id_card = fillModel.cno
                ocr.first_name = fillModel.oname
                ocr.middle_name = fillModel.tname
                ocr.last_name = fillModel.lname
                bindOCRModel(ocr)
                guard let titleView: Moto_SelectInputView = containerView.viewWithTag(50) as? Moto_SelectInputView else { return }
                titleView.inputText.text = fillModel.type
                
                cacheModel.IDType = fillModel.type
                guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                Moto_Utils.saveData(2, String(data: data, encoding: .utf8))
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func loadData() {
        
        group.enter()
        loadInfoList()
        
        group.enter()
        loadFaceData()
        
        if rollback {
            group.enter()
            rollbackData()
        }
        WisdomHUD.showLoading(text: "")
        group.notify(queue: .main) { [weak self] in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let faceView: Moto_IdentityView = containerView.viewWithTag(51) as? Moto_IdentityView else { return }
            guard let urlstring = faceData?.ez_photo else { return }
            if !urlstring.isEmpty {
                faceView.icon.kf.setImage(with: URL(string: urlstring))
            }
            faceView.iconHeight.constant = 85
            faceView.icon.layer.cornerRadius = 42.5
            faceView.icon.layer.masksToBounds = true
        }
    }
    
    private func loadCacheData() {
        
        if let dataString = Moto_Utils.cacheData(2) {
            if let data = dataString.data(using: .utf8) {
                if let model = try? JSONDecoder().decode(Moto_IdentityCacheModel.self, from: data) {
                    cacheModel = model
                }else {
                    cacheModel = Moto_IdentityCacheModel()
                }
            }else {
                cacheModel = Moto_IdentityCacheModel()
            }
        }else {
            cacheModel = Moto_IdentityCacheModel()
        }
    }
    
    private func fillData() {
        
        loadCacheData()
        let titles = ["Type of document to submit", "Facial recognition", "Front photo of ID card", "Document ID Number", "First Name", "Middle Name(Optional)", "Last Name", "Gender", "Data of Birth(mm/dd/yy)"]
        for index in 0 ..< titles.count {
            let model = Moto_SelectInputModel()
            model.type = 1
            model.idx = 50 + index
            model.title = titles[index]
            items.append(model)
            switch index {
            case 0:
                model.type = 2
                model.content = cacheModel.IDType ?? ""
            case 1:
                model.type = 3
                model.height = 100
                model.content = Moto_Utils.cacheData(3) ?? ""
            case 2:
                model.type = 3
                model.height = 100
                if !rollback {
                    model.content = Moto_Utils.cacheData(4) ?? ""
                }
            case 3:
                model.content = cacheModel.id_card ?? ""
            case 4:
                model.content = cacheModel.first_name ?? ""
            case 5:
                model.content = cacheModel.middle_name ?? ""
            case 6:
                model.content = cacheModel.last_name ?? ""
            case 7:
                model.type = 4
                model.content = cacheModel.gender ?? ""
            case 8:
                model.type = 2
                model.content = cacheModel.birthday ?? ""
            default:
                break
            }
        }
    }
    
    @objc private func textInputHasChange(_ noti: Notification) {
        
        guard let textField = noti.object as? UITextField else { return }
        guard let row = textField.superview?.superview?.tag else { return }
        guard let text = textField.text else { return }
        textField.textColor = .black
        let model = items[row - 50]
        model.content = text
        switch model.idx {
        case 53:
            let length = cacheModel.type_id == "1" ? 12 : cacheModel.type_id == "2" ? 9 : cacheModel.type_id == "3" ? 11 : cacheModel.type_id == "4" ? 10 : cacheModel.type_id == "13" ? 7 : cacheModel.type_id == "22" ? 12 : 16
            textField.text = String(text.prefix(length))
            cacheModel.id_card = textField.text
        case 54:
            cacheModel.first_name = text
        case 55:
            cacheModel.middle_name = text
        case 56:
            cacheModel.last_name = text
        default:
            break
        }
        guard let data = try? JSONEncoder().encode(cacheModel) else { return }
        Moto_Utils.saveData(2, String(data: data, encoding: .utf8))
    }
    
    private func itemViewClick(_ model: Moto_SelectInputModel) {
        guard let titleView: Moto_SelectInputView = containerView.viewWithTag(model.idx) as? Moto_SelectInputView else { return }
        titleView.inputText.isEnabled = false
        if model.type == 1 {
            if rollback {
                return
            }
            titleView.inputText.isEnabled = true
            titleView.inputText.becomeFirstResponder()
            // 添加邮箱输入监听
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(textInputHasChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        }else {
            if rollback {
                return
            }
            view.endEditing(true)
            switch model.idx {
            case 50:
                guard let _infoModel = infoModel else { loadData(); return }
                var selectModel = Moto_SelectInfoModel()
                guard let list = _infoModel.idtype else { return }
                selectModel.title = "ID Type"
                for type in list {
                    let selectInfoItemModel = Moto_SelectInfoItemModel()
                    selectInfoItemModel.info_title = type.title
                    selectInfoItemModel.info_id = type.id
                    selectInfoItemModel.info_select = type.title == titleView.inputText.text
                    selectModel.list.append(selectInfoItemModel)
                }
                guard let selectView = R.nib.moto_SelectInfoView.firstView(withOwner: nil) else { return }
                selectView.frame = UIScreen.main.bounds
                selectView.show(selectModel) { [weak self] select in
                    guard let self = self else { return }
                    if let _select = select {
                        titleView.inputText.text = _select.info_title
                        model.content = _select.info_title
                        cacheModel.type_id = _select.info_id
                        cacheModel.IDType = _select.info_title
                    }
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(2, String(data: data, encoding: .utf8))
                    // 更新账号输入框类型
                    let cardModel = items[3]
                    guard let cardIDView: Moto_SelectInputView = containerView.viewWithTag(53) as? Moto_SelectInputView else { return }
                    cardIDView.bindData(cardModel) { [weak self] model in
                        guard let self = self else { return }
                        itemViewClick(cardModel)
                    }
                }
            case 58:
                guard let datePicker = R.nib.moto_BrithDayPickerSelectView.firstView(withOwner: nil) else { return }
                datePicker.frame = UIScreen.main.bounds
                datePicker.dateType = .birthday
                datePicker.showDatePickerView { [weak self] dateString in
                    guard let self = self else { return }
                    titleView.inputText.text = dateString
                    model.content = dateString
                    cacheModel.birthday = dateString
                    guard let data = try? JSONEncoder().encode(cacheModel) else { return }
                    Moto_Utils.saveData(2, String(data: data, encoding: .utf8))
                }
            default:
                break
            }
        }
    }
    
    private func bindOCRModel(_ model: Moto_CardOcrModel) {
        
        guard let numView: Moto_SelectInputView = containerView.viewWithTag(53) as? Moto_SelectInputView else { return }
        guard let card_num = model.id_card else { return }
        var card_id = card_num.replacingOccurrences(of: "-", with: "")
        let charSet = CharacterSet.whitespaces
        card_id = card_id.components(separatedBy: charSet).joined(separator: "")
        cacheModel.id_card = card_id
        numView.inputText.text = card_id
        
        guard let firstNameView: Moto_SelectInputView = containerView.viewWithTag(54) as? Moto_SelectInputView else { return }
        cacheModel.first_name = model.first_name
        firstNameView.inputText.text = model.first_name
        
        guard let middleNameView: Moto_SelectInputView = containerView.viewWithTag(55) as? Moto_SelectInputView else { return }
        cacheModel.middle_name = model.middle_name
        middleNameView.inputText.text = model.middle_name
        
        guard let lastNameView: Moto_SelectInputView = containerView.viewWithTag(56) as? Moto_SelectInputView else { return }
        cacheModel.last_name = model.last_name
        lastNameView.inputText.text = model.last_name
        
        guard let genderView: Moto_GenderView = containerView.viewWithTag(57) as? Moto_GenderView else { return }
        cacheModel.gender = model.gender
        genderView.male.isSelected = ["w", "female", "woman"].contains(model.gender?.lowercased()) ? true : false
        genderView.male.backgroundColor = genderView.male.isSelected ? "#25603D".hexColorString() : .clear
        genderView.female.isSelected = !genderView.male.isSelected
        genderView.female.backgroundColor = genderView.female.isSelected ? "#25603D".hexColorString() : .clear
        
        guard let brithDayView: Moto_SelectInputView = containerView.viewWithTag(58) as? Moto_SelectInputView else { return }
        cacheModel.birthday = model.birthday
        brithDayView.inputText.text = model.birthday
        
        guard let data = try? JSONEncoder().encode(cacheModel) else { return }
        Moto_Utils.saveData(2, String(data: data, encoding: .utf8))
    }
    
    private func uploadIdentityPhoto(_ type: Int, _ img: UIImage) {
        guard let imageData = img.jpegData(compressionQuality: 0.1) else { return }
        var path = ""
        var params = [String:Any]()
        switch type {
        case 1:
            path = Moto_Apis.Moto_api_add_face_img
            params["moto_live_id"] = liscense_id
            params["moto_phone_type"] = type
            params["moto_stream"] = imageData.base64EncodedString()
            params["moto_photo_name"] = "\(Moto_Utils.generateRandomTimeString()).png"
        case 2:
            path = Moto_Apis.Moto_api_add_card_img
            params["moto_liven_id"] = ""
            params["moto_photo_type"] = type
            params["moto_card_type"] = cacheModel.IDType
            params["moto_img_stream"] = imageData.base64EncodedString()
            if rollback {
                rollbackCardImageName = "\(Moto_Utils.generateRandomTimeString()).png"
                params["moto_photo"] = rollbackCardImageName
            }else {
                params["moto_photo"] = "\(Moto_Utils.generateRandomTimeString()).png"
            }
            // save id card local
            Moto_Utils.saveData(4, imageData.base64EncodedString())
        default:
            break
        }
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: path, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            switch type {
            case 1:
                guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
                if model.code != 200 {
                    WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
                }
            case 2:
                guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_CardOcrModel>.self, from: jsonData) else { return }
                if model.code == 200 {
                    guard let ocr = model.data else { return }
                    if rollback {
                        return
                    }
                    bindOCRModel(ocr)
                }else {
                    WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
                }
            default:
                break
            }
        }
    }
    
    private func ocrLivenessId() {
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_license_id, method: .post) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<[String: String]>.self, from: jsonData) else { return }
            guard let license_id = model.data?["license"] else { return }
            checkLicense(license_id)
        }
    }
    
    private func checkLicense(_ licese_id: String) {
        
        let checkResult = AAILivenessSDK.configLicenseAndCheck(licese_id)
        if checkResult == "SUCCESS" {
            let faceVC = Moto_FaceOcrViewController()
            faceVC.detectionFailedBlk = { (vc, err) in
                print(err)
            }
            faceVC.detectionSuccessBlk = { [weak self ] (rawVC, result) in
                guard let self = self else { return }
                uploadIdentityPhoto(1, result.img)
                liscense_id = result.livenessId
                rawVC.navigationController?.popViewController(animated: true)
                guard let faceView: Moto_IdentityView = containerView.viewWithTag(51) as? Moto_IdentityView else { return }
                faceView.icon.image = result.img
            }
            navigationController?.pushViewController(faceVC, animated: true)
        }
    }
    
    private func openCustomPhotoController() {
        
        let photo = R.storyboard.home.moto_custom_photo()!
        photo.cardType = cacheModel.IDType ?? ""
        navigationController?.pushViewController(photo, animated: true)
        photo.takePic { [weak self] image in
            guard let self = self else { return }
            uploadIdentityPhoto(2, image)
            guard let faceView: Moto_IdentityView = containerView.viewWithTag(52) as? Moto_IdentityView else { return }
            faceView.icon.image = image
        }
    }
    
    private func identityInfoTapAction(_ model: Moto_SelectInputModel) {
        
        guard let popView = R.nib.moto_CancelPopView.firstView(withOwner: nil) else { return }
        popView.frame = UIScreen.main.bounds
        popView.tipsTopHeight.constant = -24
        popView.tipsText.textAlignment = .center
        popView.icon.image = R.image.mo_pop_icon()
        switch model.idx {
        case 51:
            if rollback {
                return
            }
            if (faceData != nil) && (faceData!.ez_photo != nil) && faceData?.ez_photo?.count != 0 {
                return
            }
            popView.showText("Face in the frame please. Make sure your face is clear.") { [weak self] in
                guard let self = self else { return }
                ocrLivenessId()
            }
        case 52:
            guard cacheModel.IDType != nil else { WisdomHUD.showTextCenter(text: "Please select type of ID").setFocusing(); return }
            popView.showText("Please lay the documents flat and take a picture of the documents horizontally . Ensure that the ID card in the photo is completed.") { [weak self] in
                guard let self = self else { return }
                openCustomPhotoController()
            }
        default:
            break
        }
    }
    
    private func selectGender(_ gender: String) {
        
        cacheModel.gender = gender
        guard let data = try? JSONEncoder().encode(cacheModel) else { return }
        Moto_Utils.saveData(2, String(data: data, encoding: .utf8))
    }
    
    private func layoutUI() {
        
        var lastView: UIView? = nil
        _ = containerView.subviews.map { $0.removeFromSuperview() }
        for item in items {
            switch item.type {
            case 1, 2:
                let titleView = R.nib.moto_SelectInputView.firstView(withOwner: nil)!
                titleView.tag = item.idx
                titleView.bindData(item) { [weak self] model in
                    guard let self = self else { return }
                    itemViewClick(model)
                }
                containerView.addSubview(titleView)
                titleView.snp.makeConstraints { make in
                    if lastView == nil {
                        make.top.equalTo(containerView)
                    }else {
                        make.top.equalTo(lastView!.snp.bottom)
                    }
                    make.left.right.equalTo(containerView)
                    make.height.equalTo(item.height)
                }
                lastView = titleView
            case 3:
                switch item.idx {
                case 51:
                    let faceIV = R.nib.moto_IdentityView.firstView(withOwner: nil)!
                    faceIV.tag = item.idx
                    faceIV.bindData(item) { [weak self] in
                        guard let self = self else { return }
                        identityInfoTapAction(item)
                    }
                    containerView.addSubview(faceIV)
                    faceIV.snp.makeConstraints { make in
                        if lastView == nil {
                            make.top.equalTo(containerView)
                        }else {
                            make.top.equalTo(lastView!.snp.bottom).offset(15)
                        }
                        make.left.equalTo(containerView).offset(15)
                        make.right.equalTo(containerView).offset(-15)
                        make.height.equalTo(item.height)
                    }
                    lastView = faceIV
                case 52:
                    let cardIV = R.nib.moto_IdentityView.firstView(withOwner: nil)!
                    cardIV.tag = item.idx
                    cardIV.bindData(item) { [weak self] in
                        guard let self = self else { return }
                        identityInfoTapAction(item)
                    }
                    containerView.addSubview(cardIV)
                    cardIV.snp.makeConstraints { make in
                        if lastView == nil {
                            make.top.equalTo(containerView)
                        }else {
                            make.top.equalTo(lastView!.snp.bottom).offset(15)
                        }
                        make.left.equalTo(containerView).offset(15)
                        make.right.equalTo(containerView).offset(-15)
                        make.height.equalTo(item.height)
                    }
                    lastView = cardIV
                default:
                    break
                }
            case 4:
                let genderView = R.nib.moto_GenderView.firstView(withOwner: nil)!
                genderView.tag = item.idx
                genderView.bindData(rollback,item) { [weak self] gender in
                    guard let self = self else { return }
                    selectGender(gender)
                }
                containerView.addSubview(genderView)
                genderView.snp.makeConstraints { make in
                    if lastView == nil {
                        make.top.equalTo(containerView)
                    }else {
                        make.top.equalTo(lastView!.snp.bottom)
                    }
                    make.left.right.equalTo(containerView)
                    make.height.equalTo(item.height)
                }
                lastView = genderView
            default:
                break
            }
        }
        lastView?.snp.makeConstraints({ make in
            make.bottom.equalTo(containerView)
        })
    }
    
    @IBAction func confirmAction() {
        
        if rollback {
            guard let urlstring = faceData?.ez_photo else { return }
            guard let card_name = rollbackCardImageName else {
                WisdomHUD.showTextCenter(text: "Please take your ID photo").setFocusing()
                return
            }
            guard let face_name = urlstring.components(separatedBy: "/").last else { return }
            let params = [
                "pid": "",
                "moto_face_photo": face_name,
                "moto_card_photo": card_name
            ]
            
            WisdomHUD.showLoading(text: "")
            Moto_Networking.request(path: Moto_Apis.Moto_api_card_data_back, method: .post, params: params) { [weak self] data in
                WisdomHUD.dismiss()
                guard let self = self else { return }
                guard let jsonData = data else { return }
                guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
                if model.code == 200 {
                    navigationController?.popToRootViewController(animated: true)
                }else {
                    WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
                }
            }
            
        }else {
            guard let card_no = cacheModel.id_card else { return }
            let length = cacheModel.type_id == "1" ? 12 : cacheModel.type_id == "2" ? 9 : cacheModel.type_id == "3" ? 11 : cacheModel.type_id == "4" ? 10 : cacheModel.type_id == "13" ? 7 : cacheModel.type_id == "22" ? 12 : 16
            if card_no.count != length {
                guard let cardIDView: Moto_SelectInputView = containerView.viewWithTag(53) as? Moto_SelectInputView else { return }
                if cardIDView.inputText.text?.isEmpty ?? true {
                    cardIDView.inputText.attributedPlaceholder = NSAttributedString(string: "Please fill in", attributes: [.foregroundColor: UIColor.red])
                }else {
                    cardIDView.inputText.textColor = .red
                }
                let tips = cacheModel.type_id == "1" ? "Please fill in 12 digits" : cacheModel.type_id == "2" ? "fill in 9 digits or English letters" : cacheModel.type_id == "3" ? "Please fill in 11 digits or English letters" : cacheModel.type_id == "4" ? "Please fill in 10 digits" : cacheModel.type_id == "13" ? "Please fill in 7 digits" : cacheModel.type_id == "22" ? "Please fill in 12 digits or English letters" : "Please fill in 16 digits"
                WisdomHUD.showTextCenter(text: tips).setFocusing()
                return
            }
            guard let first_name = cacheModel.first_name else { return }
            guard let last_name = cacheModel.last_name else { return }
            if let middle_name = cacheModel.middle_name {
                if !Moto_Utils.verifyName(middle_name) {
                    WisdomHUD.showTextCenter(text: "Please input your name in the correct format！").setFocusing()
                    return
                }
            }
            let name = "\(first_name)\(cacheModel.middle_name ?? "")\(last_name)"
            if !Moto_Utils.verifyName(name) {
                WisdomHUD.showTextCenter(text: "Please input your name in the correct format！").setFocusing()
                return
            }
            
            guard let type = cacheModel.IDType else { return }
            guard let birthday = cacheModel.birthday else { return }
            let params = [
                "moto_card_type": type,
                "moto_sex": cacheModel.gender ?? "Male",
                "moto_tel_mode": UIDevice.platformString,
                "moto_card_number": card_no,
                "moto_birthday_date": birthday,
                "moto_first_name": first_name,
                "moto_middle_name": cacheModel.middle_name ?? "",
                "moto_last_name": last_name,
            ]
            WisdomHUD.showLoading(text: "")
            Moto_Networking.request(path: Moto_Apis.Moto_api_submit_identity, method: .post, params: params) { [weak self] data in
                WisdomHUD.dismiss()
                guard let self = self else { return }
                guard let jsonData = data else { return }
                guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
                if model.code == 200 {
                    auditing_limit()
                    Moto_UploadRisk.uploadRKData(9)
                }else {
                    WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
                }
            }
        }
    }
    
    private func auditing_limit() {
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_user_auditing, method: .post) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                backToViewController(Moto_AuthCenterViewController.self)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    override func backAction() {
        
        if rollback {
            navigationController?.popToRootViewController(animated: true)
        }else {
            guard let popView = R.nib.moto_CancelPopView.firstView(withOwner: nil) else { return }
            view.endEditing(true)
            popView.frame = UIScreen.main.bounds
            popView.titleText.text = "Warm Reminder"
            popView.tipsText.textAlignment = .center
            popView.icon.image = R.image.mo_pop_secure()!
            popView.showText("You have not finished filling in the authentication information. Still return it?") { [weak self] in
                guard let self = self else { return }
                backToViewController(Moto_AuthCenterViewController.self)
            }
        }
    }
}
