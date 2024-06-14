//
//  Moto_ViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import UIKit

class Moto_ViewController: ViewController {
    
    var navigationBarColor = UIColor.clear {
        didSet {
            guard let navigationBar = navigationController?.navigationBar else { return }
            guard let _barbackground = navigationBar.subviews.filter({ $0.isKind(of: NSClassFromString("_UIBarBackground") ?? UIView.self) }).first else { return }
            _barbackground.backgroundColor = navigationBarColor
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBarColor = "#25603D".hexColorString()
    }
    
    @objc func backAction() {
        
        navigationController?.popViewController(animated: true)
    }
    
    func backToViewController(_ to: Moto_ViewController.Type) {
        
        guard let vcs = navigationController?.viewControllers else { return }
        var toVC: Moto_ViewController? = nil
        vcs.forEach {
            if $0.isKind(of: to) {
                toVC = $0 as? Moto_ViewController
            }
        }
        if toVC == nil {
            navigationController?.popViewController(animated: true)
        }else {
            navigationController?.popToViewController(toVC!, animated: true)
        }
    }
    
    func loadService(_ icon: UIImage? = R.image.mo_navigation_service()) {
        let rightBtn = UIButton(type: .custom)
        rightBtn.setImage(icon, for: .normal)
        rightBtn.addTarget(self, action: #selector(serviceAction), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: rightBtn)
        navigationItem.rightBarButtonItem = rightItem
    }
    
    func loadBackItem() {
        let backBtn = UIButton(type: .custom)
        backBtn.contentHorizontalAlignment = .left
        backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backBtn.setImage(R.image.mo_navigation_back(), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: backBtn)
        navigationItem.leftBarButtonItem = leftItem
    }
    
    @objc private func serviceAction() {
        
        let webvc = R.storyboard.main.moto_web()!
        webvc.title = "Custom Service"
        webvc.loadUrlString(Moto_Apis.Moto_h5_help)
        webvc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webvc, animated: true)
    }
}
