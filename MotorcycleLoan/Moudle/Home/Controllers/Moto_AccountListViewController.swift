//
//  Moto_AccountListViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit
import WisdomHUD

class Moto_AccountListViewController: Moto_ViewController {
    
    var accountType = 1
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var tipsText: UILabel!
    @IBOutlet weak var tabIV: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tipsTextHeight: NSLayoutConstraint!
    
    private var shapeLayer: CAShapeLayer? = nil
    private var accountList = [Moto_UserAccountModel]()
    var changeLoanMethod:((_ account: Moto_UserAccountModel) -> Void)? = nil
    
    lazy var placeHolder: Moto_AccountPlaceHolder = {
        let placeHolder = R.nib.moto_AccountPlaceHolder.firstView(withOwner: nil)!
        return placeHolder
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        addView.width = Moto_Const.width - 26
        if shapeLayer == nil {
            shapeLayer = addView.addDashedBorder("#25603D".hexColorString(), "#25603D".hexColorString(0.1))
        }
        addView.layer.addSublayer(shapeLayer!)
        
        let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        footerView.height = height
        tabIV.tableFooterView = footerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        placeHolder.type = accountType
        placeHolder.isHidden = true
        view.addSubview(placeHolder)
        
        tabIV.separatorStyle = .none
        tabIV.register(R.nib.moto_UserAccountListCell)
        tabIV.rowHeight = UITableView.automaticDimension
        placeHolder.addAction { [weak self] type in
            guard let self = self else { return }
            addAccountAction()
        }
        placeHolder.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        // custom tableView FooterView
        titleText.text = accountType == 1 ? "Add Ewallet" : "Add Bank Card"
        tipsText.text = "1. Please note that the withdrawal method will not be change after select it. \n2. Other unofficial repayment channels are not acceptable to avoid being frauded. \n3. If you pay the loan on time,you will enjoy the audit exemption period.If you are several days overdue,your next loan limit may reduced to the minimum."
    }
    
    private func loadData() {
        
        switch accountType {
        case 1:
            loadEwallet()
        case 2:
            loadBank()
        default:
            break
        }
    }
    
    private func loadEwallet() {
        
        accountList.removeAll()
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_ewallet_list) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<[Moto_UserAccountModel]>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let list = model.data else { return }
                for item in list {
                    accountList.append(item)
                }
                tabIV.reloadData()
                placeHolder.isHidden = !accountList.isEmpty
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func loadBank() {
        
        accountList.removeAll()
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_bank_list) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<[Moto_UserAccountModel]>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let list = model.data else { return }
                for item in list {
                    accountList.append(item)
                }
                tabIV.reloadData()
                placeHolder.isHidden = !accountList.isEmpty
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    @IBAction func tapAddAccountAction(_ sender: UITapGestureRecognizer) {
        addAccountAction()
    }
    
    
    private func addAccountAction() {
        
        guard let addAccount = R.storyboard.home.moto_add_account() else { return }
        addAccount.accountType = accountType
        navigationController?.pushViewController(addAccount, animated: true)
        switch accountType {
        case 1:
            MotoLog("add ewallet")
        case 2:
            MotoLog("add bankcard")
        default:
            break
        }
    }
}

extension Moto_AccountListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let account = accountList[indexPath.row]
        guard let account_id = account.id else { return }
        
        var params = [String: Any]()
        var baseURL = ""
        switch accountType {
        case 1:
            params["moto_wall_id"] = account_id
            baseURL = Moto_Apis.Moto_api_ewallet_default
        case 2:
            params["moto_bank_id"] = account_id
            baseURL = Moto_Apis.Moto_api_bank_default
        default:
            break
        }
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path:baseURL , method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                navigationController?.popViewController(animated: true)
                guard let chanage = changeLoanMethod else { return }
                chanage(account)
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
}

extension Moto_AccountListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_UserAccountListCell.identifier, for: indexPath) as! Moto_UserAccountListCell
        cell.bindData(accountType, accountList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
