//
//  RateRecord.swift
//  SanDiegoCrime
//
//  Created by Huangxi on 12/4/16.
//  Copyright © 2016 Huangxi. All rights reserved.
//

import UIKit;

class RateRecord {
    var type:String
    var rate:Double
    var ave_rate:Double
    
    init(Type type:String,Rate rate:Double,Ave_Rate ave_rate:Double){
        self.type = type
        self.rate = rate
        self.ave_rate = ave_rate
    }
    
    
    func set(Type type:String,Rate rate:Double,Ave_Rate ave_rate:Double){
        self.type = type
        self.rate = rate
        self.ave_rate = ave_rate
    }
    
    
}
