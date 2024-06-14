//
//  Moto_FeedViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/7/24.
//

import UIKit

class Moto_FeedViewController: Moto_ViewController {

    @IBOutlet weak var productBtn: UIButton!
    @IBOutlet weak var collectionBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollIV: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadUI()
    }
    
    private func loadUI() {
            
            loadBackItem()
            title = "Feedback"
            loadService(R.image.mo_new_service_icon())
            navigationBarColor = "#0E623A".hexColorString()

            guard let pro = R.storyboard.mine.moto_feed_pro() else { return }
            guard let coll = R.storyboard.mine.moto_feed_collection() else { return }
            
            addChild(pro)
            addChild(coll)
            
            containerView.addSubview(pro.view)
            containerView.addSubview(coll.view)
            
            pro.view.snp.makeConstraints { make in
                make.top.left.bottom.equalTo(containerView)
                make.width.equalTo(Moto_Const.width)
            }

            coll.view.snp.makeConstraints { make in
                make.top.right.bottom.equalTo(containerView)
                make.left.equalTo(pro.view.snp.right)
                make.width.equalTo(Moto_Const.width)
            }
        }
        
        @IBAction func feedbackBtnsClick(_ sender: UIButton) {
            
            _ = sender.superview?.subviews.map {
                ($0 as! UIButton).isSelected = false
                $0.backgroundColor = .white.withAlphaComponent(0.12)
            }
            
            sender.isSelected = true
            sender.backgroundColor = .white
            let contentOffsetX = sender.tag == 100 ? 0 : Moto_Const.width
            scrollIV.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
        }
    
}
