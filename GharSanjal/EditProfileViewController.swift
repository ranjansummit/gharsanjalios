//
//  EditProfileViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 10/9/17.
//  Copyright © 2017 Andmine. All rights reserved.
// change password top to 32 to reset

import UIKit
import SwiftyUserDefaults
protocol EditProfileDelegate: class {
    func didEditProfile(profile: ProfileViewModel)
}

class EditProfileViewController: RootViewController, EditProfileViewPresentation, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var newPasswordInputField: UITextField!
    @IBOutlet var confirmPasswordInputField: UITextField!
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var nameInputField: LineInputField!
    @IBOutlet var emailInputField: LineInputField!
    @IBOutlet var phoneInputField: LineInputField!

    @IBOutlet var containerView: UIView!
    
    @IBOutlet var changeProfileButton: UIButton!
    
    public var profileModel: ProfileViewModel?
    public weak var delegate: EditProfileDelegate?
    
    private var presenter: EditProfilePresenter!
    
    @IBOutlet weak var labelChangePassword: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let profile = profileModel else {
            fatalError("Profile Model should be passed from parent")
        }
        
        presenter = EditProfilePresenter(controller: self, profile: profile)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImageView.addRoundedCorner(radius: profileImageView.frame.width / 2)
    }

    func setupViews() {
        
        self.view.backgroundColor = AppTheme.Color.white
        
      //  self.title = "Edit Profile"
        
        if let _ = Defaults[.facebookID] {
            labelChangePassword.isHidden = true
            newPasswordInputField.isHidden = true
            confirmPasswordInputField.isHidden = true
        }
        
        nameInputField.setPlaceholder(text: "Full Name")
        emailInputField.setPlaceholder(text: "Email")
        phoneInputField.setPlaceholder(text: "Phone Number")
        
        nameInputField.textColor = UIColor.black
        emailInputField.textColor = UIColor.black
        phoneInputField.textColor = UIColor.black
        
        newPasswordInputField.backgroundColor = UIColor.clear
        confirmPasswordInputField.backgroundColor = UIColor.clear
        
        phoneInputField.isEnabled = false
        emailInputField.isEnabled = false
        
        setupScrollViewForKeyboardAppearance(scrollView: scrollView)
        
        profileImageView.contentMode = .scaleAspectFill
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(onSaveButtonTap))
        self.navigationItem.rightBarButtonItem = saveButton
        
        containerView.backgroundColor = AppTheme.Color.backgroundBlue
        scrollView.backgroundColor = AppTheme.Color.backgroundBlue
        self.view.backgroundColor = AppTheme.Color.backgroundBlue
        
        changeProfileButton.addTarget(self, action: #selector(onChangeProfileButtonTap), for: .touchUpInside)
        setupTextFields()
    }
    
    private func setupTextFields() {
        
        nameInputField.hideError()
        phoneInputField.hideError()
        newPasswordInputField.addBorder(width: 1, color: UIColor.black)
        confirmPasswordInputField.addBorder(width: 1, color: UIColor.black)
    }
    
    func setupProfile(profile: ProfileViewModel,isUpdate:Bool = false) {
        
        nameInputField.text = profile.name
        emailInputField.text = profile.email
        phoneInputField.text = "+977 " + profile.mobile
        
        if isUpdate {
            self.delegate?.didEditProfile(profile: profile)
        } else {
            profileImageView.sd_setImage(with: URL(string: profile.imageURL), completed: nil)
        }
    }
    
    func displayError(error: AppError) {
        
        setupTextFields()
        
        switch error {
        case ProfileError.invalidName:
            nameInputField.showError()
        case ProfileError.invalidPassword:
            newPasswordInputField.addBorder(width: 1, color: UIColor.red)
            confirmPasswordInputField.addBorder(width: 1, color: UIColor.red)
        case ProfileError.invalidPhoneNumber:
            phoneInputField.showError()
        default:
            showAlert(title: "", message: error.localizedDescription)
        }
    }
    
    func displaySuccess(message: String) {
        showAlert(title: "", message: message){
            self.navigationController?.popViewController(animated: true)
        }
    }
   
    // MARK:- ImagePicker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        profileImageView.image = image
        presenter.isImageChanged = true
        
        picker.dismiss(animated: true) { [unowned self] in
            if let image = image {
                self.presenter.updateProfilePicture(withImage: image)
            }
        }
    }
    
    @objc func onChangeProfileButtonTap() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = self.changeProfileButton
        imagePicker.popoverPresentationController?.sourceRect = self.changeProfileButton.bounds
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func onSaveButtonTap() {
        
        let name = nameInputField.text
        let mobile = phoneInputField.text
        
        let newPassword = newPasswordInputField.text
        let confirmPassword = confirmPasswordInputField.text
        if newPassword?.count == 0 || confirmPassword?.count == 0{
            self.showAlert(title: "", message: "Passwords cannot be empty.")
            return
        }
        self.presenter.saveProfile(name: name, phone: mobile, newPassword: newPassword, confirmPassword: confirmPassword)
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
