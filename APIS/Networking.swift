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
        Alamofire.request(.GET, "http://api.jambase.com/events", parameters: ["zipCode":"98102", "page":"0","api_key":"EXAMPLE_KEY" ]).responseCollection  { (_, _, events: [Event]?, _) in
                println(events)
        }
    }
}

/**
* Simple Model Objects
*/

/**
* This represents a collection of JamBase API Event models.
*/
final class Event: ResponseObjectSerializable, ResponseCollectionSerializable {

    let ticketUrl: String
    let venue: Venue
    let artists: [Artist]
    let date: String
    
    required init(response: NSHTTPURLResponse, representation: AnyObject) {
        self.ticketUrl = representation.valueForKeyPath("TicketUrl") as String
        self.venue = Venue(response:response, representation: representation.valueForKeyPath("Venue")!)
        self.date = representation.valueForKeyPath("Date") as String
        self.artists = []
        
        for artistRep in representation.valueForKeyPath("Artists") as [AnyObject]{
            self.artists.append(Artist(response: response, representation: artistRep))
        }
    }
    
    class func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Event] {
        var events:[Event] = []
        for eventsRep in representation.valueForKeyPath("Events") as [AnyObject] {
            events.append(Event(response: response, representation: eventsRep))
        }
        return events
    }
    
    func toDic() -> Dictionary<String,AnyObject> {
        return ["ticketURL": self.ticketUrl, "venue":self.venue, "artists":self.artists, "date":self.date]
    }
}

final class Artist: ResponseObjectSerializable {
    let name: String
    
    required init(response: NSHTTPURLResponse, representation: AnyObject) {
        self.name = representation.valueForKeyPath("Name") as String
    }
}

final class Venue: ResponseObjectSerializable {
    let name: String
    let city: String
    let address: String
    let country: String
    let zipCode: String
    let state: String
    let stateCode: String
    
    required init(response: NSHTTPURLResponse, representation: AnyObject) {
        self.name = representation.valueForKeyPath("Name") as String
        self.city = representation.valueForKeyPath("City") as String
        self.country = representation.valueForKeyPath("Country") as String
        self.zipCode = representation.valueForKeyPath("ZipCode") as String
        self.state = representation.valueForKeyPath("State") as String
        self.address = representation.valueForKeyPath("Address") as String
        self.stateCode = representation.valueForKeyPath("StateCode") as String
    }
}
