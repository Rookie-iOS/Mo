//
//  Moto_PreliminaryViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/9/24.
//

import UIKit
import YYText

class Moto_PreliminaryViewController: Moto_ViewController {
    
    @IBOutlet weak var minText: UILabel!
    @IBOutlet weak var secText: UILabel!
    @IBOutlet weak var timeText: YYLabel!
    @IBOutlet weak var timeBgView: UIView!
    @IBOutlet weak var timeBgViewHeight: NSLayoutConstraint!
    private var time = 20
    private var timer: DispatchSourceTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadBackItem()
        loadService(R.image.mo_new_service_icon())
        
        let string = "Expect to wait 20 seconds"
        guard let range = string.range(of: "20") else { return }
        let n_range = NSRange(range, in: string)
        let attribute = NSMutableAttributedString(string: string)
        attribute.yy_color = .black
        attribute.yy_alignment = .center
        attribute.yy_font = .systemFont(ofSize: 16)
        attribute.yy_setColor("#25603D".hexColorString(), range: n_range)
        attribute.yy_setFont(UIFont.boldSystemFont(ofSize: 16), range: n_range)
        timeText.attributedText = attribute
        
        startTimer()
        timeBgView.isHidden = false
        timeBgViewHeight.constant = 124
    }
    
    private func loadHomeStatus() {
        
        Moto_Networking.request(path: Moto_Apis.Moto_api_home, method: .post) { [weak self] data in
            guard let self = self else { return }
            guard let jsonData = data else { return }
            guard let homeModel = try? JSONDecoder().decode(Moto_HomeDataModel.self, from: jsonData) else { return }
            guard let product = homeModel.data.first else { return }
            guard let bingingStatus = product.binding_cards_status else { return }
            let loan = R.storyboard.home.moto_loan()!
            loan.bingingStatus = bingingStatus
            loan.product = product
            switch bingingStatus {
            case 1:
                navigationController?.pushViewController(loan, animated: true)
            case 2:
                navigationController?.pushViewController(loan, animated: true)
            default:
                break
            }
        }
    }
    
    private func startTimer() {
        
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if time == 0 {
                stopTimer()
                timeBgView.isHidden = true
                timeBgViewHeight.constant = 0
            }else {
                minText.text = "\(time / 10)"
                secText.text = "\(time % 10)"
                time -= 1
                if time == 16 || time == 11 || time == 6 || time == 1 {
                    loadHomeStatus()
                }
            }
        }
        timer.resume()
    }
    
    private func stopTimer() {
        
        if timer == nil {
            return
        }
        timer.cancel()
        timer = nil
        time = 20
    }
    
    override func backAction() {
        stopTimer()
        navigationController?.popToRootViewController(animated: true)
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
