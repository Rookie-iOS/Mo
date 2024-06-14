//
//  Moto_NavigatonController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/5/24.
//

import UIKit

class Moto_NavigatonController: UINavigationController {
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.hidesBackButton = true
        let appearance = UINavigationBar.appearance()
        appearance.setBackgroundImage(UIImage(), for: .default)
        appearance.shadowImage = UIImage()
        
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .clear
        navigationBar.backgroundColor = .clear
        navigationBar.titleTextAttributes = [.foregroundColor:UIColor.white, .font:UIFont.systemFont(ofSize: 18, weight: .bold)]
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
