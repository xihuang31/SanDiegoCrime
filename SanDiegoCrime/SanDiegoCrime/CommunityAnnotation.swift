//
//  CommunityAnnotation.swift
//  SanDiegoCrime
//
//  Created by Huangxi on 11/23/16.
//  Copyright © 2016 Huangxi. All rights reserved.
//

import UIKit
import MapKit

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}


class CommunityAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var communityName:String!
    var zipcode:String!
    var top3Crime3:String!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func setZipCode(_  zip:Int){
        zipcode = String(zip);
    }
    
    func setTop3Crime(Records records:[RateRecord]){
        self.top3Crime3 = "Top 3 Crimes:\n" +
        "\(records[0].type): \(records[0].rate.format(f: ".2"))‰ | \(records[0].ave_rate.format(f: ".2"))‰ \n" +
        "\(records[1].type): \(records[1].rate.format(f: ".2"))‰ | \(records[1].ave_rate.format(f: ".2"))‰ \n" +
        "\(records[2].type): \(records[2].rate.format(f: ".2"))‰ | \(records[2].ave_rate.format(f: ".2"))‰ "
    }
}
