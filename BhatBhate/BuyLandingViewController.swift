//
//  BuyLandingViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyUserDefaults
import GoogleMaps
import Starscream
import FirebaseRemoteConfig
class BuyLandingViewController: RootViewController, BuyLandingViewPresentation, BikeSearchFilterDelegate, PushNotificationBadgePresentable {
    
    @IBOutlet var tableView: UITableView!
    //    @IBOutlet var searchField: UISearchBar!
    
    //    @IBOutlet var searchButton: UIButton!
    
    
    let locationManager = CLLocationManager()
    
    let socket = Constants.webSocketURL//WebSocket(url: URL(string: "ws://staging.andmine.com:7979/")!)
    
    var searchButton:UIButton!
    var favCount = Defaults[.myWishlistCount]
    var myNotificationCount = Defaults[.myNotificationCount]
    var searchHistory:(brand: String, model: String, price: String, condition:Int)?
    
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
    
    
    fileprivate var presenter:BuyLandingViewPresenter!
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(refreshBikeList(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        refreshControl.attributedTitle = NSAttributedString(string: "Updating bike list...")
        return refreshControl
    }()
    
    fileprivate lazy var messageLabel = UILabel()
    
    var notificationBadge: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(BuyLandingViewController.getObserver(_:)), name: NSNotification.Name(rawValue: "BuyNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BuyLandingViewController.disconnectSocket(_:)), name: NSNotification.Name(rawValue: "DismissSocket"), object: nil)
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }else{
            // print("location is not enabled")
        }
        let bikeService = BikeDataManager()
        let wishlistService = WishlistManager()
        
        presenter = BuyLandingViewPresenter(viewDelegate: self, wishlistService: wishlistService, bikeService: bikeService)
        presenter.fetchBikeListings()        
    }
    
    
    
    @objc func getObserver(_ notification : Notification) {
        
        
    }
    
    @objc func disconnectSocket(_ notification: Notification){
        //print("notification is called")
        //print("disconnect in did enter background")
        socket.disconnect()
        
    }
    @objc func startSocket(_ notification: Notification){
        //print("in notification to start socket")
        if !socket.isConnected {
            socket.delegate = self
            socket.connect()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        self.tabBarController?.delegate = nil
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //print("view will layout subviews")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getAppSetting()
        
        self.tabBarController?.delegate = self
        if Defaults[.reloadBuyListing] {
            presenter.fetchBikeListings()
            Defaults[.reloadBuyListing] = false
        }
        
//        if Defaults[.promotionMode]{
//            if Defaults[.preview]{
//                var tbViewControllers = self.tabBarController?.viewControllers
//                //                print("number of tabs=", tbViewControllers?.count)
//                //                print("tab name at 2 =" ,self.tabBarController?.tabBar.items?[0].title)
//                if tbViewControllers?.count == 4 {
//                    tbViewControllers?.remove(at: 2)
//                    self.tabBarController?.setViewControllers(tbViewControllers, animated: false)
//                }
//                return
//            }
//            self.tabBarController?.tabBar.items?[2].isEnabled = false
//            self.tabBarController?.tabBar.items?[2].badgeValue = nil
//        }else{
//            self.tabBarController?.tabBar.items?[2].isEnabled = true
//        }
//
        self.myNotificationCount = Defaults[.myNotificationCount]
        updateNotifBadge()
        self.favCount = Defaults[.myWishlistCount]
        updateWishlistBadge()
        NotificationCenter.default.addObserver(self, selector: #selector(BuyLandingViewController.startSocket(_:)), name: NSNotification.Name(rawValue: "StartSocket"), object: nil)
        if Defaults[.notificationFromSeller] {   // for push notification redirection
            Defaults[.notificationFromSeller] = false
            let notificationvc = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BuyNotificationsViewController.stringIdentifier) as! BuyNotificationsViewController
            self.navigationController?.pushViewController(notificationvc, animated: false)
            return
        }
        let notificationCount = Defaults[.buyNotificationCount]
        updateNotificationBadge(count: notificationCount)
        socket.delegate = self
        if !socket.isConnected {
            // print("socket is connected")
            socket.connect()
        }
    }
    
    // MARK:- Presentation Protocol
    func setupViews() {
        
        // TableView setup
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // SearchBar setup
        //        searchField.barTintColor = AppTheme.Color.primaryBlue
        //        searchField.backgroundColor = AppTheme.Color.primaryBlue
        
        self.tableView.addSubview(refreshControl)
        
        setupBarButtons()
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
        self.navigationItem.rightBarButtonItems = [spacer, barButtonNotif, spacer, barButtonFav, spacer, barButtonSearch ]
    }
    
    func refreshFav(){
        self.wishlistBadge.removeFromSuperview()
        
    }
    
    @objc func onSearchButtonTapped(){
        let searchFilter = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BikeSearchFilterViewController.stringIdentifier) as! BikeSearchFilterViewController
        searchFilter.delegate = self
        searchFilter.searchHistory = self.searchHistory
        //self.navigationController?.pushViewController(searchFilter, animated: true)
        self.present(searchFilter, animated: true, completion: nil)
    }
    
    @objc func onFavButtonTapped(){
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let wishlistVC = UIStoryboard.morePathway.instantiateViewController(withIdentifier: WishlistViewController.stringIdentifier) as! WishlistViewController
        self.navigationController?.pushViewController(wishlistVC, animated: true)
    }
    
    func displayBikeList() {
        if Defaults[.promotionMode]{
            if Defaults[.preview]{
                var tbViewControllers = self.tabBarController?.viewControllers
                if tbViewControllers?.count == 4 {
                    tbViewControllers?.remove(at: 2)
                    self.tabBarController?.setViewControllers(tbViewControllers, animated: false)
                }
            }else{
                self.tabBarController?.tabBar.items?[2].isEnabled = false
//                self.tabBarController?.tabBar.items?[2].badgeValue = nil
            }
        }else{
            self.tabBarController?.tabBar.items?[2].isEnabled = true
        }
        self.updateWishlistBadge()
        self.updateNotifBadge()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }
    }
    
    func displayError(error: AppError) {
        self.showAlert(title: "", message: error.localizedDescription)
    }
    
    
    func displayMessage(message: String) {
        self.showAlert(title: "", message: message){
            self.hideRefreshIndicator()
        }
    }
    
    func displayDetails(forBike bike: Bike) {
        
        let previewVc = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BikePreviewViewController.stringIdentifier) as! BikePreviewViewController
        previewVc.previewState = BikePreviewState.buyPreview
        previewVc.bike = bike
        previewVc.viewDelegate = self
        self.navigationController?.pushViewController(previewVc, animated: true)
    }
    
    func updateBike(atIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        updateWishlistBadge()
    }
    
    // MARK:- Button Actions
    
    @IBAction func onNotificationButtonTap() {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let vc = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BuyNotificationsViewController.stringIdentifier) as! BuyNotificationsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onSearchButtonTap(_ sender: Any) {
        
        
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
    
    
    //    func updateWishlistBadge(){
    //        self.favCount = Defaults[.myWishlistCount]
    //        if self.favCount == 0 {
    //            if self.wishlistBadge.isDescendant(of: self.favouriteButton){
    //                wishlistBadge.removeFromSuperview()
    //            }
    //            return
    //        }
    //        if self.wishlistBadge.isDescendant(of: self.favouriteButton){
    //            if self.favCount == 0 {
    //                wishlistBadge.removeFromSuperview()
    //            }else{
    //                self.wishlistBadge.text = self.favCount.description
    //            }
    //        }else {
    //            self.favouriteButton.addSubview(wishlistBadge)
    //            wishlistBadge.text = self.favCount.description
    //        }
    //    }
    
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
    
    func didChangeSearchFilter(brand: String, model: String, price: String, condition:Int) {
        self.searchHistory = (brand,model,price,condition)
        searchButton.tintColor = .red
        searchButton.layoutIfNeeded()
        self.presenter.searchBikesWith(brand: brand, model: model, belowPrice: price, condition: condition, isOwn: false)
    }
    
    @objc func refreshBikeList(_ control: UIRefreshControl) {
        searchButton.tintColor = .white
        searchHistory = nil
        searchButton.layoutIfNeeded()
        self.presenter.refreshBikeListings()
    }
    
    func hideRefreshIndicator() {
        refreshControl.endRefreshing()
    }
    
    deinit {
        // print("deinit")
        socket.disconnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // print("view did disappear")
    }
    
    private func getAppSetting(){
        guard let _ = Defaults[.accessToken] else {
            return
        }
        ApiManager.sendRequest(toApi: .AppSetting, onSuccess: {
            [weak self]  status , response  in
            //  print(status)
            //  print(response)
            if let discountedCredit = response["data"]["discounted_credit"].int {
                Defaults[.discountedCredit] = discountedCredit
                
            }
            if let promotionMode = response["data"]["promotion_mode"].int{
                Defaults[.promotionMode] = promotionMode == 1
                if let tabItem = self?.tabBarController?.tabBar.items?[2] {
                    //                    tabItem.isEnabled = promotionMode == 0
//                    if promotionMode == 1 {
//                        tabItem.isEnabled = true
//                        tabItem.badgeValue = nil
//                    }else{
//                        tabItem.isEnabled = true
//                    }
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
                self?.updateNotifBadge()
            }
            }, onError: {
                appError in
                
        })
    }
    
}

extension BuyLandingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfBikeListings()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BuyListingCell.stringIdentifier) as! BuyListingCell
        
        let bikeInfo = presenter.bikeListingAtRow(row: indexPath.row)
        let price = Double(bikeInfo.price ?? "0")
        //        cell.bikeImageView.sd_showActivityIndicatorView()
        //        cell.bikeImageView.sd_setIndicatorStyle(.gray)
        cell.bikeImageView.sd_setImage(with: URL(string: bikeInfo.imageURL?[0] ?? ""), completed: nil)
        cell.bikeNameLabel.text = bikeInfo.name
        cell.bikeConditionView.currentRating = bikeInfo.conditionRating ?? 0
        //        cell.bikePriceLabel.text = "Rs. \(formatNumber(price: price ?? 0.0) ?? "-")"
        cell.bikePriceLabel.text = "Rs. \((price ?? 0.0).formatCurrency())"
        cell.lblWishlistCount.text = bikeInfo.wishCount?.description
        let buyers = bikeInfo.buyerCount ?? 0
        cell.lblBuyersInterested.text = "\(buyers) \(buyers < 2 ? "buyer":"buyers") interested"
        if bikeInfo.isSold || Defaults[.accessToken] == nil {
            cell.addToWishlistButton.isHidden = true
            cell.wishlistImageView.isHidden = true
        }else{
            cell.addToWishlistButton.isHidden = false
            cell.wishlistImageView.isHidden = false
        }
        if bikeInfo.isInWishlist {
            cell.wishlistImageView.image = #imageLiteral(resourceName: "ic_favourite_full")
            cell.wishlistButtonAction = {
                self.presenter.removeBikeFromWishlist(atIndex: indexPath.row)
            }
        } else {
            cell.wishlistImageView.image = #imageLiteral(resourceName: "ic_favourite_empty")
            cell.wishlistButtonAction = {
                self.presenter.addBikeToWishlist(atIndex: indexPath.row)
            }
        }
        cell.lblSold.isHidden = !bikeInfo.isSold
        cell.rearrangeViews(favCount: bikeInfo.wishCount ?? 0, buyerCount: bikeInfo.buyerCount ?? 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.getDetailsOfBike(atIndex: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - scrollView.contentOffset.y
        
        if deltaOffset < -20 {
            presenter.fetchMoreBikeListings(isOwn: false)
        }
    }
    
  
    func formatNumber(price:Double)->String?{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:price))
        return formattedNumber
    }
}

extension BuyLandingViewController: CLLocationManagerDelegate {
    
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()
        //  let _ = CLLocation(latitude: 21.4796719855459, longitude: 39.1840686276555)
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            if let err = error {
                completionHandler(nil, err.localizedDescription)
            } else if let placemarkArray = placemarks {
               // dump(placemarkArray)
                if let placemark = placemarkArray.first {
                    completionHandler(placemark, nil)
                } else {
                    completionHandler(nil, "Placemark was nil")
                }
            } else {
                completionHandler(nil, "Unknown error")
            }
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            guard let userID = Defaults[.userId] else {
                socket.disconnect()
                return
            }
            
            // let location = CLLocation(latitude: -26.4214174, longitude: 132.262404)
            
            let up = "UP#\(String(describing: userID))#\(String(describing: Defaults[.userCreditCount]))#\(location.coordinate.latitude)#\(location.coordinate.longitude)"
            // print("my location is uploaded",up)
            socket.write(string: up, completion: {
            })
            
            getPlacemark(forLocation: location){
                placeMark , text in
                guard let locality = placeMark?.locality else {
                    return
                }
                // print("locality here",locality)
                Defaults[.userLocality] = locality
                guard let _ = Defaults[.accessToken] else {
                    //    self. hideLoadingIndicator()
                    self.locationManager.stopUpdatingLocation()
                    return
                }
                ApiManager.sendRequest(toApi: .updateUserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, location: locality), onSuccess: {
                    status , response in
                    if status == 200 {
                        self.locationManager.stopUpdatingLocation()
                    }
                    
                }, onError: {
                    _ in
                    
                })
            }
            
        }
    }
}

extension BuyLandingViewController:BikeReloadDelegate{
    func reloadBikeList() {
        presenter.fetchBikeListings()
    }
}

extension BuyLandingViewController:WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        // print("web socket did connect")
        guard let userID = Defaults[.userId] else {
            socket.disconnect()
            return
        }
        let joinString = "JOIN#MBL#\(userID)#\(Defaults[.userName]!)#\(Defaults[.userEmail] ?? "NA")#\(Defaults[.userMobile] ?? "NA")#0#\(Defaults[.userCreditCount])"
        //  print("web socket join string", joinString)
        socket.write(string: joinString , completion: {
        })
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        //  print("web socket did disconnect")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        //print("web socket did receive message " , text)
        if text == "PING" {
            socket.write(string: "PONG")
        }
        locationManager.requestLocation()
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // print("web socket did receive data")
    }
}

extension BuyLandingViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // print("\(tabBarController.selectedIndex)")
        if tabBarController.selectedIndex == 0{
            self.tableView.setContentOffset(.zero, animated: true)
            
        }
        
    }
}

