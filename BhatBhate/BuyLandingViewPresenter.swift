//
//  BuyLandingViewPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/17/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
protocol BuyLandingViewPresentation:BasePresentation, NetworkRequestPresentable {
    
    func hideRefreshIndicator()
    
    func displayDetails(forBike bike:Bike)
    func displayBikeList()
    func displayError(error:AppError)
    func displayMessage(message:String)
    
    func updateBike(atIndex index:Int)
}

class BuyLandingViewPresenter {
    
    private weak var viewDelegate:BuyLandingViewPresentation!
    private var wishlistService: WishlistDataManagement!
    private var bikeService: BikeDataManagement!
    
    private var bikeListings = [Bike]()
    
    private var pageOffset:Int = 0
    private var limitPerPage:Int = 20
    private var canFetchMoreListings = true
    
    public var searchFilter:(brand:String,model:String,price:String,condition:Int)?
    private var isSearchGoingOn = false

    init(viewDelegate:BuyLandingViewPresentation, wishlistService: WishlistDataManagement, bikeService: BikeDataManagement) {
        
        self.viewDelegate = viewDelegate
        self.wishlistService = wishlistService
        self.bikeService = bikeService
        
        self.viewDelegate.setupViews()
    }
    
    func fetchBikeListings() {
        
        self.viewDelegate.showLoadingIndicator()
        
        self.isSearchGoingOn = false
        
        bikeService.fetchBikeList(pageOffset: pageOffset, limitPerPage: limitPerPage, onSuccess: { (bikes,wishlist) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.bikeListings = bikes
            self.viewDelegate.displayBikeList()
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.hideRefreshIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
    
    func refreshBikeListings() {
        
        // TODO:
        //
        // Maintain Cache for the fetched bike listings. Currently all the previous bike listings is purged and
        // replaced by the new bike listings
        
        self.pageOffset = 0
        self.isSearchGoingOn = false
        
        bikeService.fetchBikeList(pageOffset: pageOffset, limitPerPage: limitPerPage, onSuccess: { (bikes,wishlist) in
            
            self.canFetchMoreListings = true
            self.bikeListings = bikes
            self.viewDelegate.displayMessage(message: "Bikelist updated")
            self.viewDelegate.displayBikeList()
            
        }) { (error) in
            
            self.viewDelegate.hideRefreshIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
    
    func fetchMoreBikeListings(isOwn:Bool) {
        
        if canFetchMoreListings {
            
            canFetchMoreListings = false
            // Updating page offset
            pageOffset = pageOffset + limitPerPage
            
            /// CHECK IF SEARCH IS GOING ON OR ITS REGULAR LISTING
            
            self.viewDelegate.showLoadingIndicator()
            
            if isSearchGoingOn {
                print("search bike list")
                
                guard let filter = searchFilter else {
                    Log.error(info: "No search filter found. This should not happen")
                    return
                    
                }
                
                // Fetch more bikes for search
                bikeService.fetchBikeList(withBrand: filter.brand, model: filter.model, price: filter.price,condition: filter.condition, pageOffset: pageOffset, limitPerPage: limitPerPage,isOwn:isOwn, onSuccess: { (bikes,wishlist) in
                    
                    self.viewDelegate.hideLoadingIndicator()
                    self.bikeListings.append(contentsOf: bikes)
                    self.viewDelegate.displayBikeList()
                    self.canFetchMoreListings = bikes.count == self.limitPerPage
                }) { (error) in
                    self.viewDelegate.hideLoadingIndicator()
                    
                    switch error {
                    case BikeListError.emptyBuyList:
                        print("search bike list in empty error")
                        self.canFetchMoreListings = false
                        self.viewDelegate.displayError(error: CustomError.with(message: "You have reached the end of the list."))
                    default:
                        print("search bike list in default error")
                        self.canFetchMoreListings = false
                        self.viewDelegate.displayError(error: error)
                    }
                    
                    
                    self.viewDelegate.displayError(error: error)
                }
                
            } else {
                
                bikeService.fetchBikeList(pageOffset: pageOffset, limitPerPage: limitPerPage, onSuccess: { (bikes,wishlist) in
                    
                    self.viewDelegate.hideLoadingIndicator()
                    self.bikeListings.append(contentsOf: bikes)
                    self.viewDelegate.displayBikeList()
                    
                    self.canFetchMoreListings = true
                    
                }, onError: { (error) in
                    
                    self.viewDelegate.hideLoadingIndicator()
                    
                    switch error {
                        
                    case BikeListError.emptyBuyList:
                        self.canFetchMoreListings = false
                        self.viewDelegate.displayError(error: CustomError.with(message: "You have reached the end of the list."))
                    default:
                        self.canFetchMoreListings = true
                        self.viewDelegate.displayError(error: error)
                    }
                })
            }
        }
    }
    
    func getDetailsOfBike(atIndex index:Int) {
        
        let bike = bikeListings[index]
        viewDelegate.displayDetails(forBike: bike)
    }
    
    func numberOfBikeListings() -> Int {
        return bikeListings.count
    }
    
    func sellBikeListings() -> [Bike]{
        return self.bikeListings
    }
    
    func bikeListingAtRow(row:Int) -> Bike {
        return bikeListings[row]
    }
    
    func addBikeToWishlist(atIndex index:Int) {
        
        if let bikeId = bikeListings[index].id {
            
            self.viewDelegate.showLoadingIndicator()
            wishlistService.addBikeToWishlist(bikeId: bikeId, onSuccess: {
                Defaults[.myWishlistCount] += 1
                self.viewDelegate.hideLoadingIndicator()
                self.bikeListings[index].isInWishlist = true
                //let wishCount = self.bikeListings[index].wishCount ?? 0
                self.bikeListings[index].wishCount! += 1
                self.viewDelegate.updateBike(atIndex: index)
                self.viewDelegate.displayMessage(message: "Added to wishlist")
                
            }, onError: { (error) in
                
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.displayError(error: error)
            })
        }
    }
    
    func removeBikeFromWishlist(atIndex index:Int) {
        
        if let bikeId = bikeListings[index].id {
            
            self.viewDelegate.showLoadingIndicator()
            wishlistService.removeBikeFromWishlist(bikeId: bikeId, onSuccess: {
                Defaults[.myWishlistCount] -= 1
                self.viewDelegate.hideLoadingIndicator()
                self.bikeListings[index].isInWishlist = false
                self.bikeListings[index].wishCount! -= 1
                self.viewDelegate.updateBike(atIndex: index)
                self.viewDelegate.displayMessage(message: "Removed from wishlist")
                
            }, onError: { (error) in
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.displayError(error: error)
            })
        }
    }
    
    func searchBikesWith(brand:String,model:String,belowPrice price:String,condition:Int,isOwn:Bool) {
        
        self.searchFilter = (brand,model,price,condition)
        self.viewDelegate.showLoadingIndicator()
        self.isSearchGoingOn = true
        
        pageOffset = 0
        
        bikeService.fetchBikeList(withBrand: brand, model: model, price: price,condition:condition, pageOffset: pageOffset, limitPerPage: limitPerPage,isOwn:isOwn, onSuccess: { (bikes,wishlist) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.bikeListings = bikes
            self.viewDelegate.displayBikeList()
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
}
