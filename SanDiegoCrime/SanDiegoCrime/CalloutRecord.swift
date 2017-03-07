//
//  CalloutRecord.swift
//  SanDiegoCrime
//
//  Created by Huangxi on 12/4/16.
//  Copyright © 2016 Huangxi. All rights reserved.
//

import UIKit

class CalloutRecord {
    
    var code:String
    var communityName:String;
    var lon:Double;
    var lat:Double
    var zipcode:Int
    var crimeRates:[RateRecord] = [RateRecord]()
    
    init(Comm_Code code:String, Comm_Name communityName:String, Lon lon:Double, Lat lat:Double, Zip zip:Int){
        self.code = code
        self.communityName = communityName
        self.lat = lat
        self.lon = lon
        self.zipcode = zip
    }
    
    func addCrimeRateRecord(Record record:RateRecord){
        crimeRates.append(record);
    }
    
    func toString() ->String{
        return "Code \(code)  zipcode: \(zipcode) firstCrime:\(crimeRates[0].rate) \(crimeRates[1].rate)  \(crimeRates[2].rate)"
    }
}
