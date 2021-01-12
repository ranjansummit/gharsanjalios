//
//  ListViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 12/15/17.
//  Copyright © 2017 Andmine. All rights reserved.
//


import UIKit
import SwiftyUserDefaults
enum ListType {
    case Model
    case Brand
    case EngineCapacity
}


class ListViewController: RootViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var list:[Any]?
    var selectedName:String?
    var selectedIndex:((Int?)->())?
    var listType:ListType!
    
    public var pageTitle:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = self.list else {
            showAlert(title: "", message: "No list available."){
            self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        //   self.title = pageTitle
        self.navigationItem.hidesBackButton = true
        
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_nav_back"), style: .plain, target: self, action: #selector(ListViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem = button
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    @objc private func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
}



extension ListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (list?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCell")
        cell?.tintColor = .red
        switch listType {
        case .Brand?:
            let brands = list as! [Brands]
            let brand = brands[indexPath.row]
            cell?.textLabel?.text = brand.brand_name
            if let brandSelected = selectedName{
                cell!.accessoryType = brandSelected == brand.brand_name ? .checkmark : .none
            }
        case .Model?:
            let models = list as!  [Models]
            let model = models[indexPath.row]
            cell?.textLabel?.text = model.model_name
            if let modelSelected = selectedName{
                cell!.accessoryType = modelSelected == model.model_name ? .checkmark : .none
            }
            
        default :
            let engines = list as! [Engine]
            let engine = engines[indexPath.row]
            cell?.textLabel?.text = engine.capacity
            if let engineSelected = selectedName {
                cell?.accessoryType = engineSelected == engine.capacity ? .checkmark : .none
            }
        }
        
        return cell!
    }
}


extension ListViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex!(indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
}
