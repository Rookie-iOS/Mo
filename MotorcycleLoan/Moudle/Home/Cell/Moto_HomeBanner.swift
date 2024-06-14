//
//  Moto_HomeBanner.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/6/24.
//

import UIKit

class Moto_HomeBanner: UICollectionViewCell {
    
    private var imgIV = UIImageView()
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override init(frame: CGRect) {
            
            super.init(frame: frame)
            addSubview(imgIV)
            imgIV.contentMode = .scaleAspectFill
            imgIV.snp.makeConstraints { make in
                make.edges.equalTo(self)
            }
        }
        
        func bindImage(_ image: UIImage) {
            
            imgIV.image = image
        }
}
