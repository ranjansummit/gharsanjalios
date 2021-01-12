//
//  SellNotificationViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 12/25/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwipeCellKit
import SwiftyUserDefaults
class SellNotificationViewController: RootViewController, SellNotificationViewPresentation {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    fileprivate lazy var messageLabel = UILabel()
    fileprivate var presenter: SellNotificationViewPresenter!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let service = NotificationManager()
        
        presenter = SellNotificationViewPresenter(viewDelegate: self, notificationService: service)
        presenter.fetchNotifications()
    }
    
    // MARK:- View Presentation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    func setupViews() {
        
     //   self.title = "Sell Notifications"
        
        view.backgroundColor = AppTheme.Color.white
        segmentedControl.tintColor = AppTheme.Color.primaryBlue
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
    
    func displayNotificationList() {
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.hideMessageLabel(embeddedLabel: messageLabel)
        
        tableView.reloadData()
    }
    
    func displayError(error: AppError) {
        
        switch error {
        case NotificationError.bikeNotificationEmpty,NotificationError.creditNotificationEmpty:
            
            tableView.reloadData()
            tableView.showMessageLabel(embeddedLabel: messageLabel, message: error.localizedDescription)
            
        default:
            self.showAlert(title: "", message: error.localizedDescription)
        }
    }
    
    func displayMessage(message: String) {
        
        self.showAlert(title: "", message: message)
    }
    
    func updateNotification(at indexPath:IndexPath) {
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func deleteNotification(at indexPath: IndexPath) {
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK:- Button Actions
    
    @IBAction func onCurrentSectionChange(_ sender: UISegmentedControl) {
        
        let selectedSegment = sender.selectedSegmentIndex
        
        if selectedSegment == 0 {
            presenter.displayNotification(for: .bikeNotification)
        } else {
            presenter.displayNotification(for: .creditNotification)
        }
    }
}



extension SellNotificationViewController: UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch presenter.currentSection {
        case .allNotification:
            return 0
        case .bikeNotification:
            return presenter.bikeNotifications.count
        case .creditNotification:
            return presenter.creditNotifications.count
        case .bikeSellNotification:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BikeNotificationCell.stringIdentifier) as! BikeNotificationCell
        cell.delegate = self
        
        let notificationRow = indexPath.row
        
        switch presenter.currentSection {
            
        case .bikeNotification:
            
            let data = presenter.bikeNotifications[notificationRow]
            
            cell.bikeImageView.image = nil
            cell.creditAmountLabel.text = ""
            cell.bikeImageView.contentMode = .scaleAspectFill
            cell.notificationTitleLabel.text = data.status.descriptionForSeller
            cell.notificationDescriptionLabel.text = data.description ?? ""
            cell.bikeImageView.sd_setImage(with: URL(string: data.imageUrl ?? ""), completed: nil)
            
        case .creditNotification:
            
            let data = presenter.creditNotifications[notificationRow]
            
            cell.creditAmountLabel.text = "\(data.creditQuantity ?? 0)"
            cell.notificationTitleLabel.text = "Credit \(data.status.descriptionForSeller)"
            cell.bikeImageView.contentMode = .scaleAspectFit
            cell.bikeImageView.image = #imageLiteral(resourceName: "ic_credit_small")
            cell.notificationDescriptionLabel.text = data.description
        case .allNotification:
            return cell
        case .bikeSellNotification:
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch presenter.currentSection {
        case .creditNotification:
            
            let data = presenter.creditNotifications[indexPath.row]
            
            if data.status == .sent || data.status == .accepted{
                
                let vc = UIStoryboard.sellPathway.instantiateViewController(withIdentifier: CreditBuyerInfoViewController.stringIdentifier) as! CreditBuyerInfoViewController
                vc.info = data
                vc.onCreditRequestAccepted = { [weak self] in
                    self?.presenter.updateCreditNotification(toStatus: .accepted, at: indexPath.row)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
    
    /* MARK:- Swipe Actions
     *
     * Notes:
     *
     * Bike Notification: Swipe actions available are Accept & Decline request
     * Credit Notification: Swipe actions available are Delete Request. Accept is handled from another screen
     */
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        switch presenter.currentSection {
            
        case .bikeNotification:
            
            let notification = presenter.bikeNotifications[indexPath.row]
            
            if notification.status != .expired && notification.status != .rejected && notification.status != .accepted {
                
                let deleteAction = SwipeAction(style: .destructive, title: "Decline \nRequest", handler: { [unowned self] (action, indexPath) in
                    
                    self.presenter.rejectBikeNotification(atIndex: indexPath.row, withVehicleId: notification.vehicleId!, notificationId: notification.id!)
                })
                
                let acceptAction = SwipeAction(style: .default, title: "Accept \nRequest", handler: { [unowned self] (action, indexPath) in
                    
                    self.presenter.acceptBikeNotification(atIndex: indexPath.row, withVehicleId: notification.vehicleId!, notificationId: notification.id!)
                    
                })
                
                acceptAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                acceptAction.backgroundColor = AppTheme.Color.primaryBlue
                
                deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                deleteAction.backgroundColor = AppTheme.Color.primaryRed
                
                acceptAction.image = #imageLiteral(resourceName: "ic_swipe_tick")
                deleteAction.image = #imageLiteral(resourceName: "ic_swipe_cross")
                
                return [acceptAction,deleteAction]
                
            } else {
                
                let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { [unowned self] (action, indexPath) in
                    
                    self.presenter.deleteBikeNotification(atIndex: indexPath.row, vehicleId: notification.vehicleId!, notificationId: notification.id!)
                })
                
                deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                deleteAction.backgroundColor = AppTheme.Color.primaryRed
                deleteAction.image = #imageLiteral(resourceName: "ic_swipe_delete")
                
                return [deleteAction]
                
            }
            
        case .creditNotification:
            
            let notification = presenter.creditNotifications[indexPath.row]
            
            if notification.status == .sent {
            
                let deleteAction = SwipeAction(style: .destructive, title: "Decline \nRequest", handler: { [unowned self] (action, indexPath) in
                    
                    self.presenter.rejectCreditRequest(atIndex: indexPath.row, notificationId: notification.id!)
                    
                })
                
                deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                deleteAction.backgroundColor = AppTheme.Color.primaryRed
                
                deleteAction.image = #imageLiteral(resourceName: "ic_swipe_cross")
                
                return [deleteAction]
                
            } else {
                
                let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { [unowned self] (action, indexPath) in
                    
                    self.presenter.deleteCreditNotification(atIndex: indexPath.row, notificationId: notification.id!)
                })
                
                deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                deleteAction.backgroundColor = AppTheme.Color.primaryRed
                
                deleteAction.image = #imageLiteral(resourceName: "ic_swipe_delete")
                
                return [deleteAction]
            }
        case .allNotification:
            return []
        case .bikeSellNotification:
            return []
        }
        
        /*
         let notification = self.notifications[indexPath.row]
         let vehicleID = notification.vehicleId!
         
         let deleteAction = SwipeAction(style: .destructive, title: "Decline Request"){
         action , indexPath in
         self.updateNotificationStatus(response: 3, vehicleID: vehicleID)
         self.notifications.remove(at: indexPath.row)
         self.tableView.beginUpdates()
         action.fulfill(with: .delete)
         self.tableView.endUpdates()
         
         }
         let acceptAction = SwipeAction(style: .default, title: "Accept Request"){
         action, indexPath in
         self.updateNotificationStatus(response: 1, vehicleID: vehicleID)
         self.notifications.remove(at: indexPath.row)
         self.tableView.beginUpdates()
         action.fulfill(with: .delete)
         self.tableView.endUpdates()
         }
         acceptAction.backgroundColor = AppTheme.Color.primaryBlue
         acceptAction.image = #imageLiteral(resourceName: "ic_rate")
         deleteAction.image = #imageLiteral(resourceName: "ic_rate")
         return [acceptAction,deleteAction]
         
         */
    }
    
    
    private func getCredit(){
        guard let _ = Defaults[.accessToken] else {
            return
        }
        showLoadingIndicator()
        ApiManager.sendRequest(toApi: .getCredit, onSuccess: {status , response in
            self.hideLoadingIndicator()
            if status == 200 {
                if let credit = response["data"].int {
                    Defaults[.callGetCreditInShop] = false
                    Defaults[.userCreditCount] = credit
                    let tabArray = self.tabBarController?.tabBar.items
                    let tabItem = tabArray?[2]
//                    tabItem?.badgeValue = "\(credit)"
                    
                }
            }
            
        }, onError: {error in
            self.hideLoadingIndicator()
            self.showAlert(title: "Error", message: error.localizedDescription)
            
        })
       
    }
}
