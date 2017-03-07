//
//  DataBaseAccess.swift
//  SanDiegoCrime
//
//  Created by Huangxi on 11/28/16.
//  Copyright © 2016 Huangxi. All rights reserved.
//

import UIKit
import SQLite

class DataBaseAccess {

    var db:Connection?
    var path:String?
    let communityTableName:String = "Community"
    let comm_total_rateName:String = "comm_total_rate"
    let average_rate_tableName:String = "average"
    let average_rate_year_tableName:String = "total_rate_each_year"
    let comm_rate_year_tableName:String = "comm_rate_each_year"
    
    let comm_code = Expression<String>("code")
    let comm_name = Expression<String>("name")
    let community_name = Expression<String>("community")
    let year = Expression<Int>("year")
    let rate = Expression<Double>("rate")
    let crime_type = Expression<String>("type")
    let ave_rate = Expression<Double>("average_rate");
    let totalrate = Expression<Double>("rate")
    let  lon = Expression<Double>("lon")
    let lat  = Expression<Double>("lat")
    let zipcode = Expression<Int>("zipcode")
    
    var community:Table?
    var comm_total_rate:Table?
    var average_rate_table:Table?
    var comm_rate_year_table:Table?
    var average_rate_year_table:Table?
    
    init(){
        
    }
    
    init(Path path:String?){
        self.path  = path!;
    }
    
    func getConnection() throws ->Connection?{
        if db == nil{
            let path:String = Bundle.main.path(forResource: "CrimeData", ofType: "sqlite")!
            print(path);
            db = try Connection(path, readonly: true)
        }else{
            return db!;
        }
        return nil
    }
    
    
    func createDatabase() throws{
        community = Table(self.communityTableName)
        comm_total_rate = Table(self.comm_total_rateName)
        average_rate_table = Table(self.average_rate_tableName)
        average_rate_year_table = Table(self.average_rate_year_tableName)
        comm_rate_year_table = Table(self.comm_rate_year_tableName)
    }
    
    func getCommunitys() throws ->[CalloutRecord]{
        var calloutRecordArray:[CalloutRecord] = [CalloutRecord]();
        var newCalloutRecord:CalloutRecord
        
        for comm in (try db?.prepare(community!))! {
            newCalloutRecord = CalloutRecord(Comm_Code: comm[comm_code],Comm_Name: comm[comm_name],Lon: comm[lon],Lat: comm[lat],Zip: comm[zipcode]);
            
            let query = comm_total_rate?.join(average_rate_table!, on: comm_total_rate![crime_type] == average_rate_table![crime_type] ).filter((comm_total_rate?[community_name])! == newCalloutRecord.code).order((comm_total_rate?[rate])!.desc).limit(3)
            
            for crimeRecord in (try db?.prepare(query!))!{
                newCalloutRecord.addCrimeRateRecord(Record: RateRecord(
                Type: crimeRecord[(comm_total_rate?[crime_type])!],
                Rate: crimeRecord[(comm_total_rate?[rate])!]*1000/57,
                Ave_Rate: crimeRecord[(average_rate_table?[ave_rate])!]*1000/57) )
            }
           // print(newCalloutRecord.toString())
            calloutRecordArray.append(newCalloutRecord)
        }
        
        return calloutRecordArray
    }
//        let crime_type_num:Int = 14;
//        let comm_num:Int = 57;
//        for i in  comm_num {
//            
//        }
//        
//        let query = community!.join(comm_total_rate!,on: community![comm_code] == comm_total_rate![community_name]).order(community![comm_code],
//            comm_total_rate![rate].desc).limit(3, offset:5);
//        for comm in (try db?.prepare(query))! {
//            print("id: \(comm[comm_code]), name: \(comm[comm_name]), email: \(comm[lon])"
//                 + "rate:\(comm[rate])")
  
    func getCommunityCrime(Comm communityCode:String) throws ->([String],[Double],[Double]){
        var crimeType:[String] = [String]()
        var crimeRate:[Double] = [Double]()
        var averageRate:[Double] = [Double]()
        
        let query = comm_total_rate?.filter(community_name == communityCode).join(average_rate_table!, on:comm_total_rate![crime_type] == average_rate_table![crime_type] )
        
        for record in (try db?.prepare(query!))!{
            crimeType.append(record[(comm_total_rate?[crime_type])!])
            crimeRate.append(record[(comm_total_rate?[rate])!])
            averageRate.append(record[(average_rate_table?[ave_rate])!])
        }
        
        return (crimeType,crimeRate,averageRate)
    }
    
    func getCommunityYearCrime(Comm communityCode:String) throws ->([[Double]],[[Double]]){
        var crimeYearData = [[Double]]()
        var averageYearData = [[Double]]()
        
        let query = comm_rate_year_table?.filter(community_name == communityCode).order(crime_type.asc, year.asc)
        

        var rateArray = [Double]()
        var aveArray = [Double]()
        for recrod in (try db?.prepare(query!))! {
            let type = recrod[crime_type]
            let year = recrod[self.year]
            let que = average_rate_year_table?.filter(crime_type == type && self.year == year)
            var averageRateRecord = try (db?.pluck(que!)!)
            rateArray.append(recrod[rate])
            aveArray.append((averageRateRecord?[rate])!)
            if rateArray.count == 5 {
                crimeYearData.append(rateArray)
                averageYearData.append(aveArray)
                rateArray.removeAll()
                aveArray.removeAll()
            }
        }
        
        return (crimeYearData,averageYearData)
    }
    
}
