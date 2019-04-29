
import UIKit
import MapKit
import SwiftTheme

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var evStationDetailed : ChargePoint?
    let pickerLabels = ["Food Nearby", "Coffee Nearby", "Attractions Nearby", "Parking Nearby", "Hotels Nearby"]
    let pickerData = ["Food", "Coffee", "Attraction", "Parking", "Hotel"]
    var localSearchQueryWord : String = ""
    var POInearEVcharger: [MKMapItem] = []
    let regionRadius: CLLocationDistance = 1250
    var evLatitude : Float = 52.2852
    var evLongitude : Float = -1.5201
    var currentLat : Float? = nil
    var currentLong : Float? = nil
    var vehicleRange: Float = 1
    
    var evLocation : CLLocation = CLLocation(latitude: 0, longitude: 0)
    var CLManager = CLLocationManager()
    var flag : Int = 0
    var tag : Int = 0
    var rowPicked: Int = 0
    var previousPickerRow = 3
    var nearbyRange = 600
    
    func updateDetailViewer(station2BDetailed: ChargePoint, currentLat: Float, currentLong: Float, vehicleRange: Float){
        self.evStationDetailed = station2BDetailed
        self.currentLat = currentLat
        self.currentLong = currentLong
        self.vehicleRange = vehicleRange
        self.refreshUI()
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var address2Label: UILabel!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var wordPicker: UIPickerView!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var townLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var noOfConnectorsLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func routePressed(_ sender: Any) {
        MKMapItem.openMaps(with: ([MKMapItem(placemark:
            MKPlacemark(coordinate:
                CLLocationCoordinate2D(latitude: CLLocationDegrees((self.evStationDetailed?.AddressInfo.Latitude)!), longitude: CLLocationDegrees((self.evStationDetailed?.AddressInfo.Longitude)!))))]),
                           launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionPOI: UICollectionView!
    
    override func viewDidLoad() {

        collectionPOI.theme_backgroundColor = Colors.primaryColor
        evLocation = CLLocation(latitude: CLLocationDegrees(self.evLatitude), longitude: CLLocationDegrees(self.evLongitude))
        mapView.delegate = self
        wordPicker.delegate = self
        wordPicker.dataSource = self
        self.view.theme_backgroundColor = Colors.primaryColor
        routeButton.theme_backgroundColor = Colors.accentColor
        routeButton.theme_tintColor = Colors.buttonTextColor
        titleLabel.theme_textColor = Colors.primaryTextColor
        address1Label.theme_textColor = Colors.detailSubTextColor
        address2Label.theme_textColor = Colors.detailSubTextColor
        postcodeLabel.theme_textColor = Colors.detailSubTextColor
        townLabel.theme_textColor = Colors.detailSubTextColor
        noOfConnectorsLabel.theme_textColor = Colors.detailSubTextColor
        costLabel.theme_textColor = Colors.detailSubTextColor
        backButton.theme_tintColor = Colors.accentColor
        backButton.titleLabel!.font = UIFont.boldSystemFont(ofSize:UIFont.labelFontSize)
        
        if self.evStationDetailed!.Connections?.description.contains("Type 2") ?? false{
            if CLLocation(latitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Latitude!), longitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Longitude!)).distance(from: CLLocation(latitude: CLLocationDegrees(self.currentLat!), longitude: CLLocationDistance(self.currentLong!))) < Double(self.vehicleRange * 1609.34) {
                self.mapView.addAnnotation(evStationAnnotation(
                    title: self.evStationDetailed!.AddressInfo.AddressLine1 ?? "No Address Available",
                    listInID: self.evStationDetailed!.ID,
                    noOfConnectors: self.evStationDetailed!.NumberOfPoints ?? 0,
                    coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Latitude!),longitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Longitude!)),
                    compatible: true, colour: .green))
            }else{
                self.mapView.addAnnotation(evStationAnnotation(
                    title: self.evStationDetailed!.AddressInfo.AddressLine1 ?? "No Address Available",
                    listInID: self.evStationDetailed!.ID,
                    noOfConnectors: self.evStationDetailed!.NumberOfPoints ?? 0,
                    coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Latitude!),longitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Longitude!)),
                    compatible: true, colour: .amber))
            }
        } else {
            self.mapView.addAnnotation(evStationAnnotation(
                title: self.evStationDetailed!.AddressInfo.AddressLine1 ?? "No Address Available",
                listInID: self.evStationDetailed!.ID,
                noOfConnectors: self.evStationDetailed!.NumberOfPoints ?? 0,
                coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Latitude!),longitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Longitude!)),
                compatible: false, colour: .red))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(true)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if MyThemes.isNight(){
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    func localSearch(_ pickerRow: Int) {
        let searchQuery = pickerData[pickerRow]
        centerMapOnLocation(location: CLLocation(latitude: CLLocationDegrees(self.evLatitude),longitude: CLLocationDegrees(self.evLongitude)))
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        request.region = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.evLatitude), longitude: CLLocationDegrees(self.evLongitude)), latitudinalMeters: CLLocationDistance(self.nearbyRange), longitudinalMeters: CLLocationDistance(self.nearbyRange))
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("There was an error searching for: \(String(describing: request.naturalLanguageQuery)) error: \(String(describing: error))")
                return}
            self.POInearEVcharger = self.filterForNearbyRange(response.mapItems)
            self.updatePOIannotations(pickerRow)
            self.collectionPOI.reloadData()
        }
    }
    
    func updatePOIannotations(_ type: Int) {
        var listOfPOIannotations : [POIannotation] = []
        for onePOI in self.POInearEVcharger{
            listOfPOIannotations.append(POIannotation(title: onePOI.name!, type: type, coordinate: onePOI.placemark.coordinate))
        }
        self.mapView.removeAnnotations(self.mapView.annotations)
        if self.evStationDetailed!.Connections?.description.contains("Type 2") ?? false{
            if CLLocation(latitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Latitude!), longitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Longitude!)).distance(from: CLLocation(latitude: CLLocationDegrees(self.currentLat!), longitude: CLLocationDistance(self.currentLong!))) < Double(self.vehicleRange * 1609.34) {
                self.mapView.addAnnotation(evStationAnnotation(
                    title: self.evStationDetailed!.AddressInfo.AddressLine1 ?? "No Address Available",
                    listInID: self.evStationDetailed!.ID,
                    noOfConnectors: self.evStationDetailed!.NumberOfPoints ?? 0,
                    coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Latitude!),longitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Longitude!)),
                    compatible: true, colour: .green))
            }else{
                self.mapView.addAnnotation(evStationAnnotation(
                    title: self.evStationDetailed!.AddressInfo.AddressLine1 ?? "No Address Available",
                    listInID: self.evStationDetailed!.ID,
                    noOfConnectors: self.evStationDetailed!.NumberOfPoints ?? 0,
                    coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Latitude!),longitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Longitude!)),
                    compatible: true, colour: .amber))
            }
        } else {
            self.mapView.addAnnotation(evStationAnnotation(
                title: self.evStationDetailed!.AddressInfo.AddressLine1 ?? "No Address Available",
                listInID: self.evStationDetailed!.ID,
                noOfConnectors: self.evStationDetailed!.NumberOfPoints ?? 0,
                coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Latitude!),longitude: CLLocationDegrees(self.evStationDetailed!.AddressInfo.Longitude!)),
                compatible: false, colour: .red))
        }
        self.mapView.addAnnotations(listOfPOIannotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationIdentifier = "AnnotationIdentifier"
        if annotation is evStationAnnotation{
            let evAnnotation = annotation as! evStationAnnotation
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: evAnnotation, reuseIdentifier: annotationIdentifier)
                annotationView!.canShowCallout = false
            }
            else {
                annotationView!.annotation = evAnnotation
            }
            annotationView!.frame.size.height = 40
            annotationView!.frame.size.width = 40
            annotationView?.centerOffset = CGPoint(x: 0, y: -20)
            let pinImage = UIImage(named: "mapPinIcon")
            let pinBoarderImageView = UIImageView(frame: CGRect(x:0 , y:0, width: 40, height: 40))
            pinBoarderImageView.image = pinImage?.withRenderingMode(.alwaysTemplate)
            pinBoarderImageView.contentMode = .scaleAspectFit
            let pinColourImageView = UIImageView(frame: CGRect(x: 1, y: 1, width: 38, height: 38))
            pinColourImageView.image = pinImage?.withRenderingMode(.alwaysTemplate)
            switch evAnnotation.colour{
            case .red:
                pinColourImageView.tintColor = UIColor(named: "pinRed")
                pinBoarderImageView.tintColor = UIColor(white: 30/255, alpha: 1)
            case .amber:
                pinColourImageView.tintColor = UIColor(named: "pinAmber")
                pinBoarderImageView.tintColor = UIColor(white: 30/255, alpha: 1)
            case .green:
                pinColourImageView.tintColor = UIColor(named: "pinGreen")
                pinBoarderImageView.tintColor = UIColor(white: 30/255, alpha: 1)
            }
            pinColourImageView.contentMode = .scaleAspectFit
            let iconImage = UIImage(named: "chargingStationIcon")
            let iconImageView = UIImageView(frame: CGRect(x: 8, y: 3, width: 24, height: 24))
            iconImageView.image = iconImage?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = UIColor.white
            iconImageView.contentMode = .scaleAspectFit
            
            annotationView?.addSubview(pinBoarderImageView)
            annotationView?.addSubview(pinColourImageView)
            annotationView?.addSubview(iconImageView)
            return annotationView
        }
        
        if annotation is POIannotation{
            let poiAnnotation = annotation as! POIannotation
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: poiAnnotation, reuseIdentifier: annotationIdentifier)
                annotationView!.canShowCallout = true
            }
            else {
                annotationView!.annotation = poiAnnotation
            }
            annotationView!.frame.size.height = 40
            annotationView!.frame.size.width = 40
            annotationView?.centerOffset = CGPoint(x: 0, y: -20)
            let pinImage = UIImage(named: "mapPinIcon")
            let pinBoarderImageView = UIImageView(frame: CGRect(x:0 , y:0, width: 40, height: 40))
            pinBoarderImageView.image = pinImage?.withRenderingMode(.alwaysTemplate)
            pinBoarderImageView.contentMode = .scaleAspectFit
            let pinColourImageView = UIImageView(frame: CGRect(x: 1, y: 1, width: 38, height: 38))
            pinColourImageView.image = pinImage?.withRenderingMode(.alwaysTemplate)
            var iconImage = UIImage()
            let iconImageView = UIImageView(frame: CGRect(x: 8, y: 3, width: 24, height: 24))
            pinColourImageView.contentMode = .scaleAspectFit
            
            switch poiAnnotation.type{
            case 0:
                pinColourImageView.tintColor = UIColor.init(named: "Accent1")
                iconImage = UIImage(named: "foodIcon")!
            case 1:
                pinColourImageView.tintColor = UIColor.init(named: "Accent2")
                iconImage = UIImage(named: "coffeeIcon")!
            case 2:
                pinColourImageView.tintColor = UIColor.init(named: "Accent3")
                iconImage = UIImage(named: "attractionsIcon")!
            case 3:
                pinColourImageView.tintColor = UIColor.init(named: "Accent4")
                iconImage = UIImage(named: "parkingIcon")!
                iconImageView.frame = CGRect(x: 9, y: 4, width: 22, height: 22)
                
            case 4:
                pinColourImageView.tintColor = UIColor.init(named: "Accent5")
                iconImage = UIImage(named: "hotelsIcon")!
                iconImageView.frame = CGRect(x: 9, y: 4, width: 22, height: 22)
                
            default:
                pinColourImageView.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
                pinBoarderImageView.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
                iconImage = UIImage(named: "closeIcon")!
                iconImageView.frame = CGRect(x: 9, y: 4, width: 22, height: 22)
            }
            
            iconImageView.image = iconImage.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = UIColor.white
            iconImageView.contentMode = .scaleAspectFit
            annotationView?.addSubview(pinBoarderImageView)
            annotationView?.addSubview(pinColourImageView)
            annotationView?.addSubview(iconImageView)
            return annotationView
        }
        return MKAnnotationView()
    }
    
    func refreshUI() {
        loadViewIfNeeded()
        
        titleLabel.text = evStationDetailed?.AddressInfo.Title
        titleLabel.adjustsFontSizeToFitWidth = true
        address1Label.text = evStationDetailed?.AddressInfo.AddressLine1
        if evStationDetailed?.AddressInfo.AddressLine2 != nil{
            address2Label.text = evStationDetailed?.AddressInfo.AddressLine2
        } else {
            address2Label.isHidden = true
        }
        postcodeLabel.text = evStationDetailed?.AddressInfo.Postcode
        townLabel.text = evStationDetailed?.AddressInfo.Town
        costLabel.text = evStationDetailed?.UsageCost ?? "No Cost Information"
        costLabel.sizeToFit()
        costLabel.numberOfLines = 2
        if let noOfConnText: Int = evStationDetailed?.NumberOfPoints{
            noOfConnectorsLabel.text = "Number Of Connectors: "+String(noOfConnText)
        }else {
            noOfConnectorsLabel.text = "Unknown Number Of Points"
        }
        
        self.evLatitude = (self.evStationDetailed?.AddressInfo.Latitude)!
        self.evLongitude = (self.evStationDetailed?.AddressInfo.Longitude)!
        self.evLocation = CLLocation(latitude: CLLocationDegrees(self.evLatitude), longitude: CLLocationDegrees(self.evLongitude))
        centerMapOnLocation(location: self.evLocation)
        self.pickerView(wordPicker, didSelectRow: 0, inComponent: 0)
    }
    
    
    func filterForNearbyRange(_ MapList2Filter: [MKMapItem]) -> [MKMapItem]{
        var list2return: [MKMapItem] = []
        for aMapItem in MapList2Filter{
            if Int((aMapItem.placemark.location?.distance(from: self.evLocation))!) <= self.nearbyRange {
                list2return.append(aMapItem)
            }
        }
        return list2return
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getPlacemarkFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil) {
                    print("reverse geodcode fail: \(String(describing: error?.localizedDescription))")
                    
                }
                let pm : [CLPlacemark] = placemarks!
                if pm.count > 0 {
                    print (pm[0].name ?? "no value")
                }})
    }
    
}

extension DetailViewController{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return POInearEVcharger.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "POICollectionViewCell", for: indexPath) as! POICollectionViewCell
        
        switch self.rowPicked{
        case 0:
            cell.layer.backgroundColor = UIColor.init(named: "Accent1")?.cgColor
            cell.imagePOI.image = UIImage(named: "foodIcon")!.withRenderingMode(.alwaysTemplate)
            cell.imagePOI.tintColor = UIColor.white
            cell.imagePOI.contentMode = .scaleAspectFit
        case 1:
            cell.layer.backgroundColor = UIColor.init(named: "Accent2")?.cgColor
            cell.imagePOI.image = UIImage(named: "coffeeIcon")!.withRenderingMode(.alwaysTemplate)
            cell.imagePOI.tintColor = UIColor.white
            cell.imagePOI.contentMode = .scaleAspectFit
        case 2:
            cell.layer.backgroundColor = UIColor.init(named: "Accent3")?.cgColor
            cell.imagePOI.image = UIImage(named: "attractionsIcon")!.withRenderingMode(.alwaysTemplate)
            cell.imagePOI.tintColor = UIColor.white
            cell.imagePOI.contentMode = .scaleAspectFit
        case 3:
            cell.layer.backgroundColor = UIColor.init(named: "Accent4")?.cgColor
            cell.imagePOI.image = UIImage(named: "parkingIcon")!.withRenderingMode(.alwaysTemplate)
            cell.imagePOI.tintColor = UIColor.white
            cell.imagePOI.contentMode = .scaleAspectFit
        case 4:
            cell.layer.backgroundColor = UIColor.init(named: "Accent5")?.cgColor
            cell.imagePOI.image = UIImage(named: "hotelsIcon")!.withRenderingMode(.alwaysTemplate)
            cell.imagePOI.tintColor = UIColor.white
            cell.imagePOI.contentMode = .scaleAspectFit
        default:
            cell.layer.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor
        }
        
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        
        let onePOInearEVcharger: MKMapItem = POInearEVcharger[indexPath.row]
        cell.namePOI.text = onePOInearEVcharger.name ?? "Name not available"
        
        cell.distancePOI.text = String(Int(self.evLocation.distance(from: onePOInearEVcharger.placemark.location!)).magnitude) + " meters away"
        return cell
    }
}

extension DetailViewController{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        
//        return pickerLabels[row]
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.rowPicked = row
        self.localSearch(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let placeholder = UILabel()
        placeholder.theme_textColor = Colors.primaryTextColor
        let toReturn = NSAttributedString(string: pickerLabels[row], attributes: [NSAttributedString.Key.foregroundColor: placeholder.textColor!])
        
       return toReturn
    }
    
}
