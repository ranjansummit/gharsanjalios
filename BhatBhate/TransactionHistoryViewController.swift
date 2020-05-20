//
//  TransactionHistoryViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 10/12/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwipeCellKit
class TransactionHistoryViewController: RootViewController, TransactionHistoryViewPresentation {
    
    @IBOutlet var tableView: UITableView!
    
    var presenter: TransactionHistoryPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = TransactionHistoryPresenter(controller: self)
        presenter.fetchTransactionHistory()
    }
    
    func displaySuccessMessage(){
        showAlert(title: "Success", message: "Transaction has been removed."){
            self.presenter.fetchTransactionHistory()
        }
        
    }
    
    func displayTransactionHistory() {
        
      //  self.title = "Transaction History"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.reloadData()
    }
    
    func setupViews() {
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
        tableView.tableFooterView = UIView()
    }
    
    func displayError(error: AppError) {
        showAlert(title: "", message: error.localizedDescription){
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
extension TransactionHistoryViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.transactionModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionHistoryTableViewCell.stringIdentifier) as! TransactionHistoryTableViewCell
        
        let viewModel = presenter.transactionModels[indexPath.row]
        cell.delegate = self
        cell.titleLabel.text = viewModel.title
    
        cell.voucherIdLabel.text = viewModel.voucherId
        cell.transactionDateLabel.text = viewModel.date
        cell.iconImageView.image = viewModel.type == 1 ? #imageLiteral(resourceName: "ic_transaction_cart") : #imageLiteral(resourceName: "ic_transaction_swap")
        var status = ""
        var numberOfPurchases =  "\(viewModel.numberOfPurchases)"
        switch viewModel.title {
        case "Vehicle published":
            numberOfPurchases = viewModel.numberOfPurchases == 0 ? "Promotion" : "\(viewModel.numberOfPurchases)"
            status = "Number of Credit Consumed:"
        case "Credit purchased":
            status = "Number of Purchases:"
        case "Credit reverted":
            status = "Number of credit reverted:"
        default:
            status = "Number of Transfers:"
        }
        cell.noOfPurchaseLabel.text = numberOfPurchases
        cell.labelStatus.text = status
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return nil
        }
       let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: {
        [unowned self] action, indexPath in
        self.presenter.deleteTransaction(index: indexPath.row)
       })
        deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        deleteAction.backgroundColor = AppTheme.Color.primaryRed
        deleteAction.image = #imageLiteral(resourceName: "ic_swipe_delete")
        return [deleteAction]
        
    }
    
}


