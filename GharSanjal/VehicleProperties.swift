//
//  VehiclePropertiesResponse.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/29/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Brand: Codable {
    
    enum CodingKeys: String, CodingKey {
        case brandId = "brand_id"
        case brandName = "brand_name"
        case models = "models"
    }
    
    var brandId:Int?
    var brandName:String?
    var models:[Model]?
    
    init(json: JSON) {
        
        brandId = json[CodingKeys.brandId.rawValue].int
        brandName = json[CodingKeys.brandName.rawValue].string
        if let brandModels = json[CodingKeys.models.rawValue].array {
            
            models = brandModels.map{ Model(json: $0) }
        }
    }
}

struct Model: Codable {
    
    enum CodingKeys:String,CodingKey {
        case engines = "engines"
        case modelName = "model_name"
        case modelId = "model_id"
    }
    
    var engines:[Engine]?
    var modelName:String?
    var modelId:Int?
    
    init(json: JSON) {
        
        if let engineList = json[CodingKeys.engines.rawValue].array {
            engines = engineList.map{ Engine(json: $0) }
        }
        
        modelName = json[CodingKeys.modelName.rawValue].string
        modelId = json[CodingKeys.modelId.rawValue].int
    }
}

public class Engine: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case capacity = "capacity"
    }
    
    var id:Int?
    var capacity:String?
    
    init(json: JSON) {
       // print(json)
        id = json[CodingKeys.id.rawValue].int
        capacity = json[CodingKeys.capacity.rawValue].string
    }
    
    public class func modelsFromDictionaryArray(array:[JSON]) -> [Engine]
    {
       // dump(array)
        var engines:[Engine] = []
        for item in array
        {
            engines.append(Engine(json: item))
        }
        return engines
    }

    
}
