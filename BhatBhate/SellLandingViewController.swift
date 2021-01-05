//
//  SellLandingViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class SellLandingViewController: RootViewController, PushNotificationBadgePresentable,BuyLandingViewPresentation {
    
    
    @IBOutlet weak var viewAddBike: UIView!
    @IBOutlet weak var btnAddBike: UIButton!
    @IBOutlet weak var lblNeedLogin: UILabel!
    @IBOutlet weak var btnNeedLogin: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var modelBikes:[Bike] = []
    
    private var pageOffset:Int = 0
    private var limitPerPage:Int = 20
    
    var notificationBadge: UILabel?
    var searchButton:UIButton!
    fileprivate var presenter : BuyLandingViewPresenter!
    var searchHistory:(brand: String, model: String, price: String, condition:Int)?
    
    @IBOutlet weak var labelCreditRemaining: UILabel! {
        didSet {
            let creditCount = Defaults[.userCreditCount]
            let stringCredit = creditCount > 1 ? "credits" : "credit"
            labelCreditRemaining.text = "(\(creditCount) \(stringCredit) remaining)"
            if creditCount == 0 {
                labelCreditRemaining.text = "(No credits available)"
            }
        }
    }
    fileprivate lazy var refreshControl : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshBikeList(_:)), for: .valueChanged)
        refreshControl.tintColor = .gray
        refreshControl.attributedTitle = NSAttributedString(string: "Updating bike list...")
        return refreshControl
    }()
    
    var favCount = Defaults[.myWishlistCount]
    var myNotificationCount = Defaults[.myNotificationCount]
    lazy var favouriteButton:UIButton = {
        let favIcon = #imageLiteral(resourceName: "ic_favourite_full")
        let favButton = UIButton(frame: CGRect(x: 0, y: 0, width: favIcon.size.width, height: favIcon.size.height))
        favButton.setImage(favIcon, for: .normal)
        favButton.addTarget(self, action: #selector(onFavButtonTapped), for: .touchUpInside)
        return favButton
    }()
    lazy var  wishlistBadge:UILabel = {
        let notificationBadge =  UILabel(frame: CGRect(x: (favouriteButton.frame.width / 2) + 7, y: favouriteButton.frame.height / 2.5, width: 22, height: 22))
        notificationBadge.textAlignment = .left
        notificationBadge.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        notificationBadge.text = favCount.description
        notificationBadge.addRoundedCorner(radius: 11)
        notificationBadge.textColor = UIColor.white
        return notificationBadge
    }()
    
    lazy var notificationButton:UIButton = {
        let notificationIcon = #imageLiteral(resourceName: "ic_message_white")
        let notificationButton = UIButton(frame: CGRect(x: 0, y: 0, width: notificationIcon.size.width, height: notificationIcon.size.height))
        notificationButton.setImage(notificationIcon, for: .normal)
        notificationButton.addTarget(self, action: #selector(onNotificationButtonTap), for: .touchUpInside)
        return notificationButton
    }()
    
    lazy  var  notifBadge:UILabel = {
        let notificationBadge =  UILabel(frame: CGRect(x: 22 , y: 22 / 2.5, width: 22, height: 22))
        notificationBadge.textAlignment = .center
        notificationBadge.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        notificationBadge.text =  myNotificationCount.description
        notificationBadge.backgroundColor = AppTheme.Color.primaryRed
        notificationBadge.addRoundedCorner(radius: 11)
        notificationBadge.textColor = UIColor.white
        return notificationBadge
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // self.title = "Sell a Bike"
        tableView.estimatedRowHeight = 240
        tableView.rowHeight = UITableView.automaticDimension
        tableView.addSubview(refreshControl)
        // self.navigationItem.title = "Sell a Bike"
        setupBarButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge(notification:)), name: .updateBadge, object: nil)
        
        let bikeService = BikeDataManager()
        let wishlistService = WishlistManager()
        presenter = BuyLandingViewPresenter(viewDelegate: self, wishlistService: wishlistService, bikeService: bikeService)
        
        if let _ = Defaults[.accessToken]{
            self.showLoadingIndicator()
            loadMyBikes()
        }else{
            tableView.isHidden = true
            btnAddBike.isHidden = true
            viewAddBike.isHidden = true
            btnNeedLogin.isHidden = false
            lblNeedLogin.isHidden = false
            lblNeedLogin.text = "You need to login before listing bike. Click below to login."
        }
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAppSetting()
        self.tabBarController?.delegate = self
        labelCreditRemaining.isHidden = Defaults[.promotionMode]
        self.myNotificationCount = Defaults[.myNotificationCount]
        updateNotifBadge()
        self.favCount = Defaults[.myWishlistCount]
        updateWishlistBadge()
        let creditCount = Defaults[.userCreditCount]
        let stringCredit = creditCount > 1 ? "credits" : "credit"
        labelCreditRemaining.text = "(\(creditCount) \(stringCredit) remaining)"
        if creditCount == 0 {
            labelCreditRemaining.text = "(No credits available)"
        }
        
        if Defaults[.notificationFromBuyer] {
            Defaults[.notificationFromBuyer] = false
            let notificationvc = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BuyNotificationsViewController.stringIdentifier) as! BuyNotificationsViewController
            self.navigationController?.pushViewController(notificationvc, animated: false)
            return
        }
        let notificationCount = Defaults[.sellNotificationCount]
        updateNotificationBadge(count: notificationCount)
        
        if Defaults[.reloadSellLsting] {
            if let _ = Defaults[.accessToken]{
                self.showLoadingIndicator()
                loadMyBikes()
            }else{
                tableView.isHidden = true
                btnAddBike.isHidden = true
                viewAddBike.isHidden = true
                btnNeedLogin.isHidden = false
                lblNeedLogin.isHidden = false
                //self.showLoginScreen()
            }
            Defaults[.reloadSellLsting] = false
        }
    }
    
    @objc func refreshBikeList(_ control: UIRefreshControl){
        searchButton.tintColor = .white
        searchHistory = nil
        self.loadMyBikes()
    }
    
    func hideRefreshIndicator() {
        //
    }
    
    func displayDetails(forBike bike: Bike) {
        //
    }
    
    func displayBikeList() {
        // print("display bike list in sell landing page")
        self.modelBikes = presenter.sellBikeListings()
        //  print("listing count", self.modelBikes.count.description)
        tableView.reloadData()
    }
    
    func displayError(error: AppError) {
        self.showAlert(title: "", message: error.localizedDescription)
    }
    
    func displayMessage(message: String) {
        self.showAlert(title: "", message: message){
            self.hideRefreshIndicator()
        }
        //
    }
    
    func updateBike(atIndex index: Int) {
        //
    }
    
    func setupViews() {
        //
    }
    
    @objc func onFavButtonTapped(){
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let wishlistVC = UIStoryboard.morePathway.instantiateViewController(withIdentifier: WishlistViewController.stringIdentifier) as! WishlistViewController
        self.navigationController?.pushViewController(wishlistVC, animated: true)
    }
    
    
    private func setupBarButtons() {
        let search = #imageLiteral(resourceName: "ic_search")
        let tintedSearch = search.withRenderingMode(.alwaysTemplate)
        searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: search.size.width, height: search.size.height))
        searchButton.setImage(tintedSearch, for: .normal)
        searchButton.tintColor = .white
        searchButton.addTarget(self, action: #selector(onSearchButtonTapped), for: .touchUpInside)
        let barButtonSearch = UIBarButtonItem(customView: searchButton)
        
        if myNotificationCount != 0 {
            self.notificationButton.addSubview(self.notifBadge)
        }
        let barButtonNotif = UIBarButtonItem(customView: self.notificationButton)
        
        if favCount != 0 {
            self.favouriteButton.addSubview(self.wishlistBadge)
        }
        let barButtonFav = UIBarButtonItem(customView: self.favouriteButton)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 20.0
        self.navigationItem.rightBarButtonItems = Defaults[.accessToken] == nil ? [spacer, barButtonNotif, spacer, barButtonFav] : [spacer, barButtonNotif, spacer, barButtonFav, spacer, barButtonSearch]
    }
    
    @IBAction func actionAddBike(_ sender: UIButton) {
        if Defaults[.userEmail] == "" || Defaults[.userMobile] == "" {
            let navVC = UIStoryboard.main.instantiateViewController(withIdentifier: CollectInfoNavViewController.stringIdentifier) as! CollectInfoNavViewController
            let collectVc = navVC.viewControllers.first as? UserInformationFormController
            collectVc?.userEmail = Defaults[.userEmail]
            collectVc?.userMobile = Defaults[.userMobile]
            self.present(navVC, animated: true, completion: nil)
            return
        }
        
        // print("updateBadge notification is added")
        GlobalVar.sharedInstance.answer = [:]
        GlobalVar.sharedInstance.answer1 = [:]
        performSegue(withIdentifier: "SellBike", sender: self)
        
    }
    
    @objc func onSearchButtonTapped(){
        let searchFilter = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BikeSearchFilterViewController.stringIdentifier) as! BikeSearchFilterViewController
        searchFilter.delegate = self
        searchFilter.searchHistory = self.searchHistory
        searchFilter.isOwnSearch = true
        self.present(searchFilter, animated: true, completion: nil)
    }
    
    func updateWishlistBadge(){
        self.favCount = Defaults[.myWishlistCount]
        if self.favCount == 0 {
            if self.wishlistBadge.isDescendant(of: self.favouriteButton){
                wishlistBadge.removeFromSuperview()
            }
            return
        }
        if !self.wishlistBadge.isDescendant(of: self.favouriteButton){
            self.favouriteButton.addSubview(wishlistBadge)
        }
        wishlistBadge.text = self.favCount.description
    }
    
    func updateNotifBadge(){
        self.myNotificationCount = Defaults[.myNotificationCount]
        if self.myNotificationCount == 0 {
            if self.notifBadge.isDescendant(of: self.notificationButton){
                notifBadge.removeFromSuperview()
            }
            return
        }
        if !self.notifBadge.isDescendant(of: self.notificationButton){
            self.notificationButton.addSubview(notifBadge)
        }
        notifBadge.text = self.myNotificationCount.description
    }
    
    @objc func updateBadge(notification:Notification){
        //  print("updating badge ***********")
//        self.tabBarController?.tabBar.items?[2].badgeValue = "\(Defaults[.userCreditCount])"
        let creditCount = Defaults[.userCreditCount]
        let stringCredit = creditCount > 1 ? "credits" : "credit"
        labelCreditRemaining.text = "(\(creditCount) \(stringCredit) remaining)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //   self.tabBarController?.delegate = nil
    }
    
    @IBAction func showLoginPage(_ sender: UIButton) {
        showLoginScreen()
    }
    private func loadMyBikes(){
        
        ApiManager.sendRequest(toApi: .getVehicles(filter: "sell", offset: pageOffset, limit: limitPerPage), onSuccess: {
            [unowned self] statusCode , response in
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }else{
                self.hideLoadingIndicator()
            }
            if statusCode == 200 {
                if let myNotifCount = response["unread_notification"].int {
                    Defaults[.myNotificationCount] = myNotifCount
                }
                if let bikeCount = response["vehicles_count"].int {
                    Defaults[.bikeCount] = bikeCount
                }
                if let wishlistCount = response["wishlist_count"].int {
                    Defaults[.myWishlistCount] = wishlistCount
                }
                let promotionMode = response["promotion_mode"].int ?? 0
                Defaults[.promotionMode] = promotionMode == 1
                
//                if promotionMode == 1 {
//                    if !Defaults[.preview]{
//                        self.tabBarController?.tabBar.items?[2].isEnabled = false
//                        self.tabBarController?.tabBar.items?[2].badgeValue = nil
//                    }
//                    
//                }else{
//                    self.tabBarController?.tabBar.items?[2].isEnabled = true
//                }
                
                let normalCredit = response["normal_credit"].int ?? 500
                Defaults[.normalCredit] = normalCredit
                
                let discountedCredit = response["discounted_credit"].int ?? 400
                Defaults[.discountedCredit] = discountedCredit
                
                self.modelBikes = []
                let bikes = response["data"].array
                for bike in bikes! {
                    let modelBike = Bike(json: bike)
                    self.modelBikes.append(modelBike)
                }
                self.updateNotifBadge()
                self.updateWishlistBadge()
                self.btnAddBike.isHidden = false
                self.viewAddBike.isHidden = false
                self.btnNeedLogin.isHidden = true
                self.lblNeedLogin.isHidden = true
                if self.modelBikes.count == 0 {
                    self.lblNeedLogin.isHidden = false
                    self.tableView.isHidden = true
                    self.lblNeedLogin.text = "You have no listing right now."
                }else{
                    self.tableView.isHidden = false
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                }
            }else{
                
            }
            }, onError: {
                httpError in
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }else{
                    self.hideLoadingIndicator()
                }
                self.showAlert(title: "", message: httpError.localizedDescription){
                    
                }
        })
    }
    
    @objc func onNotificationButtonTap() {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let vc = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BuyNotificationsViewController.stringIdentifier) as! BuyNotificationsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getAppSetting(){
        guard let _ = Defaults[.accessToken] else {
            return
        }
        ApiManager.sendRequest(toApi: .AppSetting, onSuccess: {
            [weak self]  status , response  in
            print(status)
            print(response)
            if let discountedCredit = response["data"]["discounted_credit"].int {
                Defaults[.discountedCredit] = discountedCredit
                
            }
            if let promotionMode = response["data"]["promotion_mode"].int{
                Defaults[.promotionMode] = promotionMode == 1
                if let tabItem = self?.tabBarController?.tabBar.items?[2] {
                    //                    tabItem.isEnabled = promotionMode == 0
                    if promotionMode == 1 {
                        tabItem.isEnabled = true
//                        tabItem.badgeValue = nil
                    }else{
                        tabItem.isEnabled = true
                    }
                }
            }
            if let vehiclesCount = response["data"]["vehicles_count"].int{
                Defaults[.bikeCount] = vehiclesCount
                
            }
            if let normalCredit = response["data"]["normal_credit"].int{
                Defaults[.normalCredit] = normalCredit
                
            }
            if let unreadNotifications = response["data"]["unread_notification"].int{
                Defaults[.myNotificationCount] = unreadNotifications
            }
            }, onError: {
                appError in
                
        })
    }
    
}

extension SellLandingViewController: UITableViewDataSource, UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelBikes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SellLanding") as! SellLandingTableViewCell
        let bike = modelBikes[indexPath.row]
        cell.selectionStyle = .none
        cell.editBike = {
            GlobalVar.sharedInstance.answer = [:]
            GlobalVar.sharedInstance.answer1 = [:]
            let sellInfoOneVC = UIStoryboard.sellPathway.instantiateViewController(withIdentifier: SellInformationViewControllerOne.stringIdentifier) as! SellInformationViewControllerOne
            sellInfoOneVC.editBike = bike
            self.navigationController?.pushViewController(sellInfoOneVC, animated: true)
        }
        cell.publishBike = {
            self.showLoadingIndicator()
            ApiManager.sendRequest(toApi: .publishBike(bikeID: bike.id!), onSuccess: {
                statusCode , response in
                print(response)
                self.hideLoadingIndicator()
                if let error = response["error"].bool , error {
                    
                    let message = response["message"].string
                    self.showAlert(title: "", message: message!)
                    return
                }else{
                    if let remainingCredit = response["data"]["remaining_credit"].int{
                        Defaults[.userPublishedBikeCount] = response["data"]["listing_vehicle"].int!
                        Defaults[.userCreditCount] = remainingCredit
//                        if !Defaults[.preview]{
//                            self.tabBarController?.tabBar.items?[2].badgeValue = "\(remainingCredit)"
//                        }
                        let creditCount = Defaults[.userCreditCount]
                        let stringCredit = creditCount > 1 ? "credits" : "credit"
                        self.labelCreditRemaining.text = "(\(creditCount) \(stringCredit) remaining)"
                        
                    }
                    let message =  response["message"].string!
                    self.showAlert(title: "Success", message: message){
                        self.loadMyBikes()
                    }
                }
            }, onError: {
                error in
                self.hideLoadingIndicator()
                print(error)
            })
        }
        cell.populateCell(bike: bike)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBike = modelBikes[indexPath.row]
        let previewVc = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BikePreviewViewController.stringIdentifier) as! BikePreviewViewController
        previewVc.previewState = selectedBike.isPublished ? BikePreviewState.sellPreviewPublished : .draft
        previewVc.bike = selectedBike
        //        previewVc.viewDelegate = self
        self.navigationController?.pushViewController(previewVc, animated: true)
    }
    
}

extension SellLandingViewController:BikeSearchFilterDelegate {
    func didChangeSearchFilter(brand: String, model: String, price: String, condition: Int) {
        self.searchHistory = (brand,model,price,condition)
        searchButton.tintColor = .red
        searchButton.layoutIfNeeded()
        self.presenter.searchBikesWith(brand: brand, model: model, belowPrice: price, condition: condition,isOwn:true)
    }
    
    func didClickedCancel(wasSearchOn: Bool) {
        if wasSearchOn {
            self.searchHistory = nil
            self.notifBadge.text = self.favCount.description
            self.favCount = 0
            searchButton.tintColor = .white
            searchButton.layoutIfNeeded()
            presenter.fetchBikeListings()
        }
    }
    
    
}

extension SellLandingViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //  print("\(tabBarController.selectedIndex)")
        if tabBarController.selectedIndex == 1{
            self.tableView.setContentOffset(.zero, animated: true)
            
        }
        
    }
}
