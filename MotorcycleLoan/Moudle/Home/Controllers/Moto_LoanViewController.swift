//
//  Moto_LoanViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit
import YYText
import StoreKit
import WisdomHUD

class Moto_LoanViewController: Moto_ViewController {
    
    /*
     首页状态=12的时候会返回binding_cards_status字段
     binding_cards_status=0，跳倒计时页面，循环几秒刷新首页接口。
     binding_cards_status=1，审核拒绝，跳转详细页面展示合规费率
     binding_cards_status=2，审核通过，跳转详情页面展示真实费率
     **/
    
    private var isReloan = false
    var bingingStatus: Int = 1
    var product: Moto_ProductModel?
    private var pay_type = 2
    private var currentIdx = 0
    private var _maxMoney: Int = 0
    private var group = DispatchGroup()
    private var terms: [Moto_LoadTermModel]?
    private var termExpanded: Bool = false
    private var detailExpanded: Bool = false
    private var userAccount: Moto_LoanAccountModel?
    private var loanDetailData: Moto_LoanDetailModel?
    private var selectTermModel: Moto_UserDataModel?
    private var selectInfoModel: Moto_LoadUserDataInfoDataModel?
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var reduceBtn: UIButton!
    @IBOutlet weak var agreeText: YYLabel!
    @IBOutlet weak var amounText: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var accountText: UILabel!
    @IBOutlet weak var repayInfoText: UILabel!
    @IBOutlet weak var loanAmountText: UILabel!
    @IBOutlet weak var termContainerView: UIView!
    @IBOutlet weak var repayContainerView: UIView!
    @IBOutlet weak var repayInfoIcon: UIImageView!
    @IBOutlet weak var detailInfoIcon: UIImageView!
    @IBOutlet weak var detailAmountText: UILabel!
    @IBOutlet weak var detailIssuedText: UILabel!
    @IBOutlet weak var detailServiceText: UILabel!
    @IBOutlet weak var detailInterestText: UILabel!
    @IBOutlet weak var detailViewHeight: NSLayoutConstraint!

    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           loadData()
       }
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           // Do any additional setup after loading the view.
           loadUI()
           showDetail()
       }
       
       private func loadUI() {
           
           title = "Loan"
           loadBackItem()
           loadService(R.image.mo_new_service_icon())
           
           let string = "I have read and understand the \"Loan Agreement\""
           guard let range = string.range(of: "\"Loan Agreement\"") else { return }
           let n_range = NSRange(range, in: string)
           let attribute = NSMutableAttributedString(string: string)
           attribute.yy_font = .systemFont(ofSize: 13)
           attribute.yy_color = "#333333".hexColorString()
           attribute.yy_setTextHighlight(n_range, color: "#25603D".hexColorString(), backgroundColor: nil) { [weak self] _, _, _, _ in
               guard let self = self else { return }
               tapAgreeText()
           }
           agreeText.numberOfLines = 0
           agreeText.attributedText = attribute
       }
       
       // 合规汇率
       private func refuseData() {
           guard let pid = product?.id else { return }
           let params = ["pid": pid]
           Moto_Networking.request(path: Moto_Apis.Moto_api_refuse_data, method: .post, params: params) { [weak self] data in
               guard let self = self else { self?.group.leave(); return }
               guard let jsonData = data else { group.leave(); return }
               guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_LoanModel>.self, from: jsonData) else { group.leave(); return }
               group.leave()
               if model.code == 200 {
                   guard let _loanData = model.data else { return }
                   guard let list = _loanData.user_data else { return }
                   if list.isEmpty {
                       return
                   }
                   
                   selectTermModel = list.last
                   guard let maxMoney = selectTermModel?.info?.money else { return }
                   _maxMoney = Int(maxMoney) ?? 0
                   
                   guard let moneyList = selectTermModel?.info?.data else { return }
                   guard let index = moneyList.firstIndex(where: { $0.amount == self._maxMoney }) else { return }
                   selectInfoModel = moneyList[index]
                   currentIdx = index
                   
                   guard let _terms = _loanData.user_days else { return }
                   terms = _terms
               }else {
                   WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
               }
           }
       }
       
       private func refusePageTwo() {
           
           guard let termInfo = selectTermModel else { return }
           guard let moneyInfo = selectInfoModel else { return }
           
           let params: [String: Any] = [
               "moto_tid": termInfo.term_id ?? "",
               "moto_money": moneyInfo.amount ?? 0,
               "moto_days": termInfo.days ?? "",
               "moto_rate_id": moneyInfo.rid ?? "",
               "moto_pro_id": termInfo.info?.pro_id ?? "",
           ]
           
           Moto_Networking.request(path: Moto_Apis.Moto_api_refuse_page_two, method: .post, params: params) { [weak self] data in
               WisdomHUD.dismiss()
               guard let self = self else { self?.group.leave(); return }
               guard let jsonData = data else { group.leave(); return}
               guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_LoanDetailModel>.self, from: jsonData) else { group.leave(); return }
               if model.code == 200 {
                   guard let _data = model.data else { group.leave(); return }
                   loanDetailData = _data
                   bindDetailUI()
               }else {
                   WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
               }
           }
       }
       
       // 真实汇率
       private func getMoneyData() {
           guard let pid = product?.id else { return }
           let params = ["pid": pid]
           Moto_Networking.request(path: Moto_Apis.Moto_api_get_money_data, method: .post, params: params) { [weak self] data in
               guard let self = self else { self?.group.leave(); return }
               guard let jsonData = data else { group.leave(); return }
               guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_LoanModel>.self, from: jsonData) else { group.leave(); return }
               group.leave()
               if model.code == 200 {
                   guard let _loanData = model.data else { return }
                   guard let list = _loanData.user_data else { return }
                   if list.isEmpty {
                       return
                   }
                   
                   selectTermModel = list.last
                   guard let maxMoney = selectTermModel?.info?.money else { return }
                   _maxMoney = Int(maxMoney) ?? 0
                   
                   guard let moneyList = selectTermModel?.info?.data else { return }
                   guard let index = moneyList.firstIndex(where: { $0.amount == self._maxMoney }) else { return }
                   selectInfoModel = moneyList[index]
                   currentIdx = index
                   
                   guard let _terms = _loanData.user_days else { return }
                   terms = _terms
               }else {
                   WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
               }
           }
       }
       
       // 账号信息
       private func userAccountInfo() {
           Moto_Networking.request(path: Moto_Apis.Moto_api_account_info, method: .post) { [weak self] data in
               guard let self = self else { self?.group.leave(); return }
               guard let jsonData = data else { group.leave(); return }
               guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_LoanAccountModel>.self, from: jsonData) else { group.leave(); return }
               group.leave()
               if model.code == 200 {
                   guard let _data = model.data else { return }
                   userAccount = _data
               }else {
                   WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
               }
           }
       }
       
       private func showDetail(_ isShow: Bool = false) {
           detailView.isHidden = !isShow
           detailViewHeight.constant = isShow ? 160 : 0
           detailInfoIcon.image = isShow ? R.image.mo_detail_expand() : R.image.mo_arrow_right()
       }
       
       private func detailInfo(_ showLoading: Bool = true) {
           
           guard let termInfo = selectTermModel else { WisdomHUD.dismiss(); return }
           guard let moneyInfo = selectInfoModel else { WisdomHUD.dismiss(); return }
           if showLoading {
               WisdomHUD.showLoading(text: "")
           }
           let params: [String: Any] = [
               "moto_tid": termInfo.term_id ?? "",
               "moto_money": moneyInfo.amount ?? 0,
               "moto_days": termInfo.days ?? "",
               "moto_rate_id": moneyInfo.rid ?? "",
               "moto_pro_id": termInfo.info?.pro_id ?? "",
           ]
           Moto_Networking.request(path: Moto_Apis.Moto_api_loan_detail, method: .post, params: params) { [weak self] data in
               WisdomHUD.dismiss()
               guard let self = self else { return }
               guard let jsonData = data else { return}
               guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_LoanDetailModel>.self, from: jsonData) else { return }
               if model.code == 200 {
                   guard let _data = model.data else { return }
                   loanDetailData = _data
                   bindDetailUI()
               }else {
                   WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
               }
           }
       }
       
       private func loadData() {
           
           group.enter()
           userAccountInfo()
           
           guard let status = product?.status else { return }
           if status == 3 || status == 10 {
               group.enter()
               getMoneyData()
               WisdomHUD.showLoading(text: "")
               group.notify(queue: .main) { [weak self] in
                   guard let self = self else { WisdomHUD.dismiss(); return }
                   detailInfo(false)
                   bindUI()
               }
           }else {
               if bingingStatus == 1 {
                   group.enter()
                   refuseData()
                   
                   WisdomHUD.showLoading(text: "")
                   group.notify(queue: .main) { [weak self] in
                       guard let self = self else { WisdomHUD.dismiss(); return }
                       refusePageTwo()
                       bindUI()
                   }
               }else {
                   group.enter()
                   getMoneyData()
                   
                   WisdomHUD.showLoading(text: "")
                   group.notify(queue: .main) { [weak self] in
                       guard let self = self else { WisdomHUD.dismiss(); return }
                       detailInfo(false)
                       bindUI()
                   }
               }
           }
       }
       
       private func bindUI() {
           
           layoutTerms()
           amounText.text = "PHP \(Moto_Utils.formatMoney(_maxMoney))"
           loanAmountText.text = "PHP \(Moto_Utils.formatMoney(_maxMoney))"
           
           if currentIdx == 0 {
               reduceBtn.isEnabled = false
               reduceBtn.isSelected = false
               addBtn.isEnabled = false
               addBtn.isSelected = false
           }else {
               addBtn.isSelected = false
               addBtn.isEnabled = false
               reduceBtn.isEnabled = true
               reduceBtn.isSelected = true
           }
           
           guard let account = userAccount else { return }
           guard let accountNo = account.account_no else { return }
           let range = accountNo.startIndex ..< accountNo.index(accountNo.endIndex, offsetBy: -4)
           let encry = accountNo.replacingCharacters(in: range, with: "****")
           accountText.text = "\(account.bank_name ?? "") \(encry)"
       }
       
       private func layoutTerms() {
           guard let _terms = terms else { return }
           let width = 150
           _ = termContainerView.subviews.map { $0.removeFromSuperview() }
           var lastView: UIView? = nil
           for item in _terms {
               let itemView = UIView()
               let day = UILabel()
               day.text = item.days_number
               day.textAlignment = .center
               day.font = UIFont.systemFont(ofSize: 16, weight: .medium)
               day.textColor = item.status == 1 ? .white : "#666666".hexColorString()
               
               let termText = UILabel()
               termText.textAlignment = .center
               termText.text = item.stage_number
               termText.font = UIFont.systemFont(ofSize: 14)
               termText.textColor = item.status == 1 ? .white : "#666666".hexColorString()
               
               itemView.layer.cornerRadius = 10
               itemView.backgroundColor = item.status == 1 ? "#25603D".hexColorString() : "#F3F5F7".hexColorString()
               
               itemView.addSubview(day)
               itemView.addSubview(termText)
               
               day.snp.makeConstraints { make in
                   make.centerX.equalTo(itemView)
                   make.top.equalTo(itemView).offset(12)
                   make.size.equalTo(CGSize(width: width, height: 19))
               }
               
               termText.snp.makeConstraints { make in
                   make.bottom.equalTo(itemView).offset(-12)
                   make.size.equalTo(CGSize(width: width, height: 17))
                   make.centerX.equalTo(itemView)
               }
               
               termContainerView.addSubview(itemView)
               itemView.tag = 100 + termContainerView.subviews.count
               let ges = UITapGestureRecognizer(target: self, action: #selector(termSelectAction(_:)))
               itemView.addGestureRecognizer(ges)
               itemView.snp.makeConstraints { make in
                   make.size.equalTo(CGSize(width: width, height: 68))
                   make.centerY.equalTo(termContainerView)
                   if lastView == nil {
                       make.left.equalTo(termContainerView)
                   }else {
                       make.left.equalTo(lastView!.snp.right).offset(8)
                   }
               }
               lastView = itemView
           }
           lastView!.snp.makeConstraints { make in
               make.right.equalTo(termContainerView)
           }
       }
       
       @objc private func termSelectAction(_ ges: UITapGestureRecognizer) {
           
           guard let idx = ges.view?.tag else { return }
           guard let _terms = terms else { return }
           let model = _terms[idx - 101]
           if model.status != 1 {
               WisdomHUD.showTextCenter(text: "Pepay on time for a longer loan term.").setFocusing()
           }
       }
       
       private func bindDetailUI() {
           
           guard let detail = loanDetailData else { return }
           detailAmountText.text = "PHP \(Moto_Utils.formatMoney(detail.loan_amount ?? 0))"
           detailIssuedText.text = "PHP \(Moto_Utils.formatMoney(detail.issued_amount ?? 0))"
           detailServiceText.text = "PHP \(Moto_Utils.formatMoney(detail.service_fee ?? 0))"
           detailInterestText.text = "PHP \(Moto_Utils.formatMoney(detail.interest ?? 0))"
           layoutRepayItem()
       }
       
       private func layoutRepayItem() {
           
           _ = repayContainerView.subviews.map { $0.removeFromSuperview() }
           guard var list = loanDetailData?.repay_data else { return }
           guard let status = product?.status else { return }
           if bingingStatus != 1 || status == 13 {
               //2: zhenshihuilv 1: buxianshicineirong
               let json = "{\"back_time\":\"\", \"repay_price\":0 ,\"install\": -100}"
               guard let data = json.data(using: .utf8) else { return }
               guard let model = try? JSONDecoder().decode(Moto_LoanRepayDatModel.self, from: data) else { return }
               list.insert(model, at: 2)
           }
           
           let count = termExpanded ? list.count : 3
           var last:Moto_BaseView? = nil
           for idx in 0 ..< count {
               let model = list[idx]
               if model.install == -100 {
                   guard let tipsView = R.nib.moto_LoanTipsView.firstView(withOwner: nil) else { return }
                   repayContainerView.addSubview(tipsView)
                   tipsView.snp.makeConstraints { make in
                       if last == nil {
                           make.top.equalTo(repayContainerView)
                       }else {
                           make.top.equalTo(last!.snp.bottom).offset(0.5)
                       }
                       make.left.right.equalTo(repayContainerView)
                       make.height.equalTo(76)
                   }
                   last = tipsView
               }else {
                   guard let repayView = R.nib.moto_LoanRepayItemView.firstView(withOwner: nil) else { return }
                   repayView.bindData(model)
                   repayContainerView.addSubview(repayView)
                   repayView.snp.makeConstraints { make in
                       if last == nil {
                           make.top.equalTo(repayContainerView)
                       }else {
                           make.top.equalTo(last!.snp.bottom).offset(0.5)
                       }
                       make.height.equalTo(76)
                       make.left.equalTo(repayContainerView)
                       make.right.equalTo(repayContainerView)
                   }
                   last = repayView
               }
           }
           last!.snp.makeConstraints { make in
               make.bottom.equalTo(repayContainerView).offset(-0.5)
           }
       }
       
       private func tapAgreeText() {
           let webvc = R.storyboard.main.moto_web()!
           webvc.title = "Loan Service"
           webvc.hidesBottomBarWhenPushed = true
           navigationController?.pushViewController(webvc, animated: true)
           let url = "\(Moto_Apis.Moto_h5_loan_service)?token=\(Moto_Utils.userInfo()?.token ?? "")&use_days=\(selectTermModel?.days ?? "6")&money=\(selectInfoModel?.amount ?? 0)"
           webvc.loadUrlString(url, "Aceptar") { [weak self] in
               guard let self = self else { return }
               agreeBtn.isSelected = true
           }
       }
       
       private func loanSubmit() {
           /**
            check_type: 1：合规汇率 2：真实汇率 3：复借
            moto_pay_type: 2: 电子钱包 1：银行卡
            */
           guard let pid = product?.id else { confirmBtn.isEnabled = true; return }
           let params: [String: Any] = [
               "pid": pid,
               "moto_tid": selectTermModel?.term_id ?? "",
               "moto_money": selectInfoModel?.amount ?? 0,
               "moto_rid": selectInfoModel?.rid ?? "",
               "moto_days": selectTermModel?.days ?? "",
               "moto_pro_id": selectTermModel?.info?.pro_id ?? "",
               "moto_pay_type": pay_type,
               "check_type": bingingStatus,
           ]
           
           WisdomHUD.showLoading(text: "")
           Moto_Networking.request(path: Moto_Apis.Moto_api_submit_loan, method: .post, params: params) { [weak self] data in
               guard let self = self else {
                   self?.confirmBtn.isEnabled = true;
                   WisdomHUD.dismiss()
                   return
               }
               guard let jsonData = data else {
                   confirmBtn.isEnabled = true
                   WisdomHUD.dismiss()
                   return
               }
               guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else {
                   confirmBtn.isEnabled = true
                   WisdomHUD.dismiss()
                   return
               }
               confirmBtn.isEnabled = true
               if model.code == 200 {
                   loanSuccess()
                   WisdomHUD.dismiss()
                   Moto_UploadRisk.uploadRKData(1)
               }else {
                   WisdomHUD.dismiss()
                   WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
               }
           }
       }
       
       private func loanSuccess() {
           
           guard let successView = R.nib.moto_OneBtnPopView.firstView(withOwner: nil) else { return }
           successView.frame = UIScreen.main.bounds
           successView.show { [weak self] in
               guard let self = self else { return }
               if isReloan {
                   showCommit()
               }else {
                   navigationController?.popToRootViewController(animated: true)
               }
           }
       }
       
       private func showCommit() {
           
           SKStoreReviewController.requestReview()
           navigationController?.popToRootViewController(animated: true)
       }
       
       private func getMoney(_ passwd: String, _ code: String? = nil) {
           
           guard let pid = product?.id else {
               confirmBtn.isEnabled = true
               WisdomHUD.dismiss()
               return
           }
           var params: [String: Any] = [
               "moto_tid": selectTermModel?.term_id ?? "",
               "moto_money": selectInfoModel?.amount ?? 0,
               "moto_rid": selectInfoModel?.rid ?? "",
               "moto_password": passwd,
               "moto_pro_id": selectTermModel?.info?.pro_id ?? "",
               "pid": pid,
               "moto_dev_id": Moto_Utils.uuid(),
           ]
           
           if let _code = code {
               if !_code.isEmpty {
                   params["moto_sms_code"] = _code
               }
           }
           
           var url: String!
           if pay_type == 1 {
               url = Moto_Apis.Moto_api_bank_loan
               params["moto_days"] = selectTermModel?.days ?? ""
               params["moto_risk_data"] = Moto_UploadRisk.riskModelString() ?? ""
           }else {
               guard let wcid = userAccount?.wcid else { WisdomHUD.dismiss(); return }
               guard let accountNo = userAccount?.account_no else { WisdomHUD.dismiss(); return }
               url = Moto_Apis.Moto_api_ewallet_loan
               params["moto_wid"] = wcid
               params["moto_acc_number"] = accountNo
               params["moto_pay_days"] = selectTermModel?.days ?? ""
               params["moto_risk_datas"] = Moto_UploadRisk.riskModelString() ?? ""
           }
           
           Moto_Networking.request(path: url, method: .post, params: params) { [weak self] data in
               WisdomHUD.dismiss()
               guard let self = self else {
                   self?.confirmBtn.isEnabled = true
                   return
               }
               guard let jsonData = data else {
                   confirmBtn.isEnabled = true
                   return
               }
               guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_LoanSuccessModel>.self, from: jsonData) else {
                   confirmBtn.isEnabled = true
                   return
               }
               isReloan = true
               confirmBtn.isEnabled = true
               if model.code == 200 {
                   loanSuccess()
                   guard let oid = model.data?.oid, let deta_id = model.data?.deta_id else { return }
                   Moto_UploadRisk.uploadRKData(2, oid, deta_id)
               }else {
                   WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
               }
           }
       }
       
       private func showCodeView(_ passwd: String) {
           guard let codeView = R.nib.moto_LoanSmsCodeView.firstView(withOwner: nil) else {
               confirmBtn.isEnabled = true
               WisdomHUD.dismiss()
               return
           }
           codeView.show { [weak self] code in
               guard let self = self else {
                   self?.confirmBtn.isEnabled = true
                   WisdomHUD.dismiss()
                   return
               }
               getMoney(passwd,code)
           }
       }
       
       private func checkDevice(_ passwd: String) {
           // moto_pay_type: 1: 电子钱包 2：银行卡
           guard let account_no = userAccount?.account_no else {
               confirmBtn.isEnabled = true
               return
           }
           let type = pay_type == 1 ? 2 : 1
           let params: [String: Any] = [
               "moto_pay_type": type,
               "moto_account": account_no,
               "motodev_id": Moto_Utils.uuid()
           ]
           WisdomHUD.showLoading(text: "")
           Moto_Networking.request(path: Moto_Apis.Moto_api_loan_check_device, method: .post, params: params) { [weak self] data in
               guard let self = self else {
                   self?.confirmBtn.isEnabled = true
                   WisdomHUD.dismiss()
                   return
               }
               guard let jsonData = data else {
                   confirmBtn.isEnabled = true
                   WisdomHUD.dismiss()
                   return
               }
               guard let model = try? JSONDecoder().decode(Moto_BaseModel<MO_LoginCheckModel>.self, from: jsonData) else {
                   confirmBtn.isEnabled = true
                   WisdomHUD.dismiss()
                   return
               }
               if model.code == 200 {
                   guard let data = model.data else {
                       confirmBtn.isEnabled = true
                       WisdomHUD.dismiss()
                       return
                   }
                   if data.code_type == 1 {
                       // 直接提款
                       getMoney(passwd)
                   }else {
                       // 弹出密码输入框
                       showCodeView(passwd)
                   }
               }else {
                   WisdomHUD.dismiss()
                   WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
               }
           }
       }
       
       private func surePassword(_ tag: Int, _ passwd: String) {
           
           switch tag {
           case 200:
               let forget = R.storyboard.register.moto_forget()!
               forget.fromLoanPage = true
               navigationController?.pushViewController(forget, animated: true)
           case 400:
               checkDevice(passwd)
           default:
               break
           }
       }
       
       @IBAction func operatitionAmountAction(_ sender: UIButton) {
           switch sender.tag {
           case 100:
               guard let _selectTermModel = selectTermModel else { return }
               guard let moneyList = _selectTermModel.info?.data else { return }
               reduceBtn.isSelected = true
               reduceBtn.isEnabled = true
               if currentIdx < moneyList.count {
                   currentIdx -= 1
                   selectInfoModel = moneyList[currentIdx]
                   loanAmountText.text = "PHP \(Moto_Utils.formatMoney(selectInfoModel?.amount ?? 0))"
                   if currentIdx == 0 {
                       reduceBtn.isSelected = false
                       reduceBtn.isEnabled = false
                   }
                   addBtn.isSelected = true
                   addBtn.isEnabled = true
               }
               detailInfo(false)
               
           case 200:
               guard let _selectTermModel = selectTermModel else { return }
               guard let moneyList = _selectTermModel.info?.data?.filter({ ($0.amount ?? 0) <= _maxMoney }) else { return }
               addBtn.isSelected = true
               addBtn.isEnabled = true
               if currentIdx < moneyList.count {
                   currentIdx += 1
                   selectInfoModel = moneyList[currentIdx]
                   loanAmountText.text = "PHP \(Moto_Utils.formatMoney(selectInfoModel?.amount ?? 0))"
                   if currentIdx == moneyList.count - 1 {
                       addBtn.isSelected = false
                       addBtn.isEnabled = false
                   }
                   reduceBtn.isSelected = true
                   reduceBtn.isEnabled = true
               }
               detailInfo(false)
               
           case 300:
               sender.isSelected = !sender.isSelected
           case 400:
               if !agreeBtn.isSelected {
                   WisdomHUD.showTextCenter(text: "Please read and agree to the agreement").setFocusing()
                   return
               }
               guard let status = product?.status else { return }
               confirmBtn.isEnabled = false
               if status == 12 {
                   loanSubmit()
               }else if (status == 3 || status == 10) {
                   guard let popView = R.nib.moto_ReLoanPopView.firstView(withOwner: nil) else {
                       confirmBtn.isEnabled = true
                       return
                   }
                   guard let loan = loanDetailData else {
                       confirmBtn.isEnabled = true
                       return
                   }
                   guard let account = userAccount else {
                       confirmBtn.isEnabled = true
                       return
                   }
                   popView.show(pay_type, account, loan) { [weak self] tag, passwd in
                       guard let self = self else {
                           self?.confirmBtn.isEnabled = true
                           return
                       }
                       surePassword(tag, passwd)
                   }
               }
           default:
               break
           }
       }
       
       @IBAction func loanTapAction(_ sender: UITapGestureRecognizer) {
           
           guard let tag = sender.view?.tag else { return }
           switch tag {
           case 100:
               let withdraw = R.storyboard.home.moto_withdraw()!
               navigationController?.pushViewController(withdraw, animated: true)
               withdraw.changeLoanMethod = { [weak self] in
                   guard let self = self else { return }
                   var accountNo = ""
                   var accountName = ""
                   if ($0.bank_number != nil) && !$0.bank_number!.isEmpty {
                       accountNo = $0.bank_number ?? ""
                       accountName = $0.name ?? ""
                       pay_type = 1
                   }else {
                       pay_type = 2
                       accountName = $0.title ?? ""
                       accountNo = $0.account_number ?? ""
                   }
                   let range = accountNo.startIndex ..< accountNo.index(accountNo.endIndex, offsetBy: -4)
                   let encry = accountNo.replacingCharacters(in: range, with: "****")
                   accountText.text = "\(accountName) \(encry)"
               }
           case 200:
               detailExpanded = !detailExpanded
               showDetail(detailExpanded)
           case 300:
               termExpanded = !termExpanded
               layoutRepayItem()
               repayInfoText.text = termExpanded ? "Close" : "View more"
               repayInfoIcon.image = termExpanded ? R.image.mo_detail_up() : R.image.mo_detail_down()
           default:
               break
           }
       }
       
       @IBAction func serviceFeeClick() {
           
           guard let detail = loanDetailData else { return }
           guard let feeView = R.nib.moto_ServiceFeeView.firstView(withOwner: nil) else { return }
           feeView.show(detail)
       }
       
       override func backAction() {
           navigationController?.popToRootViewController(animated: true)
       }
   }
