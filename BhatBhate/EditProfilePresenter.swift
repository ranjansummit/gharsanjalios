//
//  EditProfilePresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/20/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
protocol EditProfileViewPresentation: BasePresentation, NetworkRequestPresentable {
    
    func setupProfile(profile: ProfileViewModel,isUpdate:Bool)
    
    func displayError(error:AppError)
    func displaySuccess(message:String)
}

class EditProfilePresenter {
    
    private var viewDelegate: EditProfileViewPresentation!
    private var profileModel: ProfileViewModel!
    
    public var isImageChanged: Bool = false
    
    init(controller: EditProfileViewPresentation, profile: ProfileViewModel) {
        self.viewDelegate = controller
        self.profileModel = profile
        
        self.viewDelegate.setupViews()
        self.viewDelegate.setupProfile(profile: profile,isUpdate: false)
    }
    
    func saveProfile(name:String?,phone:String?,newPassword:String?,confirmPassword:String?) {
        
        guard let name = name, !name.isEmpty else {
            viewDelegate.displayError(error: ProfileError.invalidName)
            return
        }
        
        guard let phone = phone, !phone.isEmpty  else {
            viewDelegate.displayError(error: ProfileError.invalidPhoneNumber)
            return
        }

        var password:String?
        
        // Checking for password change
        if let nPassword = newPassword,!nPassword.isEmpty {
            if let cPassword = confirmPassword, !cPassword.isEmpty {
                if nPassword != cPassword {
                    viewDelegate.displayError(error: ProfileError.passwordMismatch)
                    return
                }
                password = nPassword
            } else {
                viewDelegate.displayError(error: ProfileError.invalidPassword)
                return
            }
        }else{
            if let cPassword = confirmPassword , !cPassword.isEmpty{
            viewDelegate.displayError(error: ProfileError.invalidPassword)
            return
            }
            password = ""
        }
        
       
        
        self.viewDelegate.showLoadingIndicator()
        ApiManager.sendRequest(toApi: Api.Endpoint.editProfile(name: name, mobile: phone, newPassword: password, confirmPassword: password), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if !isErrorPresent {
                    
                    let id = data["data"]["id"].int ?? -1
                    let name = data["data"]["name"].string ?? ""
                    let email = data["data"]["email"].string ?? ""
                    let mobile = data["data"]["mobile"].string ?? ""
                    let image = data["data"]["image"].string ?? ""
                    
                    self.profileModel.id = id
                    self.profileModel.name = name
                    self.profileModel.email = email
                    self.profileModel.mobile = mobile
                    self.profileModel.imageURL = image
                   
                    self.viewDelegate.setupProfile(profile: self.profileModel,isUpdate: true)
                    self.viewDelegate.displaySuccess(message: "Password changed successfully.")
                    
                } else {
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            default:
                
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.displayError(error: CustomError.standard)
            }
            
        }) { (error) in
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
    
    func updateProfilePicture(withImage image:UIImage) {
        
        self.viewDelegate.showLoadingIndicator()
        if let dataRepr = image.jpegData(compressionQuality: 0.7) {
            
            Alamofire.upload(multipartFormData: { (multipartData) in
                
                multipartData.append(dataRepr, withName: "image", fileName: "image_profile_picture", mimeType: "image/jpeg")
            
            }, to: Api.Endpoint.saveImage.url, method: Api.Endpoint.saveImage.method, headers: Api.Endpoint.saveImage.headers, encodingCompletion: { (encodingResult) in
                
                switch encodingResult {
                    
                case .success(let uploadRequest,_,_):
                    
                    uploadRequest.response(completionHandler: { (networkResponse) in
                        
                        self.viewDelegate.hideLoadingIndicator()
                        
                        // If any unforseen error
                        if let error = networkResponse.error {
                            self.viewDelegate.displayError(error: ApiError.invalidResponse(message: error.localizedDescription))
                            return
                        }
                        
                        guard let data = networkResponse.data else {
                            self.viewDelegate.displayError(error: CustomError.standard)
                            return
                        }
                        
                        let response = JSON(data)
                        
                        if let isErrorPresent = response["error"].bool, isErrorPresent == false {
                            
                            let imageURL = response["data"].string ?? ""
                            self.profileModel.imageURL = imageURL
                            Defaults[.userPicURL] = imageURL
                            self.viewDelegate.displaySuccess(message: "Profile picture updated")
                            self.viewDelegate.setupProfile(profile: self.profileModel, isUpdate: true)
                            
                            return
                            
                        } else {
                            
                            let message = response["message"].string ?? ""
                            self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
                        }
                    })
                    
                case .failure(let error):
                    
                    Log.error(info: error)
                    
                    self.viewDelegate.hideLoadingIndicator()
                    self.viewDelegate.displayError(error: ApiError.invalidResponse(message: error.localizedDescription))
                }
                
            })
            
        } else {
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: ProfileError.uploadError)
        }
        
    }
}
