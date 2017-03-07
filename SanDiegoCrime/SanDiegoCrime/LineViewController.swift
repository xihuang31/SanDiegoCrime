//
//  SecondViewController.swift
//  Final
//
//  Created by Wen Lin on 12/12/16.
//  Copyright © 2016 Wen Lin. All rights reserved.
//

import UIKit
import JBChart

class LineViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var lineChart: JBLineChartView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
      
    // Data goes here
    var crimeType = ["ARSON",  "ASSAULT", "BURGLARY" ,"DRUGS/ALCOHOL", "DUI",
              "FRAUD","HOMICIDE",  "MOTOR VEHICLE THEFT", "ROBBERY",
              "SEX CRIMES", "THEFT/LARCENY","VANDALISM", "VEHICLE BREAK-IN", "WEAPONS" ]
    var chartLegend = ["2008", "2009", "2010", "2011", "2012"]
    var crimeYearData = [[Double]]()
    var aveYearData = [[Double]]()
    var chartData = [Double]()
    var cityAverage = [Double]()
    
    // District name for header
    let district:String = ViewController.CURRENT_COMM_NAME

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getData()
        
        view.backgroundColor = UIColor.darkGray
        
        // lineChart setup 
        lineChart.backgroundColor = UIColor.darkGray
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.minimumValue = 10
        
        // to do add header and footer 
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: lineChart.frame.width, height: 16))
        
        print("lineChart, \(lineChart.frame.width)")
        let footer1 = UILabel(frame: CGRect(x: 0, y: 0, width: lineChart.frame.width/2, height: 16))
        footer1.textColor = UIColor.white
        footer1.text = "\(district)"
        footer1.backgroundColor = UIColor.blue
        
        let footer2 = UILabel(frame: CGRect(x: lineChart.frame.width/2, y: 0, width: lineChart.frame.width/2, height: 16))
        footer2.textColor = UIColor.white
        footer2.text = "San Diego Average"
        footer2.textAlignment = NSTextAlignment.right
        footer2.backgroundColor = UIColor.green
        
        footerView.addSubview(footer1)
        footerView.addSubview(footer2)
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: lineChart.frame.width, height: 50))
        header.textColor = UIColor.white
        header.font = UIFont.systemFont(ofSize: 24)
        header.text = "Crimes history: \(district)"
        header.textAlignment = NSTextAlignment.center
        
        lineChart.footerView = footerView
        lineChart.headerView = header
        
        lineChart.reloadData()
        lineChart.setState(.collapsed, animated: false)
        
        // Picker viwe set up 
        pickerView.backgroundColor = UIColor.darkGray
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: false)
        lineChart.reloadData()
        
    }
    
    func getData(){
        do{
            let db = DataBaseAccess();
            try db.getConnection();
            try db.createDatabase();
            (crimeYearData,aveYearData) = try db.getCommunityYearCrime(Comm: ViewController.CURRENT_COMM_CODE)
        }catch{
            
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        lineChart.reloadData()
        let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(LineViewController.showChart), userInfo: nil, repeats: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideChart()
    }
    
    func hideChart() {
        lineChart.setState(.collapsed, animated: true)
    }
    
    func showChart() {
        lineChart.setState(.expanded, animated: true)
    }
    
    // Mark: JBLineChartView 
    func numberOfLines(in lineChartView: JBLineChartView!) -> UInt {
        return 2
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        if (lineIndex == 0) {
            return UInt(chartData.count)
        } else if (lineIndex == 1) {
            return UInt(cityAverage.count)
        }
        return 0
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        if (lineIndex == 0) {
            return CGFloat(chartData[Int(horizontalIndex)])
        } else if (lineIndex == 1) {
            return CGFloat(cityAverage[Int(horizontalIndex)])
        }
        return 0
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        if (lineIndex == 0) {
            return UIColor.blue
        } else if (lineIndex == 1) {
            return UIColor.green
        }
        return UIColor.blue
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        if (lineIndex == 0) {return true}
        else if (lineIndex == 1) { return false }
        return false
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.lightGray
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        if (lineIndex == 0) { return false }
        else if (lineIndex == 1) { return true }
        
        return true
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, didSelectLineAt lineIndex: UInt, horizontalIndex: UInt) {
        if (lineIndex == 0) {
            let data = (chartData[Int(horizontalIndex)]*100).format(f: "0.2")
            let key = chartLegend[Int(horizontalIndex)]
            informationLabel.text = "\(key) in \(district): \(data) %"
        } else if (lineIndex == 1) {
            let data = (cityAverage[Int(horizontalIndex)] * 100).format(f: "0.2")
            let key = chartLegend[Int(horizontalIndex)]
            informationLabel.text = "Average of \(key): \(data) %"
        }
    }
    
    func didDeselectLine(in lineChartView: JBLineChartView!) {
        informationLabel.text = ""
    }

    // Mark: Picker View 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return crimeType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return crimeType[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "SanFranciscoText-Light", size:24)
        
        label.text = crimeType[row]
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chartData = crimeYearData[row]
        cityAverage = aveYearData[row]
        lineChart.reloadData()
    }


}

