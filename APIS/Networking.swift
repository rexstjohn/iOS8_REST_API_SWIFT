//
//  Networking.swift
//  APIS
//
//  Created by Rex St John on 10/26/14.
//  Copyright (c) 2014 Rex St John. All rights reserved.
//

import Foundation
import Alamofire

/**
* Response Object Serializer Extension
*/

@objc public protocol ResponseObjectSerializable {
    init(response: NSHTTPURLResponse, representation: AnyObject)
}

extension Alamofire.Request {
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            if response != nil && JSON != nil {
                return (T(response: response!, representation: JSON!), nil)
            } else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? T, error)
        })
    }
}

/**
* Response Object Collection Extension
*/

@objc public protocol ResponseCollectionSerializable {
    class func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}

extension Alamofire.Request {
    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            if response != nil && JSON != nil {
                return (T.collection(response: response!, representation: JSON!), nil)
            } else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? [T], error)
        })
    }
}

/**
* Our Networking class
*/

final class Networking {
    
    // Get nearby events by a provided Zip Code
    class func getEventsNearby() {
        Alamofire.request(.GET, "http://api.jambase.com/events", parameters: ["zipCode": "95128","page":"0","api_key": "YOUR_KEY_HERE" ])
            .responseCollection  { (_, _, events: EventCollection?, _) in
                println(events)
        }
    }
}

/**
* A few model objects
*/

final class EventCollection: ResponseCollectionSerializable {
    
    class func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [EventCollection]{
        
    }

}

final class Artist: ResponseObjectSerializable {
    let name: String
    
    required init(response: NSHTTPURLResponse, representation: AnyObject) {
        self.name = representation.valueForKeyPath("Name") as String
    }
}

final class Event: ResponseObjectSerializable {
    let ticketUrl: String
    let venue: Venue
    
    required init(response: NSHTTPURLResponse, representation: AnyObject) {
        self.ticketUrl = representation.valueForKeyPath("TicketUrl") as String
        self.venue = representation.valueForKeyPath("Venue") as Venue
    }
}

final class Venue: ResponseObjectSerializable {
    let name: String
    let city: String
    let address: String
    
    required init(response: NSHTTPURLResponse, representation: AnyObject) {
        self.name = representation.valueForKeyPath("Name") as String
        self.city = representation.valueForKeyPath("City") as String
        self.address = representation.valueForKeyPath("Address") as String
    }
}
