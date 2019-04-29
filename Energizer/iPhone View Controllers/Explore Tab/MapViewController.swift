//
//  MapViewController.swift
//  UBottomSheet
//
//  Created by ugur on 13.08.2018.
//  Copyright © 2018 otw. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import CodableFirebase
import SwiftTheme

class MapViewController: UIViewController, BottomSheetDelegate, CLLocationManagerDelegate, PassFilterProtocol{
    
    func reloadForNetwork(sender: UIBarButtonItem) {
        self.viewWillAppear(true)
    }
    
    func fetchedRecents() -> [myMKLocalSearchCompletion] {
        return self.searchRecents
    }
    
    //MARK: Original outlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var mapView: MKMapView!

    //MARK: New Outlets
    @IBOutlet weak var collapseFilterContainer: UIButton!
    @IBOutlet weak var filterContainer: UIView!
    @IBOutlet weak var filterContainerYOverBottom: NSLayoutConstraint!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var compassView: UIView!
    @IBAction func collapseFilterPressed(_ sender: UIButton) {
        toggleFilterContainer()
    }
    @IBAction func filterPressed(_ sender: UIButton) {
        toggleFilterContainer()
        updateFilterButton()
    }
    
    //MARK: New Vars
    var defaultFilter = Filter(WithinRangeOnly: false, EVChargerTypeOnly: false, PriceMax: 500, IsOperationalNow: false, FastestChargersOnly: false, minPower: 120.0, minQuantity: 0)
    var previousfitler = Filter(WithinRangeOnly: false, EVChargerTypeOnly: false, PriceMax: 500, IsOperationalNow: false, FastestChargersOnly: false, minPower: 120.0, minQuantity: 0)
    
    let regionRadius: CLLocationDistance = 3500
    var ref: DatabaseReference!
    var previousNearbyConditions: String = "Non-optinal (Placeholder)"
    var currentLat: Float = 51.5074
    var currentLong: Float = -0.1278
    var currentLocation = CLLocation(latitude: CLLocationDegrees(51.50998), longitude: CLLocationDegrees(-0.1337))
    var firstCenteringDone = false
    var locationManager = CLLocationManager()
    var circle = MKCircle()
    var circleOverlay = MKCircleRenderer()

    var allChargeStationList: [ChargePoint] = []
    var alwaysUnfilteredStationList: [ChargePoint] = []
    
    var favouritesList : [ChargePoint] = []
    var unfilteredFavouritesList : [ChargePoint] = []
    var resultsList : [ChargePoint] = []
    var unfilteredResultsList : [ChargePoint] = []
    var nearbyList : [ChargePoint] = []
    var unfilteredNearbyList : [ChargePoint] = []
    var evAnnotations2show : [evStationAnnotation] = []
    var searchRecents : [myMKLocalSearchCompletion] = []
    
    var conditions : String = "?output=json&countrycode=GB&verbose=False"
    var previousConditions: String = ""
    var Longitude : Float = -1.5
    var Latitude : Float = 52.5
    var vehicleRange : Float = 1 //miles
    var ResultsNo : Int = 150
    var Distance: Int = 20
    var DistanceUnit: Int = 0 //Miles: 0 KM:1
    var childViewerReference: BottomSheetViewController? = nil
    var accentColor = UIColor.init(named: "AccentColour1")
    var rangeLabel: UIButton? = nil
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
//        UITabBar.appearance().theme_barTintColor = Colors.secondaryColor // your color
//        UITabBar.appearance().theme_tintColor = Colors.accentColor
//        UITabBar.appearance().unselectedItemTintColor = UIColor.init(named: "Accent5")
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.5))
        lineView.theme_backgroundColor = Colors.tabBarSeparationColor
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Gotham-Book", size: 9)], for: .normal)
        UITabBar.appearance().addSubview(lineView)

        mapView.delegate = self
        ref = Database.database().reference()
        self.unfilteredFavouritesList = self.favoutitesLoaded()     //load locally saved favourites list
        
        //MARK: Viewer formatting
        setUpFormatting()
        updateFilterButton()
    
        for subView in filterContainer.subviews {
            if let filtersView = subView as? FiltersView {
                filtersView.delegate = self
            }
        }
        
        ref.child("users/email/UserInfo/CurrentCar/").observe(.value, with: { snapshot in
            guard let value = snapshot.value else { return }
            do {
                let currentCarInfo = try FirebaseDecoder().decode(myCarInfo.self, from: value)
                self.vehicleRange = currentCarInfo.milesRemaining!
            } catch let error {
                print(error)
            }
//            let rangeText = String.localizedStringWithFormat("%.2f %@", self.vehicleRange, "miles")
            self.rangeLabel!.setTitle(String(format: "%.1f miles", self.vehicleRange), for: .normal)
            self.rangeLabel!.titleLabel?.frame = CGRect(x: self.rangeLabel!.frame.height * 0.8, y: 0, width: self.rangeLabel!.frame.width - (self.rangeLabel!.frame.height * 0.8), height: self.rangeLabel!.frame.height)
            self.annotateEVonMap(self.allChargeStationList)
            self.updateRadiusCircle(location: self.currentLocation)
            
        })
        
        ref.child("users/email/UserInfo/RecentSearches").observe(.value, with: { snapshot in
            self.searchRecents = []
            print ("Observing Recent Searches")
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                do {
                    let aRecent = try FirebaseDecoder().decode(myMKLocalSearchCompletion.self, from: child.value!)
                    self.searchRecents.append(aRecent)
                } catch let error {
                    print(error)
                }
            }
            self.searchRecents = self.searchRecents.sorted(by: { $0.timestamp > $1.timestamp })
            if self.searchRecents.count > 10{
                self.ref.child("users/email/UserInfo/RecentSearches/" + self.searchRecents.last!.title).removeValue()
            }
            self.childViewerReference?.refreshTable()
        })
        
        ref.child("users/email/FavouriteStations/").observe(.value, with: { snapshot in
            self.unfilteredFavouritesList = []
            print ("Observing Favourites")
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                do {
                    let station = try FirebaseDecoder().decode(ChargePoint.self, from: child.value!)
                    self.unfilteredFavouritesList.append(station)
                } catch let error {
                    print(error)
                }
            }
            self.saveFavourites(favouritesToSave: self.unfilteredFavouritesList)
            self.unfilteredFavouritesList = self.getNewDistances(list2SetNewDistances: self.unfilteredFavouritesList)
            self.favouritesList = self.filterList(filter: self.previousfitler, unfilteredStationList: self.unfilteredFavouritesList)
            self.childViewerReference?.refreshTable()
        })
        
        //get current location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        mapView.showsPointsOfInterest = false
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        registerAnnotationViewClasses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if evAnnotations2show.count > 2{
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(self.evAnnotations2show)
        }
        self.childViewerReference?.refreshTable()

        //Attempt to have offline mode
//        if Reachability.isConnectedToNetwork(){
//            print("Yes Internet Connection!")
//            self.childViewerReference?.tableShown = .menu
//            self.childViewerReference?.searchBar.isHidden = false
//            self.childViewerReference?.navBarTitle.isHidden = true
//            self.childViewerReference?.navBarTitle.barTintColor = UIColor.white
//            self.childViewerReference?.navBarBackButton.title = "Back"
//        } else {
//            print("No Internet Connection")
//            self.childViewerReference?.tableShown = .favourites
//            self.childViewerReference?.navBarTitle.barTintColor = UIColor.red.withAlphaComponent(0.8)
//            self.childViewerReference?.searchBar.isHidden = true
//            self.childViewerReference?.navBarTitle.isHidden = false
//            let offlineLabel = UILabel()
//            offlineLabel.text = "No Network Connection"
//            self.childViewerReference?.navBarTitleText.titleView = offlineLabel
//            self.childViewerReference?.navBarBackButton.title = "Reload"
//        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAuthorizedtoGetUserLocation()
        updateFilterButton()
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        if MyThemes.isNight(){
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BottomSheetViewController{
            childViewerReference = vc
            vc.bottomSheetDelegate = self
            vc.parentView = container
        }
    }

    func updateBottomSheet(frame: CGRect) {
        container.frame = frame
                backView.frame = self.view.frame.offsetBy(dx: 0, dy: 15 + container.frame.minY - self.view.frame.height)
                backView.backgroundColor = UIColor.black.withAlphaComponent(1 - (frame.minY)/200)
                rangeLabel?.alpha = (frame.minY)/200 - 0.3
    }
    
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func toggleFilterContainer(){
        UIView.animate(withDuration:0.2, delay:0, options: .curveEaseIn, animations: {
            if self.filterContainerYOverBottom.constant == UIScreen.main.bounds.height{
                self.collapseFilterContainer.isHidden = false
                self.filterContainerYOverBottom.constant -= UIScreen.main.bounds.height/1.4
                self.collapseFilterContainer.alpha = 0.5
            } else {
                self.collapseFilterContainer.isHidden = true
                self.filterContainerYOverBottom.constant = UIScreen.main.bounds.height
                self.collapseFilterContainer.alpha = 0
            }
            self.view.layoutIfNeeded()
            self.filterContainer.layoutIfNeeded()
        }, completion: nil)
    }
    
    func removeDuplicates(list2Filter: [ChargePoint]) -> [ChargePoint] {
        var list2Return : [ChargePoint] = []
        var IDlist : [Int] = []
        for aPoint in list2Filter{
            IDlist.append(aPoint.ID)
        }
        IDlist = Array(Set(IDlist))
        for bPoint in list2Filter{
            if IDlist.contains(bPoint.ID){
                list2Return.append(bPoint)
                IDlist.remove(at: IDlist.firstIndex(of: bPoint.ID)!)
            }
        }
        return list2Return
    }
    
    func saveFavourites(favouritesToSave: [ChargePoint]){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(favouritesToSave), forKey: "savedFavourites")
    }
    
    func favoutitesLoaded() -> [ChargePoint] {
        if UserDefaults.standard.object(forKey: "savedFavourites") != nil{
            let firstCarData = UserDefaults.standard.object(forKey: "savedFavourites") as! Data
            return try! PropertyListDecoder().decode([ChargePoint].self, from: firstCarData)
        } else {
            return []
        }
    }
    
    func updateFilterButton(){
        if self.previousfitler == self.defaultFilter{
            self.childViewerReference?.navBarFilterButton.theme_tintColor = Colors.primaryTextColor
            self.filterButton.theme_tintColor = Colors.mapIconsColor
        } else {
            self.childViewerReference?.navBarFilterButton.tintColor = UIColor.init(named: "Accent5")
            self.filterButton.tintColor = UIColor.init(named: "Accent5")
        }
    }
    
    func setUpFormatting() {
        
        mapView.showsCompass = false
        let compass = MKCompassButton(mapView: mapView)
        compassView.addSubview(compass)
        
        collapseFilterContainer.isHidden = true
        filterContainerYOverBottom.constant = UIScreen.main.bounds.height
//        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        container.layer.cornerRadius = 15
//        container.layer.masksToBounds = false
//
        buttonView.layer.shadowOpacity = 0.7
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowRadius = 2.5
        buttonView.layer.shadowOffset = CGSize(width: 0, height: 0)
        buttonView.theme_backgroundColor = Colors.containerColor
        filterButton.layer.masksToBounds = true
        filterButton.theme_backgroundColor = Colors.primaryColor
        
        filterButton.setImage(#imageLiteral(resourceName: "FilterIcon").withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        filterButton.theme_tintColor = Colors.mapIconsColor
        filterButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        filterButton.layer.theme_borderColor = Colors.containerBorderColor
        filterButton.layer.borderWidth = 1
//        filterButton.layer.backgroundColor = UIColor.white.cgColor
        filterButton.clipsToBounds = true
        filterButton.layer.cornerRadius = 8
        filterButton.layer.cornerRadius = buttonView.layer.cornerRadius
        filterButton.contentEdgeInsets = UIEdgeInsets(top: 4.5, left: 4.5, bottom: 4.5, right: 4.5)
        
        let buttonTracking = MKUserTrackingButton(mapView: mapView)
        buttonTracking.theme_backgroundColor = Colors.primaryColor
        buttonTracking.theme_tintColor = Colors.mapIconsColor
        buttonTracking.layer.theme_borderColor = Colors.containerBorderColor
        buttonTracking.layer.borderWidth = 1
        buttonTracking.clipsToBounds = true
        buttonTracking.layer.cornerRadius = filterButton.layer.cornerRadius
        buttonTracking.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        buttonTracking.translatesAutoresizingMaskIntoConstraints = false

        buttonView.addSubview(buttonTracking)
        
        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .trailing
        scale.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scale)
        
        NSLayoutConstraint.activate([buttonTracking.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 1),
                                     buttonTracking.trailingAnchor.constraint(equalTo: filterButton.trailingAnchor),
                                     buttonTracking.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor),
                                     buttonTracking.trailingAnchor.constraint(equalTo: buttonTracking.trailingAnchor),
                                     buttonTracking.heightAnchor.constraint(equalToConstant: 40), scale.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     scale.topAnchor.constraint(equalTo: view.topAnchor,constant: 25)])
        
        self.rangeLabel = UIButton(frame: CGRect(x: container.frame.maxX * 0.70, y: -(container.frame.width*0.055), width: container.frame.width * 0.25, height:container.frame.width*0.052))
        self.rangeLabel?.setImage(UIImage.init(named: "rangeIcon"), for: .normal)
        self.rangeLabel?.imageView?.contentMode = .scaleAspectFit
        self.rangeLabel?.setTitleColor(UIColor.black, for: .normal)
        self.rangeLabel?.titleLabel?.font = self.rangeLabel?.titleLabel?.font.withSize(12)
        self.rangeLabel?.imageView?.frame = CGRect(x: 0, y: 0, width: rangeLabel!.frame.height * 0.8, height: rangeLabel!.frame.height)
        self.rangeLabel?.titleLabel!.numberOfLines = 1
        container.addSubview(self.rangeLabel!)

    }

}

extension MapViewController {    // functions to get the information
    func setupConditions(latitude: Float, longitude: Float) -> String{
        var conditions : String = "?output=json&countrycode=GB&verbose=False"
        conditions+="&maxresults="+String(self.ResultsNo)
        conditions+="&longitude="+String(longitude)
        conditions+="&latitude="+String(latitude)
        
        if self.Distance > 0{
            conditions+="&distance="+String(self.Distance)
            conditions+="&distanceunit="+String(self.DistanceUnit)
        }
        return conditions
    }
    
    func getNearbyStations(){
        self.Latitude = self.currentLat
        self.Longitude = self.currentLong
        centerMapOnLocation(location: CLLocation(latitude: CLLocationDegrees(self.currentLat), longitude: CLLocationDegrees(self.currentLong)))
        let nearbyConditions = self.setupConditions(latitude: self.currentLat, longitude: self.currentLong)
        self.getEVapi(conditions: nearbyConditions, list2update: .nearbyList)
    }
    
    func getEVapi(conditions: String, list2update: list2Update){
        DispatchQueue.main.async {
            let url = URL(string: "https://api.openchargemap.io/v3/poi/" + conditions)
            if conditions != self.previousConditions{
                print(conditions)
                self.previousConditions = conditions
                if let usableUrl = url {
                    let request = URLRequest(url: usableUrl)
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                        guard let data = data else {return}
                        do {
                            let chargeStations = try JSONDecoder().decode([ChargePoint].self, from: data)
                            let list2Return = chargeStations
                            DispatchQueue.main.async{
                                switch list2update {
                                case .nearbyList:
                                    self.unfilteredNearbyList = list2Return
                                    self.filterAllData(filter: self.previousfitler)
                                case .resultsList:
                                    self.unfilteredResultsList = list2Return
                                    self.filterAllData(filter: self.previousfitler)
                                    self.resultsList = self.filterList(filter: self.previousfitler, unfilteredStationList: self.unfilteredResultsList)
                                case .favouritesList:
                                    self.unfilteredFavouritesList = list2Return
                                    self.filterAllData(filter: self.previousfitler)
                                }
                            }
                            print("API fetch Done")
                        } catch let jsonErr {
                            print("error serializing json:", jsonErr)
                        }
                    })
                    task.resume()
                }
            }
        }
    }
    
}

extension MapViewController {   //location stuff
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        self.currentLocation = userLocation
        self.currentLat = Float(userLocation.coordinate.latitude)
        self.currentLong = Float(userLocation.coordinate.longitude)
        if self.firstCenteringDone == false{
            self.getNearbyStations()
            self.firstCenteringDone = true
        }     
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    func updateRadiusCircle(location: CLLocation){
        mapView.removeOverlays(mapView.overlays)
        self.circle = MKCircle(center: location.coordinate, radius: CLLocationDegrees(self.vehicleRange * 1609.34) as CLLocationDistance)
        self.mapView.addOverlay(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            self.circleOverlay = MKCircleRenderer(overlay: overlay)
            self.circleOverlay.strokeColor = accentColor
            self.circleOverlay.fillColor = accentColor?.withAlphaComponent(0.05)
            self.circleOverlay.lineWidth = 1
            return self.circleOverlay
        } else {
            return MKOverlayRenderer()
        }
    }
    
}

extension MapViewController{ //filter stuff
    func filterAllData(filter: Filter){
        if self.previousfitler != filter{
            self.nearbyList = filterList(filter: filter, unfilteredStationList: self.unfilteredNearbyList)
            self.favouritesList = filterList(filter: filter, unfilteredStationList: self.unfilteredFavouritesList)
            self.resultsList = filterList(filter: filter, unfilteredStationList: self.unfilteredResultsList)
            self.previousfitler = filter           //assign filter to previous filter for future comparison
            
        } else {
            self.nearbyList = self.unfilteredNearbyList
            self.favouritesList = self.unfilteredFavouritesList
            self.resultsList = self.unfilteredResultsList
        }
        
        self.allChargeStationList = removeDuplicates(list2Filter: (self.nearbyList + self.resultsList + self.favouritesList))
        self.annotateEVonMap(self.allChargeStationList)
        self.childViewerReference?.refreshTable()
        updateFilterButton()
    }
    
    func filterList(filter: Filter, unfilteredStationList: [ChargePoint]) -> [ChargePoint]{
        var filteredStationList : [ChargePoint] = []
        filteredStationList = filterPrice(unfilteredStationList, filter.PriceMax)            //price filtering
        filteredStationList = filterNoOfChargers(filteredStationList, filter.minQuantity)          //quantity filtering
        filteredStationList = filterType2(filteredStationList, filter.EVChargerTypeOnly)           //type2 filtering
        filteredStationList = filterRange(filteredStationList, filter.WithinRangeOnly)             //within range filtering
        return filteredStationList
    }
    
    func filterNoOfChargers(_ list2Filter:[ChargePoint], _ minQnty: Int) -> [ChargePoint] {
        var returnTable : [ChargePoint] = []
        for chargeStation in list2Filter{
            if let numPoints = chargeStation.NumberOfPoints,
                numPoints >= minQnty {
                returnTable.append(chargeStation)
            } else {
                if minQnty == 0{
                    returnTable.append(chargeStation)
                }
            }
        }
        return returnTable
    }
    
    func filterPrice(_ list2Filter:[ChargePoint], _ maxPrc: Int) -> [ChargePoint] {
        var returnTable : [ChargePoint] = []
        if maxPrc != 500{
            for var cStation in list2Filter{
                if cStation.UsageCost == nil{
                    cStation.UsageCost = "Free"
                    returnTable.append(cStation)
                } else {
                    cStation.UsageCost = cStation.UsageCost?.returnPriceForCostFromString().first
                    if let theCost = Int(cStation.UsageCost ?? "Free"){
                        if cStation.UsageCost == "Free" || cStation.UsageCost == "FREE"{
                            returnTable.append(cStation)
                        } else if theCost < maxPrc{
                            returnTable.append(cStation)
                        }
                    }
                }
            }
        } else {
            returnTable = list2Filter
        }
        return returnTable
    }
    
    func filterType2(_ list2Filter:[ChargePoint], _ filterForType2Only:Bool) -> [ChargePoint]{
        var returnTable : [ChargePoint] = []
        if filterForType2Only == true{
            for cStation in list2Filter{
                if (cStation.Connections?.description.contains("Type 2")) ?? false{
                    returnTable.append(cStation)
                }
            }
        }else{
            returnTable = list2Filter
        }
        return (returnTable)
    }
    
    func filterRange(_ list2Filter:[ChargePoint], _ filterForRange: Bool) -> [ChargePoint] {
        var returnTable: [ChargePoint] = []
        if filterForRange == true{
            for cStation in list2Filter{
                if (cStation.AddressInfo.Distance < self.vehicleRange ){
                    returnTable.append(cStation)
                }
            }
        } else {
            returnTable = list2Filter
        }
        return (returnTable)
    }

}

extension MapViewController: MKMapViewDelegate{    //map annotation stuff
    func annotateEVonMap(_ evStations2Annotate: [ChargePoint]) {
        DispatchQueue.main.async {
            self.evAnnotations2show = []
            var listID : Int = 0
            for aStation in evStations2Annotate{
                if aStation.Connections?.description.contains("Type 2") ?? false{
                    if CLLocation(latitude: CLLocationDegrees(aStation.AddressInfo.Latitude!), longitude: CLLocationDegrees(aStation.AddressInfo.Longitude!)).distance(from: self.currentLocation) < Double(self.vehicleRange * 1609.34) {
                        self.evAnnotations2show.append(evStationAnnotation(
                            title: aStation.AddressInfo.AddressLine1 ?? "No Address Available",
                            listInID: aStation.ID,
                            noOfConnectors: aStation.NumberOfPoints ?? 0,
                            coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(aStation.AddressInfo.Latitude!),longitude: CLLocationDegrees(aStation.AddressInfo.Longitude!)),
                            compatible: true, colour: .green))
                    }else{
                        self.evAnnotations2show.append(evStationAnnotation(
                            title: aStation.AddressInfo.AddressLine1 ?? "No Address Available",
                            listInID: aStation.ID,
                            noOfConnectors: aStation.NumberOfPoints ?? 0,
                            coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(aStation.AddressInfo.Latitude!),longitude: CLLocationDegrees(aStation.AddressInfo.Longitude!)),
                            compatible: true, colour: .amber))
                    }
                } else {
                    self.evAnnotations2show.append(evStationAnnotation(
                        title: aStation.AddressInfo.AddressLine1 ?? "No Address Available",
                        listInID: aStation.ID,
                        noOfConnectors: aStation.NumberOfPoints ?? 0,
                        coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(aStation.AddressInfo.Latitude!),longitude: CLLocationDegrees(aStation.AddressInfo.Longitude!)),
                        compatible: false, colour: .red))
                }
                listID += 1
            }
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(self.evAnnotations2show)
        }
    }
    
    func registerAnnotationViewClasses() {
        mapView.register(RedAnnotationMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(AmberAnnotationMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(GreenAnnotationMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier:
            MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.register(FavouriteAnnotationMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    func getNewDistances(list2SetNewDistances: [ChargePoint]) -> [ChargePoint]{
        var list2Return : [ChargePoint] = []
        for aStation in list2SetNewDistances{
            var newStation = aStation
            newStation.AddressInfo.Distance = Float(CLLocation(latitude: CLLocationDegrees(aStation.AddressInfo.Latitude!), longitude: CLLocationDegrees(aStation.AddressInfo.Longitude!)).distance(from: self.currentLocation)) / Float(1609.34)
            list2Return.append(newStation)
        }
        return list2Return
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let evAnnotationpressed = view.annotation as? evStationAnnotation{
            let station2DETAIL: ChargePoint = getChargePoint(ID: evAnnotationpressed.whatID!, fromList: self.allChargeStationList)
            childViewerReference?.fromMap2Detail = station2DETAIL
            childViewerReference?.pass2detail(evStation2Detail: station2DETAIL)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let evannotation = annotation as? evStationAnnotation else {return nil }
        var favesList : [Int] = []
        for fave in self.favouritesList{
            favesList.append(fave.ID)
        }
        if favesList.contains(evannotation.listInID){
            return FavouriteAnnotationMarker(annotation: evannotation, reuseIdentifier: FavouriteAnnotationMarker.ReuseID)
        } else {
            switch evannotation.colour {
            case .red:
                return RedAnnotationMarker(annotation: evannotation, reuseIdentifier: RedAnnotationMarker.ReuseID)
            case .amber:
                return AmberAnnotationMarker(annotation: evannotation, reuseIdentifier: AmberAnnotationMarker.ReuseID)
            case .green:
                return GreenAnnotationMarker(annotation: evannotation, reuseIdentifier: GreenAnnotationMarker.ReuseID)
            }
        }
    }
    
    func getAnnotation(ID: Int, fromList: [evStationAnnotation]) -> evStationAnnotation {
        var annotation2Return: evStationAnnotation? = nil
        for entry in fromList{
            if entry.whatID == ID{
                annotation2Return = entry
            }
        }
        return annotation2Return!
    }
    
    func getChargePoint(ID: Int, fromList: [ChargePoint]) -> ChargePoint {
        var chargePoint2Return: ChargePoint? = nil
        for entry in fromList{
            if entry.ID == ID{
                chargePoint2Return = entry
            }
        }
        return chargePoint2Return!
    }
}

extension MapViewController{   //Protocol Functions
    func getCurrentLong() -> Float{
        return self.currentLong
    }
    
    func getCurrentLat() -> Float{
        return self.currentLat
    }
    
    func getVehicleRange() -> Float {
        return self.vehicleRange
    }
    
    func getFavouritesList() -> [ChargePoint]{
        return self.favouritesList
    }
    
    func getNearbyList() -> [ChargePoint] {
        return self.nearbyList
    }
    
    func getResultsList() -> [ChargePoint] {
        return self.resultsList
    }
}     //Protocol Functions

