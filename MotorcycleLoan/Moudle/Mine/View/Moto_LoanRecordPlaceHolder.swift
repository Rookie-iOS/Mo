//
//  Moto_LoanRecordPlaceHolder.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class Moto_LoanRecordPlaceHolder: Moto_BaseView {
    
    @IBAction func getLoan() {
        
        controller?.navigationController?.popToRootViewController(animated: false)
        Moto_Utils.goHome()
    }
}
