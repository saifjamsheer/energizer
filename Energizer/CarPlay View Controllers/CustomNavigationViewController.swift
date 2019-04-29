
import Foundation
import UIKit
import CarPlay
import MapKit
import Firebase
import CodableFirebase


class CustomNavigationViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, UISearchControllerDelegate{
    
    //MARK: UI Objects
    var mainView = UIView()
    var mapView = MKMapView()
    var panContainer = UIView()
    var sideButtonView = UIView()
    let panButton = mapButton()
    let searchView = UIView()
    var resultsView = UIView()
    let nearbyView = UIView()
    let favouritesView = UIView()
    let filtersView = UIView()
    let detailView = UIView()
    let detailBackgroundView = UIView()
    let keyboardView = UIView()
    let searchController = UISearchController(searchResultsController: nil)
    let searchBar = UISearchBar()
    var circle = MKCircle()
    var circleOverlay = MKCircleRenderer()
    
    let searchTable = UITableView()
    var searchCompleter = MKLocalSearchCompleter()
    var searchList = [MKLocalSearchCompletion]()
    let favouritesTable = UITableView()
    var favouritesList : [ChargePoint] = []
    var unfilteredFavouritesList : [ChargePoint] = []
    let resultsTable = UITableView()
    var resultsList : [ChargePoint] = []
    var unfilteredResultsList : [ChargePoint] = []
    let nearbyTable = UITableView()
    var nearbyList : [ChargePoint] = []
    let recentsTable = UITableView()
    var recentsList : [myMKLocalSearchCompletion] = []
    var unfilteredNearbyList : [ChargePoint] = []
    var allStationsToShowFiltered : [ChargePoint] = []
    var evAnnotations2show : [evStationAnnotation] = []

    enum list2Update {
        case resultsList
        case favouritesList
        case nearbyList
    }
    
    enum previousViewer{
        case nearby
        case favourites
        case results
        case map
    }

    //MARK: Location variables
    let regionRadius: CLLocationDistance = 5000
    var locationManager = CLLocationManager()
    var currentLat: Float = 51.5074
    var currentLong: Float = -0.1278
    var currentLocation = CLLocation(latitude: CLLocationDegrees(51.50998), longitude: CLLocationDegrees(-0.1337))
    var firstCenteringDone = false
    var Longitude : Float = -1.5
    var Latitude : Float = 52.5
    var vehicleRange : Float = 1.0 //miles
    let ResultsNo = 150
    var Distance: Int = 50
    var DistanceUnit: Int = 0 //Miles: 0 KM:1
    var previousNearbyConditions: String = "Placeholder"
    var placementLabelForResultsView = UILabel()
    let resultsActivityIndicator = UIActivityIndicatorView()
    let nearbyActivityIndicator = UIActivityIndicatorView()
    let favouritesActivityIndicator = UIActivityIndicatorView()
    let buttonTracking = MKUserTrackingButton()
    var showAllClicked : Bool = true
    var clusterAnnotations: Bool = true
    var ref: DatabaseReference!

    
    //MARK: Filter UI elements
    let filterNavBarButton = navBarButton()
    let favouritesNavBarButton = navBarButton()
    let nearbyNavBarButton = navBarButton()
    let searchNavBarButton = navBarButton()
    let withinRangeButton = UIButton()
    let showAllButton = UIButton()
    let type2OnlyButton = UIButton()
    var priceRangeLabel = UILabel()
    let priceRangeSlider = CustomSlider()
    var noOfConnectorsLabel = UILabel()
    let noOfConnectorsSlider = CustomSlider()
    var accentColor = UIColor.init(named: "FilterAccent")
    var accent2Color = UIColor(white: 0, alpha: 1)
    
    //MARK: DetailView elements
    var titleDetailLabel = UILabel()
    var address1DetailLabel = UILabel()
    var address2DetailLabel = UILabel()
    var postcodeDetailLabel = UILabel()
    var costInfoDetailLabel = UILabel()
    var noOfConnectorsDetailLabel = UILabel()
    var type2ConnectorsDetailLabel = UILabel()
    var phoneNumberDetailLabel = UILabel()
    var routeButton = routeWithStation()
    var closeDetailViewButton = UIButton()

    //MARK: Filters
    var defaultFilter = Filter(WithinRangeOnly: false, EVChargerTypeOnly: false, PriceMax: 500, IsOperationalNow: false, FastestChargersOnly: false, minPower: 120.0, minQuantity: 0)
    
    var previousFilter = Filter(WithinRangeOnly: false, EVChargerTypeOnly: false, PriceMax: 500, IsOperationalNow: false, FastestChargersOnly: false, minPower: 120.0, minQuantity: 0)
    
    var currentFilter = Filter(WithinRangeOnly: false, EVChargerTypeOnly: false, PriceMax: 500, IsOperationalNow: false, FastestChargersOnly: false, minPower: 120.0, minQuantity: 0)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        mainView.frame = self.view.bounds
        self.view.addSubview(mainView)
        self.view.addSubview(mapView)
        self.view.addSubview(panContainer)
        self.view.addSubview(sideButtonView)
        self.view.addSubview(searchView)
        self.view.addSubview(resultsView)
        self.view.addSubview(nearbyView)
        self.view.addSubview(favouritesView)
        self.view.addSubview(filtersView)

        filtersView.isHidden = true
        searchView.isHidden = true
        resultsView.isHidden = true
        nearbyView.isHidden = true
        favouritesView.isHidden = true
        panContainer.isHidden = true
        searchTable.isHidden = true
        resultsTable.isHidden = true
        nearbyTable.isHidden = true
        detailView.isHidden = true

        
        self.searchBar.delegate = self
        
        mapView.delegate = self
        mapView.showsCompass = false
        searchCompleter.delegate = self
        searchTable.delegate = self
        searchTable.dataSource = self
        resultsTable.delegate = self
        resultsTable.dataSource = self
        nearbyTable.delegate = self
        nearbyTable.dataSource = self
        favouritesTable.delegate = self
        favouritesTable.dataSource = self
        recentsTable.dataSource = self
        recentsTable.delegate = self
        
        self.nearbyTable.register(resultsCell.self, forCellReuseIdentifier: "celln")
        self.resultsTable.register(resultsCell.self, forCellReuseIdentifier: "cellr")
        self.favouritesTable.register(resultsCell.self, forCellReuseIdentifier: "cellf")

        let recognizer = UITapGestureRecognizer(target: self,action:#selector(self.handleTap(recognizer:)))
        panContainer.isUserInteractionEnabled = true
        recognizer.delegate = self
        panContainer.addGestureRecognizer(recognizer)

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        mapView.showsPointsOfInterest = false
        mapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        registerAnnotationViewClasses()
        
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
            self.unfilteredFavouritesList = self.getNewDistances(list2SetNewDistances: self.unfilteredFavouritesList)
            self.favouritesList = self.filterList(filter: self.currentFilter, unfilteredStationList: self.unfilteredFavouritesList)
            self.favouritesTable.reloadData()
        })
        
        ref.child("users/email/UserInfo/CurrentCar/").observe(.value, with: { snapshot in
            guard let value = snapshot.value else { return }
            do {
                let currentCarInfo = try FirebaseDecoder().decode(myCarInfo.self, from: value)
                self.vehicleRange = currentCarInfo.milesRemaining!
            } catch let error {
                print(error)
            }
            self.annotateEVonMap(self.allStationsToShowFiltered)
            
            self.nearbyTable.reloadData()
            self.favouritesTable.reloadData()
            self.resultsTable.reloadData()
            self.updateRadiusCircle(location: self.currentLocation)
        })
        
        ref.child("users/email/UserInfo/RecentSearches").observe(.value, with: { snapshot in
            self.recentsList = []
            print ("Observing Recent Searches")
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                do {
                    let aRecent = try FirebaseDecoder().decode(myMKLocalSearchCompletion.self, from: child.value!)
                    self.recentsList.append(aRecent)
                } catch let error {
                    print(error)
                }
            }
            self.recentsList = self.recentsList.sorted(by: { $0.timestamp > $1.timestamp })
            if self.recentsList.count > 10{
                self.ref.child("users/email/UserInfo/RecentSearches/" + self.recentsList.last!.title).removeValue()
            }
            self.recentsTable.reloadData()
            
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        self.mapView.frame = self.view.bounds
        self.panContainer.frame = CGRect(x: view.bounds.minX, y: view.bounds.minY + view.bounds.height * 0.18, width: view.bounds.width, height: view.bounds.height * 0.82)
        
        self.mainView.frame = self.view.bounds
        self.searchView.frame = self.view.bounds
        self.resultsView.frame = self.view.bounds
        self.nearbyView.frame = self.view.bounds
        self.favouritesView.frame = self.view.bounds
        self.filtersView.frame = self.view.bounds
        if self.view.frame.height < self.view.frame.width{
            self.keyboardView.frame = CGRect(x: 0, y: self.view.frame.height*2/3, width: self.view.frame.width, height: self.view.frame.height/3)
        } else {
            self.keyboardView.frame = CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2)
        }
     
        placementLabelForResultsView.text = "Near Current Location"
        placementLabelForResultsView.numberOfLines = 2
        setupMainView()
        setupSearchView()
        setupResultsView()
        setupNearbyView()
        setupFavouritesView()
        setupFilterView()
        setupDetailView()
        setupKeyboardView()
        
        self.view.layoutIfNeeded()
        
        let compass = MKCompassButton(mapView: mapView)
        compass.frame.origin = CGPoint(x: mapView.frame.maxX - compass.frame.width - (mapView.frame.height * 0.015) , y: mapView.frame.minY + (mapView.frame.height * 0.195))
        compass.compassVisibility = .adaptive
        mapView.addSubview(compass)
        
        
    }

    func setupKeyboardView(){
        keyboardView.backgroundColor = UIColor.init(white: 0.2, alpha: 1)
        let keyboardHeightUnit = keyboardView.frame.height / 4
        let keyboardWidthUnit = keyboardView.frame.width / 20
        var widthPoint :  CGFloat = 0
        var heightPoint :  CGFloat = 0
        let keyboardValues : String = "1234567890QWERTYUIOPASDFGHJKL/ZXCVBNM?"
        
        for aCharacter in keyboardValues {
            switch aCharacter{
            case "1":
                heightPoint = 0
                widthPoint = 0
            case "Q":
                heightPoint = 1
                widthPoint = 0
            case "A":
                heightPoint = 2
                widthPoint = 0.5
            case "/":
                heightPoint = 3
                widthPoint = 0
            default :
                break
            }
            let someKey = UIButton()
            switch aCharacter{
            case "/":
                someKey.setImage(UIImage(named: "spaceIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
                someKey.tintColor = UIColor.white
                someKey.frame = CGRect(x: 2*widthPoint*keyboardWidthUnit, y: heightPoint*keyboardHeightUnit, width: 3*keyboardWidthUnit, height: keyboardHeightUnit)
                widthPoint = widthPoint + 1.5
                someKey.addTarget(self, action: #selector(enterKey), for: .touchUpInside)
            case "?":
                someKey.setImage(UIImage(named: "backspaceIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
                someKey.tintColor = UIColor.white
                someKey.frame = CGRect(x: 2*widthPoint*keyboardWidthUnit, y: heightPoint*keyboardHeightUnit, width: 3*keyboardWidthUnit, height: keyboardHeightUnit)
                someKey.addTarget(self, action: #selector(backspaceKey), for: .touchUpInside)

            default:
                someKey.setTitle(String(aCharacter), for: .normal)
                someKey.frame = CGRect(x: 2*widthPoint*keyboardWidthUnit, y: heightPoint*keyboardHeightUnit, width: 2*keyboardWidthUnit, height: keyboardHeightUnit)
                widthPoint = widthPoint + 1
                someKey.addTarget(self, action: #selector(enterKey), for: .touchUpInside)

            }
            someKey.setTitleColor(.white, for: .normal)
            someKey.backgroundColor = .darkGray
            someKey.layer.borderWidth = 2
            someKey.layer.borderColor = keyboardView.backgroundColor?.cgColor
            someKey.layer.cornerRadius = 3
            keyboardView.addSubview(someKey)
            
        }
        searchView.addSubview(keyboardView)
    }
    
    func setupDetailView(){
        
        self.detailView.frame = CGRect(x: 0, y: 0.18 * mapView.frame.height, width: mapView.frame.width * 0.44, height: 0.82 * mapView.frame.height)
        self.mapView.addSubview(detailView)
            
        self.detailBackgroundView.frame = CGRect(x: 0.03 * detailView.frame.height, y: 0.03 * detailView.frame.height, width: 0.4 * mapView.frame.width, height: 0.94 * detailView.frame.height)
        self.detailBackgroundView.layer.backgroundColor = UIColor(white: 30/255, alpha: 1).cgColor
        self.detailBackgroundView.layer.cornerRadius = detailBackgroundView.frame.width/25
        self.detailView.addSubview(detailBackgroundView)
        
        let heightUnit = self.detailBackgroundView.frame.height / 18
        
        titleDetailLabel.frame = CGRect(x: heightUnit, y: heightUnit, width: self.detailBackgroundView.frame.width - (2 * heightUnit), height: 2.5 * heightUnit)
        titleDetailLabel.textColor = .white
        titleDetailLabel.text = "Title"
        self.detailBackgroundView.addSubview(titleDetailLabel)
        
        address1DetailLabel.frame = CGRect(x: heightUnit, y: 4*heightUnit, width: self.detailBackgroundView.frame.width - (2 * heightUnit), height: heightUnit)
        address1DetailLabel.textColor = .white
        address1DetailLabel.text = "address1"
        self.detailBackgroundView.addSubview(address1DetailLabel)
        
        
        address2DetailLabel.frame = CGRect(x: heightUnit, y: 5 * heightUnit, width: self.detailBackgroundView.frame.width - (2 * heightUnit), height: heightUnit)
        address2DetailLabel.textColor = .white
        address2DetailLabel.text = "address2"

        self.detailBackgroundView.addSubview(address2DetailLabel)
        
        postcodeDetailLabel.frame = CGRect(x: heightUnit, y: 6*heightUnit, width: self.detailBackgroundView.frame.width - (2 * heightUnit), height: heightUnit)
        postcodeDetailLabel.textColor = .white
        postcodeDetailLabel.text = "postcode"
        self.detailBackgroundView.addSubview(postcodeDetailLabel)
        
        costInfoDetailLabel.frame = CGRect(x: heightUnit, y: 11*heightUnit, width: self.detailBackgroundView.frame.width - (2 * heightUnit), height: 4*heightUnit)
        costInfoDetailLabel.textColor = .white
        costInfoDetailLabel.text = "CostInfo"
        self.detailBackgroundView.addSubview(costInfoDetailLabel)
        
        noOfConnectorsDetailLabel.frame = CGRect(x: heightUnit, y: 10*heightUnit, width: self.detailBackgroundView.frame.width - (2 * heightUnit), height: heightUnit)
        noOfConnectorsDetailLabel.textColor = .white
        noOfConnectorsDetailLabel.text = "NoOfConnectors"
        self.detailBackgroundView.addSubview(noOfConnectorsDetailLabel)
        
        type2ConnectorsDetailLabel.frame = CGRect(x: heightUnit, y: 9*heightUnit, width: self.detailBackgroundView.frame.width - (2 * heightUnit), height: heightUnit)
        type2ConnectorsDetailLabel.textColor = .white
        type2ConnectorsDetailLabel.text = "Type2Compatibility"
        self.detailBackgroundView.addSubview(type2ConnectorsDetailLabel)
        
        phoneNumberDetailLabel.frame = CGRect(x: heightUnit, y: 7*heightUnit, width: self.detailBackgroundView.frame.width - (2 * heightUnit), height: heightUnit)
        phoneNumberDetailLabel.textColor = .white
        phoneNumberDetailLabel.text = "PhoneNumber"
        self.detailBackgroundView.addSubview(phoneNumberDetailLabel)
        
        routeButton.frame = CGRect(x: 0, y: 16*heightUnit, width: self.detailBackgroundView.frame.width, height: detailBackgroundView.frame.height - 16*heightUnit)
        routeButton.layer.cornerRadius = self.detailBackgroundView.frame.width/25
        routeButton.layer.backgroundColor = UIColor(red: 90/255, green: 200/250, blue: 230/255, alpha: 0.8).cgColor
        routeButton.setTitle("Route", for: .normal)
        routeButton.setTitleColor(UIColor.white, for: .normal)
        routeButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        routeButton.clipsToBounds = true
        detailBackgroundView.addSubview(routeButton)
        
        closeDetailViewButton.frame = CGRect(x: detailView.frame.maxX , y: 1, width: -2*heightUnit, height: 2*heightUnit)
        closeDetailViewButton.layer.backgroundColor = UIColor.white.cgColor
        closeDetailViewButton.layer.cornerRadius = closeDetailViewButton.frame.height/2
        closeDetailViewButton.clipsToBounds = true
        closeDetailViewButton.layer.borderWidth = 1
        closeDetailViewButton.layer.borderColor = UIColor(white: 30/255, alpha: 1).cgColor
        closeDetailViewButton.setImage(UIImage(named: "closeIcon"), for: .normal)
        closeDetailViewButton.contentMode = .scaleAspectFit
        detailView.addSubview(closeDetailViewButton)
    }
    
    func setupSearchView() {
        self.searchView.backgroundColor = UIColor.init(white: 30/255, alpha: 1)
        self.searchController.view.frame = CGRect(x: searchView.frame.minX, y: searchView.frame.minY, width: searchView.frame.width, height: searchView.frame.height)
        self.searchController.view.backgroundColor = UIColor.init(red: 25.5/255.0, green: 22.7/255.0, blue: 255.0/255.0, alpha: 0.5)
        self.searchBar.frame = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height * 0.17)
        
        let navBar = UIView(frame: CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height * 0.17))
        navBar.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let navBarAccent = UIView()
        navBarAccent.backgroundColor = UIColor.init(red: 255/255, green: 227/255, blue: 110/255, alpha: 1)
        navBarAccent.translatesAutoresizingMaskIntoConstraints = false
        self.searchView.addSubview(navBar)
        self.searchView.addSubview(navBarAccent)

        NSLayoutConstraint.activate([
            navBar.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.17),
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.heightAnchor.constraint(equalToConstant: (self.view.frame.height * 0.01)),
            navBarAccent.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBarAccent.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.topAnchor.constraint(equalTo: navBar.bottomAnchor)
            ])
        
        self.recentsTable.frame = CGRect(x: 0, y: 0.18 * self.searchView.frame.height, width: self.searchView.frame.width, height: 0.82 * self.searchView.frame.height - self.keyboardView.frame.height)
        self.searchView.addSubview(self.recentsTable)

         self.searchTable.frame = CGRect(x: 0, y: 0.18 * self.searchView.frame.height, width: self.searchView.frame.width, height: 0.82 * self.searchView.frame.height - self.keyboardView.frame.height)
        self.searchView.addSubview(self.searchTable)
        
        
        self.searchBar.frame = CGRect(x: navBar.frame.width * 0.0, y: navBar.bounds.height * 0.2, width: navBar.frame.width * 0.80, height: navBar.frame.height * 0.6)
        self.searchBar.barTintColor = UIColor.init(white: 30/255, alpha: 1)
        self.searchController.searchBar.barTintColor = UIColor.init(red: 250/255, green: 30/255, blue: 30/255, alpha: 1)
        self.searchView.addSubview(self.searchBar)
//        self.searchController.view.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
//        self.searchController.searchBar.frame = CGRect(x: 50, y: 0, width: 200, height: 200)
//        self.searchView.addSubview(self.searchController.searchBar)
//        self.searchView.addSubview(self.searchController.view)
        
        let searchBackButton = navBarButton(frame: CGRect(x: navBar.frame.width * 0.80, y: navBar.bounds.height * 0.15, width: navBar.frame.width * 0.2, height: navBar.frame.height * 0.7))
        searchBackButton.setTitle("Cancel", for: .normal)
        searchBackButton.setTitleColor(UIColor.white, for: .normal)
        searchBackButton.addTarget(self, action: #selector(backHome), for: .touchUpInside)
        self.searchView.addSubview(searchBackButton)
    }
    
    func setupResultsView(){
       let navBarIconSpace : CGFloat = 8
        self.resultsView.layer.backgroundColor = UIColor.init(red: 25.5/255.0, green: 22.7/255.0, blue: 11.0/255.0, alpha: 1).cgColor
        let navBar = UIView(frame: CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height * 0.17))
        navBar.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let navBarAccent = UIView()
        navBarAccent.backgroundColor = UIColor.init(red: 255/255, green: 227/255, blue: 110/255, alpha: 1)
        navBarAccent.translatesAutoresizingMaskIntoConstraints = false
        self.resultsView.addSubview(navBar)
        self.resultsView.addSubview(navBarAccent)
        
        NSLayoutConstraint.activate([
            navBar.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.17),
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.heightAnchor.constraint(equalToConstant: (self.view.frame.height * 0.01)),
            navBarAccent.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBarAccent.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.topAnchor.constraint(equalTo: navBar.bottomAnchor)
            ])
        
        self.resultsTable.frame = CGRect(x: 0, y: 0.18 * self.resultsView.frame.height, width: self.resultsView.frame.width, height: 0.82 * self.resultsView.frame.height)
        self.resultsView.addSubview(self.resultsTable)
        
        placementLabelForResultsView.frame = CGRect(x: 0.2 * navBar.bounds.width, y: navBar.bounds.height * 0.1, width: navBar.frame.width * 0.6, height: navBar.frame.height * 0.8)
        placementLabelForResultsView.textColor = UIColor.white
        placementLabelForResultsView.textAlignment = .center
        navBar.addSubview(placementLabelForResultsView)
        
        let resultsBackButton = UIButton(frame: CGRect(x: 0, y: navBar.bounds.height * 0.15, width: navBar.frame.width * 0.15, height: navBar.frame.height * 0.7))
        resultsBackButton.setTitle("Back", for: .normal)
        resultsBackButton.setTitleColor(UIColor.white, for: .normal)
        resultsBackButton.titleLabel?.textAlignment = .left
        resultsBackButton.addTarget(self, action: #selector(hideResults), for: .touchUpInside)
        navBar.addSubview(resultsBackButton)
        
        let filterNavBarButton = UIButton(frame: CGRect(x: navBar.frame.maxX - (navBar.bounds.height * 0.85), y: navBar.bounds.height * 0.15, width: navBar.frame.height * 0.7, height: navBar.frame.height * 0.7))
        filterNavBarButton.setImage(UIImage(named: "FilterIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterNavBarButton.tintColor = UIColor.init(white: 1, alpha: 1)
        filterNavBarButton.contentVerticalAlignment = .fill
        filterNavBarButton.contentHorizontalAlignment = .fill
        filterNavBarButton.imageEdgeInsets = UIEdgeInsets(top: navBarIconSpace, left: navBarIconSpace, bottom: navBarIconSpace, right: navBarIconSpace)
        filterNavBarButton.layer.cornerRadius = 6
        filterNavBarButton.addTarget(self, action: #selector(showFiltersView), for: .touchUpInside)
        
        navBar.addSubview(filterNavBarButton)
        
        self.resultsActivityIndicator.frame = CGRect(x: 0, y: 0.18 * self.resultsView.frame.height, width: self.resultsView.frame.width, height: 0.82 * self.resultsView.frame.height)
        self.resultsActivityIndicator.hidesWhenStopped = true
        self.resultsActivityIndicator.transform = CGAffineTransform(scaleX: 4, y: 4)
        self.resultsView.addSubview(self.resultsActivityIndicator)
        
    }
    
    func setupNearbyView(){
        let navBarIconSpace : CGFloat = 8
        self.nearbyView.layer.backgroundColor = UIColor.init(red: 7.9/255.0, green: 8.9/255.0, blue: 21.3/255.0, alpha: 1).cgColor
        let navBar = UIView(frame: CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height * 0.17))
        navBar.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let navBarAccent = UIView()
        navBarAccent.backgroundColor = UIColor.init(named: "NearbyAccent")
        navBarAccent.translatesAutoresizingMaskIntoConstraints = false
        self.nearbyView.addSubview(navBar)
        self.nearbyView.addSubview(navBarAccent)
        
        NSLayoutConstraint.activate([
            navBar.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.17),
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.heightAnchor.constraint(equalToConstant: (self.view.frame.height * 0.01)),
            navBarAccent.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBarAccent.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.topAnchor.constraint(equalTo: navBar.bottomAnchor)
            ])
        
        self.nearbyTable.frame = CGRect(x: 0, y: 0.18 * self.nearbyView.frame.height, width: self.nearbyView.frame.width, height: 0.82 * self.nearbyView.frame.height)
        self.nearbyView.addSubview((self.nearbyTable))
        
        let nearbyLabel = UILabel(frame: CGRect(x: 0.2 * navBar.bounds.width, y: navBar.bounds.height * 0.1, width: navBar.frame.width * 0.6, height: navBar.frame.height * 0.8))
        nearbyLabel.text = "Near Current Location"
        nearbyLabel.textColor = UIColor.white
        nearbyLabel.textAlignment = .center
        navBar.addSubview(nearbyLabel)
        
        let nearbyBackButton = navBarButton(frame: CGRect(x: 0, y: navBar.bounds.height * 0.15, width: navBar.frame.width * 0.15, height: navBar.frame.height * 0.7))
        nearbyBackButton.setTitle("Back", for: .normal)
        nearbyBackButton.setTitleColor(UIColor.white, for: .normal)
        nearbyBackButton.titleLabel?.textAlignment = .left
        nearbyBackButton.addTarget(self, action: #selector(backHome), for: .touchUpInside)
        navBar.addSubview(nearbyBackButton)
        
        let filterNavBarButton = navBarButton(frame: CGRect(x: navBar.frame.maxX - (navBar.bounds.height * 0.85), y: navBar.bounds.height * 0.15, width: navBar.frame.height * 0.7, height: navBar.frame.height * 0.7))
        filterNavBarButton.setImage(UIImage(named: "FilterIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterNavBarButton.tintColor = UIColor.init(white: 1, alpha: 1)
        filterNavBarButton.contentVerticalAlignment = .fill
        filterNavBarButton.contentHorizontalAlignment = .fill
        filterNavBarButton.imageEdgeInsets = UIEdgeInsets(top: navBarIconSpace, left: navBarIconSpace, bottom: navBarIconSpace, right: navBarIconSpace)
        filterNavBarButton.layer.cornerRadius = 6
        filterNavBarButton.addTarget(self, action: #selector(showFiltersView), for: .touchUpInside)
        navBar.addSubview(filterNavBarButton)
        
        self.nearbyActivityIndicator.frame = CGRect(x: 0, y: 0.18 * self.resultsView.frame.height, width: self.resultsView.frame.width, height: 0.82 * self.resultsView.frame.height)
        self.nearbyActivityIndicator.hidesWhenStopped = true
        self.nearbyActivityIndicator.transform = CGAffineTransform(scaleX: 4, y: 4)
        self.nearbyView.addSubview(self.nearbyActivityIndicator)
    }
    
    func setupFavouritesView(){
        let navBarIconSpace : CGFloat = 8
        self.favouritesView.layer.backgroundColor = UIColor.init(red: 25.3/255.0, green: 10.9/255.0, blue: 10.9/255.0, alpha: 1).cgColor
        let navBar = UIView(frame: CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height * 0.17))
        navBar.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let navBarAccent = UIView()
        navBarAccent.backgroundColor = UIColor.init(named: "FavouritesAccent")
        navBarAccent.translatesAutoresizingMaskIntoConstraints = false
        self.favouritesView.addSubview(navBar)
        self.favouritesView.addSubview(navBarAccent)
        
        NSLayoutConstraint.activate([
            navBar.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.17),
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.heightAnchor.constraint(equalToConstant: (self.view.frame.height * 0.01)),
            navBarAccent.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBarAccent.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.topAnchor.constraint(equalTo: navBar.bottomAnchor)
            ])
        
        self.favouritesTable.frame = CGRect(x: 0, y: 0.18 * self.favouritesView.frame.height, width: self.favouritesView.frame.width, height: 0.82 * self.favouritesView.frame.height)
        self.favouritesView.addSubview((self.favouritesTable))
    
        
        let favouritesLabel = UILabel(frame: CGRect(x: 0.2 * navBar.bounds.width, y: navBar.bounds.height * 0.1, width: navBar.frame.width * 0.6, height: navBar.frame.height * 0.8))
        favouritesLabel.text = "Favourites"
        favouritesLabel.textColor = UIColor.white
        favouritesLabel.textAlignment = .center
        navBar.addSubview(favouritesLabel)
        
        let favouritesBackButton = navBarButton(frame: CGRect(x: 0, y: navBar.bounds.height * 0.15, width: navBar.frame.width * 0.15, height: navBar.frame.height * 0.7))
        favouritesBackButton.setTitle("Back", for: .normal)
        favouritesBackButton.setTitleColor(UIColor.white, for: .normal)
        favouritesBackButton.addTarget(self, action: #selector(backHome), for: .touchUpInside)
        navBar.addSubview(favouritesBackButton)
        
        let filterNavBarButton = navBarButton(frame: CGRect(x: navBar.frame.maxX - (navBar.bounds.height * 0.85), y: navBar.bounds.height * 0.15, width: navBar.frame.height * 0.7, height: navBar.frame.height * 0.7))
        filterNavBarButton.setImage(UIImage(named: "FilterIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterNavBarButton.tintColor = UIColor.init(white: 1, alpha: 1)
        filterNavBarButton.contentVerticalAlignment = .fill
        filterNavBarButton.contentHorizontalAlignment = .fill
        filterNavBarButton.imageEdgeInsets = UIEdgeInsets(top: navBarIconSpace, left: navBarIconSpace, bottom: navBarIconSpace, right: navBarIconSpace)
        filterNavBarButton.layer.cornerRadius = 6
        filterNavBarButton.addTarget(self, action: #selector(showFiltersView), for: .touchUpInside)

        self.favouritesActivityIndicator.frame = CGRect(x: 0, y: 0.18 * self.resultsView.frame.height, width: self.resultsView.frame.width, height: 0.82 * self.resultsView.frame.height)
        self.favouritesActivityIndicator.hidesWhenStopped = true
        self.favouritesActivityIndicator.transform = CGAffineTransform(scaleX: 4, y: 4)
        self.favouritesView.addSubview(self.favouritesActivityIndicator)
        
        navBar.addSubview(filterNavBarButton)
    }
    
    func setupFilterView(){
        let widthUnit: CGFloat = self.filtersView.frame.width/13
        var heightUnit: CGFloat = self.filtersView.frame.height/9
        if self.filtersView.frame.height > self.filtersView.frame.width{   //consider if tall display is used
            heightUnit = self.filtersView.frame.width/9
        }
        
        self.filtersView.layer.backgroundColor = UIColor.init(red: 3/255.0, green: 10/255.0, blue: 7/255.0, alpha: 1).cgColor
        let navBar = UIView(frame: CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height * 0.17))
        navBar.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let navBarAccent = UIView()
        navBarAccent.backgroundColor = UIColor.init(named: "FilterAccent")
        navBarAccent.translatesAutoresizingMaskIntoConstraints = false
        self.filtersView.addSubview(navBar)
        self.filtersView.addSubview(navBarAccent)
        
        NSLayoutConstraint.activate([
            navBar.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.17),
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.heightAnchor.constraint(equalToConstant: (self.view.frame.height * 0.01)),
            navBarAccent.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBarAccent.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.topAnchor.constraint(equalTo: navBar.bottomAnchor)
            ])
        
        let stationsToDisplayLabel = UILabel(frame: CGRect(x: 0, y: navBar.frame.maxY + (heightUnit/5), width: self.filtersView.frame.width, height: heightUnit))
        stationsToDisplayLabel.text = "Stations To Display"
        stationsToDisplayLabel.textColor = UIColor.white
        stationsToDisplayLabel.textAlignment = .center
        self.filtersView.addSubview(stationsToDisplayLabel)
        
        withinRangeButton.frame = CGRect(x: widthUnit * 9, y: stationsToDisplayLabel.frame.maxY, width: 3 * widthUnit, height: 3 / 4 * heightUnit)
        withinRangeButton.layer.borderWidth = 2
        withinRangeButton.layer.borderColor = UIColor.white.cgColor
        withinRangeButton.layer.cornerRadius = withinRangeButton.frame.height/8
        withinRangeButton.setTitle("Within Range", for: .normal)
        withinRangeButton.setTitleColor(UIColor.white, for: .normal)
        withinRangeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        withinRangeButton.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        self.filtersView.addSubview(withinRangeButton)
        
        
        showAllButton.frame = CGRect(x: widthUnit, y: stationsToDisplayLabel.frame.maxY, width: 3 * widthUnit, height: 3 / 4 * heightUnit)
        showAllButton.layer.borderWidth = 2
        showAllButton.layer.borderColor = UIColor.white.cgColor
        showAllButton.layer.cornerRadius = showAllButton.frame.height/8
        showAllButton.setTitle("   Show All   ", for: .normal)
        showAllButton.setTitleColor(UIColor.white, for: .normal)
        showAllButton.titleLabel?.adjustsFontSizeToFitWidth = true
        showAllButton.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        self.filtersView.addSubview(showAllButton)

        type2OnlyButton.frame = CGRect(x: widthUnit * 5, y: stationsToDisplayLabel.frame.maxY, width: 3 * widthUnit, height: 3 / 4 * heightUnit)
        type2OnlyButton.layer.borderWidth = 2
        type2OnlyButton.layer.borderColor = UIColor.white.cgColor
        type2OnlyButton.layer.cornerRadius = showAllButton.frame.height/8
        type2OnlyButton.setTitle("  Type 2 Only  ", for: .normal)
        type2OnlyButton.setTitleColor(UIColor.white, for: .normal)
        type2OnlyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        type2OnlyButton.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        self.filtersView.addSubview(type2OnlyButton)
        recolorFilterButtons()
        
        let firstLine = UIView(frame: CGRect(x: 0, y: stationsToDisplayLabel.frame.maxY + heightUnit, width: navBar.frame.width, height: 1))
        firstLine.backgroundColor = UIColor.black
        self.filtersView.addSubview(firstLine)
        
        priceRangeLabel.frame = CGRect(x: 0, y: firstLine.frame.maxY + (heightUnit/5), width: self.filtersView.frame.width, height: heightUnit)
        priceRangeLabel.text = "Maximum Price: Any"
        priceRangeLabel.textColor = UIColor.white
        priceRangeLabel.textAlignment = .center
        self.filtersView.addSubview(priceRangeLabel)
        
        priceRangeSlider.frame = CGRect(x: widthUnit, y: priceRangeLabel.frame.maxY, width: widthUnit * 11, height: heightUnit)
        priceRangeSlider.minimumTrackTintColor = navBarAccent.backgroundColor
        priceRangeSlider.maximumTrackTintColor = navBarAccent.backgroundColor?.withAlphaComponent(0.25)
        priceRangeSlider.maximumValue = 5
        priceRangeSlider.minimumValue = 0
        priceRangeSlider.addTarget(self, action: #selector(priceSliderChanged), for: .valueChanged)
        self.filtersView.addSubview(priceRangeSlider)

        let anyPriceLabel = UILabel(frame: CGRect(x: priceRangeSlider.frame.minX, y: priceRangeSlider.frame.midY + (heightUnit / 4), width: widthUnit, height: heightUnit/2))
        anyPriceLabel.text = "Any"
        anyPriceLabel.textColor = UIColor.white
        anyPriceLabel.textAlignment = .left
        anyPriceLabel.adjustsFontSizeToFitWidth = true
        self.filtersView.addSubview(anyPriceLabel)
        
        let freePriceLabel = UILabel(frame: CGRect(x: priceRangeSlider.frame.maxX, y: priceRangeSlider.frame.midY + (heightUnit / 4), width: -widthUnit, height: heightUnit/2))
        freePriceLabel.text = "Free"
        freePriceLabel.textColor = UIColor.white
        freePriceLabel.textAlignment = .right
        freePriceLabel.adjustsFontSizeToFitWidth = true
        self.filtersView.addSubview(freePriceLabel)
        
        let secondLine = UIView(frame: CGRect(x: 0, y: priceRangeLabel.frame.maxY + (1.4 * heightUnit), width: navBar.frame.width, height: 1))
        secondLine.backgroundColor = UIColor.black
        self.filtersView.addSubview(secondLine)
        
        noOfConnectorsLabel.frame = CGRect(x: 0, y: secondLine.frame.maxY + (heightUnit/5), width: self.filtersView.frame.width, height: heightUnit)
        noOfConnectorsLabel.text = "Minimum Number of Connectors: Any"
        noOfConnectorsLabel.textColor = UIColor.white
        noOfConnectorsLabel.textAlignment = .center
        self.filtersView.addSubview(noOfConnectorsLabel)
        
        noOfConnectorsSlider.frame = CGRect(x: widthUnit, y: noOfConnectorsLabel.frame.maxY, width: widthUnit * 11, height: heightUnit)
        noOfConnectorsSlider.minimumTrackTintColor = navBarAccent.backgroundColor
        noOfConnectorsSlider.maximumTrackTintColor = navBarAccent.backgroundColor?.withAlphaComponent(0.25)
        noOfConnectorsSlider.maximumValue = 10
        noOfConnectorsSlider.minimumValue = 0
        noOfConnectorsSlider.addTarget(self, action: #selector(noOfConnectorsSliderChanged), for: .valueChanged)
        self.filtersView.addSubview(noOfConnectorsSlider)
        
        let anyConnectorsLabel = UILabel(frame: CGRect(x: noOfConnectorsSlider.frame.minX, y: noOfConnectorsSlider.frame.midY + (heightUnit / 4), width: widthUnit, height: heightUnit/2))
        anyConnectorsLabel.text = "Any"
        anyConnectorsLabel.textColor = UIColor.white
        anyConnectorsLabel.textAlignment = .left
        anyConnectorsLabel.adjustsFontSizeToFitWidth = true
        self.filtersView.addSubview(anyConnectorsLabel)
        
        let tenConnectorsLabel = UILabel(frame: CGRect(x: noOfConnectorsSlider.frame.maxX, y: noOfConnectorsSlider.frame.midY + (heightUnit / 4), width: -widthUnit, height: heightUnit/2))
        tenConnectorsLabel.text = "10"
        tenConnectorsLabel.textColor = UIColor.white
        tenConnectorsLabel.textAlignment = .right
        tenConnectorsLabel.adjustsFontSizeToFitWidth = true
        self.filtersView.addSubview(tenConnectorsLabel)
        
        
        let filtersLabel = UILabel(frame: CGRect(x: 0, y: navBar.bounds.height * 0.1, width: navBar.frame.width, height: navBar.frame.height * 0.8))
        filtersLabel.text = "Filter Stations"
        filtersLabel.textColor = UIColor.white
        filtersLabel.textAlignment = .center
        navBar.addSubview(filtersLabel)
        
        let filtersBackButton = UIButton(frame: CGRect(x: 0, y: navBar.bounds.height * 0.15, width: navBar.frame.width * 0.15, height: navBar.frame.height * 0.7))
        filtersBackButton.setTitle("Back", for: .normal)
        filtersBackButton.setTitleColor(UIColor.white, for: .normal)
        filtersBackButton.addTarget(self, action: #selector(hideFilterView), for: .touchUpInside)
        navBar.addSubview(filtersBackButton)
        
        let resetFilterButton = UIButton(frame: CGRect(x: navBar.frame.maxX, y: navBar.bounds.height * 0.15, width: -navBar.frame.width * 0.15, height: navBar.frame.height * 0.7))
        resetFilterButton.setTitle("Reset", for: .normal)
        resetFilterButton.setTitleColor(UIColor.white, for: .normal)
        resetFilterButton.addTarget(self, action: #selector(resetFilterPressed), for: .touchUpInside)
        navBar.addSubview(resetFilterButton)
    }
    
    func setupMainView(){
        let navBarIconSpace : CGFloat = 8
        var buttonSizeConstant: CGFloat = 0.13 * self.mapView.frame.width
        var buttonSeparationConstant: CGFloat = 0.025 * self.mapView.frame.width
        if self.view.frame.height < self.view.frame.width{
            buttonSizeConstant = 0.13 * self.mapView.frame.height * 0.82
            buttonSeparationConstant = 0.025 * self.mapView.frame.height * 0.82
        }

        let upPanImage = UIImageView(image: UIImage(named: "upPanIcon"))
        upPanImage.frame = CGRect(x: panContainer.frame.width/2.5, y: panContainer.frame.height/5, width: panContainer.frame.width/5, height: panContainer.frame.height/5)
        upPanImage.contentMode = .scaleAspectFit

        let leftPanImage = UIImageView(image: UIImage(named: "leftPanIcon"))
        leftPanImage.frame = CGRect(x: panContainer.frame.width/5, y: panContainer.frame.height/2.5, width: panContainer.frame.width/5, height: panContainer.frame.height/5)
        leftPanImage.contentMode = .scaleAspectFit

        let rightPanImage = UIImageView(image: UIImage(named: "rightPanIcon"))
        rightPanImage.frame = CGRect(x: panContainer.frame.width/1.66666667, y: panContainer.frame.height/2.5, width: panContainer.frame.width/5, height: panContainer.frame.height/5)
        rightPanImage.contentMode = .scaleAspectFit

        let downPanImage = UIImageView(image: UIImage(named: "downPanIcon"))
        downPanImage.frame = CGRect(x: panContainer.frame.width/2.5, y: panContainer.frame.height/1.666667, width: panContainer.frame.width/5, height: panContainer.frame.height/5)
        downPanImage.contentMode = .scaleAspectFit
        
        panContainer.addSubview(upPanImage)
        panContainer.addSubview(leftPanImage)
        panContainer.addSubview(rightPanImage)
        panContainer.addSubview(downPanImage)

        
        let navBar = UIView(frame: CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height * 0.17))
        navBar.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let navBarAccent = UIView()
        navBarAccent.backgroundColor = UIColor.init(red: 90/255, green: 200/250, blue: 230/255, alpha: 1)
        navBarAccent.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.addSubview(navBar)
        self.mapView.addSubview(navBarAccent)
        
        searchNavBarButton.frame = CGRect(x: navBar.bounds.height * 0.15 , y: navBar.bounds.height * 0.15, width: navBar.frame.height * 0.7, height: navBar.frame.height * 0.7)
        searchNavBarButton.layer.backgroundColor = UIColor.init(named: "SearchAccent")!.cgColor
        searchNavBarButton.setImage(UIImage(named: "searchIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        searchNavBarButton.tintColor = UIColor.init(white: 1, alpha: 1)
        searchNavBarButton.contentVerticalAlignment = .fill
        searchNavBarButton.contentHorizontalAlignment = .fill
        searchNavBarButton.imageEdgeInsets = UIEdgeInsets(top: navBarIconSpace, left: navBarIconSpace, bottom: navBarIconSpace, right: navBarIconSpace)
        searchNavBarButton.layer.cornerRadius = 6
        searchNavBarButton.addTarget(self, action: #selector(showSearchView), for: .touchUpInside)
        self.mapView.addSubview(searchNavBarButton)
        
        nearbyNavBarButton.frame = CGRect(x: searchNavBarButton.frame.maxX + (navBar.bounds.height * 0.15), y: navBar.bounds.height * 0.15, width: navBar.frame.height * 0.7, height: navBar.frame.height * 0.7)
        nearbyNavBarButton.layer.backgroundColor = UIColor.init(named: "NearbyAccent")!.cgColor
        nearbyNavBarButton.setImage(UIImage(named: "nearMeIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        nearbyNavBarButton.tintColor = UIColor.init(white: 1, alpha: 1)
        nearbyNavBarButton.contentVerticalAlignment = .fill
        nearbyNavBarButton.contentHorizontalAlignment = .fill
        nearbyNavBarButton.imageEdgeInsets = UIEdgeInsets(top: navBarIconSpace, left: navBarIconSpace, bottom: navBarIconSpace, right: navBarIconSpace)
        nearbyNavBarButton.layer.cornerRadius = 6
        nearbyNavBarButton.addTarget(self, action: #selector(showNearbyView), for: .touchUpInside)
        self.mapView.addSubview(nearbyNavBarButton)

        filterNavBarButton.frame = CGRect(x: navBar.frame.maxX - (navBar.bounds.height * 0.85), y: navBar.bounds.height * 0.15, width: navBar.frame.height * 0.7, height: navBar.frame.height * 0.7)
        filterNavBarButton.layer.backgroundColor = UIColor.init(named: "FilterAccent")!.cgColor
        filterNavBarButton.setImage(UIImage(named: "FilterIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterNavBarButton.tintColor = UIColor.init(white: 1, alpha: 1)
        filterNavBarButton.contentVerticalAlignment = .fill
        filterNavBarButton.contentHorizontalAlignment = .fill
        filterNavBarButton.imageEdgeInsets = UIEdgeInsets(top: navBarIconSpace, left: navBarIconSpace, bottom: navBarIconSpace, right: navBarIconSpace)
        filterNavBarButton.layer.cornerRadius = 6
        filterNavBarButton.addTarget(self, action: #selector(showFiltersView), for: .touchUpInside)
        self.mapView.addSubview(filterNavBarButton)
        updateFilterButton()

        favouritesNavBarButton.frame = CGRect(x: filterNavBarButton.frame.minX - (navBar.bounds.height * 0.85), y: navBar.bounds.height * 0.15, width: navBar.frame.height * 0.7, height: navBar.frame.height * 0.7)
        favouritesNavBarButton.layer.backgroundColor = UIColor.init(named: "FavouritesAccent")?.cgColor
        favouritesNavBarButton.setImage(UIImage(named: "heartIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        favouritesNavBarButton.tintColor = UIColor.init(white: 1, alpha: 1)
        favouritesNavBarButton.contentVerticalAlignment = .fill
        favouritesNavBarButton.contentHorizontalAlignment = .fill
        favouritesNavBarButton.imageEdgeInsets = UIEdgeInsets(top: navBarIconSpace, left: navBarIconSpace, bottom: navBarIconSpace, right: navBarIconSpace)
        favouritesNavBarButton.layer.cornerRadius = 6
        favouritesNavBarButton.addTarget(self, action: #selector(showFavouritesView), for: .touchUpInside)
        self.mapView.addSubview(favouritesNavBarButton)
        

        sideButtonView.layer.cornerRadius = buttonSizeConstant/2
        sideButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        panButton.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        panButton.setImage(UIImage(named: "PanIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        panButton.clipsToBounds = true
        panButton.layer.cornerRadius = buttonSizeConstant/2
        panButton.translatesAutoresizingMaskIntoConstraints = false
        panButton.addTarget(self, action: #selector(panPressed), for: .touchUpInside)
        self.sideButtonView.addSubview(panButton)
        
        buttonTracking.mapView = self.mapView
        buttonTracking.layer.cornerRadius = buttonSizeConstant/2
        buttonTracking.translatesAutoresizingMaskIntoConstraints = false
        buttonTracking.clipsToBounds = true
        self.sideButtonView.addSubview(buttonTracking)
       
        let zoomInButton = mapButton()
        zoomInButton.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        zoomInButton.setImage(UIImage(named: "PlusIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        zoomInButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        zoomInButton.clipsToBounds = true
        zoomInButton.layer.cornerRadius = buttonSizeConstant/2
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        zoomInButton.addTarget(self, action: #selector(zoomInPressed), for: .touchUpInside)
        self.sideButtonView.addSubview(zoomInButton)
        
        let zoomOutButton = mapButton()
        zoomOutButton.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        zoomOutButton.setImage(UIImage(named: "MinusIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        zoomOutButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        zoomOutButton.clipsToBounds = true
        zoomOutButton.layer.cornerRadius = buttonSizeConstant/2
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        zoomOutButton.addTarget(self, action: #selector(zoomOutPressed), for: .touchUpInside)
        self.sideButtonView.addSubview(zoomOutButton)

        NSLayoutConstraint.activate([
            navBar.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.17),
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.heightAnchor.constraint(equalToConstant: (self.view.frame.height * 0.01)),
            navBarAccent.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBarAccent.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBarAccent.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            sideButtonView.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: -(buttonSeparationConstant)),
            sideButtonView.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -(buttonSeparationConstant)),
            sideButtonView.heightAnchor.constraint(equalToConstant: ((buttonSizeConstant * 4) + (buttonSeparationConstant * 2) + 1)),
            sideButtonView.widthAnchor.constraint(equalToConstant: buttonSizeConstant),
            buttonTracking.bottomAnchor.constraint(equalTo: zoomInButton.topAnchor, constant:  -(buttonSeparationConstant)),
            buttonTracking.trailingAnchor.constraint(equalTo: self.sideButtonView.trailingAnchor),
            buttonTracking.heightAnchor.constraint(equalToConstant: buttonSizeConstant),
            buttonTracking.widthAnchor.constraint(equalToConstant: buttonSizeConstant),
            zoomInButton.bottomAnchor.constraint(equalTo: zoomOutButton.topAnchor, constant: -1),
            zoomInButton.trailingAnchor.constraint(equalTo: self.sideButtonView.trailingAnchor),
            zoomInButton.heightAnchor.constraint(equalToConstant: buttonSizeConstant),
            zoomInButton.widthAnchor.constraint(equalToConstant: buttonSizeConstant),
            zoomOutButton.bottomAnchor.constraint(equalTo: sideButtonView.bottomAnchor),
            zoomOutButton.trailingAnchor.constraint(equalTo: self.sideButtonView.trailingAnchor),
            zoomOutButton.heightAnchor.constraint(equalToConstant: buttonSizeConstant),
            zoomOutButton.widthAnchor.constraint(equalToConstant: buttonSizeConstant),
            panButton.bottomAnchor.constraint(equalTo: buttonTracking.topAnchor, constant: -(buttonSeparationConstant)),
            panButton.trailingAnchor.constraint(equalTo: self.sideButtonView.trailingAnchor),
            panButton.heightAnchor.constraint(equalToConstant: buttonSizeConstant),
            panButton.widthAnchor.constraint(equalToConstant: buttonSizeConstant)])

//        addFocusGuide(from: sideButtonView, to: navBar, direction: .top)
//        addFocusGuide(from: navBar, to: sideButtonView, direction: .bottom)
//
        
//        addFocusGuide(from: nearbyNavBarButton, to: searchNavBarButton, direction: .top)
//        addFocusGuide(from: favouritesNavBarButton, to: nearbyNavBarButton, direction: .top)
//        addFocusGuide(from: filterNavBarButton, to: [favouritesNavBarButton, nearbyNavBarButton, searchNavBarButton], direction: .top)
//        addFocusGuide(from: panButton, to: [filterNavBarButton, favouritesNavBarButton, nearbyNavBarButton, searchNavBarButton], direction: .top)
//        addFocusGuide(from: buttonTracking, to: panButton, direction: .top)
//        addFocusGuide(from: zoomInButton, to: buttonTracking, direction: .top)
//        addFocusGuide(from: zoomOutButton, to: zoomInButton, direction: .top)
//        addFocusGuide(from: searchNavBarButton, to: zoomOutButton, direction: .top)
//
//        addFocusGuide(from: searchNavBarButton, to: nearbyNavBarButton, direction: .bottom)
//        addFocusGuide(from: nearbyNavBarButton, to: favouritesNavBarButton, direction: .bottom)
//        addFocusGuide(from: favouritesNavBarButton, to: filterNavBarButton, direction: .bottom)
//        addFocusGuide(from: filterNavBarButton, to: panButton, direction: .bottom)
//        addFocusGuide(from: panButton, to: buttonTracking, direction: .bottom)
//        addFocusGuide(from: buttonTracking, to: zoomInButton, direction: .bottom)
//        addFocusGuide(from: zoomInButton, to: zoomOutButton, direction: .bottom)
//        addFocusGuide(from: zoomOutButton, to: searchNavBarButton, direction: .bottom)
//
//        self.updateFocusIfNeeded()
//        self.setNeedsFocusUpdate()
        }
    
}

extension CustomNavigationViewController{    //Map Stuff
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        self.currentLat = Float(userLocation.coordinate.latitude)
        self.currentLong = Float(userLocation.coordinate.longitude)
        self.currentLocation = userLocation
        if self.firstCenteringDone == false{
            self.getNearbyStations()
            self.firstCenteringDone = true
        }
        self.updateRadiusCircle(location: userLocation)
        self.unfilteredFavouritesList = self.getNewDistances(list2SetNewDistances: self.unfilteredFavouritesList)
        self.favouritesList = self.filterList(filter: self.currentFilter, unfilteredStationList: self.unfilteredFavouritesList)
        self.favouritesTable.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    func getNearbyStations() {
        self.Latitude = self.currentLat
        self.Longitude = self.currentLong
        centerMapOnLocation(location: CLLocation(latitude: CLLocationDegrees(self.currentLat), longitude: CLLocationDegrees(self.currentLong)))
        let nearbyConditions = self.setupConditions(latitude: self.currentLat, longitude: self.currentLong)
        if  nearbyConditions != self.previousNearbyConditions{
                self.previousNearbyConditions = nearbyConditions
                self.getEVapi(conditions: nearbyConditions, list2update: .nearbyList)
        }
    }

    func getResultStations(latitude: Float, longitude: Float) {
            let resultConditions = self.setupConditions(latitude: latitude, longitude: longitude)
            self.getEVapi(conditions: resultConditions, list2update: .resultsList)
    }
    
    func getEVapi(conditions: String, list2update: list2Update){
        DispatchQueue.main.async {
            switch list2update{
            case .resultsList:
                self.resultsActivityIndicator.startAnimating()
            case .favouritesList:
                self.favouritesActivityIndicator.startAnimating()
            case .nearbyList:
                self.nearbyActivityIndicator.startAnimating()
            }
        self.resultsActivityIndicator.startAnimating()
        var list2Return: [ChargePoint] = []
        let url = URL(string: "https://api.openchargemap.io/v3/poi/"+conditions)
        print(conditions)
        if let usableUrl = url {
            let request = URLRequest(url: usableUrl)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let data = data else {return}
                do {
                    let chargeStations = try JSONDecoder().decode([ChargePoint].self, from: data)
                    list2Return = chargeStations
                    DispatchQueue.main.async{
                        switch list2update {
                            case .nearbyList:
                                self.unfilteredNearbyList = list2Return
                                self.filterAllData(filter: self.currentFilter)
                                self.nearbyTable.reloadData()
                                self.nearbyTable.isHidden = false
                                self.nearbyActivityIndicator.stopAnimating()
                            case .resultsList:
                                self.unfilteredResultsList = list2Return
                                self.filterAllData(filter: self.currentFilter)
                                self.resultsList = self.filterList(filter: self.currentFilter, unfilteredStationList: self.unfilteredResultsList)
                                self.resultsTable.reloadData()
                                self.resultsTable.isHidden = false
                                self.resultsActivityIndicator.stopAnimating()
                            case .favouritesList:
                                self.unfilteredFavouritesList = list2Return
                                self.filterAllData(filter: self.currentFilter)
                                self.favouritesTable.reloadData()
                                self.favouritesActivityIndicator.stopAnimating()
                            }
                        self.allStationsToShowFiltered = self.removeDuplicates(list2Filter: (self.nearbyList + self.resultsList + self.favouritesList))
                        self.annotateEVonMap(self.allStationsToShowFiltered)
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
    
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        let centerPointwith9PercentOffset = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + (0.09 * coordinateRegion.span.latitudeDelta), coordinateRegion.center.longitude)
        let adjustedRegion = MKCoordinateRegion(center: centerPointwith9PercentOffset, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        self.mapView.setRegion(adjustedRegion, animated: true)
    }
    
    func detailCenterMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,latitudinalMeters: regionRadius/8, longitudinalMeters: regionRadius/10)
        let centerPointOfNewRegion = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + (0.09 * coordinateRegion.span.latitudeDelta), coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta/4.0)
        let newRegion = MKCoordinateRegion(center: centerPointOfNewRegion, latitudinalMeters: regionRadius/10, longitudinalMeters: regionRadius/10)
        self.mapView.setRegion(newRegion, animated: false)
    }
    
    func zoomMap(byFactor delta: Double) {
        var region: MKCoordinateRegion = self.mapView.region
        var span: MKCoordinateSpan = self.mapView.region.span
        span.latitudeDelta *= delta
        span.longitudeDelta *= delta
        region.span = span
        self.mapView.setRegion(region, animated: false)
    }
    
    func moveMap(direction:String)  {
        var mapCenter = self.mapView.region.center
        let span: MKCoordinateSpan = self.mapView.region.span
        switch direction {
        case "right":
            mapCenter.longitude += span.longitudeDelta * 0.25
        case "up":
            mapCenter.latitude += span.latitudeDelta * 0.25
        case "down":
            mapCenter.latitude -= span.latitudeDelta * 0.25
        case "left":
            mapCenter.longitude -= span.longitudeDelta * 0.25
        default:
            print(direction)
        }
        centerMapOnLocation(location: CLLocation(latitude: (mapCenter.latitude), longitude: (mapCenter.longitude)))
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
            return MKPolylineRenderer()
        }
    }
    
}  //MapStuff

extension CustomNavigationViewController{    //Button functions
    @objc func enterKey(sender: UIButton){
        switch sender.titleLabel?.text {
        case nil:
            searchBar.text = (searchBar.text ?? "") + " "
        default:
            searchBar.text = (searchBar.text ?? "") + (sender.titleLabel?.text ?? "")
        }
        self.searchBar(self.searchBar, textDidChange: self.searchBar.text ?? "")
    }
    
    @objc func backspaceKey(sender: UIButton){
        if searchBar.text != nil{
            searchBar.text = String(searchBar.text!.dropLast())
            self.searchBar(self.searchBar, textDidChange: self.searchBar.text ?? "")
        }
    }
  
    
    @objc func zoomInPressed(sender : UIButton){
        zoomMap(byFactor: 0.75)
    }
    
    @objc func zoomOutPressed(sender : UIButton){
        zoomMap(byFactor: 1.25)
    }
    
    @objc func panPressed(sender : UIButton){
        
        if self.panContainer.isHidden == true {
            self.panContainer.isHidden = false
            panButton.backgroundColor = UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)

        } else {
            self.panContainer.isHidden = true
            panButton.backgroundColor = UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        }
    }
    
    @objc func showSearchView(sender: UIButton){
        self.searchView.isHidden = false
        self.detailView.isHidden = true
    }
    
    @objc func showNearbyView(sender: UIButton){
        getNearbyStations()
        self.nearbyView.isHidden = false
        self.detailView.isHidden = true
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    @objc func hideResults(sender: UIButton){
        self.resultsTable.isHidden = true
        self.resultsView.isHidden = true
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    @objc func showFavouritesView(sender: UIButton){
        self.favouritesView.isHidden = false
        self.detailView.isHidden = true
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    @objc func showFiltersView(sender: UIButton){
        self.filtersView.isHidden = false
        self.detailView.isHidden = true
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    @objc func showResultsView(sender: UIButton){
        self.resultsView.isHidden = false
        self.searchView.isHidden = false
        self.detailView.isHidden = true
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    @objc func backHome(sender: UIButton){
//        self.searchList = []
//        self.searchController.searchBar.text = ""
//        self.searchTable.reloadData()
//        self.searchTable.isHidden = true
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
        self.searchView.isHidden = true
        self.nearbyView.isHidden = true
        self.favouritesView.isHidden = true
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    @objc func hideFilterView(sender: UIButton){
        self.filtersView.isHidden = true
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    @objc func hideDetailView(sender: UIButton){
        self.detailView.isHidden = true
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    @objc func routeTo(sender: routeWithStation){
        let evStationDetailed = sender.chargepoint
        MKMapItem.openMaps(with: ([MKMapItem(placemark:
            MKPlacemark(coordinate:
                CLLocationCoordinate2D(latitude: CLLocationDegrees(evStationDetailed!.AddressInfo.Latitude!), longitude: CLLocationDegrees(evStationDetailed!.AddressInfo.Longitude!))))]),
                           launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    @objc func resetFilterPressed(sender: UIButton){
        self.currentFilter = self.defaultFilter
        self.previousFilter = self.defaultFilter
        filterAllData(filter: self.currentFilter)
        self.showAllClicked = true
        priceRangeSlider.setValue((5.00 - Float(self.currentFilter.PriceMax)/100.0), animated: true)
        noOfConnectorsSlider.setValue(Float(self.currentFilter.minQuantity), animated: true)
        priceSliderChanged(sender: priceRangeSlider)
        noOfConnectorsSliderChanged(sender: noOfConnectorsSlider)
        recolorFilterButtons()

    }
    
    @objc func priceSliderChanged(sender: CustomSlider){
        priceRangeLabel.text = "Maximum Price: " + String (sender.value)
        let reversePriceValue = 5 - sender.value
        self.currentFilter.PriceMax = Int((100*reversePriceValue).rounded())
        if "\(round(100*sender.value)/100)".count == 3 {
            priceRangeLabel.text = "Maximum Price: \(round(100*reversePriceValue)/100)"+"0£/kWh"
            
        }else{
            priceRangeLabel.text = "Maximum Price: \(round(100*reversePriceValue)/100)"+"£/kWh"
        }
        if sender.value == 0 {
            priceRangeLabel.text = "Maximum Price: Any"
        }
        if sender.value == 5{
            priceRangeLabel.text = "Maximum Price: Free"
        }
        if self.previousFilter.PriceMax != self.currentFilter.PriceMax{
            filterAllData(filter: self.currentFilter)
        }
    }
    
    @objc func noOfConnectorsSliderChanged(sender: CustomSlider){
        sender.setValue(Float(lroundf(sender.value)), animated: true)
        noOfConnectorsLabel.text = "Minimum Number of Connectors: \(Int(sender.value))"
        self.currentFilter.minQuantity = Int(sender.value)
        if sender.value == 0 {
            noOfConnectorsLabel.text = "Minimum Number of Connectors: Any"
        }
        if self.previousFilter.minQuantity != self.currentFilter.minQuantity{
            filterAllData(filter: self.currentFilter)
        }
    }
    
    @objc func filterButtonPressed(sender: UIButton) {
        switch sender {
        case withinRangeButton:
            if self.currentFilter.WithinRangeOnly == true{
                self.currentFilter.WithinRangeOnly = false
                if self.currentFilter.EVChargerTypeOnly == false {
                    showAllClicked = true
                }
            } else {
                self.currentFilter.WithinRangeOnly = true
                if showAllClicked == true {
                    showAllClicked = false
                }
            }
        case type2OnlyButton:
            if self.currentFilter.EVChargerTypeOnly == true{
                self.currentFilter.EVChargerTypeOnly = false
                if self.currentFilter.WithinRangeOnly == false {
                    showAllClicked = true
                }
            } else {
                self.currentFilter.EVChargerTypeOnly = true
                if showAllClicked == true {
                    showAllClicked = false
                }
            }
        case showAllButton:
            if showAllClicked == true{
                showAllClicked = false
                self.currentFilter.EVChargerTypeOnly = true
                self.currentFilter.WithinRangeOnly = true
            } else {
                showAllClicked = true
                self.currentFilter.EVChargerTypeOnly = false
                self.currentFilter.WithinRangeOnly = false
            }
        default:
            print("Break")
            break
        }
        recolorFilterButtons()
        filterAllData(filter: self.currentFilter)
    }

    @objc func handleTap(recognizer:UITapGestureRecognizer) {    //Pan Stuff
        let screenRatio : CGFloat = self.panContainer.frame.width/self.panContainer.frame.height
        let touchPoint = recognizer.location(in: self.panContainer)
        
        if touchPoint.y < self.panContainer.frame.height - touchPoint.y{
            let yComponent = touchPoint.y
            if touchPoint.x < self.panContainer.frame.width - touchPoint.x{
                let xComponent = touchPoint.x
                if xComponent < yComponent * screenRatio{
                    moveMap(direction: "left")
                } else {
                    moveMap(direction: "up")
                }
            } else {
                let xComponent = self.panContainer.frame.width - touchPoint.x
                if xComponent < yComponent * screenRatio{
                    moveMap(direction: "right")
                } else {
                    moveMap(direction: "up")
                }
            }
        } else {
            let yComponent = self.panContainer.frame.height - touchPoint.y
            if touchPoint.x < self.panContainer.frame.width - touchPoint.x{
                let xComponent = touchPoint.x
                if xComponent < yComponent * screenRatio{
                    moveMap(direction: "left")
                } else {
                    moveMap(direction: "down")
                }
            } else {
                let xComponent = self.panContainer.frame.width - touchPoint.x
                if xComponent < yComponent * screenRatio{
                    moveMap(direction: "right")
                } else {
                    moveMap(direction: "down")
                }
            }
        }
    }
}  //Button functions

extension CustomNavigationViewController: UITableViewDelegate, UITableViewDataSource{ //table stuff
    
    @objc func addToFaveFirebase(sender: faveButton) {
        let singleStation = sender.chargepoint
        let data = try! FirebaseEncoder().encode(singleStation)
        ref.child("users/email/FavouriteStations/" + singleStation!.UUID).setValue(data)
        favouritesTable.reloadData()
        nearbyTable.reloadData()
        resultsTable.reloadData()
    }
    
    func addToRecentFirebase(title: String, subtitle: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let cellObject = myMKLocalSearchCompletion(title: title, subtitle: subtitle, latitude: latitude, longitude: longitude, timestamp: TimeInterval(NSDate().timeIntervalSince1970))
        let data = try! FirebaseEncoder().encode(cellObject)
        ref.child("users/email/UserInfo/RecentSearches/" + title).setValue(data)
        self.recentsTable.reloadData()
    }
    
    @objc func removeRecentFromFirebase(sender: UIButton){
        let title = sender.title(for: .selected)
        ref.child("users/email/UserInfo/RecentSearches/" + title!).removeValue()
    }
    
    @objc func removeFaveFromFirebase(sender: faveButton){
        let singleStation = sender.chargepoint
        self.ref.child("users").child("email").child("FavouriteStations").child(singleStation!.UUID).removeValue(){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                self.favouritesTable.reloadData()
                self.nearbyTable.reloadData()
                self.resultsTable.reloadData()            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int
        switch tableView{
        case favouritesTable:
            count = favouritesList.count
        case searchTable:
            count = searchList.count
        case nearbyTable:
            count = nearbyList.count
        case resultsTable:
            count = resultsList.count
        case recentsTable:
            count = recentsList.count
        default:
            count = 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        switch tableView{
            case favouritesTable:
                tableView.rowHeight = 48
                let cellStationList = tableView.dequeueReusableCell(withIdentifier: "cellf") as! resultsCell
                let EVstation = favouritesList[indexPath.row]
                cellStationList.frame = CGRect(x: 0, y: 0, width: nearbyTable.frame.width, height: 48)
                cellStationList.nameLabel.frame = CGRect(x: cellStationList.nameLabel.frame.minX, y: cellStationList.nameLabel.frame.minY, width: 0.8 * cellStationList.frame.width - cellStationList.pillShape.frame.width * 1.4, height: cellStationList.nameLabel.frame.height)
                cellStationList.heartView.frame = CGRect(x: cellStationList.frame.width * 0.8, y: cellStationList.frame.height * 0.3, width: cellStationList.frame.width * 0.1, height: cellStationList.frame.height * 0.4)
                cellStationList.nameLabel.text = EVstation.AddressInfo.Title
                cellStationList.nameLabel.textColor = UIColor.white
                let NoOfChargingPoints: String = EVstation.NumberOfPoints != nil ? "\(EVstation.NumberOfPoints!)" : "NA"
                cellStationList.distanceLabel.text = String((round(100*EVstation.AddressInfo.Distance)/100))+" Miles"
                cellStationList.distanceLabel.textColor = UIColor.white
                cellStationList.connectionNumberLabel.text = NoOfChargingPoints
                cellStationList.connectionNumberLabel.textAlignment = .center
                cellStationList.connectionNumberLabel.textColor = UIColor.white
                cellStationList.backgroundColor = UIColor.clear
                cellStationList.favouriteButton.frame = CGRect(x: cellStationList.frame.width * 0.8, y: cellStationList.frame.height * 0.2, width: cellStationList.frame.width * 0.1, height: cellStationList.frame.height * 0.6)
                cellStationList.favouriteButton.tintColor = UIColor.gray
                cellStationList.favouriteButton.imageView?.contentMode = .scaleAspectFit
                cellStationList.favouriteButton.chargepoint = EVstation
                ref.child("users").child("email").child("FavouriteStations").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild(EVstation.UUID){
                        cellStationList.favouriteButton.setImage(UIImage.init(named: "heartIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
                        cellStationList.favouriteButton.removeTarget(nil, action: nil, for: .allEvents)
                        cellStationList.favouriteButton.addTarget(self, action: #selector(self.removeFaveFromFirebase), for: .touchUpInside)
                    }else{
                        cellStationList.favouriteButton.setImage(UIImage.init(named: "hollowHeartIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
                        cellStationList.favouriteButton.removeTarget(nil, action: nil, for: .allEvents)
                        cellStationList.favouriteButton.addTarget(self, action: #selector(self.addToFaveFirebase), for: .touchUpInside)
                    }
                })
                if EVstation.Connections?.description.contains("Type 2") ?? false {
                    if CLLocation(latitude: CLLocationDegrees(EVstation.AddressInfo.Latitude!), longitude: CLLocationDegrees(EVstation.AddressInfo.Longitude!)).distance(from: CLLocation(latitude: CLLocationDegrees(self.currentLat), longitude: CLLocationDistance(self.currentLong))) < Double(vehicleRange * 1609.34) {
                        cellStationList.compatibilityIndicator.layer.backgroundColor = UIColor.init(named: "pinGreen")!.cgColor
                    } else {
                        cellStationList.compatibilityIndicator.layer.backgroundColor = UIColor.init(named: "pinAmber")!.cgColor
                    }
                } else {
                    cellStationList.compatibilityIndicator.layer.backgroundColor = UIColor.init(named: "pinRed")!.cgColor
                }
                cell = cellStationList
            
            case searchTable:
                tableView.rowHeight = 36
                let cellSearchResults = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                cellSearchResults.frame.size = CGSize(width: tableView.frame.width, height: 36)
                let searchResult = searchList[indexPath.row]
                cellSearchResults.textLabel?.text = searchResult.title
                cellSearchResults.detailTextLabel?.text = searchResult.subtitle
                cellSearchResults.backgroundColor = UIColor.clear
                cell = cellSearchResults
            
            case recentsTable:
                tableView.rowHeight = 36
                let cellSearchResults = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                cellSearchResults.frame.size = CGSize(width: tableView.frame.width, height: 36)
                let recentSearch = recentsList[indexPath.row]
                cellSearchResults.textLabel?.text = recentSearch.title
                cellSearchResults.detailTextLabel?.text = recentSearch.subtitle
                cellSearchResults.textLabel?.frame.size = CGSize(width: cellSearchResults.frame.width * 0.8, height: cellSearchResults.textLabel!.frame.height)
                cellSearchResults.detailTextLabel?.frame.size = CGSize(width: cellSearchResults.frame.width * 0.8, height: cellSearchResults.detailTextLabel!.frame.height)
                let removeButton = UIButton(frame: CGRect(x: cellSearchResults.frame.width * 0.8, y: cellSearchResults.frame.height * 0.2, width: cellSearchResults.frame.width * 0.1, height: cellSearchResults.frame.height * 0.6))
                removeButton.setImage(UIImage(named: "closeIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
                removeButton.tintColor = UIColor.white
                removeButton.imageView?.contentMode = .scaleAspectFit
                removeButton.contentMode = .center
                removeButton.setTitle(recentSearch.title, for: .selected)
                removeButton.addTarget(self, action: #selector(self.removeRecentFromFirebase), for: .touchUpInside)
                cellSearchResults.addSubview(removeButton)
                cellSearchResults.backgroundColor = UIColor.clear
                cell = cellSearchResults
            
            case nearbyTable:
                tableView.rowHeight = 48
                let cellStationList = tableView.dequeueReusableCell(withIdentifier: "celln") as! resultsCell
                let EVstation = nearbyList[indexPath.row]
                cellStationList.frame = CGRect(x: 0, y: 0, width: nearbyTable.frame.width, height: 48)
                cellStationList.nameLabel.frame = CGRect(x: cellStationList.nameLabel.frame.minX, y: cellStationList.nameLabel.frame.minY, width: 0.8 * cellStationList.frame.width - cellStationList.pillShape.frame.width * 1.4, height: cellStationList.nameLabel.frame.height)
                cellStationList.heartView.frame = CGRect(x: cellStationList.frame.width * 0.8, y: cellStationList.frame.height * 0.3, width: cellStationList.frame.width * 0.1, height: cellStationList.frame.height * 0.4)
                cellStationList.nameLabel.text = EVstation.AddressInfo.Title
                cellStationList.nameLabel.textColor = UIColor.white
                let NoOfChargingPoints: String = EVstation.NumberOfPoints != nil ? "\(EVstation.NumberOfPoints!)" : "NA"
                cellStationList.distanceLabel.text = String((round(100*EVstation.AddressInfo.Distance)/100))+" Miles"
                cellStationList.distanceLabel.textColor = UIColor.white
                cellStationList.connectionNumberLabel.text = NoOfChargingPoints
                cellStationList.connectionNumberLabel.textAlignment = .center
                cellStationList.connectionNumberLabel.textColor = UIColor.white
                cellStationList.backgroundColor = UIColor.clear
                cellStationList.favouriteButton.frame = CGRect(x: cellStationList.frame.width * 0.8, y: cellStationList.frame.height * 0.2, width: cellStationList.frame.width * 0.1, height: cellStationList.frame.height * 0.6)
                cellStationList.favouriteButton.tintColor = UIColor.gray
                cellStationList.favouriteButton.imageView?.contentMode = .scaleAspectFit
                cellStationList.favouriteButton.chargepoint = EVstation
                ref.child("users").child("email").child("FavouriteStations").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild(EVstation.UUID){
                        cellStationList.favouriteButton.setImage(UIImage.init(named: "heartIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
                        cellStationList.favouriteButton.removeTarget(nil, action: nil, for: .allEvents)
                        cellStationList.favouriteButton.addTarget(self, action: #selector(self.removeFaveFromFirebase), for: .touchUpInside)
                    }else{
                        cellStationList.favouriteButton.setImage(UIImage.init(named: "hollowHeartIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
                        cellStationList.favouriteButton.removeTarget(nil, action: nil, for: .allEvents)
                        cellStationList.favouriteButton.addTarget(self, action: #selector(self.addToFaveFirebase), for: .touchUpInside)
                    }
                })
                if EVstation.Connections?.description.contains("Type 2") ?? false {
                    if CLLocation(latitude: CLLocationDegrees(EVstation.AddressInfo.Latitude!), longitude: CLLocationDegrees(EVstation.AddressInfo.Longitude!)).distance(from: CLLocation(latitude: CLLocationDegrees(self.currentLat), longitude: CLLocationDistance(self.currentLong))) < Double(vehicleRange * 1609.34) {
                        cellStationList.compatibilityIndicator.layer.backgroundColor = UIColor.init(named: "pinGreen")!.cgColor
                    } else {
                        cellStationList.compatibilityIndicator.layer.backgroundColor = UIColor.init(named: "pinAmber")!.cgColor
                    }
                } else {
                    cellStationList.compatibilityIndicator.layer.backgroundColor = UIColor.init(named: "pinRed")!.cgColor
                }
                cell = cellStationList
            
            case resultsTable:
                tableView.rowHeight = 48
                let cellStationList = tableView.dequeueReusableCell(withIdentifier: "cellr") as! resultsCell
                let EVstation = resultsList[indexPath.row]
                cellStationList.frame = CGRect(x: 0, y: 0, width: nearbyTable.frame.width, height: 48)
                cellStationList.nameLabel.frame = CGRect(x: cellStationList.nameLabel.frame.minX, y: cellStationList.nameLabel.frame.minY, width: 0.8 * cellStationList.frame.width - cellStationList.pillShape.frame.width * 1.4, height: cellStationList.nameLabel.frame.height)
                cellStationList.favouriteButton.frame = CGRect(x: cellStationList.frame.width * 0.8, y: cellStationList.frame.height * 0.2, width: cellStationList.frame.width * 0.1, height: cellStationList.frame.height * 0.6)
                cellStationList.nameLabel.text = EVstation.AddressInfo.Title
                cellStationList.nameLabel.textColor = UIColor.white
                let NoOfChargingPoints: String = EVstation.NumberOfPoints != nil ? "\(EVstation.NumberOfPoints!)" : "NA"
                cellStationList.distanceLabel.text = String((round(100*EVstation.AddressInfo.Distance)/100))+" Miles"
                cellStationList.distanceLabel.textColor = UIColor.white
                cellStationList.connectionNumberLabel.text = NoOfChargingPoints
                cellStationList.connectionNumberLabel.textAlignment = .center
                cellStationList.connectionNumberLabel.textColor = UIColor.white
                cellStationList.backgroundColor = UIColor.clear
                cellStationList.favouriteButton.frame = CGRect(x: cellStationList.frame.width * 0.8, y: cellStationList.frame.height * 0.3, width: cellStationList.frame.width * 0.1, height: cellStationList.frame.height * 0.4)
                cellStationList.favouriteButton.tintColor = UIColor.gray
                cellStationList.favouriteButton.imageView?.contentMode = .scaleAspectFit
                cellStationList.favouriteButton.chargepoint = EVstation
                ref.child("users").child("email").child("FavouriteStations").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild(EVstation.UUID){
                        cellStationList.favouriteButton.setImage(UIImage.init(named: "heartIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
                        cellStationList.favouriteButton.removeTarget(nil, action: nil, for: .allEvents)
                        cellStationList.favouriteButton.addTarget(self, action: #selector(self.removeFaveFromFirebase), for: .touchUpInside)
                    }else{
                        cellStationList.favouriteButton.setImage(UIImage.init(named: "hollowHeartIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
                        cellStationList.favouriteButton.removeTarget(nil, action: nil, for: .allEvents)
                        cellStationList.favouriteButton.addTarget(self, action: #selector(self.addToFaveFirebase), for: .touchUpInside)
                    }
                })
                if EVstation.Connections?.description.contains("Type 2") ?? false {
                    if CLLocation(latitude: CLLocationDegrees(EVstation.AddressInfo.Latitude!), longitude: CLLocationDegrees(EVstation.AddressInfo.Longitude!)).distance(from: CLLocation(latitude: CLLocationDegrees(self.currentLat), longitude: CLLocationDistance(self.currentLong))) < Double(vehicleRange * 1609.34) {
                        cellStationList.compatibilityIndicator.layer.backgroundColor = UIColor.init(named: "pinGreen")!.cgColor
                    } else {
                        cellStationList.compatibilityIndicator.layer.backgroundColor = UIColor.init(named: "pinAmber")!.cgColor
                    }
                } else {
                    cellStationList.compatibilityIndicator.layer.backgroundColor = UIColor.init(named: "pinRed")!.cgColor
                }
                cell = cellStationList
            
            default:
                let defaultFailCell = UITableViewCell(style: .default, reuseIdentifier: nil)
                defaultFailCell.textLabel?.text = "Fail"
                cell = defaultFailCell
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView {
        case favouritesTable:
            let singleStation = favouritesList[indexPath.row]
            updateDetailViewer(singleChargePoint: singleStation, from: .favourites, annotation: nil)
            self.detailCenterMapOnLocation(location: CLLocation(latitude: CLLocationDegrees(singleStation.AddressInfo.Latitude!), longitude: CLLocationDegrees(singleStation.AddressInfo.Longitude!)))
            print (singleStation.AddressInfo.AddressLine1 ?? "Address Unavailable")
            self.mapView.selectAnnotation(self.getAnnotation(ID: singleStation.ID, fromList: evAnnotations2show), animated: true)
        case nearbyTable:
            let singleStation = nearbyList[indexPath.row]
            updateDetailViewer(singleChargePoint: singleStation, from: .nearby, annotation: nil)
            self.detailCenterMapOnLocation(location: CLLocation(latitude: CLLocationDegrees(singleStation.AddressInfo.Latitude!), longitude: CLLocationDegrees(singleStation.AddressInfo.Longitude!)))
            print (singleStation.AddressInfo.AddressLine1 ?? "Address Unavailable")
            self.mapView.selectAnnotation(self.getAnnotation(ID: singleStation.ID, fromList: evAnnotations2show), animated: true)
            
        case resultsTable:
            let singleStation = resultsList[indexPath.row]
            updateDetailViewer(singleChargePoint: singleStation, from: .results, annotation: nil)
            self.detailCenterMapOnLocation(location: CLLocation(latitude: CLLocationDegrees(singleStation.AddressInfo.Latitude!), longitude: CLLocationDegrees(singleStation.AddressInfo.Longitude!)))
            print (singleStation.AddressInfo.AddressLine1 ?? "Address Unavailable")
            self.mapView.selectAnnotation(self.getAnnotation(ID: singleStation.ID, fromList: evAnnotations2show), animated: true)
        case searchTable:
            let completion = searchList[indexPath.row]
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                let coordinate = response?.mapItems[0].placemark.coordinate
                self.placementLabelForResultsView.text = "Near " + (response?.mapItems[0].placemark.title)!
                self.getResultStations(latitude: Float((coordinate?.latitude)!), longitude: Float((coordinate?.longitude)!))
                self.resultsView.isHidden = false
                if completion.subtitle != "Search Nearby"{
                    self.addToRecentFirebase(title: completion.title, subtitle: completion.subtitle, latitude: coordinate!.latitude, longitude: coordinate!.longitude)
                }
            }
        case recentsTable:
            let recentClicked = recentsList[indexPath.row]
            self.placementLabelForResultsView.text = "Near " + recentClicked.title
            self.getResultStations(latitude: Float(recentClicked.latitude), longitude: Float(recentClicked.longitude))
            self.resultsView.isHidden = false
        default:
            print("selected cell error")
        }
    }
} //TableStuff

extension CustomNavigationViewController: MKLocalSearchCompleterDelegate{  //location stuff
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchList = completer.results
        self.searchTable.reloadData()
        if self.searchCompleter.queryFragment.isEmpty {
            self.searchTable.isHidden = true
        }
        if searchList.count == 0{
            self.searchTable.isHidden = true
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
} //LocationStuff

extension CustomNavigationViewController {  //searchbar stuff
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        self.searchTable.isHidden = false
        if searchText.isEmpty {
            self.searchTable.isHidden = true
        }
    }
} //SearchBAR stuff

extension CustomNavigationViewController{    //filter stuff
    
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
    
    func updateFilterButton(){
        DispatchQueue.main.async {
            if self.previousFilter == self.defaultFilter{
                self.filterNavBarButton.layer.backgroundColor = UIColor.init(red: 67/255, green: 214/255, blue: 152/255, alpha: 1).cgColor
                self.filterNavBarButton.tintColor = UIColor.init(white: 1, alpha: 1)
            } else {
                self.filterNavBarButton.layer.backgroundColor = UIColor.init(red: 108/255, green: 255/255, blue: 193/255, alpha: 1).cgColor
                self.filterNavBarButton.tintColor = UIColor.init(white: 0, alpha: 1)

            }
        }
    }
    
    func filterAllData(filter: Filter){
        if previousFilter != filter{
            self.nearbyList = filterList(filter: filter, unfilteredStationList: self.unfilteredNearbyList)
            self.favouritesList = filterList(filter: filter, unfilteredStationList: self.unfilteredFavouritesList)
            self.resultsList = filterList(filter: filter, unfilteredStationList: self.unfilteredResultsList)
            self.previousFilter = filter           //assign filter to previous filter for future comparison
            
        } else {
            self.nearbyList = self.unfilteredNearbyList
            self.favouritesList = self.unfilteredFavouritesList
            self.resultsList = self.unfilteredResultsList
        }
        
        self.allStationsToShowFiltered = removeDuplicates(list2Filter: (self.nearbyList + self.resultsList + self.favouritesList))
        self.annotateEVonMap(self.allStationsToShowFiltered)

        self.nearbyTable.reloadData()
        self.favouritesTable.reloadData()
        self.resultsTable.reloadData()
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
    
    func returnPriceForCostFromString (_ string2Trim:String) -> String{
        var string2Return : String = "Free"
        if var stringWithInt = string2Trim.matchingStrings(regex:"[0-9]+(\\.[0-9][0-9]?)?").first?[0]{
            if let index = stringWithInt.index(string2Return.startIndex, offsetBy: 1, limitedBy: string2Return.endIndex) {
                stringWithInt.remove(at: index)
                string2Return = stringWithInt
            }
        }
        return (string2Return)
    }
    
    func filterType2(_ list2Filter:[ChargePoint], _ filterForType2Only:Bool) -> [ChargePoint]{
        var returnTable : [ChargePoint] = []
        if filterForType2Only == true{
            for cStation in list2Filter{
                if cStation.Connections?.description.contains("Type 2") ?? false {
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
    
    func recolorFilterButtons(){
        if showAllClicked == true{
            showAllButton.layer.backgroundColor = accentColor!.cgColor
        }else {
            showAllButton.layer.backgroundColor = accent2Color.cgColor
        }
        if self.currentFilter.EVChargerTypeOnly == true{
            type2OnlyButton.layer.backgroundColor = accentColor!.cgColor

        }else {
            type2OnlyButton.layer.backgroundColor = accent2Color.cgColor
        }
        if self.currentFilter.WithinRangeOnly == true{
            withinRangeButton.layer.backgroundColor = accentColor!.cgColor
        }else{
            withinRangeButton.layer.backgroundColor = accent2Color.cgColor
            
        }
    }
    
} //FilterStuff

extension CustomNavigationViewController{
    
    func updateDetailViewer(singleChargePoint: ChargePoint, from: previousViewer, annotation: MKAnnotation?) {
        if annotation != nil{
            self.mapView.selectAnnotation(annotation!, animated: true)
        }
        titleDetailLabel.lineBreakMode = .byWordWrapping
        titleDetailLabel.numberOfLines = 2
        titleDetailLabel.text = singleChargePoint.AddressInfo.Title
        
        address1DetailLabel.text = singleChargePoint.AddressInfo.AddressLine1
        address1DetailLabel.font = address1DetailLabel.font.withSize(titleDetailLabel.font.pointSize - 2)
        address2DetailLabel.text = singleChargePoint.AddressInfo.AddressLine2
        if address2DetailLabel.text == nil{
            address2DetailLabel.text = singleChargePoint.AddressInfo.Town
        }
        address2DetailLabel.font = address1DetailLabel.font
        
        postcodeDetailLabel.text = singleChargePoint.AddressInfo.Postcode
        postcodeDetailLabel.font = address1DetailLabel.font
        
        costInfoDetailLabel.text = singleChargePoint.UsageCost
        if costInfoDetailLabel.text == nil{
            costInfoDetailLabel.text = "Cost Unavailable"
        } else {
            costInfoDetailLabel.text = "Cost: " + costInfoDetailLabel.text!
        }
        costInfoDetailLabel.font = titleDetailLabel.font.withSize(titleDetailLabel.font.pointSize - CGFloat(costInfoDetailLabel.text!.components(separatedBy: " ").count/3 - 2))
        costInfoDetailLabel.lineBreakMode = .byWordWrapping
        costInfoDetailLabel.numberOfLines = 0
        
        if let NoOfChargingPoints: Int = singleChargePoint.NumberOfPoints{
            noOfConnectorsDetailLabel.text = "Connectors: " + String(NoOfChargingPoints)
        }else{
            noOfConnectorsDetailLabel.text = "Connectors: NA"
        }
        noOfConnectorsDetailLabel.font = titleDetailLabel.font
        
        phoneNumberDetailLabel.text = singleChargePoint.AddressInfo.ContactTelephone1
        phoneNumberDetailLabel.font = address1DetailLabel.font
        
        if singleChargePoint.Connections?.description.contains("Type 2") ?? false {
            type2ConnectorsDetailLabel.text = "Type 2 Compatible"
        } else {
            type2ConnectorsDetailLabel.text = "Type 2 Incompatible"
        }
        detailView.isHidden = false
        
        routeButton.removeTarget(nil, action: nil, for: .allEvents)
        closeDetailViewButton.removeTarget(nil, action: nil, for: .allEvents)
        switch from {
        case .nearby:
            nearbyView.isHidden = true
            closeDetailViewButton.addTarget(self, action: #selector(showNearbyView), for: .touchUpInside)
        case .favourites:
            favouritesView.isHidden = true
            closeDetailViewButton.addTarget(self, action: #selector(showFavouritesView), for: .touchUpInside)
        case .results:
            resultsView.isHidden = true
            searchView.isHidden = true
            closeDetailViewButton.addTarget(self, action: #selector(showResultsView), for: .touchUpInside)
        case .map:
            closeDetailViewButton.addTarget(self, action: #selector(hideDetailView), for: .touchUpInside)
        }
        routeButton.chargepoint = singleChargePoint
        routeButton.addTarget(self, action: #selector(routeTo), for: .touchUpInside)

    }
    
} //DetailView Stuff

extension CustomNavigationViewController: MKMapViewDelegate{
    func annotateEVonMap(_ evStations2Annotate: [ChargePoint]) {
        DispatchQueue.main.async {
            self.evAnnotations2show = []
            var listID : Int = 0
            for aStation in evStations2Annotate{
                if aStation.Connections?.description.contains("Type 2") ?? false{
                    if CLLocation(latitude: CLLocationDegrees(aStation.AddressInfo.Latitude!), longitude: CLLocationDegrees(aStation.AddressInfo.Longitude!)).distance(from: CLLocation(latitude: CLLocationDegrees(self.currentLat), longitude: CLLocationDistance(self.currentLong))) < Double(self.vehicleRange * 1609.34) {
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let evAnnotationpressed = view.annotation as? evStationAnnotation{
            let station2DETAIL: ChargePoint = getChargePoint(ID: evAnnotationpressed.whatID!, fromList: self.allStationsToShowFiltered)
            self.updateDetailViewer(singleChargePoint: station2DETAIL, from: .map, annotation: view.annotation!)
        }
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
    
    func registerAnnotationViewClasses() {
        mapView.register(RedAnnotationMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(AmberAnnotationMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(GreenAnnotationMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(FavouriteAnnotationMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let evannotation = annotation as? evStationAnnotation else {return nil }
        var favesList : [Int] = []
        for fave in self.favouritesList{
            favesList.append(fave.ID)
        }
        if favesList.contains(evannotation.listInID){
            let marker2Return = FavouriteAnnotationMarker(annotation: evannotation, reuseIdentifier: FavouriteAnnotationMarker.ReuseID)
            if clusterAnnotations{
                marker2Return.clusteringIdentifier = "FavouritesCluster"
            } else {
                marker2Return.clusteringIdentifier = nil
            }
            return marker2Return
        } else {
            switch evannotation.colour {
            case .red:
                let marker2Return = RedAnnotationMarker(annotation: evannotation, reuseIdentifier: RedAnnotationMarker.ReuseID)
                if clusterAnnotations{
                    marker2Return.clusteringIdentifier = "Cluster"
                } else {
                    marker2Return.clusteringIdentifier = nil
                }
                return marker2Return
            case .amber:
                let marker2Return = AmberAnnotationMarker(annotation: evannotation, reuseIdentifier: AmberAnnotationMarker.ReuseID)
                if clusterAnnotations{
                    marker2Return.clusteringIdentifier = "Cluster"
                } else {
                    marker2Return.clusteringIdentifier = nil
                }
                return marker2Return
            case .green:
                let marker2Return = GreenAnnotationMarker(annotation: evannotation, reuseIdentifier: GreenAnnotationMarker.ReuseID)
                if clusterAnnotations{
                    marker2Return.clusteringIdentifier = "Cluster"
                } else {
                    marker2Return.clusteringIdentifier = nil
                }
                return marker2Return
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        checkDecluster()
    }
    
    func toggleClustering(){
        self.clusterAnnotations.toggle()
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations(annotations)
        self.mapView.addAnnotations(annotations)
    }
    
    func checkDecluster() {
        if self.mapView.region.span.longitudeDelta < 0.025{
            if self.clusterAnnotations == true{
                toggleClustering()
            }
            
        }else{
            if self.clusterAnnotations == false{
                toggleClustering()
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
}    //AnnotationStuff

class navBarButton: UIButton{
    override var canBecomeFocused: Bool{
        return true
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self{
            self.tintColor = UIColor.init(named: "AccentColour1")
            self.setTitleColor(UIColor.init(named: "AccentColour1"), for: .normal)
            self.layer.borderColor = UIColor.init(named: "AccentColour1")?.cgColor
            self.layer.borderWidth = 2
            self.layer.cornerRadius = 7
        } else {
            self.tintColor = UIColor.white
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0

        }
    }
}

class mapButton: UIButton{
    override var canBecomeFocused: Bool{
        return true
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self{
            self.tintColor = UIColor(white: 30/255, alpha: 1)
            self.backgroundColor = UIColor.init(named: "AccentColour1")
        } else {
            self.tintColor = UIColor.init(named: "AccentColour1")
            self.backgroundColor = UIColor(white: 30/255, alpha: 1)
            
        }
    }
}

class uiButtonUnfocusable: UIButton{
    override var canBecomeFocused: Bool{
        return false
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self{
            self.tintColor = UIColor(white: 30/255, alpha: 1)
            self.backgroundColor = UIColor.init(named: "AccentColour1")
        } else {
            self.tintColor = UIColor.init(named: "AccentColour1")
            self.backgroundColor = UIColor(white: 30/255, alpha: 1)
            
        }
    }
}

extension UIViewController {
    @discardableResult
    func addFocusGuide(from origin: UIView, to destination: UIView, direction: UIRectEdge, debugMode: Bool = true) -> UIFocusGuide {
        return addFocusGuide(from: origin, to: [destination], direction: direction, debugMode: debugMode)
    }
    
    @discardableResult
    func addFocusGuide(from origin: UIView, to destinations: [UIView], direction: UIRectEdge, debugMode: Bool = false) -> UIFocusGuide {
        let focusGuide = UIFocusGuide()
        view.addLayoutGuide(focusGuide)
        focusGuide.preferredFocusEnvironments = destinations
        focusGuide.widthAnchor.constraint(equalTo: origin.widthAnchor).isActive = true
        focusGuide.heightAnchor.constraint(equalTo: origin.heightAnchor).isActive = true
        
        switch direction {
        case .bottom:
            focusGuide.topAnchor.constraint(equalTo: origin.bottomAnchor).isActive = true
            focusGuide.leftAnchor.constraint(equalTo: origin.leftAnchor).isActive = true
            focusGuide.rightAnchor.constraint(equalTo: origin.rightAnchor).isActive = true
        case .top:
            focusGuide.bottomAnchor.constraint(equalTo: origin.topAnchor).isActive = true
            focusGuide.leftAnchor.constraint(equalTo: origin.leftAnchor).isActive = true
            focusGuide.rightAnchor.constraint(equalTo: origin.rightAnchor).isActive = true
        case .left:
            focusGuide.topAnchor.constraint(equalTo: origin.topAnchor).isActive = true
            focusGuide.rightAnchor.constraint(equalTo: origin.leftAnchor).isActive = true
            focusGuide.bottomAnchor.constraint(equalTo: origin.bottomAnchor).isActive = true
        case .right:
            focusGuide.topAnchor.constraint(equalTo: origin.topAnchor).isActive = true
            focusGuide.leftAnchor.constraint(equalTo: origin.rightAnchor).isActive = true
            focusGuide.bottomAnchor.constraint(equalTo: origin.bottomAnchor).isActive = true
        default:
            // Not supported :(
            break
        }
        
        if focusGuide.isEnabled{
            print("")
        }
        
        if debugMode {
            view.addSubview(FocusGuideDebugView(focusGuide: focusGuide, destination: destinations.first!))
        }
        
        return focusGuide
    }
}

class FocusGuideDebugView: UIView {
    init(focusGuide: UIFocusGuide, destination: UIView) {
        super.init(frame: focusGuide.layoutFrame)
        layer.backgroundColor = UIColor(cgColor: destination.layer.backgroundColor ?? UIColor.purple.cgColor).withAlphaComponent(0.2).cgColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
