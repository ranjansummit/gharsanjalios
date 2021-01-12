//
//  UserDefaultsExtension.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    
    static let accessToken = DefaultsKey<String?>("access_token")
    static let refreshToken = DefaultsKey<String?>("refresh_token")
    static let clientId = DefaultsKey<String>("client_id")
    static let clientSecret = DefaultsKey<String>("client_secret")
    
    static let isLoggedIn = DefaultsKey<Bool>("is_logged_In")
    static let expiresIn = DefaultsKey<Int?>("expires_in")
    static let facebookID = DefaultsKey<Any?>("facebook_id")
    //    static let emailISPresent = DefaultsKey<Bool>("email_is_present")
    //    static let mobileISPresent = DefaultsKey<Bool>("mobile_is_present")
    //
    // FCM Update Status
    static let fcmToken = DefaultsKey<String?>("fcm_push_notification_token")
    
    static let bikeCount = DefaultsKey<Int>("bike_count")
    static let buyNotificationCount = DefaultsKey<Int>("buy_notification_count")
    static let sellNotificationCount = DefaultsKey<Int>("sell_notification_count")
    
    static let userName = DefaultsKey<String?>("user_name")
    static let userEmail = DefaultsKey<String?>("user_email")
    static let userMobile = DefaultsKey<String?>("user_mobile")
    static let userId = DefaultsKey<Int?>("user_id")
    static let userPicURL = DefaultsKey<String?>("user_pic_url")
    static let userLoggedInDate = DefaultsKey<String?>("user_logged_in_date")
    static let userCreditCount = DefaultsKey<Int>("user_credit_count")
    static let userPublishedBikeCount = DefaultsKey<Int>("user_published_bike_count")
    
    static let notificationFromSeller = DefaultsKey<Bool>("notification_from_seller")
    static let notificationFromBuyer = DefaultsKey<Bool>("notification_from_buyer")
    static let notificatinForSellerCreditTx = DefaultsKey<Bool>("notification_for_seller_credit_tx")
    static let userLocality = DefaultsKey<String>("user_locality")
    static let userLocalityISUpdated = DefaultsKey<Bool>("user_locality_is_updated")
    static let noEmailOrMobile =  DefaultsKey<Bool>("user_has_no_email_mobile")
    
    static let callGetCreditInShop =  DefaultsKey<Bool>("get_credit_in_shop_landing")
    
    static let reloadBuyListing =  DefaultsKey<Bool>("reload_buy_listing")
    static let reloadSellLsting = DefaultsKey<Bool>("reload_sell_listing")
    static let reloadWishListing = DefaultsKey<Bool>("reload_wish_listing")
    //Counts
    static let myWishlistCount =  DefaultsKey<Int>("my_wishlist_count")
    static let myNotificationCount =  DefaultsKey<Int>("my_notification_count")
    //Credit price
    static let normalCredit =  DefaultsKey<Int>("normal_credit")
    static let discountedCredit =  DefaultsKey<Int>("discounted_credit")
    static let promotionMode =  DefaultsKey<Bool>("promotion_mode")
    
    static let preview = DefaultsKey<Bool>("preview")
    static let isInReview = DefaultsKey<Bool>("is_in_review")
    static let showVersionDialogue = DefaultsKey<Bool>("preview")
    
    static let webSocketURL = DefaultsKey<String?>("web_socket_url")
    
}
