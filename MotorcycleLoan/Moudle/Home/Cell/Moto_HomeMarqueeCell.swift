//
//  Moto_HomeMarqueeCell.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit

class Moto_HomeMarqueeCell: UICollectionViewCell {
    
    private let marqueeText = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addSubview(marqueeText)
        marqueeText.font = .systemFont(ofSize: 12)
        marqueeText.textColor = "#25603D".hexColorString()
        marqueeText.snp.makeConstraints { make in
            make.edges.equalTo(self)
            make.height.equalTo(36)
        }
    }
    
    func bindData(_ marquee: Moto_HomeMarqueeModel) {
        
        marqueeText.text = marquee.name
    }
}
