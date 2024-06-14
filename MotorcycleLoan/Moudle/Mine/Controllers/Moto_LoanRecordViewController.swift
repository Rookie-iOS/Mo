//
//  Moto_LoanRecordViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/11/24.
//

import UIKit
import WisdomHUD

class Moto_LoanRecordViewController: Moto_ViewController {

    @IBOutlet weak var tabIV: UITableView!
        private var dataArray = [Moto_LoanRecordModel]()
        lazy var placeholderView: Moto_LoanRecordPlaceHolder = {
            let placeHolder = R.nib.moto_LoanRecordPlaceHolder.firstView(withOwner: nil)!
            return placeHolder
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Do any additional setup after loading the view.
            
            loadUI()
            loadRecordData()
        }
        
        private func loadUI() {
            
            loadBackItem()
            title = "Loan Record"
            
            tabIV.separatorStyle = .none
            tabIV.register(R.nib.moto_LoanRecordCell)
            
            view.addSubview(placeholderView)
            placeholderView.snp.makeConstraints { make in
                make.edges.equalTo(view)
            }
        }
        
        private func loadRecordData() {
            
            WisdomHUD.showLoading(text: "")
            Moto_Networking.request(path: Moto_Apis.Moto_api_loan_record, method: .post) { [weak self] data in
                WisdomHUD.dismiss()
                guard let self = self else { return }
                guard let jsonData = data else { return }
                guard let model = try? JSONDecoder().decode(Moto_BaseModel<[Moto_LoanRecordModel]>.self, from: jsonData) else { return }
                if model.code == 200 {
                    dataArray.removeAll()
                    guard let list = model.data else { return }
                    dataArray.append(contentsOf: list)
                    placeholderView.isHidden = !dataArray.isEmpty
                    tabIV.reloadData()
                }else {
                    WisdomHUD.showTextCenter(text: model.error ?? "").setFocusing()
                }
            }
        }
}

extension Moto_LoanRecordViewController: UITableViewDelegate {}
extension Moto_LoanRecordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_LoanRecordCell.identifier, for: indexPath) as! Moto_LoanRecordCell
        cell.bindData(dataArray[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
