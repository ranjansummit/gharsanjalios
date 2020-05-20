//
//  CreditSellerMarker.swift
//  BhatBhate
//
//  Created by Nishan-82 on 1/2/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import Foundation
import GoogleMaps

class CreditSellerMarker: GMSMarker {
    
    let sellerInfo:CreditSeller
    
    init(sellerInfo:CreditSeller) {
        
        self.sellerInfo = sellerInfo
        super.init()
        
        let coordinate = CLLocationCoordinate2D(latitude: sellerInfo.latitude ?? 0.0, longitude: sellerInfo.longitude ?? 0.0)
        self.position = coordinate
        self.icon = sellerInfo.type == CreditSellerType.shop ? #imageLiteral(resourceName: "ic_marker_shop") : #imageLiteral(resourceName: "ic_marker_bike")
    }
    
    
}
