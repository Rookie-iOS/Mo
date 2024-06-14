//
//  Moto_AuthCenterViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD

class Moto_AuthCenterViewController: Moto_ViewController {
    
    @IBOutlet weak var basicView: UIView!
    @IBOutlet weak var identityView: UIView!
    @IBOutlet weak var withdrawView: UIView!
    @IBOutlet weak var smileOptionalView: UIView!
    @IBOutlet weak var basicIcon: UIImageView!
    @IBOutlet weak var optionIcon: UIImageView!
    @IBOutlet weak var identityIcon: UIImageView!
    @IBOutlet weak var cardIcon: UIImageView!
    @IBOutlet weak var submitBtn: UIButton!
    
    private var statusModel: Moto_AuthStatusModel? = nil
    private var basicGradientLayer: CAGradientLayer? = nil
    private var identityGradientLayer: CAGradientLayer? = nil
    private var withdrawGradientLayer: CAGradientLayer? = nil
    private var smileOptionalGradientLayer: CAGradientLayer? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadUI()
    }
    
    private func loadUI() {
        
        loadBackItem()
        title = "Identity Authentication"
        basicGradientLayer = basicView.addGradient("#F19F85".hexColorString(), "#F6D365".hexColorString())
        identityGradientLayer = identityView.addGradient("#5CC9C3".hexColorString(), "#96DEDA".hexColorString())
        withdrawGradientLayer = withdrawView.addGradient("#6190E8".hexColorString(), "#A7BFE8".hexColorString())
        smileOptionalGradientLayer = smileOptionalView.addGradient("#6991C7".hexColorString(), "#A3BDED".hexColorString())
    }
    
    private func loadStatus() {
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_auth_center) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let model = try? JSONDecoder().decode(Moto_BaseModel<Moto_AuthStatusModel>.self, from: jsonData) else { return }
            if model.code == 200 {
                guard let status = model.data else { return }
                statusModel = status
                if statusModel?.user_identity == 1 {
                    basicIcon.image = R.image.mo_authentication_success()!
                }
                if statusModel?.user_face == 1 {
                    identityIcon.image = R.image.mo_authentication_success()!
                }
                if statusModel?.binding_cards == 1 {
                    cardIcon.image = R.image.mo_authentication_success()!
                }
            }else {
                WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
            }
        }
    }
    
    override func backAction() {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func loadHomeStatus() {
        
        WisdomHUD.showLoading(text: "")
        Moto_Networking.request(path: Moto_Apis.Moto_api_home, method: .post) { [weak self] data in
            WisdomHUD.dismiss()
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let homeModel = try? JSONDecoder().decode(Moto_HomeDataModel.self, from: jsonData) else { return }
            guard let product = homeModel.data.first else { return }
            guard let bingingStatus = product.binding_cards_status else { return }
            switch bingingStatus {
            case 0:
                let examine = R.storyboard.home.moto_preliminary()!
                navigationController?.pushViewController(examine, animated: true)
            case 1:
                let loan = R.storyboard.home.moto_loan()!
                loan.bingingStatus = bingingStatus
                loan.product = product
                navigationController?.pushViewController(loan, animated: true)
            case 2:
                let loan = R.storyboard.home.moto_loan()!
                loan.bingingStatus = bingingStatus
                loan.product = product
                navigationController?.pushViewController(loan, animated: true)
            default:
                break
            }
        }
    }
    
    @IBAction func submitAction() {
        
        guard let basic = statusModel?.user_identity else { return }
        guard let identity = statusModel?.user_face else { return }
        guard let cards = statusModel?.binding_cards else { return }
        if basic != 1{
            WisdomHUD.showTextCenter(text: "Please finish basic information first").setFocusing()
            return
        }
        if identity != 1 {
            WisdomHUD.showTextCenter(text: "Please finish identify information first").setFocusing()
            return
        }
        
        if cards == 0 {
            WisdomHUD.showTextCenter(text: "Please finish withdrawal method").setFocusing()
            return
        }
        loadHomeStatus()
    }
    
    @IBAction func authenticationViewTapAction(_ sender: UITapGestureRecognizer) {
        
        guard let tag = sender.view?.tag else { return }
        switch tag {
        case 100:
            guard let basic = statusModel?.user_identity else { return }
            if basic == 1 {
                WisdomHUD.showTextCenter(text: "Please note that the data can't be changed after submission").setFocusing()
                return
            }
            let basicVC = R.storyboard.home.moto_basic()!
            navigationController?.pushViewController(basicVC, animated: true)
        case 200:
            guard let basic = statusModel?.user_identity else { return }
            if basic != 1 {
                WisdomHUD.showTextCenter(text: "Please finish basic information first").setFocusing()
                return
            }
            guard let identity = statusModel?.user_face else { return }
            if identity == 1 {
                WisdomHUD.showTextCenter(text: "Please note that the data can't be changed after submission").setFocusing()
                return
            }
            let face = R.storyboard.home.moto_identify()!
            navigationController?.pushViewController(face, animated: true)
        case 300:
            guard let withdrawStatus = statusModel?.binding_cards else { return }
            if withdrawStatus != 0 {
                return
            }
            let withdraw = R.storyboard.home.moto_withdraw()!
            navigationController?.pushViewController(withdraw, animated: true)
        case 400:
            let webvc = R.storyboard.main.moto_web()!
            webvc.loadSmile()
            webvc.title = "Smile"
            navigationController?.pushViewController(webvc, animated: true)
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        basicGradientLayer?.frame = basicView.bounds
        identityGradientLayer?.frame = identityView.bounds
        withdrawGradientLayer?.frame = withdrawView.bounds
        smileOptionalGradientLayer?.frame = smileOptionalView.bounds
    }
}
