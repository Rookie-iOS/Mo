//
//  Moto_HomeInViewCell.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/8/24.
//

import UIKit

class Moto_HomeInViewCell: UITableViewCell {
    
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var hourText: UILabel!
    @IBOutlet weak var minText: UILabel!
    @IBOutlet weak var secText: UILabel!
    @IBOutlet weak var hourView: UIView!
    @IBOutlet weak var minView: UIView!
    @IBOutlet weak var secView: UIView!
    @IBOutlet weak var countView: UIStackView!
    @IBOutlet weak var bgView: Moto_CornerRaduisView!
    
    private var time = 0
    private var timer: DispatchSourceTimer!
    private var hourGradientLayer: CAGradientLayer? = nil
    private var minGradientLayer: CAGradientLayer? = nil
    private var secGradientLayer: CAGradientLayer? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView.radius = 6
        bgView.layer.borderWidth = 1
        bgView.layer.cornerRadius = 8
        bgView.width = Moto_Const.width - 26
        bgView.layer.borderColor = "#E6E6E6".hexColorString().cgColor
        
        waitView.width = Moto_Const.width - 47 * 2
        hourGradientLayer = hourView.addGradient("#F6D365".hexColorString(), "#F19F85".hexColorString())
        minGradientLayer = minView.addGradient("#F6D365".hexColorString(), "#F19F85".hexColorString())
        secGradientLayer = secView.addGradient("#F6D365".hexColorString(), "#F19F85".hexColorString())
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        hourGradientLayer?.frame = hourView.bounds
        minGradientLayer?.frame = minView.bounds
        secGradientLayer?.frame = secView.bounds
        bgView.drawRadiusWithDashLine(at: 180, "#E6E6E6".hexColorString())
        waitView.addDashedBorder("#EFA000".hexColorString(), "#EFA000".hexColorString(0.1))
    }
    
    private func startTimer() {
        
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if time == 0 {
                stopTimer()
            }else {
                hourText.text = String(format: "%02d", (time/60/60))
                minText.text = String(format: "%02d", (time/60 % 60))
                secText.text = String(format: "%02d", (time % 60))
                time -= 1
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
        waitView.isHidden = false
        countView.isHidden = true
    }
    
    func bindData(_ model: Moto_HomeDataModel?) {
        
        guard let product = model?.data.first else { return }
        
        switch product.status {
        case 2:
            if product.count_down == 0 {
                countView.isHidden = true
                waitView.isHidden = false
            }else {
                time = product.count_down
                countView.isHidden = false
                waitView.isHidden = true
                startTimer()
            }
        case 9:
            time = product.count_down
            countView.isHidden = false
            waitView.isHidden = true
            startTimer()
        default:
            break
        }
    }
    
}
