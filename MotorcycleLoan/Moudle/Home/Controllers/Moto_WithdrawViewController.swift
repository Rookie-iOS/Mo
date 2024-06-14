//
//  Moto_WithdrawViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit

class Moto_WithdrawViewController: Moto_ViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ewalletBtn: UIButton!
    @IBOutlet weak var bankCardBtn: UIButton!
    @IBOutlet weak var scrollIV: UIScrollView!
    var changeLoanMethod:((_ account: Moto_UserAccountModel) -> Void)? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadUI()
    }
    
    private func loadUI() {
        
        loadBackItem()
        title = "Withdrawal Method"
        loadService(R.image.mo_new_service_icon())
        navigationBarColor = "#0E623A".hexColorString()
        
        guard let ewallet = R.storyboard.home.moto_account_list() else { return }
        ewallet.accountType = 1
        
        guard let bank = R.storyboard.home.moto_account_list() else { return }
        bank.accountType = 2
        
        addChild(ewallet)
        addChild(bank)
        ewallet.changeLoanMethod = changeLoanMethod
        bank.changeLoanMethod = changeLoanMethod
        containerView.addSubview(ewallet.view)
        containerView.addSubview(bank.view)
        
        ewallet.view.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(containerView)
            make.width.equalTo(Moto_Const.width)
        }
        
        bank.view.snp.makeConstraints { make in
            make.left.equalTo(ewallet.view.snp.right)
            make.top.right.bottom.equalTo(containerView)
            make.width.equalTo(ewallet.view)
        }
    }
    
    @IBAction func methodViewBtnsAction(_ sender: UIButton) {
        
        _ = sender.superview?.subviews.map {
            ($0 as! UIButton).isSelected = false
            $0.backgroundColor = .white.withAlphaComponent(0.12)
        }
        
        sender.isSelected = true
        sender.backgroundColor = .white
        
        let offsetX = sender.tag == 100 ? 0 : Moto_Const.width
        scrollIV.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

extension Moto_WithdrawViewController:  UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x == 0 {
            methodViewBtnsAction(ewalletBtn)
        }
        
        if scrollView.contentOffset.x == Moto_Const.width {
            methodViewBtnsAction(bankCardBtn)
        }
    }
}
