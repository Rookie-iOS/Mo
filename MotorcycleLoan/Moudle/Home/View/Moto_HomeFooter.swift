//
//  Moto_HomeFooter.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/6/24.
//

import UIKit
import SwiftPageView

class Moto_HomeFooter: Moto_BaseView {
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var companyInfoText: UILabel!
    
    private let banner = PageView()
    private var items = [UIImage]()
    private let pageControl = UIPageControl()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        banner.delegate = self
        banner.dataSource = self
        banner.isInfinite = true
        banner.interitemSpacing = 10
        bannerView.addSubview(banner)
        bannerView.layer.cornerRadius = 10
        banner.automaticSlidingInterval = 3
        bannerView.layer.masksToBounds = true
        banner.registerCell(Moto_HomeBanner.self)
        banner.snp.makeConstraints { make in
            make.edges.equalTo(bannerView)
        }
        items = [R.image.mo_home_banner_1()!, R.image.mo_home_banner_2()!, R.image.mo_home_banner_3()!]
        companyInfoText.text = "Asiasource Financial Inc \nCompany Registration No.CS201412567 \nCertificate of Authority No.1085"
        
        bannerView.addSubview(pageControl)
        pageControl.numberOfPages = items.count
        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        pageControl.snp.makeConstraints { make in
            make.right.equalTo(bannerView).offset(20)
            make.bottom.equalTo(bannerView).offset(-5)
            make.size.equalTo(CGSize(width: 120, height: 20))
        }

    }
    
    @IBAction func footerBtnClick(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            let webvc = R.storyboard.main.moto_web()!
            webvc.title = "Custom Service"
            webvc.loadUrlString(Moto_Apis.Moto_h5_help)
            webvc.hidesBottomBarWhenPushed = true
            controller?.navigationController?.pushViewController(webvc, animated: true)
        case 200:
            let feedBack = R.storyboard.mine.moto_feed()!
            feedBack.hidesBottomBarWhenPushed = true
            controller?.navigationController?.pushViewController(feedBack, animated: true)
        default:
            break
        }
    }
}

extension Moto_HomeFooter: PageViewDelegate {
    
    func pageViewDidScroll(_ pageView: PageView, scrollProgress: CGFloat) {
        
        let index = Int(floor(scrollProgress))
        pageControl.currentPage = index
    }
}

extension Moto_HomeFooter: PageViewDataSource {
    
    func numberOfItems(in pageView: SwiftPageView.PageView) -> Int {
        return items.count
    }
    
    func pageView(_ pageView: SwiftPageView.PageView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = pageView.dequeueReusableCell(Moto_HomeBanner.self, indexPath: indexPath)
        cell.bindImage(items[indexPath.row])
        return cell
    }
}
