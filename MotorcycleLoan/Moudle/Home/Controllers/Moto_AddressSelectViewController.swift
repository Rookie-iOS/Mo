//
//  Moto_AddressSelectViewController.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_AddressSelectViewController: Moto_ViewController {
    
    enum MO_AddressFrom {
        case job
        case address
    }
    var level = 1
    var from: MO_AddressFrom = .job
    
    var selectCity:Moto_City?
    var selectProvice:Moto_Provice?
    
    var provices = [[Moto_Provice]]()
    var cities = [[Moto_City]]()
    var streets = [[Moto_Barangay]]()
    private var addressSelected:((_ provice: Moto_Provice, _ city: Moto_City, _ street: Moto_Barangay) -> Void)? = nil
    
    @IBOutlet weak var tabIV: UITableView!
    @IBOutlet weak var cityIV: UIView!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var provinceIV: UIView!
    @IBOutlet weak var barangayIV: UIView!
    @IBOutlet weak var barangayView: UIView!
    @IBOutlet weak var selectCityText: UITextField!
    @IBOutlet weak var selectProviceText: UITextField!
    @IBOutlet weak var selectBarangayText: UITextField!
    @IBOutlet weak var cityViewHeight: NSLayoutConstraint!
    @IBOutlet weak var barangayViewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadUI()
        layoutSelectUI()
    }
    
    private func loadUI() {
        
        loadBackItem()
        title = "Address"
        
        provinceIV.layer.borderWidth = 1
        provinceIV.layer.cornerRadius = 10
        provinceIV.layer.borderColor = "#25603D".hexColorString().cgColor
        
        cityIV.layer.borderWidth = 1
        cityIV.layer.cornerRadius = 10
        cityIV.layer.borderColor = "#25603D".hexColorString().cgColor
        
        barangayIV.layer.borderWidth = 1
        barangayIV.layer.cornerRadius = 10
        barangayIV.layer.borderColor = "#25603D".hexColorString().cgColor
        
        tabIV.separatorStyle = .none
        tabIV.register(R.nib.moto_AddressCell)
        tabIV.separatorInset = UIEdgeInsets.zero
        tabIV.rowHeight = UITableView.automaticDimension
    }
    
    func addressFinishSelectAction(_ completion:@escaping((_ provice: Moto_Provice, _ city: Moto_City, _ street: Moto_Barangay) -> Void)) {
        addressSelected = completion
    }
    
    private func layoutSelectUI() {
        
        switch level {
        case 1:
            if level == 1 {
                Moto_AddressParse.parseAddress { [weak self] list in
                    guard let self = self else { return }
                    provices.append(contentsOf: list)
                    tabIV.reloadData()
                }
            }
        case 2:
            
            cityView.isHidden = false
            cityViewHeight.constant = 64
            selectProviceText.text = selectProvice?.name
            provinceIV.layer.borderColor = "#CCCCCC".hexColorString().cgColor
            
        case 3:
            
            cityView.isHidden = false
            cityViewHeight.constant = 64
            
            barangayView.isHidden = false
            barangayViewHeight.constant = 64
            
            selectCityText.text = selectCity?.name
            selectProviceText.text = selectProvice?.name
            cityIV.layer.borderColor = "#CCCCCC".hexColorString().cgColor
            provinceIV.layer.borderColor = "#CCCCCC".hexColorString().cgColor
            
        default:
            break
        }
    }
    
    @IBAction func resetAction() {
        
        switch level {
        case 2:
            level = 1
            layoutSelectUI()
            navigationController?.popViewController(animated: true)
        case 3:
            level = 1
            layoutSelectUI()
            guard let vcs = navigationController?.viewControllers else { return }
            let count = vcs.count
            if count - 3 > 0 {
                let vc = vcs[count - 3]
                navigationController?.popToViewController(vc, animated: true)
            }
        default:
            break
        }
        print("reset")
    }
    
}

extension Moto_AddressSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: Moto_Const.width, height: height))
        header.backgroundColor = "#F3F5F7".hexColorString()
        let titleText = UILabel(frame: CGRect(x: 13, y: 0, width: Moto_Const.width - 26, height: height))
        switch level {
        case 1:
            guard let pre = provices[section].first?.name.prefix(1) else { return nil }
            titleText.text = String(pre)
        case 2:
            guard let pre = cities[section].first?.name.prefix(1) else { return nil }
            titleText.text = String(pre)
        case 3:
            guard let pre = streets[section].first?.name.prefix(1) else { return nil }
            titleText.text = String(pre)
        default:
            break
        }
        
        header.addSubview(titleText)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch level {
        case 1:
            let provice = provices[indexPath.section][indexPath.row]
            selectProvice = provice
            let addressSelect = R.storyboard.home.moto_address_select()!
            addressSelect.from = from
            addressSelect.level = 2
            addressSelect.selectProvice = provice
            addressSelect.cities = provice.cities
            addressSelect.addressSelected = addressSelected
            navigationController?.pushViewController(addressSelect, animated: true)
        case 2:
            let city = cities[indexPath.section][indexPath.row]
            let addressSelect = R.storyboard.home.moto_address_select()!
            addressSelect.from = from
            addressSelect.level = 3
            addressSelect.selectCity = city
            addressSelect.selectProvice = selectProvice
            addressSelect.streets = city.barangaies
            addressSelect.addressSelected = addressSelected
            navigationController?.pushViewController(addressSelect, animated: true)
        case 3:
            let barangay = streets[indexPath.section][indexPath.row]
            guard let p = selectProvice, let c = selectCity else { return }
            guard let select = addressSelected else { return }
            select(p, c, barangay)
            if from == .job {
                backToViewController(Moto_JobViewController.self)
            }else {
                backToViewController(Moto_AddressInfoViewController.self)
            }
        default:
            break
        }
    }
}

extension Moto_AddressSelectViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return level == 1 ? provices.count : level == 2 ? cities.count : streets.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return level == 1 ? provices[section].count : level == 2 ? cities[section].count : streets[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.moto_AddressCell.identifier, for: indexPath) as! Moto_AddressCell
        cell.selectionStyle = .none
        if level == 1 {
            cell.bindProviceData(provices[indexPath.section][indexPath.row])
        }else if(level == 2){
            cell.bindCityData(cities[indexPath.section][indexPath.row])
        }else {
            cell.bindBarangayData(streets[indexPath.section][indexPath.row])
        }
        return cell
    }
}
