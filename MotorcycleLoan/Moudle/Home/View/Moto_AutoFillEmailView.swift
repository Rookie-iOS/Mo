//
//  Moto_AutoFillEmailView.swift
//  MotorcycleLoan
//
//  Created by Relyn Acha on 6/10/24.
//

import UIKit

class Moto_AutoFillEmailView: Moto_BaseView {
    
    private var dataArray = [String]()
    @IBOutlet weak var tabIV: UITableView!
    private var _selected: ((String) -> Void)? = nil
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        tabIV.delegate = self
        tabIV.dataSource = self
        
        tabIV.rowHeight = 45
        tabIV.separatorStyle = .none
        tabIV.register(UITableViewCell.self, forCellReuseIdentifier: "auto_fill_email_cell")
        
        layer.borderWidth = 0.5
        layer.cornerRadius = 20
        layer.masksToBounds = true
        layer.borderColor = "#cccccc".hexColorString().cgColor
    }
    
    func bindData(_ list: [String], _ selected:@escaping((String) ->Void)) {
        
        _selected = selected
        dataArray.removeAll()
        dataArray.append(contentsOf: list)
        tabIV.reloadData()
    }
    
}

extension Moto_AutoFillEmailView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let s = _selected else { return }
        let email = dataArray[indexPath.row]
        s(email)
    }
}

extension Moto_AutoFillEmailView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "auto_fill_email_cell", for: indexPath)
        cell.textLabel?.textColor = "#333333".hexColorString()
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.textLabel?.text = dataArray[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

