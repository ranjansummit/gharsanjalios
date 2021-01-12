//
//  WishlistViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/24/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class WishlistViewController: RootViewController, WishlistViewPresentation {
   
    @IBOutlet var tableView: UITableView!
    
    fileprivate var presenter:WishlistViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wishlistService = WishlistManager()
        presenter = WishlistViewPresenter(controller: self, service: wishlistService)
        presenter.fetchWishlist()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
    func setupViews() {
        
        //self.title = "Wishlist"
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = AppTheme.Color.backgroundBlue
    }
    
    func displayWishlist() {
//        if Defaults[.promotionMode]{
//            if !Defaults[.preview]{
//        self.tabBarController?.tabBar.items?[2].isEnabled = false
//        self.tabBarController?.tabBar.items?[2].badgeValue = nil
//            }
//        }else{
//        self.tabBarController?.tabBar.items?[2].isEnabled = true
//        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    
    func wishListRemoved(bikeName : String) {
        self.showAlert(title: "", message:"\(bikeName) is removed from wishlist." ){
        self.presenter.fetchWishlist()
        }
        
        
    }
    
    func displayError(error:AppError) {
        if error.localizedDescription == BikeListError.emptyWishlist.localizedDescription {
            self.showAlert(title: "", message: error.localizedDescription){
                self.navigationController?.popViewController(animated: true)
            } 
        }else{
            self.showAlert(title: "", message: error.localizedDescription)
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - scrollView.contentOffset.y
        
        if deltaOffset < -20 {
            presenter.fetchMoreWishlist()
        }
    }
}

extension WishlistViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Defaults[.myWishlistCount] = presenter.bikeList.count
        return presenter.bikeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BuyListingCell.stringIdentifier) as! BuyListingCell
        
        let bikeInfo = presenter.bikeListingAtRow(row: indexPath.row)
        
        cell.bikeImageView.sd_setImage(with: URL(string: bikeInfo.imageURL?[0] ?? ""), completed: nil)
        cell.bikeNameLabel.text = bikeInfo.name
        cell.bikeConditionView.currentRating = bikeInfo.conditionRating ?? 0
        let price = Double(bikeInfo.price ?? "0.0")
        cell.bikePriceLabel.text = "Rs. \((price ?? 0.0).formatCurrency())"
        //"Rs \(bikeInfo.price ?? "0.0")"
        
        cell.wishlistImageView.isHidden = false
        cell.addToWishlistButton.isHidden = false
        cell.wishlistButtonAction  = {
            self.presenter.removeBikeFromWishlist(bike: bikeInfo, index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bike = presenter.bikeListingAtRow(row: indexPath.row)
        let previewVc = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BikePreviewViewController.stringIdentifier) as! BikePreviewViewController
        previewVc.previewState = BikePreviewState.wishlist
        previewVc.bike = bike
        previewVc.viewDelegate = self
        self.navigationController?.pushViewController(previewVc, animated: true)
        
    }
   
   
   
}

extension WishlistViewController:BikeReloadDelegate {
    func reloadBikeList() {
     presenter.fetchWishlist()
    }
    
    
}
