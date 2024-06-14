//
//  Moto_BrithDayPickerSelectView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit
import WisdomHUD

class Moto_BrithDayPickerSelectView: Moto_BaseView {
    
    enum DateType {
        case birthday //身份认证-生日选择
    }
    
    private var select:((String) -> Void)? = nil
    @IBOutlet weak var picker: UIDatePicker!
    private var dateStr: String?
    var dateType: DateType = .birthday {
        didSet {
            if dateType == .birthday {
                //当前年-22
                let todaydate = Date()
                let calendar = Calendar.current
                // 设置默认值
                if let defaultDate = calendar.date(byAdding: .year, value: -22, to: todaydate) {
                    picker.date = defaultDate
                    dateSelectAction()
                }
                //最小
                if let minDates = calendar.date(byAdding: .year, value: -80, to: todaydate) {
                    picker.minimumDate = minDates
                }
                //最大
                if let maxDates = calendar.date(byAdding: .year, value: -18, to: todaydate) {
                    picker.maximumDate = maxDates
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        picker.addTarget(self, action: #selector(dateSelectAction), for: .valueChanged)
    }
    
    @objc private func dateSelectAction() {
        
        dateStr = Moto_Utils.formatDateString(picker.date, "MM/dd/YYYY")
    }
    
    @IBAction private func popBtnsAction(_ sender: UIButton) {
        if sender.tag == 101{// 取消
            removeFromSuperview()
        }
        else if sender.tag == 102{
            switch dateType {
            case .birthday:
                guard let block = select else { return }
                guard let date = self.dateStr else { WisdomHUD.showTextCenter(text: "Please select birthday"); return }
                removeFromSuperview()
                block(date)
                break
            }
        }
    }
    
    func showDatePickerView(_ select:@escaping ((String) ->Void)) {
        
        guard let keyWindow = Moto_Utils.keyWindow else { return }
        self.select = select
        keyWindow.addSubview(self)
    }
    
}
