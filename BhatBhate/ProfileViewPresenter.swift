//
//  ProfileViewPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/20/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import Alamofire
import SwiftyJSON
protocol ProfileViewPresentation: BasePresentation, NetworkRequestPresentable {
    
    func displayError(error:AppError)
    func displaySuccess(message:String)
    func updateProfile(profileModel: ProfileViewModel)
    func editProfile(profileModel: ProfileViewModel)
    func setupProfile(profile: ProfileViewModel,isUpdate: Bool)
}

struct ProfileViewModel {
    
    var id:Int
    var name:String
    var email:String
    var mobile:String
    var imageURL:String
    var purchasedCreditCount:String
    var availableCreditCount:String
    var bikeListingCount:String
    var isSocialLogin:Bool
}

class ProfileViewPresenter {
    
    private weak var viewDelegate: ProfileViewPresentation?
     var profileModel: ProfileViewModel?
    
    init(controller: ProfileViewPresentation) {
        self.viewDelegate = controller
        self.viewDelegate?.setupViews()
    }
    
    func fetchCurrentProfile() {
        
        self.viewDelegate?.showLoadingIndicator()
        ApiManager.sendRequest(toApi: Api.Endpoint.getProfile, onSuccess: { (statusCode, data) in
            
            self.viewDelegate?.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if !isErrorPresent {
                    
                    let id = data["data"]["id"].int ?? -1
                    let name = data["data"]["name"].string ?? ""
                    let email = data["data"]["email"].string ?? ""
                    let mobile = data["data"]["mobile"].string ?? ""
                    let purchasedCredit = data["data"]["purchased_credit"].int ?? 0
                    let availableCredit = data["data"]["available_credit"].int ?? 0
                    let numberOfListings = data["data"]["number_of_listings"].int ?? 0
                    let image = data["data"]["image"].string ?? ""
                    let isSocialLogin = (data["data"]["facebook"].int ?? 0) == 1
                    Defaults[.userCreditCount] = availableCredit
                    
                    self.profileModel = ProfileViewModel(id: id, name: name, email: email, mobile: mobile,imageURL:image,purchasedCreditCount: "\(purchasedCredit)", availableCreditCount: "\(availableCredit)", bikeListingCount: "\(numberOfListings)", isSocialLogin: isSocialLogin)
                    self.viewDelegate?.updateProfile(profileModel: self.profileModel!)
                    
                } else {
                    self.viewDelegate?.displayError(error: CustomError.standard)
                }

            default:
                self.viewDelegate?.hideLoadingIndicator()
                self.viewDelegate?.displayError(error: CustomError.standard)
            }
            
        }) { (error) in
            
            self.viewDelegate?.hideLoadingIndicator()
            self.viewDelegate?.displayError(error: error)
        }
    }
    
    func saveProfile(name:String?,phone:String?,newPassword:String?,confirmPassword:String?) {
        
        guard let name = name, !name.isEmpty else {
            viewDelegate?.displayError(error: ProfileError.invalidName)
            return
        }
        
        guard let phone = phone, !phone.isEmpty  else {
            viewDelegate?.displayError(error: ProfileError.invalidPhoneNumber)
            return
        }
  
        self.viewDelegate?.showLoadingIndicator()
        ApiManager.sendRequest(toApi: Api.Endpoint.editProfile(name: name, mobile: phone, newPassword: "", confirmPassword: ""), onSuccess: { (statusCode, data) in
            
            self.viewDelegate?.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if !isErrorPresent {
                    
                    let id = data["data"]["id"].int ?? -1
                    let name = data["data"]["name"].string ?? ""
                    let email = data["data"]["email"].string ?? ""
                    let mobile = data["data"]["mobile"].string ?? ""
                    let image = data["data"]["image"].string ?? ""
                    
                    self.profileModel?.id = id
                    self.profileModel?.name = name
                    self.profileModel?.email = email
                    self.profileModel?.mobile = mobile
                    self.profileModel?.imageURL = image
                    
                    self.viewDelegate?.setupProfile(profile: self.profileModel!,isUpdate: true)
                    self.viewDelegate?.displaySuccess(message: "Profile Updated")
                    
                } else {
                    self.viewDelegate?.displayError(error: CustomError.standard)
                }
                
            default:
                
                self.viewDelegate?.hideLoadingIndicator()
                self.viewDelegate?.displayError(error: CustomError.standard)
            }
            
        }) { (error) in
            self.viewDelegate?.hideLoadingIndicator()
            self.viewDelegate?.displayError(error: error)
        }
    }
    
    
    func presentEditScreen() {
        
        if let profile = self.profileModel {
            self.viewDelegate?.editProfile(profileModel: profile)
        }
    }
    
    func updateProfilePicture(withImage image:UIImage) {
        
        self.viewDelegate?.showLoadingIndicator()
        if let dataRepr = image.jpegData(compressionQuality: 0.7) {
            
            Alamofire.upload(multipartFormData: { (multipartData) in
                multipartData.append(dataRepr, withName: "image", fileName: "image_profile_picture", mimeType: "image/jpeg")
                
            }, to: Api.Endpoint.saveImage.url, method: Api.Endpoint.saveImage.method, headers: Api.Endpoint.saveImage.headers, encodingCompletion: { (encodingResult) in
                
                switch encodingResult {
                    
                case .success(let uploadRequest,_,_):
                    
                    uploadRequest.response(completionHandler: { (networkResponse) in
                        
                        self.viewDelegate?.hideLoadingIndicator()
                        
                        // If any unforseen error
                        if let error = networkResponse.error {
                            self.viewDelegate?.displayError(error: ApiError.invalidResponse(message: error.localizedDescription))
                            return
                        }
                        
                        guard let data = networkResponse.data else {
                            self.viewDelegate?.displayError(error: CustomError.standard)
                            return
                        }
                        
                        let response = JSON(data)
                        
                        if let isErrorPresent = response["error"].bool, isErrorPresent == false {
                            
                            let imageURL = response["data"].string ?? ""
                            self.profileModel?.imageURL = imageURL
                            Defaults[.userPicURL] = imageURL
                            self.viewDelegate?.displaySuccess(message: "Profile picture updated")
                            self.viewDelegate?.updateProfile(profileModel: self.profileModel!)
                            
                            return
                            
                        } else {
                            
                            let message = response["message"].string ?? ""
                            self.viewDelegate?.displayError(error: ApiError.invalidResponse(message: message))
                        }
                    })
                    
                case .failure(let error):
                    
                    Log.error(info: error)
                    
                    self.viewDelegate?.hideLoadingIndicator()
                    self.viewDelegate?.displayError(error: ApiError.invalidResponse(message: error.localizedDescription))
                }
                
            })
            
        } else {
            self.viewDelegate?.hideLoadingIndicator()
            self.viewDelegate?.displayError(error: ProfileError.uploadError)
        }
        
    }
    
}
