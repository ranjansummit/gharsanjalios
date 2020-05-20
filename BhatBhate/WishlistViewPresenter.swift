//
//  WishlistViewPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/22/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
protocol WishlistViewPresentation: BasePresentation,NetworkRequestPresentable {
    
    func displayError(error:AppError)
    func displayWishlist()
    func wishListRemoved(bikeName:String)
}

class WishlistViewPresenter {
    
    private weak var viewDelegate: WishlistViewPresentation!
    private var service: WishlistDataManagement!
    
    var bikeList = [Bike]()
    
    private var pageOffset:Int = 0
    private var limitPerPage:Int = 20
    private var canFetchMoreListings = true
    
    init(controller: WishlistViewPresentation, service: WishlistDataManagement) {
        
        self.viewDelegate = controller
        self.service = service
        
        self.viewDelegate.setupViews()
    }
    
    func fetchWishlist() {
        
        self.viewDelegate.showLoadingIndicator()
        pageOffset = 0
        service.fetchAllBikeInWishlist(pageOffset: pageOffset, limitPerPage: limitPerPage, onSuccess: { [weak self] (bikes) in
            self?.viewDelegate.hideLoadingIndicator()
            self?.bikeList = bikes
            if self?.bikeList.count != Defaults[.myWishlistCount]{
                Defaults[.reloadBuyListing] = true
            }
            if let weakSelf = self , weakSelf.bikeList.count > 0 {
                self?.viewDelegate.displayWishlist()
            } else {
                self?.viewDelegate.displayWishlist()
                self?.viewDelegate.displayError(error: BikeListError.emptyWishlist)
            }
            
        }) { [weak self] (error) in
            
            self?.viewDelegate.hideLoadingIndicator()
            self?.viewDelegate.displayError(error: error)
        }
    }
    
    func removeBikeFromWishlist( bike:Bike,index:Int) {
        let bikeID = bike.id
        if let bikeId = bikeID {
            
            self.viewDelegate.showLoadingIndicator()
            service.removeBikeFromWishlist(bikeId: bikeId, onSuccess: {
                
                self.viewDelegate.hideLoadingIndicator()
                Defaults[.reloadBuyListing] = true
                self.viewDelegate.wishListRemoved(bikeName: bike.bikeFullName)
                
            }, onError: { (error) in
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.displayError(error: error)
            })
        }
    }
    
    func fetchMoreWishlist() {
        
        if canFetchMoreListings {
            
            canFetchMoreListings = false
            pageOffset = pageOffset + limitPerPage
            
            self.viewDelegate.showLoadingIndicator()
            
            service.fetchAllBikeInWishlist(pageOffset: pageOffset, limitPerPage: limitPerPage, onSuccess: { (bikes) in
                
                self.viewDelegate.hideLoadingIndicator()
                
                if bikes.count == 0 {
                    self.canFetchMoreListings = false
                    self.viewDelegate.displayError(error: CustomError.with(message: "You have reached the end of the list"))
                }else{
                self.bikeList.append(contentsOf: bikes)
                self.viewDelegate.displayWishlist()
                
                self.canFetchMoreListings = true
                }
                print(bikes.count.description)
            }, onError: { (error) in
                
                self.viewDelegate.hideLoadingIndicator()
                
                switch error {
                    
                case BikeListError.emptyWishlist:
                    self.canFetchMoreListings = false
                    self.viewDelegate.displayError(error: CustomError.with(message: "You have reached the end of the list"))
                default:
                    self.canFetchMoreListings = true
                    self.viewDelegate.displayError(error: error)
                }
            }) 
        }
    }
    
    func bikeListingAtRow(row: Int) -> Bike {
        return bikeList[row]
    }
}
