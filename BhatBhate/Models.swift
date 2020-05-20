

import Foundation
 import SwiftyJSON
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class Models {
    public var engines:Array<Engine>?
	public var engine_capacity : String?
	public var model_id : Int?
	public var model_name : String?
    
/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let models_list = Models.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Models Instances.
*/
    public class func modelsFromDictionaryArray(array:[JSON]) -> [Models]
    {
        var models:[Models] = []
        for item in array
        {
            models.append(Models(dictionary: item.dictionary!)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let models = Models(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Models Instance.
*/
    required public init?(dictionary: [String:JSON]) {
        if (dictionary["engines"] != nil ){
            engines = Engine.modelsFromDictionaryArray(array: (dictionary["engines"]?.array)!)
        }
		engine_capacity = dictionary["engine"]?.string
		model_id = dictionary["model_id"]?.int
		model_name = dictionary["model_name"]?.string
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.engine_capacity, forKey: "engine_capacity")
		dictionary.setValue(self.model_id, forKey: "model_id")
		dictionary.setValue(self.model_name, forKey: "model_name")

		return dictionary
	}

}
