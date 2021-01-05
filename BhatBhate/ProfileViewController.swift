//
//  ProfileViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/24/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class ProfileViewController: RootViewController, ProfileViewPresentation, EditProfileDelegate {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userEmailLabel: UILabel!
    @IBOutlet var userMobileLabel: UILabel!
    @IBOutlet weak var profileLable: UILabel!
    
    @IBOutlet weak var viewCover: UIView!
    @IBOutlet weak var textName: UITextField!
    @IBOutlet var numberOfPurchasesLabel: UILabel!
    @IBOutlet var numberOfCreditsLabel: UILabel!
    @IBOutlet var numberOfListingsLabel: UILabel!
    
    @IBOutlet var logoutButton: UIButton!
    
    private var presenter: ProfileViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewCover.backgroundColor = AppTheme.Color.backgroundBlue
        viewCover.isHidden = !Defaults[.preview]
        presenter = ProfileViewPresenter(controller: self)
        presenter.fetchCurrentProfile()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if Defaults[.promotionMode]{
//            if !Defaults[.preview] {
//            self.tabBarController?.tabBar.items?[2].isEnabled = false
//            self.tabBarController?.tabBar.items?[2].badgeValue = nil
//            }
//        }else{
//            self.tabBarController?.tabBar.items?[2].isEnabled = true
//        }
    }
    
    func setupViews() {
        self.textName.delegate = self
        self.title = ""
        self.textName.setLeftPaddingPoints(47.0)
        if  Defaults[.facebookID] == nil {
            let editButton = UIBarButtonItem(title: "Change password", style: .plain, target: self, action: #selector(onEditButtonTap))
            self.navigationItem.rightBarButtonItem = editButton
        }
        profileImageView.contentMode = .scaleAspectFill
        
        userNameLabel.text = "Username"
        userEmailLabel.text = "Email"
        userMobileLabel.text = "Mobile No"
        numberOfListingsLabel.text = "0"
        numberOfCreditsLabel.text = "0"
        numberOfPurchasesLabel.text = "0"
        
        logoutButton.addTarget(self, action: #selector(onLogoutButtonTap), for: .touchUpInside)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(AppTheme.Color.white, for: .normal)
        logoutButton.backgroundColor = AppTheme.Color.primaryRed
        
    }
    
    func displayError(error: AppError) {
        showAlert(title: "", message: error.localizedDescription)
    }
    
    @IBAction func changeProfileAction(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = sender
        imagePicker.popoverPresentationController?.sourceRect =  sender.bounds
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func updateProfile(profileModel: ProfileViewModel) {
       // print("in update profile")
        
        if let availableCredit = Int(profileModel.availableCreditCount){
            Defaults[.userCreditCount] = availableCredit
            if Defaults[.promotionMode]{
                if !Defaults[.preview]{
                self.tabBarController?.tabBar.items?[2].isEnabled = false
//                self.tabBarController?.tabBar.items?[2].badgeValue = nil
                }
            }else{
                self.tabBarController?.tabBar.items?[2].isEnabled = true
                self.tabBarController?.tabBar.items?[2].badgeValue = "\(availableCredit)"
            }
            
        }
        
        userNameLabel.text = profileModel.name
        textName.text = profileModel.name
        userEmailLabel.text = profileModel.email
        userMobileLabel.text = "+977 " + profileModel.mobile
        
        numberOfPurchasesLabel.text = profileModel.purchasedCreditCount
        numberOfCreditsLabel.text = profileModel.availableCreditCount
        numberOfListingsLabel.text = profileModel.bikeListingCount
        Defaults[.userPicURL] = profileModel.imageURL
        if profileModel.imageURL != "" {
            //            profileImageView.sd_showActivityIndicatorView()
            //            profileImageView.sd_setIndicatorStyle(.gray)
            profileImageView.sd_setImage(with: URL(string: profileModel.imageURL), completed: nil)
            
            profileImageView.isHidden = false
            profileLable.isHidden = true
        }else if !profileModel.isSocialLogin{
            profileImageView.isHidden = true
            profileLable.isHidden = false
            let firstChar = profileModel.name.first
            profileLable.text = "\(String(describing: firstChar!))"
            profileLable.backgroundColor = AppTheme.Color.primaryBlue
        }
    }
    
    func editProfile(profileModel: ProfileViewModel) {
        
        let vc = UIStoryboard.morePathway.instantiateViewController(withIdentifier: EditProfileViewController.stringIdentifier) as! EditProfileViewController
        vc.profileModel = profileModel
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImageView.addRoundedCorner(radius: profileImageView.frame.width / 2)
        profileLable.addRoundedCorner(radius: profileLable.frame.width/2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onLogoutButtonTap() {
        
        showLoadingIndicator()
        ApiManager.sendRequest(toApi: .Logout(fcmToken: Defaults[.fcmToken] ?? ""),
                               onSuccess: { status, response in
                                print(status)
                                print(response)
                                self.hideLoadingIndicator()
                                if status == 200 {
                                    let bikeCount = Defaults[.bikeCount]
                                    // Remove all stored values
                                    Defaults.removeAll()
                                    Defaults.synchronize()
                                    Defaults[.bikeCount] = bikeCount
                                    // Show Login Screen
//                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                                    appDelegate.showLoginScreen()
//                                    Defaults[.reloadSellLsting] = true
//                                    Defaults[.reloadBuyListing] = true
                                    self.showAlert(title: "", message: "Logged out successfully"){
                                   // self.navigationController?.popViewController(animated: true)
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        let window = appDelegate.window
                                        let tabBarViewController = UIStoryboard.main.instantiateViewController(withIdentifier: TabBarViewController.stringIdentifier) as! UITabBarController
                                        window?.rootViewController = tabBarViewController
                                    }
                                    
                                }else{
                                    self.showAlert(title: "", message: "Error logging out.Please try again later.")
                                }
        },
                               onError: { error in
                                self.hideLoadingIndicator()
                                self.showAlert(title: "", message: error.localizedDescription)
        })
        
    }
    
    @objc func onEditButtonTap() {
        //        if presenter.profileModel?.name != textName.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
        //            showAlert(title: "", message: "changed")
        //        }else{
        //            showAlert(title: "", message: "hello  not chnaged")
        //        }
        self.presenter.presentEditScreen()
    }
    
    // *******************************
    // MARK:- Edit Profile Delegate
    // *******************************
    
    func didEditProfile(profile: ProfileViewModel) {
       // print("edit profile")
        self.updateProfile(profileModel: profile)
    }
    
    func displaySuccess(message: String) {
        showAlert(title: "", message: message)
    }
    
    func setupProfile(profile: ProfileViewModel,isUpdate:Bool = false) {
        
        textName.text = profile.name
        userEmailLabel.text = profile.email
        userMobileLabel.text = "+977 " + profile.mobile
        
        if isUpdate {
            self.didEditProfile(profile: profile)
        } else {
            profileImageView.sd_setImage(with: URL(string: Defaults[.userPicURL]!), completed: nil)
        }
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK:- ImagePicker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        profileImageView.image = image
        // presenter.isImageChanged = true
        
        picker.dismiss(animated: true) { [unowned self] in
            if let image = image {
                self.presenter.updateProfilePicture(withImage: image)
            }
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if presenter.profileModel?.name != textName.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.presenter.saveProfile(name: textName.text, phone: userMobileLabel.text, newPassword: "", confirmPassword: "")
        }
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
