//
//  ViewController.swift
//  SanDiegoCrime
//
//  Created by Huangxi on 11/23/16.
//  Copyright © 2016 Huangxi. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController ,MKMapViewDelegate, UITableViewDelegate,
                UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate{

    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    static var  CURRENT_COMM_NAME:String!
    static var  CURRENT_COMM_ZIPCODE:String!
    static var  CURRENT_COMM_CODE:String!
    
    var isSearchMode:Bool = false;
    
    var coordinates: [[Double]]!
    var communityNames:[String]!
    var top3Crimes:[String]!
    var zipcodes:[String]!
    var calloutRecordArray:[CalloutRecord] = [CalloutRecord]()
    var filterRecrodArray:[CalloutRecord] = [CalloutRecord]()
    
    var locationManager:CLLocationManager = CLLocationManager()
    var geocoder:CLGeocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView();
        getDataFromDatabase();
        setUpAnotation();
    }
    
    func setUpAnotation(){
        
        for record in calloutRecordArray {
            let coordinate = [record.lat , record.lon]
            let point = CommunityAnnotation(coordinate: CLLocationCoordinate2D(latitude: coordinate[0] , longitude: coordinate[1] ))
            
            point.communityName = record.communityName
            point.setZipCode(record.zipcode)
            point.setTop3Crime(Records: record.crimeRates)
            map.addAnnotation(point);
        }
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 32.77334474, longitude: -117.1458151), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.map.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        // 1
        if (view.annotation is MKUserLocation)
        {
            // Don't proceed with custom callout
            return
        }
        // 2
        let communityAnnotation = view.annotation as! CommunityAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.communityName.text = communityAnnotation.communityName
        calloutView.top3Crime.text = communityAnnotation.top3Crime3
        calloutView.zipcode.text = communityAnnotation.zipcode
        ViewController.CURRENT_COMM_NAME = communityAnnotation.communityName
        ViewController.CURRENT_COMM_ZIPCODE = communityAnnotation.zipcode
        ViewController.CURRENT_COMM_CODE = calloutRecordArray.filter({$0.communityName == ViewController.CURRENT_COMM_NAME}).first?.code
        // or for swift 2 +
        let gestureSwift2AndHigher = UITapGestureRecognizer(target: self, action:  #selector (self.someAction (_:)))
        calloutView.addGestureRecognizer(gestureSwift2AndHigher)
        calloutView.isUserInteractionEnabled = true
        //3
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        
        view.addSubview(calloutView)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureSwift2AndHigher)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    // or for Swift 3
    func someAction(_ sender:UITapGestureRecognizer){
        // do other task
        let storyboard = self.storyboard
        let destination = storyboard?.instantiateViewController(withIdentifier: "Tabbarviewcontroller")
        guard destination != nil else { return }
//        let main = UIApplication.shared
//        if let window = main.delegate?.window { window?.rootViewController = destination
//        }
        self.present(destination!, animated: true, completion: nil)
    }
    
//    func goToDetailView(sender: UIButton){
//        let storyboard = self.storyboard
//        let destination = storyboard?.instantiateViewController(withIdentifier: "Tabbarviewcontroller")
//        guard destination != nil else { return }
//        let main = UIApplication.shared
//        if let window = main.delegate?.window { window?.rootViewController = destination
//        }
//    }
    

   
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if (view.isKind(of: MKAnnotationView.self)){
            view.isUserInteractionEnabled = false
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getDataFromDatabase(){
        do{
            let db = DataBaseAccess();
            try db.getConnection();
            try db.createDatabase();
            calloutRecordArray = try db.getCommunitys();
        }catch{
            
        }
    }
    
    
    @IBAction func touchLocation(_ sender: AnyObject) {
        var zip:String?
        let allAnnotate = map.annotations as! [CommunityAnnotation]
        var annotate:CommunityAnnotation?
        geocoder.reverseGeocodeLocation(locationManager.location!, completionHandler:{ (placemarks,error) in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            // Zip code
            zip = placeMark.addressDictionary!["ZIP"] as? String!
            
        });
        if zip != nil {
            annotate  =  allAnnotate.filter({ $0.zipcode == zip!}).first
        }
        if annotate != nil  {
            map.selectAnnotation(annotate!, animated: true)
        }else{
            self.map.setCenter(locationManager.location!.coordinate, animated: true)
        }
        locationManager.requestLocation() //need remvoe later
    }
    
    @IBAction func back(unwindSegue:UIStoryboardSegue) {
        print("---------")
    }
    
    
    func setUpView(){
        map.delegate = self
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        searchTableView.isHidden = true
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed to \(status.rawValue)")
        switch status {
        case .authorized, .authorizedWhenInUse:
           // locationManager.startUpdatingLocation();
            locationManager.requestLocation()
        default: locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isSearchMode {
            return filterRecrodArray.count
        }
        return calloutRecordArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell
        if (indexPath.row % 2 == 0 ){
            cell = tableView.dequeueReusableCell(withIdentifier: "area",
                                                 for: indexPath)
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: "area2",
                                                 for: indexPath)
        }
        
        if isSearchMode {
            let record:CalloutRecord = filterRecrodArray[indexPath.row]
            cell.textLabel?.text =  record.communityName + "   " + String(record.zipcode)
        }else{
            let record:CalloutRecord = calloutRecordArray[indexPath.row]
            cell.textLabel?.text =  record.communityName + "   " + String(record.zipcode)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var mapAnnotations:[MKAnnotation] = map.annotations
        var flag:Int = 0
        for i in 1...mapAnnotations.count {
            if (mapAnnotations[i] is MKUserLocation){
                mapAnnotations.remove(at: i)
                flag = 1
            }
            if flag == 1 {
                break;
            }
        }
        let allAnnotations:[CommunityAnnotation] = mapAnnotations as! [CommunityAnnotation]
        var selectedAnnotation:CommunityAnnotation
        if isSearchMode {
          selectedAnnotation =  allAnnotations.filter({$0.communityName.lowercased() == filterRecrodArray[indexPath.row].communityName.lowercased() }).first!
        }else{
            selectedAnnotation =  allAnnotations.filter({$0.communityName.lowercased() == calloutRecordArray[indexPath.row].communityName.lowercased() }).first!
        }
        map.selectAnnotation(selectedAnnotation, animated: true);
        searchBar.text = ""
        searchTableView.isHidden = true
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchTableView.isHidden = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true);
        searchTableView.isHidden = true;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true);
        searchTableView.isHidden = true;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearchMode = false;
            searchBar.endEditing(true)
            searchTableView.reloadData()
            searchTableView.isHidden = true;
            searchTableView.reloadData();
        }else{
            isSearchMode = true;
            searchTableView.isHidden = false;
            let text = searchBar.text!;
            if Int(text) != nil{
                filterRecrodArray = calloutRecordArray.filter({String($0.zipcode).range(of:
                    text.lowercased()) != nil})
            }else{
                filterRecrodArray = calloutRecordArray.filter({$0.communityName.lowercased().range(of: text.lowercased()) != nil})
            }
            searchTableView.reloadData();
        }
            
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true);
    }

}

