//
//  Moto_HomeViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/6/24.
//

import UIKit
import WisdomHUD
import SwiftPageView
import StoreKit
import AppsFlyerLib

class Moto_HomeViewController: Moto_ViewController {
    
    @IBOutlet weak var sayText: UILabel!
    @IBOutlet weak var tabIV: UITableView!
    @IBOutlet weak var marqueeViewContainer: UIView!
    
    private let marquee = PageView()
    private var homeModel: Moto_HomeDataModel? = nil
    private var repayModel: Moto_HomeRepayModel? = nil
    private var marquees = [Moto_HomeMarqueeModel]()
    lazy var footerView: Moto_HomeFooter = {
        let footer = R.nib.moto_HomeFooter.firstView(withOwner: nil)!
        return footer
    }()
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        footerView.height = height
        tabIV.tableFooterView = footerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarColor = .clear
        loadData()
    }
    
    private func uploadHomeRiskData() {
        
        guard let token = Moto_Utils.userInfo()?.phone else { return }
        if token.isEmpty {
            return
        }
        UserDefaults.standard.register(defaults: ["\(Moto_Utils.userInfo()?.phone ?? "")_count": 20])
        UserDefaults.standard.register(defaults: ["\(Moto_Utils.userInfo()?.phone ?? "")_date": Date()])
        
        let date = UserDefaults.standard.value(forKey: "\(Moto_Utils.userInfo()?.phone ?? "")_date") as! Date
        if !Calendar.current.isDateInToday(date) {
            UserDefaults.standard.set(Date(), forKey: "\(Moto_Utils.userInfo()?.phone ?? "")_date")
            UserDefaults.standard.setValue(20, forKey: "\(Moto_Utils.userInfo()?.phone ?? "")_count")
        }
        var count = UserDefaults.standard.integer(forKey: "\(Moto_Utils.userInfo()?.phone ?? "")_count")
        if count != 0 {
            Moto_UploadRisk.uploadRKData(3)
            count -= 1
            UserDefaults.standard.setValue(count, forKey: "\(Moto_Utils.userInfo()?.phone ?? "")_count")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadUI()
    }
    
    private func loadMarquee() {
        
        marquee.isInfinite = true
        marquee.dataSource = self
        marquee.scrollDirection = .vertical
        marquee.automaticSlidingInterval = 3
        marqueeViewContainer.addSubview(marquee)
        marquee.isUserInteractionEnabled = false
        marquee.itemSize = marqueeViewContainer.bounds.size
        marquee.registerCell(Moto_HomeMarqueeCell.self)
        marquee.snp.makeConstraints { make in
            make.left.centerX.right.equalTo(marqueeViewContainer)
            make.height.equalTo(36)
        }
    }
    
    private func loadUI() {
        
        loadMarquee()
        loadService()
        
        tabIV.separatorStyle = .none
        tabIV.showsVerticalScrollIndicator = false
        
        tabIV.register(R.nib.moto_HomeInitalCell)
        tabIV.register(R.nib.moto_HomeStatusCell)
        tabIV.register(R.nib.moto_HomeInViewCell)
        tabIV.register(R.nib.moto_HomeRepayCell)
        
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 4 && hour < 11 {
            sayText.text = "Good Morning!"
        }else if(hour >= 11 && hour < 17) {
            sayText.text = "Good Afternoon!"
        }else {
            sayText.text = "Good Evening!"
        }
    }
    
    private func requestReapyInfo() {
        
        guard let product = homeModel?.data.first else { tabIV.reloadData(); return }
        guard let pid = product.id else { tabIV.reloadData(); return }
        
        var urlPath = ""
        let params: [String: Any] = [
            "pid": pid
        ]
        if product.tadpole_loan == 0 {
            urlPath = Moto_Apis.Moto_api_old_repay_info
        }else {
            urlPath = Moto_Apis.Moto_api_repay_info
        }
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: urlPath, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { self?.tabIV.reloadData(); return }
            guard let jsonData = data else { tabIV.reloadData(); return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_HomeRepayModel>.self, from: jsonData) else { tabIV.reloadData(); return }
            if model.code == 200 {
                guard let _model = model.data else { return }
                repayModel = _model
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
            tabIV.reloadData();
        }
    }
    
    private func loadData() {
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_home, method: .post) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let _homeModel = try? JSONDecoder().decode(Moto_HomeDataModel.self, from: jsonData) else { return }
            homeModel = _homeModel
            UserDefaults.standard.setValue(_homeModel.service_one, forKey: "service_one")
            UserDefaults.standard.setValue(_homeModel.service_two, forKey: "service_two")
            if _homeModel.code == 200 {
                marquees.append(contentsOf: _homeModel.carousel_text)
                marquee.reloadData()
                guard let product = _homeModel.data.first else { return }
                if product.status == 0 {
                    Moto_Utils.logout()
                }
                if product.status == 2 {
                    SKStoreReviewController.requestReview()
                }
                if product.status == 5 {
                    // 请求还款接口
                    requestReapyInfo()
                }else {
                    tabIV.reloadData()
                }
            }
        }
    }
    
    private func reloanAction() {
        guard let product = homeModel?.data.first else { return }
        guard let pid = product.id else { return }
        let params: [String: Any] = [
            "pid": pid
        ]
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_reloan_submit, method: .post, params: params) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_DataModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                loadData()
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    private func homeApplyBtnAction(_ status: Int) {
        guard let product = homeModel?.data.first else { return }
        switch status {
        case 3, 10:
            
            let loan = R.storyboard.home.moto_loan()!
            loan.hidesBottomBarWhenPushed = true
            loan.product = product
            navigationController?.pushViewController(loan, animated: true)
        case 4:
            let face = R.storyboard.home.moto_identify()!
            face.rollback = true
            face.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(face, animated: true)
        case 6:
            reloanAction()
            AppsFlyerLib.shared().logEvent("mo_huankuan", withValues: nil)
        case 8:
            let feedBack = R.storyboard.mine.moto_feed()!
            feedBack.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(feedBack, animated: true)
        default:
            break
        }
    }
}

extension Moto_HomeViewController: PageViewDataSource {
    func numberOfItems(in pagerView: PageView) -> Int {
        return marquees.count
    }
    
    func pageView(_ pageView: PageView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = pageView.dequeueReusableCell(Moto_HomeMarqueeCell.self, indexPath: indexPath)
        cell.bindData(marquees[indexPath.row])
        return cell
    }
}

extension Moto_HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let status = homeModel?.data.first?.status
        switch status {
        case 0, 1, 12:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_HomeInitalCell.identifier, for: indexPath) as! Moto_HomeInitalCell
            cell.selectionStyle = .none
            cell.bindData(homeModel)
            return cell
        case 2, 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_HomeInViewCell.identifier, for: indexPath) as! Moto_HomeInViewCell
            cell.selectionStyle = .none
            cell.bindData(homeModel)
            return cell
        case 3, 4, 6, 8, 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_HomeStatusCell.identifier, for: indexPath) as! Moto_HomeStatusCell
            cell.selectionStyle = .none
            cell.bindData(homeModel) { [weak self] status in
                guard let self = self else { return }
                homeApplyBtnAction(status)
            }
            return cell
        case 5:
            let product = homeModel?.data.first
            let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_HomeRepayCell.identifier, for: indexPath) as! Moto_HomeRepayCell
            cell.selectionStyle = .none
            cell.bindData(product, repayModel)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_HomeInitalCell.identifier, for: indexPath) as! Moto_HomeInitalCell
            cell.selectionStyle = .none
            cell.bindData(homeModel)
            return cell
        }
    }
}
