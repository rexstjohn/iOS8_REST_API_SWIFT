//
//  Networking.swift
//  APIS
//
//  Created by Rex St John on 10/26/14.
//  Copyright (c) 2014 Rex St John. All rights reserved.
//

import Foundation
import Alamofire

class Networking {
    
    // Get nearby events by a provided Zip Code
    class func getEventsNearby() {
        Alamofire.request(.GET, "http://api.jambase.com/events", parameters: ["zipCode": "95128","page":"0","api_key": "65ftmfqrzasncw6sm97r2nv4" ])
            .responseJSON { (_, _, JSON, _) in
                println(JSON)
        }
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