

import Foundation
 import SwiftyJSON
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class Brands {
	public var brand_id : Int?
	public var brand_name : String?
	public var models : Array<Models>?
                                                          
/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let brands_list = Brands.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Brands Instances.
*/
    public class func modelsFromDictionaryArray(array:[JSON]) -> [Brands]
    {
        var models:[Brands] = []
        for item in array
        {
            models.append(Brands(dictionary: item.dictionary!)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let brands = Brands(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Brands Instance.
*/
    required public init?(dictionary: [String:JSON]) {

		brand_id = dictionary["brand_id"]?.int
		brand_name = dictionary["brand_name"]?.string
        if (dictionary["models"] != nil) { models = Models.modelsFromDictionaryArray(array: (dictionary["models"]?.array)!) }
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.brand_id, forKey: "brand_id")
		dictionary.setValue(self.brand_name, forKey: "brand_name")

		return dictionary
	}

}
