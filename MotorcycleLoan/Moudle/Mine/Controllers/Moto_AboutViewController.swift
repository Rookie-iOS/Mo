//
//  Moto_AboutViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit

class Moto_AboutViewController: Moto_ViewController {
    
    @IBOutlet weak var versionText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadBackItem()
        title = "About Us"
        
        versionText.text = "Version \(Moto_Utils.versionString())"
    }
}
