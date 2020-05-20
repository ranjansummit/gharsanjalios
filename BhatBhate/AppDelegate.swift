//
//  AppDelegate.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleMaps
import CoreLocation
import Firebase
import UserNotifications
import SwiftyUserDefaults
import Starscream
import Fabric
import Crashlytics
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    weak var timer:Timer?
    private var myCurrentLocation:CLLocation?
    fileprivate var locationManager = CLLocationManager()
    let nc = NotificationCenter.default
    private final let GOOGLE_MAPS_API_KEY = "AIzaSyBpB1cOXSbJCPULkRZ_HwuWXnkpJz1yqL4"
    lazy var coreDataStack = CoreDataStack()
    let socket = Constants.webSocketURL
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Crashlytics , Answers
        Fabric.with([Crashlytics.self,Answers.self])
        //Answers
        Defaults[.showVersionDialogue] = true
        // Override point for customization after application launch.
        Defaults[.notificationFromSeller] = false
        Defaults[.notificationFromBuyer] = false
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        setupWebSocket()
        
        GMSServices.provideAPIKey(GOOGLE_MAPS_API_KEY)
        
        // Firebase for push notification
        setupPushNotification(forApplication: application)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        let startVc = UIStoryboard.main.instantiateViewController(withIdentifier: LaunchScreenViewController.stringIdentifier) as! LaunchScreenViewController
        self.window?.rootViewController = startVc
        
        
        
        //      window?.rootViewController = UIStoryboard.sellPathway.instantiateInitialViewController()
        UIApplication.shared.statusBarStyle = .lightContent
        return  FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    
    func setupPushNotification(forApplication application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions:UNAuthorizationOptions = [.alert,.badge,.sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (isGranted, error) in
                
                Log.add(info: "Authorization Status: \(isGranted)")
                
            })
            
        } else {
            
            let settings = UIUserNotificationSettings(types: [.alert,.sound,.badge], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    private func setupWebSocket(){
            socket.delegate = self
            socket.connect()
    }
    
    func startTimer(){
       // print("appdelegate timer started")
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runTimerCode), userInfo: nil, repeats: true)
    }
    
    @objc func  runTimerCode(){
        
        //print("appdelegate timer is running")
        
    }
    
    func showLoginScreen() {
        
        let loginVc = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
        self.window?.rootViewController = loginVc
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        //print("appdelegate will enter foreground")
        if timer == nil {
            //startTimer()
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //print("appdelegate did enter background")
        //print("appdelegate timer gone")
        
        nc.post(name: Notification.Name("DismissSocket"), object: nil)
        
        timer?.invalidate()
        // print("web socket is connected?",socket.isConnected)
        socket.disconnect()
        //print("web socket is connected?",socket.isConnected)
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        //print("appdelegate will resign active")
        nc.post(name: Notification.Name("DismissSocket"), object: nil)
        FBSDKAppEvents.activateApp()
        if timer == nil {
            //   startTimer()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
       // print("appdelegate did become active")
        
        //        socket.connect()
        nc.post(name: Notification.Name("StartSocket"), object: nil)
        FBSDKAppEvents.activateApp()
        if timer == nil {
            // startTimer()
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
      //  print("appdelegate app will terminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.coreDataStack.saveContext()
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url ,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    
    // MARK:- Firebase Messaging Delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NotificationManager.updateFCMTokenIfNeeded(obtainedToken: fcmToken)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        // For ios 10 & above only
        Log.add(info: remoteMessage)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        Log.add(info: "Remote Notification: \(userInfo)")
        
        Defaults[.reloadBuyListing] = true // for notification to load
        Defaults[.reloadSellLsting] = true
        Defaults[.reloadWishListing] = true
        
        if let notificationType = userInfo["for"] as? String, let transferType = userInfo["type"] as? String {
            displayNotificationScreen(forType: notificationType, transferType: transferType)
        }
    }
    
    func displayNotificationScreen(forType notificationType: String, transferType:String) {
        
        guard Defaults[.isLoggedIn] else { return }
        
        let tabVC = UIStoryboard.main.instantiateViewController(withIdentifier: TabBarViewController.stringIdentifier) as! TabBarViewController
        
        if notificationType == "seller" {
            if transferType == "credittransfer"{
                Defaults[.callGetCreditInShop] = true
                Defaults[.notificatinForSellerCreditTx] = true
                tabVC.selectedIndex = 2
                Defaults[.notificationFromSeller] = false
                Defaults[.notificationFromBuyer] = false
                
            }else{
                Defaults[.callGetCreditInShop] = true
                tabVC.selectedIndex = 1
                Defaults[.notificationFromSeller] = false
                Defaults[.notificationFromBuyer] = true
            }
        }else {
            tabVC.selectedIndex = 0
            Defaults[.notificationFromSeller] = true
            Defaults[.notificationFromBuyer] = false
        }
        self.window?.rootViewController = tabVC
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Defaults[.reloadBuyListing] = true // for notification to load
        Defaults[.reloadSellLsting] = true
        Defaults[.reloadWishListing] = true
        Log.add(info: notification.request.content.userInfo.description)
        
        let userInfoDict = notification.request.content.userInfo
        if let notificationType = userInfoDict["for"] as? String, let transferType = userInfoDict["type"] as? String {
           // print(userInfoDict)
            displayNotificationScreen(forType: notificationType ,transferType: transferType )
        }
        
        completionHandler([.alert,.sound])
    }
}


extension AppDelegate:WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
       // print("web socket did connect")
        
        let joinString = "JOIN#MBL#\(Defaults[.userId] ?? 0)#\(Defaults[.userName] ?? "NA")#\(Defaults[.userEmail] ?? "NA")#\(Defaults[.userMobile] ?? "NA")#0#\(Defaults[.userCreditCount])"
        //print("web socket join string", joinString)
        socket.write(string: joinString , completion: {
        })
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
       // print("web socket did disconnect")
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


extension AppDelegate:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            //print("***********************")
            self.myCurrentLocation = currentLocation
            //print(currentLocation)
            // UP#<userId>#<available_credit>#<lat>#<lng>
            if !Defaults[.isLoggedIn]{
          //  print("my location is not uploaded")
                return
            }
            let up = "UP#\(String(describing: Defaults[.userId] ?? 0))#\(String(describing: Defaults[.userCreditCount]))#\(currentLocation.coordinate.latitude)#\(currentLocation.coordinate.longitude)"
         //   print("my location is uploaded",up)
            socket.write(string: up, completion: {
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //print(status.rawValue.description)
    }
    
    
}
