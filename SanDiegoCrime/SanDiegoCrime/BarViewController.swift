//
//  FirstViewController.swift
//  Final
//
//  Created by Wen Lin on 12/12/16.
//  Copyright © 2016 Wen Lin. All rights reserved.
//

import UIKit
import JBChart

class BarViewController: UIViewController, JBBarChartViewDelegate, JBBarChartViewDataSource {
    
    @IBOutlet weak var backToMap: UIButton!
    @IBOutlet weak var barChart: JBBarChartView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var averageView: UIView!
    @IBOutlet weak var averageValue: UILabel!
    
    // Data goest here
    var chartLegend:[String] = []
    var chartData:[Double] = []
    var crimeAverage:[Double] = []
    var districtZipcode:String = ViewController.CURRENT_COMM_CODE
    var districtName:String = ViewController.CURRENT_COMM_NAME
    
    @IBAction func touchBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        getData();
        view.backgroundColor = UIColor.darkGray
        averageView.backgroundColor = UIColor.darkGray
        
        // barChart setup 
        barChart.backgroundColor = UIColor.darkGray
        barChart.delegate = self
        barChart.dataSource = self
        barChart.minimumValue = 0
        
        // add footer header
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: barChart.frame.width, height: 50))
        header.textColor = UIColor.white
        header.font = UIFont.systemFont(ofSize: 24)
        header.text = "Crime detail in: \(districtName)"
        header.textAlignment = NSTextAlignment.center
        
        barChart.headerView = header
        barChart.reloadData()
        barChart.setState(.collapsed, animated: false)
    }
    
    func getData(){
        do{
            let db = DataBaseAccess();
            try db.getConnection();
            try db.createDatabase();
            (chartLegend,chartData,crimeAverage) = try db.getCommunityCrime(Comm: ViewController.CURRENT_COMM_CODE);
        }catch{
            
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // customized code, leave the alert alone here
        barChart.reloadData()
        let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BarViewController.showChart), userInfo: nil, repeats: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideChart()
    }
    
    func hideChart() {
        barChart.setState(.collapsed, animated: true)
    }
    
    func showChart() {
        barChart.setState(.expanded, animated: true)
    }
    
    // Mark: JBBarChartView 
    func numberOfBars(in barChartView: JBBarChartView!) -> UInt {
        return UInt(chartData.count)
    }
    
    func barChartView(_ barChartView: JBBarChartView!, heightForBarViewAt index: UInt) -> CGFloat {
        return CGFloat(chartData[Int(index)])
    }
    
    func barChartView(_ barChartView: JBBarChartView!, colorForBarViewAt index: UInt) -> UIColor! {
        return (index % 2 == 0) ? UIColor.blue : UIColor.green
    }
    
    func barChartView(_ barChartView: JBBarChartView!, didSelectBarAt index: UInt) {
        let data = (chartData[Int(index)] * 100).format(f: "0.2")
        let key = chartLegend[Int(index)]
        let average = ((crimeAverage[Int(index)] / 57) * 100).format(f: "0.2")
        
        informationLabel.text = "\(key): \(data) %"
        averageValue.text = "\(average) %"
    }
    
    func didDeselect(_ barChartView: JBBarChartView!) {
        informationLabel.text = ""
        averageValue.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

