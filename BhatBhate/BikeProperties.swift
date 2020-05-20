

import Foundation
import SwiftyJSON
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class BikeProperties {
	public var brands : Array<Brands>?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let json4Swift_Base_list = Json4Swift_Base.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Json4Swift_Base Instances.
*/
    public class func modelsFromDictionaryArray(array:[JSON]) -> [BikeProperties]
    {
        var models:[BikeProperties] = []
        for item in array
        {
            models.append(BikeProperties(dictionary: (item.dictionary)!)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let json4Swift_Base = Json4Swift_Base(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Json4Swift_Base Instance.
*/
    required public init?(dictionary: [String:JSON]) {

        if (dictionary["brands"] != nil) { brands = Brands.modelsFromDictionaryArray(array: (dictionary["brands"]?.array)!) }
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
    public func dictionaryRepresentation() -> [String:JSON] {

		let dictionary = NSMutableDictionary()


        return dictionary as! [String : JSON]
	}

}
