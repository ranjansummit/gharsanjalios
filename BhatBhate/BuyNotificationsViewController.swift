//
//  SellerNotificationsViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwipeCellKit
import SwiftyUserDefaults

class BuyNotificationsViewController: RootViewController, BuyNotificationViewPresentation {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    fileprivate lazy var messageLabel = UILabel()
    fileprivate var presenter:BuyNotificationViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let service = NotificationManager()
        
        presenter = BuyNotificationViewPresenter(viewDelegate: self,notificationService: service)
        presenter.fetchNotifications()
        // presenter.fetchAllNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        if Defaults[.promotionMode] {
            if Defaults[.preview] {
            if segmentControl.numberOfSegments == 4{
                segmentControl.removeSegment(at: 3, animated: false)
                }
            }else{
           segmentControl.setEnabled(false, forSegmentAt: 3)
            }
        }else{
            segmentControl.setEnabled(true, forSegmentAt: 3)
        }
    }
    
    /*--------------------------
     MARK:- Seller Presentation Protocol
     ---------------------------*/
    
    func setupViews() {
        
        self.view.backgroundColor = AppTheme.Color.white
        
        segmentControl.tintColor = AppTheme.Color.primaryBlue
        
        //   self.title = "Notifications"
        
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
    
    func displayNotificationList() {
         
        if Defaults[.promotionMode]{
            if !Defaults[.preview]{
            self.tabBarController?.tabBar.items?[2].isEnabled = false
            self.tabBarController?.tabBar.items?[2].badgeValue = nil
            }else{
                if segmentControl.numberOfSegments == 4 {
                segmentControl.removeSegment(at: 3, animated: false)
                }
            }
        }else{
            self.tabBarController?.tabBar.items?[2].isEnabled = true
        }
        tableView.hideMessageLabel(embeddedLabel: messageLabel)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func displayError(error: AppError) {
        switch error {
        case NotificationError.notificationEmpty, NotificationError.bikeNotificationEmpty,NotificationError.creditNotificationEmpty:
            
            tableView.reloadData()
            tableView.showMessageLabel(embeddedLabel: messageLabel, message: error.localizedDescription)
            
        default:
            self.showAlert(title: "", message: error.localizedDescription)
        }
        
    }
    
    func displaySellerInfo(vehicleId: Int) {
        
        let sellerInfo = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: SellerInfoViewController.stringIdentifier) as! SellerInfoViewController
        sellerInfo.vehicleId = vehicleId
        self.navigationController?.pushViewController(sellerInfo, animated: true)
    }
    
    func displayDetailsOfBike(bike: Bike) {
        let bikePreview = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BikePreviewViewController.stringIdentifier) as! BikePreviewViewController
        bikePreview.previewState = BikePreviewState.sellPreview
        bikePreview.bike = bike
        self.navigationController?.pushViewController(bikePreview, animated: true)
    }
    
    func updateNotification(at indexPath:IndexPath) {
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func deleteNotification(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func displayMessage(message: String) {
        
        self.showAlert(title: "", message: message){
            self.presenter.fetchNotifications()
        }
    }
    
    @IBAction func onCurrentSegmentChange(_ sender: UISegmentedControl) {
        
        let selectedSegment = sender.selectedSegmentIndex
        
        switch selectedSegment {
        case 0:
            presenter.displayNotification(for: .allNotification)
        case 1:
            presenter.displayNotification(for: .bikeNotification)
        case 2:
            presenter.displayNotification(for: .bikeSellNotification)
        default:
            presenter.displayNotification(for: .creditNotification)
        }
        
    }
}

extension BuyNotificationsViewController: UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch presenter.currentSection {
        case .allNotification:
            //print("table all",presenter.allNotifications.count.description)
            return presenter.allNotifications.count
        case .bikeNotification:
            //print("table buy",presenter.bikeNotifications.count.description)
            
            return presenter.bikeNotifications.count
        case .bikeSellNotification:
           // print("table sell",presenter.bikeSellNotifications.count.description)
            return presenter.bikeSellNotifications.count
        case .creditNotification:
           // print("table credit",presenter.creditNotifications.count.description)
            return presenter.creditNotifications.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BikeNotificationCell.stringIdentifier) as! BikeNotificationCell
        cell.delegate = self
        
        let notificationRow = indexPath.row
        
        switch presenter.currentSection {
            
        case .allNotification:
            let data = presenter.allNotifications[notificationRow]
            cell.bikeImageView.image = nil
            cell.labelNotificationType.isHidden = false
            cell.creditAmountLabel.text = ""
            cell.lblCredit.isHidden = true
            cell.bikeImageView.contentMode = .scaleAspectFill
            let notificationDescription = data.description ?? ""
            cell.bikeImageView.sd_setImage(with: URL(string: data.imageUrl ?? ""), completed: nil)
            if data.type == "sell_vehicle"{
                let buyerName = data.buyerName ?? ""
                cell.notificationDescriptionLabel.attributedText = notificationDescription.boldName(name: buyerName)
                cell.labelNotificationType.text = "Sale"
                 cell.notificationTitleLabel.text = "\(data.status.descriptionForSeller) "
            }else{
                let sellerName = data.sellerName ?? ""
                cell.notificationDescriptionLabel.attributedText = notificationDescription.boldName(name: sellerName)
                cell.notificationTitleLabel.text = "\(data.status.description) \(data.vehicleName ?? "")"
                cell.labelNotificationType.text = "Home"
            }
            if data.type == "credit"{
                var name:String!
                 var titleLabel = NSMutableAttributedString(string:"")
                if let n = data.buyerName  {
                    name = n
                    if data.status == .sent {
                        titleLabel = "From \(n) to buy credit.\n".boldMultipleName()
                    }
                }
                
                if let n = data.sellerName  {
                    name = n
                    if data.status == .accepted || data.status == .rejected{
                        titleLabel = "From \(n) to sell credit.\n".boldMultipleName()
                    }
                }
                
                cell.creditAmountLabel.text = data.creditQuantity?.description
                
                cell.labelNotificationType.isHidden = true
                if let index = presenter.creditNotifications.index(where: {$0.id == data.id}) {
                let creditData = presenter.creditNotifications[index]
                cell.notificationTitleLabel.text = "Credit \(creditData.status.descriptionForBuyer)"
                }
                cell.bikeImageView.image = #imageLiteral(resourceName: "ic_credit_large")
                cell.bikeImageView.contentMode = .scaleAspectFit
                let description = data.description ?? ""
                let attr = description.boldName(name: name)
                let combination = NSMutableAttributedString()
                combination.append(titleLabel)
                combination.append(attr)
                cell.notificationDescriptionLabel.attributedText = combination
                let creditCount = data.creditQuantity ?? 0
                let strCreditLable = creditCount > 1 ? "credits" : "credit"
                cell.lblCredit.isHidden = false
                cell.lblCredit.text = strCreditLable
                //cell.creditAmountLabel.text = data.credit
            }
            
        case .bikeNotification:
            let data = presenter.bikeNotifications[notificationRow]
            let name = data.sellerName ?? ""
            let description = data.description ?? ""
            cell.labelNotificationType.isHidden = false
            cell.labelNotificationType.text = "Buy"
            cell.bikeImageView.image = nil
            cell.creditAmountLabel.text = ""
            cell.bikeImageView.contentMode = .scaleAspectFill
            cell.notificationTitleLabel.text = "\(data.status.description) \(data.vehicleName ?? "")"
            cell.notificationDescriptionLabel.attributedText = description.boldName(name: name)
            cell.bikeImageView.sd_setImage(with: URL(string: data.imageUrl ?? ""), completed: nil)
            cell.lblCredit.isHidden = true
        case .bikeSellNotification:
            let data = presenter.bikeSellNotifications[notificationRow]
            let name = data.buyerName ?? ""
            let description = data.description ?? ""
            cell.labelNotificationType.isHidden = false
            cell.labelNotificationType.text = "Sale"
            cell.bikeImageView.image = nil
            cell.creditAmountLabel.text = ""
            cell.bikeImageView.contentMode = .scaleAspectFill
            cell.notificationTitleLabel.text = "\(data.status.descriptionForSeller)"
            cell.notificationDescriptionLabel.attributedText = description.boldName(name: name)
            cell.bikeImageView.sd_setImage(with: URL(string: data.imageUrl ?? ""), completed: nil)
            cell.lblCredit.isHidden = true
        case .creditNotification:
            var titleLabel = NSMutableAttributedString(string:"")
            let data = presenter.creditNotifications[notificationRow]
            var name:String!
            if let n = data.buyerName  {
                name = n
                if data.status == .sent {
                    titleLabel = "From \(n) to buy credit.\n".boldMultipleName()
                }
            }
            
            if let n = data.sellerName  {
                name = n
                if data.status == .accepted || data.status == .rejected{
                titleLabel = "From \(n) to sell credit.\n".boldMultipleName()
                }
            }
           let description =  (data.description ?? "")
            cell.labelNotificationType.isHidden = true
            cell.creditAmountLabel.text = "\(data.creditQuantity ?? 0)"
            cell.notificationTitleLabel.text = "Credit \(data.status.descriptionForBuyer)"
            cell.bikeImageView.contentMode = .scaleAspectFit
            cell.bikeImageView.image = #imageLiteral(resourceName: "ic_credit_small")
            let attr = description.boldName(name: name)
            let combination = NSMutableAttributedString()
            combination.append(titleLabel)
            combination.append(attr)
            cell.notificationDescriptionLabel.attributedText = combination
            cell.lblCredit.isHidden = false
            let creditCount = data.creditQuantity ?? 0
            let strCreditLable = creditCount > 1 ? "credits" : "credit"
            cell.lblCredit.text = strCreditLable
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch presenter.currentSection {
        case .allNotification:
            let notificationData = presenter.allNotifications[indexPath.row]
            if notificationData.type == "buy_vehicle" && notificationData.status == .accepted {
                self.presenter.fetchSellerDetails(forVehicleId: notificationData.vehicleId!)
            }
            if notificationData.type == "credit"{
                if notificationData.status == .sent || notificationData.status == .accepted {
                    let requestedBy = notificationData.buyerName
                   // let requestedTo = notificationData.sellerName
                    guard let _ = requestedBy else {
                        // for requester dont open credit buyer information
                        return
                    }
                   
                    let vc = UIStoryboard.sellPathway.instantiateViewController(withIdentifier: CreditBuyerInfoViewController.stringIdentifier ) as! CreditBuyerInfoViewController
                   let index = presenter.creditNotifications.index(where: {$0.id == notificationData.id})
                    vc.info = presenter.creditNotifications[index!]
                    vc.onCreditRequestAccepted = { [weak self] in
                        self?.presenter.updateCreditNotification(toStatus: .accepted, at: indexPath.row)
                        self?.presenter.fetchAllNotifications()
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        case .bikeNotification:
            
            let notificationData = presenter.bikeNotifications[indexPath.row]
            
            if notificationData.status == .accepted {
                self.presenter.fetchSellerDetails(forVehicleId: notificationData.vehicleId!)
            }
            
        case .creditNotification:
            let data = presenter.creditNotifications[indexPath.row]
            if data.status == .sent || data.status == .accepted{
                
                let vc = UIStoryboard.sellPathway.instantiateViewController(withIdentifier: CreditBuyerInfoViewController.stringIdentifier) as! CreditBuyerInfoViewController
                vc.info = data
                vc.onCreditRequestAccepted = { [weak self] in
                    self?.presenter.updateCreditNotification(toStatus: .accepted, at: indexPath.row)
                    self?.presenter.fetchNotifications()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        // Only allow swipe from right
        guard orientation == .right else { return nil }
        switch presenter.currentSection {
        case .allNotification:
            var swipeActions:[SwipeAction] = []
            let notification = presenter.allNotifications[indexPath.row]
            switch notification.type! {
            case "buy_vehicle":
                var swipeActions:[SwipeAction] = []
                let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
                    
                    self.presenter.deleteBikeNotificationRequest(atIndex: indexPath.row, vehicleId: notification.vehicleId!, notificationId: notification.id!)
                })
                
                deleteAction.backgroundColor = AppTheme.Color.primaryRed
                deleteAction.image = #imageLiteral(resourceName: "ic_swipe_delete")
                swipeActions.append(deleteAction)
                
                if notification.status.rawValue == 2 {
                    let resendAction = SwipeAction(style: .default, title: "Request", handler: {
                        action , indexPath in
                        
                        self.presenter.notifySellerForInterestInPurchase(vehicleID: notification.vehicleId!, notificationID: notification.id!)
                        
                    })
                    resendAction.backgroundColor = UIColor.lightGray
                    resendAction.image = #imageLiteral(resourceName: "ic_swipe_request")
                    swipeActions.append(resendAction)
                }
                return swipeActions
            case "sell_vehicle":
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
                    swipeActions = [acceptAction,deleteAction]
                    return swipeActions
                    
                } else {
                    
                    let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { [unowned self] (action, indexPath) in
                        
                        self.presenter.deleteBikeNotification(atIndex: indexPath.row, vehicleId: notification.vehicleId!, notificationId: notification.id!)
                    })
                    
                    deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                    deleteAction.backgroundColor = AppTheme.Color.primaryRed
                    deleteAction.image = #imageLiteral(resourceName: "ic_swipe_delete")
                    return [deleteAction]
                }
                
            default:

                if notification.status == .sent && notification.buyerName != nil{
//                    print(notification.buyerName) // nil
//                    print(notification.sellerName) // aayo
                    let deleteAction = SwipeAction(style: .destructive, title: "Decline \nRequest", handler: { [unowned self] (action, indexPath) in
                        
                        self.presenter.rejectCreditRequest(atIndex: indexPath.row, notificationId: notification.id!, fromAll: true)
                        
                    })
                    
                    deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                    deleteAction.backgroundColor = AppTheme.Color.primaryRed
                    
                    deleteAction.image = #imageLiteral(resourceName: "ic_swipe_cross")
                    
                    return [deleteAction]
                    
                } else {
                    
                    let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { [unowned self] (action, indexPath) in
                        self.presenter.deleteCreditNotification(atIndex: indexPath.row, notificationId: notification.id!, all: true, from: (notification.buyerName == nil) ? "buyer" : "seller")
                    })
                    
                    deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                    deleteAction.backgroundColor = AppTheme.Color.primaryRed
                    
                    deleteAction.image = #imageLiteral(resourceName: "ic_swipe_delete")
                    
                    return [deleteAction]
                }
            }
            
        case .bikeNotification:
            var swipeActions:[SwipeAction] = []
            let notification = presenter.bikeNotifications[indexPath.row]
            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
                
                self.presenter.deleteBikeNotificationRequest(atIndex: indexPath.row, vehicleId: notification.vehicleId!, notificationId: notification.id!)
            })
            
            deleteAction.backgroundColor = AppTheme.Color.primaryRed
            deleteAction.image = #imageLiteral(resourceName: "ic_swipe_delete")
            swipeActions.append(deleteAction)
            
            if notification.status.rawValue == 2 {
                let resendAction = SwipeAction(style: .default, title: "Request", handler: {
                    action , indexPath in
                    
                    self.presenter.notifySellerForInterestInPurchase(vehicleID: notification.vehicleId!, notificationID: notification.id!)
                    
                })
                resendAction.backgroundColor = UIColor.lightGray
                resendAction.image = #imageLiteral(resourceName: "ic_swipe_request")
                swipeActions.append(resendAction)
            }
            
            return swipeActions
            
            
        case .bikeSellNotification:
            let notification = presenter.bikeSellNotifications[indexPath.row]
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
            
            if notification.status == .sent && notification.buyerName != nil {
                
                let deleteAction = SwipeAction(style: .destructive, title: "Decline \nRequest", handler: { [unowned self] (action, indexPath) in
                    
                    self.presenter.rejectCreditRequest(atIndex: indexPath.row, notificationId: notification.id!, fromAll: false)
                    
                })
                
                deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                deleteAction.backgroundColor = AppTheme.Color.primaryRed
                
                deleteAction.image = #imageLiteral(resourceName: "ic_swipe_cross")
                
                return [deleteAction]
                
            } else {
                
                
                let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { [unowned self] (action, indexPath) in
                    
                    self.presenter.deleteCreditNotification(atIndex: indexPath.row, notificationId: notification.id!, all: false, from: (notification.buyerName == nil) ? "buyer" : "seller")
                })
                
                deleteAction.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                deleteAction.backgroundColor = AppTheme.Color.primaryRed
                
                deleteAction.image = #imageLiteral(resourceName: "ic_swipe_delete")
                
                return [deleteAction]
            }
//            let notification = presenter.creditNotifications[indexPath.row]
//
//            let deleteAction = SwipeAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
//
//                self.presenter.deleteCreditRequestNotification(atIndex: indexPath.row, notificationId: notification.id!)
//
//            })
//
//            deleteAction.backgroundColor = AppTheme.Color.primaryRed
//            deleteAction.image = #imageLiteral(resourceName: "ic_swipe_delete")
//
//            return [deleteAction]
     
        }
}
}
