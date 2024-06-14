//
//  Moto_FaceOcrViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import AAILiveness

class Moto_FaceOcrViewController: AAILivenessViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()

            // Do any additional setup after loading the view.
            
            title = "Face"
            let backBtn = UIButton(type: .custom)
            backBtn.contentHorizontalAlignment = .left
            backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            backBtn.setImage(R.image.mo_navigation_back(), for: .normal)
            backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            let leftItem = UIBarButtonItem(customView: backBtn)
            navigationItem.leftBarButtonItem = leftItem
        }
        
        @objc func backAction() {
            
            navigationController?.popViewController(animated: true)
        }
        
        override func livenessWrapViewDidLoad(_ wrapView: AAILivenessWrapView) {
            super.livenessWrapViewDidLoad(wrapView)
            wrapView.backgroundColor = .white
            wrapView.configAvatarPreviewWidth = {
                return max($0.size.width, Moto_Const.width)
            }
        }
        
        override func loadAdditionalUI() {
            super.loadAdditionalUI()
            
            if let stateLabel = self.value(forKey: "_stateLabel") as? UILabel {
                stateLabel.textColor = "#25603D".hexColorString()
            }
            
            if let backBtn = self.value(forKey: "_backBtn") as? UIButton {
                backBtn.setImage(R.image.mo_navigation_back(), for: .normal)
            }
        }
        
        override func tapBackBtnAction() {
            dismiss(animated: true)
        }
}
