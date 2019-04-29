import UIKit
import MapKit
import Firebase
import CodableFirebase
import SwiftTheme

class BottomSheetViewController: UIViewController, UISearchBarDelegate{
    
    var ref: DatabaseReference!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var panView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var drawerTable: UITableView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var gradientAccentView: UIView!
    var tableShown: drawerTables = .menu
    @IBAction func navBarFilterPressed(_ sender: Any) {
        bottomSheetDelegate?.toggleFilterContainer()
    }
    
    @IBOutlet weak var navBarFilterButton: UIBarButtonItem!
    @IBOutlet weak var navBarTitleText: UINavigationItem!
    @IBOutlet weak var navBarTitle: UINavigationBar!
    
    @IBOutlet weak var navBarBackButton: UIBarButtonItem!
    
    @IBAction func navBarBackPressed(_ sender: UIBarButtonItem) {
        if sender.title == "Reload"{
            bottomSheetDelegate?.reloadForNetwork(sender: sender)
        } else {
        tableShown = .menu
        self.refreshTable()
        self.searchBar.isHidden = false
        self.navBarTitle.isHidden = true
        }
    }
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var selectedEVstation: ChargePoint? = nil
    let menuList : [staticMenuCellInfo] = [ staticMenuCellInfo(label: "Nearby Stations",
                                                       icon: UIImage(named: "nearMeIcon"),
                                                       ID: 1,
                                                       colour: UIColor.init(named: "Accent1")!),
                                        staticMenuCellInfo(label: "Favourites",
                                                       icon: UIImage(named: "heartIcon"),
                                                       ID: 2,
                                                       colour: UIColor.init(named: "Accent2")!),
                                        staticMenuCellInfo(label: "Route Planner",
                                                       icon: UIImage(named: "routePlannerIcon"),
                                                       ID: 3,
                                                       colour: UIColor.init(named: "Accent3")!)]
    var isSearching: Bool = false
    var detailViewControllerReference: DetailViewController? = nil
    var lastY: CGFloat = 0
    var pan: UIPanGestureRecognizer!
    var bottomSheetDelegate: BottomSheetDelegate?
    var parentView: UIView!
    var initalFrame: CGRect!
    var topY: CGFloat = 80 //change this in viewWillAppear for top position
    var middleY: CGFloat = 400 //change this in viewWillAppear to decide if animate to top or bottom
    var bottomY: CGFloat = 600 //no need to change this
    let bottomOffset: CGFloat = 143 //sheet height on bottom position
    var lastLevel: SheetLevel = .middle //choose inital position of the sheet
    var fromMap2Detail : ChargePoint? = nil
    var disableTableScroll = false
    
    //hack panOffset To prevent jump when goes from top to down
    var panOffset: CGFloat = 0
    var applyPanOffset = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //initial formatting
        panView.layer.cornerRadius = 10
        
        panView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        panView.theme_backgroundColor = Colors.primaryColor
        blurView.theme_backgroundColor = Colors.primaryColor
        backgroundView.theme_backgroundColor = Colors.primaryColor
        panView.layer.masksToBounds = true
        searchBar.theme_tintColor = Colors.primaryTextColor
        searchBar.theme_barTintColor = Colors.primaryColor
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.theme_textColor = Colors.primaryTextColor
        textFieldInsideSearchBar?.font = UIFont(name: "Gotham-Book", size: 12)
    textFieldInsideSearchBar?.theme_backgroundColor = Colors.searchBarColor
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.theme_textColor = Colors.searchTextColor
        ref = Database.database().reference()

        //MARK: Delegate assignment
        searchBar.delegate = self
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        self.panView.addGestureRecognizer(pan)
        drawerTable.delegate = self
        drawerTable.dataSource = self
        searchCompleter.delegate = self
        self.drawerTable.register(MenuTableCell.self, forCellReuseIdentifier: "cellm")
        self.drawerTable.register(resultsCell.self, forCellReuseIdentifier: "cell")
        
        //MARK: Editing setting
        tableShown = .menu
        self.refreshTable()
        setupAccentBar()
        self.navBarTitle.isHidden = true
        self.searchBar.setImage(#imageLiteral(resourceName: "FilterIcon").withRenderingMode(.alwaysTemplate), for: .resultsList, state: .normal)
        self.searchBar.showsSearchResultsButton = false
        self.drawerTable.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if MyThemes.isNight(){
            searchBar.keyboardAppearance = .dark
       //     searchBar.barStyle = .blackOpaque
        
        } else {
            searchBar.keyboardAppearance = .light
//searchBar.barStyle = .default
        }
        
        self.initalFrame = UIScreen.main.bounds
        self.topY = round(initalFrame.height * 0.05)
        self.middleY = initalFrame.height * 0.55
        self.bottomY = initalFrame.height - bottomOffset
        self.lastY = self.middleY
        
        bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
    }
    
    func refreshTable() {
        print("table refresh: ")
        print (self.tableShown)
        self.drawerTable.reloadData()
    }
    
    @objc func addToFaveFirebase(sender: faveButton) {
        let singleStation = sender.chargepoint
        let data = try! FirebaseEncoder().encode(singleStation)
        ref.child("users/email/FavouriteStations/" + singleStation!.UUID).setValue(data)
        self.refreshTable()
    }
    
    func addToRecentFirebase(title: String, subtitle: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let cellObject = myMKLocalSearchCompletion(title: title, subtitle: subtitle, latitude: latitude, longitude: longitude, timestamp: TimeInterval(NSDate().timeIntervalSince1970))
        let data = try! FirebaseEncoder().encode(cellObject)
        ref.child("users/email/UserInfo/RecentSearches/" + title).setValue(data)
        self.refreshTable()
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
                self.refreshTable()
            }
        }
        self.refreshTable()
    }
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == drawerTable else {return}

        if (self.parentView.frame.minY > topY){
            self.drawerTable.contentOffset.y = 0
        }
    }
    
    func pass2detail(evStation2Detail: ChargePoint) {
        if self.fromMap2Detail == nil{
            self.fromMap2Detail = evStation2Detail
        }
        self.detailViewControllerReference?.updateDetailViewer(station2BDetailed: evStation2Detail, currentLat: self.bottomSheetDelegate!.getCurrentLat(), currentLong: self.bottomSheetDelegate!.getCurrentLong(), vehicleRange: self.bottomSheetDelegate!.getVehicleRange())
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tableShown = .recentSearch
    }
    func setupAccentBar(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.gradientAccentView.bounds
        gradientLayer.colors = [UIColor.init(named: "Accent1")!.cgColor,
                                UIColor.init(named: "Accent2")!.cgColor,
                                UIColor.init(named: "Accent3")!.cgColor,
                                UIColor.init(named: "Accent4")!.cgColor,
                                UIColor.init(named: "Accent5")!.cgColor]
        gradientLayer.locations = [0.0, 0.2, 0.4, 0.6, 0.8]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.gradientAccentView.layer.addSublayer(gradientLayer)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        if self.isSearching != true{
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.topY))
                self.drawerTable.contentInset.bottom = 50
                self.searchBar.showsSearchResultsButton = true
                self.tableShown = .recentSearch
                self.refreshTable()
                self.lastLevel = .top
                self.isSearching = true
            })
        }
        self.lastY = self.parentView.frame.minY
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        isSearching = false
        self.searchBar.endEditing(true)
        if self.tableShown == .recentSearch{
            self.tableShown = .menu
            self.refreshTable()
        }
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        bottomSheetDelegate?.toggleFilterContainer()
        bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))

    }
    
    //this stops unintended tableview scrolling while animating to top
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == drawerTable else {return}

        if disableTableScroll{
            targetContentOffset.pointee = scrollView.contentOffset
            disableTableScroll = false
        }
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer){

        let dy = recognizer.translation(in: self.parentView).y
        switch recognizer.state {
        case .began:
            applyPanOffset = (self.drawerTable.contentOffset.y > 0)
        case .changed:
            if self.drawerTable.contentOffset.y > 0{
                panOffset = dy
                return
            }
            
            if self.drawerTable.contentOffset.y <= 0{
                if !applyPanOffset{panOffset = 0}
                let maxY = max(topY, lastY + dy - panOffset)
                let y = min(bottomY, maxY)
                //                self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: y)
                bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: y))
            }
            
            if self.parentView.frame.minY > topY{
                self.drawerTable.contentOffset.y = 0
            }
        case .failed, .ended, .cancelled:
            panOffset = 0
            
            //bug fix #6. see https://github.com/OfTheWolf/UBottomSheet/issues/6
            if (self.drawerTable.contentOffset.y > 0){
                return
            }//bug fix #6 end
            
            self.panView.isUserInteractionEnabled = false
            
            self.disableTableScroll = self.lastLevel != .top
            
            self.lastY = self.parentView.frame.minY
            self.lastLevel = self.nextLevel(recognizer: recognizer)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                
                switch self.lastLevel{
                case .top:
                    //                    self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: self.topY)
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.topY))
                    self.drawerTable.contentInset.bottom = 50
                    self.searchBar.showsSearchResultsButton = true
                case .middle:
                    //                    self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: self.middleY)
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
                    self.searchBar.showsSearchResultsButton = false

                case .bottom:
                    //                    self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: self.bottomY)
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.bottomY))
                    self.searchBar.showsSearchResultsButton = false
                }
            }) { (_) in
                self.panView.isUserInteractionEnabled = true
                self.lastY = self.parentView.frame.minY
            }
        default:
            break
        }
    }
    
    func nextLevel(recognizer: UIPanGestureRecognizer) -> SheetLevel{
      let y = self.lastY
        let velY = recognizer.velocity(in: self.view).y
        if velY < -200{
            return y > middleY ? .middle : .top
        }else if velY > 200{
            return y < (middleY + 1) ? .middle : .bottom
        }else{
            if y > middleY {
                return (y - middleY) < (bottomY - y) ? .middle : .bottom
            }else{
                return (y - topY) < (middleY - y) ? .top : .middle
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let dv = segue.destination as? DetailViewController{
            detailViewControllerReference = dv
            if self.fromMap2Detail != nil {
                detailViewControllerReference?.updateDetailViewer(station2BDetailed: self.fromMap2Detail!, currentLat: self.bottomSheetDelegate!.getCurrentLat(), currentLong: self.bottomSheetDelegate!.getCurrentLong(), vehicleRange: self.bottomSheetDelegate!.getVehicleRange())
                self.fromMap2Detail = nil
            }
        }
    }
}

extension BottomSheetViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        switch self.tableShown {
        case .menu:
            count =  menuList.count
        case .locationSearch:
            count = searchResults.count
        case .evResults:
            count = bottomSheetDelegate?.getResultsList().count
        case .nearby:
            count = bottomSheetDelegate?.getNearbyList().count
        case .favourites:
             count = bottomSheetDelegate?.getFavouritesList().count
        case .recentSearch:
            count = bottomSheetDelegate?.fetchedRecents().count
        }
        return count!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?

        switch self.tableShown {
        case .menu:
            tableView.rowHeight = 70
            let menuCell = tableView.dequeueReusableCell(withIdentifier: "cellm", for: indexPath) as! MenuTableCell
            let anEntry = menuList[indexPath.row]
            menuCell.menuTitleLabel.text = anEntry.label
            menuCell.menuTitleLabel.theme_textColor = Colors.primaryTextColor
            menuCell.menuTitleLabel.font = UIFont(name: "Gotham-Bold", size: 15)
            menuCell.iconBackground.layer.backgroundColor = anEntry.colour.cgColor
            menuCell.iconView.contentMode = .scaleAspectFit
            menuCell.iconView.image = anEntry.icon?.withRenderingMode(.alwaysTemplate)
            menuCell.iconView.tintColor = UIColor.white
            cell = menuCell
            
        case .locationSearch:
            tableView.rowHeight = 44
            let cellSearchResults = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let searchResult = searchResults[indexPath.row]
            cellSearchResults.textLabel?.text = searchResult.title
            cellSearchResults.textLabel?.font = UIFont(name: "Gotham-Medium", size: 15)
            cellSearchResults.detailTextLabel?.text = searchResult.subtitle
            cellSearchResults.detailTextLabel?.font = UIFont(name: "Gotham-Book", size: 10)
            cellSearchResults.textLabel?.theme_textColor = Colors.primaryTextColor
            cellSearchResults.detailTextLabel?.theme_textColor = Colors.subTextColor
            cellSearchResults.textLabel?.attributedText = highlightedText(searchResult.title, inRanges: searchResult.titleHighlightRanges, size: 17.0)
            cellSearchResults.detailTextLabel?.attributedText = highlightedText(searchResult.subtitle, inRanges: searchResult.subtitleHighlightRanges, size: 12.0)
            cellSearchResults.backgroundColor = UIColor.clear
            cell = cellSearchResults
            
        case .recentSearch:
            tableView.rowHeight = 44
            let cellSearchResults = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let recentSearch = bottomSheetDelegate?.fetchedRecents()[indexPath.row]
            cellSearchResults.frame.size = CGSize(width: tableView.frame.width, height: 44)
            cellSearchResults.textLabel?.text = recentSearch?.title
            cellSearchResults.detailTextLabel?.text = recentSearch?.subtitle
            cellSearchResults.textLabel?.theme_textColor = Colors.primaryTextColor
            cellSearchResults.textLabel?.font = UIFont(name: "Gotham-Medium", size: 15)
            cellSearchResults.detailTextLabel?.font = UIFont(name: "Gotham-Book", size: 10)
            cellSearchResults.detailTextLabel?.theme_textColor = Colors.subTextColor
            cellSearchResults.textLabel?.frame.size = CGSize(width: cellSearchResults.frame.width * 0.9, height: cellSearchResults.textLabel!.frame.height)
            cellSearchResults.detailTextLabel?.frame.size = CGSize(width: cellSearchResults.frame.width * 0.9, height: cellSearchResults.detailTextLabel!.frame.height)
            let removeButton = UIButton(frame: CGRect(x: cellSearchResults.frame.width * 0.9, y: cellSearchResults.frame.height * 0.2, width: cellSearchResults.frame.width * 0.1, height: cellSearchResults.frame.height * 0.6))
            removeButton.setImage(UIImage(named: "closeIcon"), for: .normal)
            removeButton.imageView?.contentMode = .scaleAspectFit
            removeButton.setTitle(recentSearch?.title, for: .selected)
            removeButton.addTarget(self, action: #selector(self.removeRecentFromFirebase), for: .touchUpInside)
            cellSearchResults.addSubview(removeButton)
            cellSearchResults.backgroundColor = UIColor.clear
            cell = cellSearchResults
            
        case .evResults:
            tableView.rowHeight = 48
            let cellStationList = tableView.dequeueReusableCell(withIdentifier: "cell") as! resultsCell
            let EVstation = bottomSheetDelegate!.getResultsList()[indexPath.row]
            cellStationList.frame = CGRect(x: 0, y: 0, width: self.drawerTable.frame.width, height: 48)
            cellStationList.nameLabel.frame = CGRect(x: cellStationList.nameLabel.frame.minX, y: cellStationList.nameLabel.frame.minY, width: 0.9 * cellStationList.frame.width - cellStationList.pillShape.frame.width * 1.4, height: cellStationList.nameLabel.frame.height)
            cellStationList.nameLabel.text = EVstation.AddressInfo.Title
            cellStationList.nameLabel.theme_textColor = Colors.primaryTextColor
            cellStationList.nameLabel.font = UIFont(name: "Gotham-Medium", size: 15)
            let NoOfChargingPoints: String = EVstation.NumberOfPoints != nil ? "\(EVstation.NumberOfPoints!)" : "NA"
            cellStationList.distanceLabel.text = String((round(100*EVstation.AddressInfo.Distance)/100))+" Miles"
            cellStationList.distanceLabel.theme_textColor = Colors.subTextColor
            cellStationList.distanceLabel.font = UIFont(name: "Gotham-Book", size: 10)
            cellStationList.connectionNumberLabel.text = NoOfChargingPoints
            cellStationList.connectionNumberLabel.theme_textColor = Colors.primaryTextColor
            cellStationList.connectionNumberLabel.font = UIFont(name: "Gotham-Bold", size: 18)
            cellStationList.connectionNumberLabel.textAlignment = .center
            cellStationList.backgroundColor = UIColor.clear
            cellStationList.favouriteButton.frame = CGRect(x: cellStationList.frame.width * 0.9, y: cellStationList.frame.height * 0.2, width: cellStationList.frame.width * 0.1, height: cellStationList.frame.height * 0.6)
            cellStationList.favouriteButton.theme_tintColor = Colors.favouriteFilledColor
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
            if (EVstation.Connections?.description.contains("Type 2") ?? false){
                if CLLocation(latitude: CLLocationDegrees(EVstation.AddressInfo.Latitude!), longitude: CLLocationDegrees(EVstation.AddressInfo.Longitude!)).distance(from: CLLocation(latitude: CLLocationDegrees(self.bottomSheetDelegate!.getCurrentLat()), longitude: CLLocationDistance(self.bottomSheetDelegate!.getCurrentLong()))) < Double(self.bottomSheetDelegate!.getVehicleRange() * 1609.34){
                    cellStationList.compatibilityIndicator.layer.theme_backgroundColor = Colors.connectorGreenColor
                } else {
                    cellStationList.compatibilityIndicator.layer.theme_backgroundColor = Colors.connectorAmberColor
                }
            } else {
                cellStationList.compatibilityIndicator.layer.theme_backgroundColor = Colors.connectorRedColor
            }
            cell = cellStationList
            
        case .nearby:
            tableView.rowHeight = 48
            let cellStationList = tableView.dequeueReusableCell(withIdentifier: "cell") as! resultsCell
            let EVstation = bottomSheetDelegate!.getNearbyList()[indexPath.row]
            cellStationList.frame = CGRect(x: 0, y: 0, width: self.drawerTable.frame.width, height: 48)
            cellStationList.nameLabel.frame = CGRect(x: cellStationList.nameLabel.frame.minX, y: cellStationList.nameLabel.frame.minY, width: 0.9 * cellStationList.frame.width - cellStationList.pillShape.frame.width * 1.4, height: cellStationList.nameLabel.frame.height)
            cellStationList.nameLabel.text = EVstation.AddressInfo.Title
            cellStationList.nameLabel.theme_textColor = Colors.primaryTextColor
            cellStationList.nameLabel.font = UIFont(name: "Gotham-Medium", size: 15)
            let NoOfChargingPoints: String = EVstation.NumberOfPoints != nil ? "\(EVstation.NumberOfPoints!)" : "NA"
            cellStationList.distanceLabel.text = String((round(100*EVstation.AddressInfo.Distance)/100))+" Miles"
            cellStationList.distanceLabel.theme_textColor = Colors.subTextColor
            cellStationList.distanceLabel.font = UIFont(name: "Gotham-Book", size: 10)
            cellStationList.connectionNumberLabel.text = NoOfChargingPoints
            cellStationList.connectionNumberLabel.textAlignment = .center
            cellStationList.connectionNumberLabel.font = UIFont(name: "Gotham-Bold", size: 18)
            cellStationList.connectionNumberLabel.theme_textColor = Colors.primaryTextColor
            cellStationList.backgroundColor = UIColor.clear
            cellStationList.favouriteButton.frame = CGRect(x: cellStationList.frame.width * 0.9, y: cellStationList.frame.height * 0.2, width: cellStationList.frame.width * 0.1, height: cellStationList.frame.height * 0.6)
            cellStationList.favouriteButton.theme_tintColor = Colors.favouriteFilledColor
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
            if (EVstation.Connections?.description.contains("Type 2") ?? false){
                if CLLocation(latitude: CLLocationDegrees(EVstation.AddressInfo.Latitude!), longitude: CLLocationDegrees(EVstation.AddressInfo.Longitude!)).distance(from: CLLocation(latitude: CLLocationDegrees(self.bottomSheetDelegate!.getCurrentLat()), longitude: CLLocationDistance(self.bottomSheetDelegate!.getCurrentLong()))) < Double(self.bottomSheetDelegate!.getVehicleRange() * 1609.34){
                    cellStationList.compatibilityIndicator.layer.theme_backgroundColor = Colors.connectorGreenColor
                } else {
                    cellStationList.compatibilityIndicator.layer.theme_backgroundColor = Colors.connectorAmberColor
                }
            } else {
                cellStationList.compatibilityIndicator.layer.theme_backgroundColor = Colors.connectorRedColor
            }
            cell = cellStationList
            
        case .favourites:
            tableView.rowHeight = 48
            let cellStationList = tableView.dequeueReusableCell(withIdentifier: "cell") as! resultsCell
            let EVstation = bottomSheetDelegate!.getFavouritesList()[indexPath.row]
            cellStationList.frame = CGRect(x: 0, y: 0, width: self.drawerTable.frame.width, height: 48)
            cellStationList.nameLabel.frame = CGRect(x: cellStationList.nameLabel.frame.minX, y: cellStationList.nameLabel.frame.minY, width: 0.9 * cellStationList.frame.width - cellStationList.pillShape.frame.width * 1.4, height: cellStationList.nameLabel.frame.height)
            cellStationList.nameLabel.text = EVstation.AddressInfo.Title
            cellStationList.nameLabel.theme_textColor = Colors.primaryTextColor
            cellStationList.nameLabel.font = UIFont(name: "Gotham-Medium", size: 15)
            let NoOfChargingPoints: String = EVstation.NumberOfPoints != nil ? "\(EVstation.NumberOfPoints!)" : "NA"
            cellStationList.distanceLabel.text = String((round(100*EVstation.AddressInfo.Distance)/100))+" Miles"
            cellStationList.distanceLabel.theme_textColor = Colors.subTextColor
            cellStationList.distanceLabel.font = UIFont(name: "Gotham-Book", size: 10)
            cellStationList.connectionNumberLabel.text = NoOfChargingPoints
            cellStationList.connectionNumberLabel.theme_textColor = Colors.primaryTextColor
            cellStationList.connectionNumberLabel.font = UIFont(name: "Gotham-Bold", size: 18)
            cellStationList.connectionNumberLabel.textAlignment = .center
            cellStationList.backgroundColor = UIColor.clear
            cellStationList.favouriteButton.frame = CGRect(x: cellStationList.frame.width * 0.9, y: cellStationList.frame.height * 0.2, width: cellStationList.frame.width * 0.1, height: cellStationList.frame.height * 0.6)
            cellStationList.favouriteButton.theme_tintColor = Colors.favouriteFilledColor
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
            if (EVstation.Connections?.description.contains("Type 2") ?? false){
                if CLLocation(latitude: CLLocationDegrees(EVstation.AddressInfo.Latitude!), longitude: CLLocationDegrees(EVstation.AddressInfo.Longitude!)).distance(from: CLLocation(latitude: CLLocationDegrees(self.bottomSheetDelegate!.getCurrentLat()), longitude: CLLocationDistance(self.bottomSheetDelegate!.getCurrentLong()))) < Double(self.bottomSheetDelegate!.getVehicleRange() * 1609.34){
                    cellStationList.compatibilityIndicator.layer.theme_backgroundColor = Colors.connectorGreenColor
                } else {
                    cellStationList.compatibilityIndicator.layer.theme_backgroundColor = Colors.connectorAmberColor
                }
            } else {
                cellStationList.compatibilityIndicator.layer.theme_backgroundColor = Colors.connectorRedColor
            }
            cell = cellStationList
        }
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch self.tableShown {
        case .menu:
            switch menuList[indexPath.row].ID {
            case 1: //Nearby Station
                self.bottomSheetDelegate?.getNearbyStations()
                self.tableShown = .nearby
                self.searchBar.isHidden = true
                let nearbyLabel = UILabel()
                nearbyLabel.text = "Stations Near Me"
                nearbyLabel.theme_textColor = Colors.primaryTextColor
                nearbyLabel.font = UIFont(name: "Gotham-Black", size: 16)
                self.navBarTitleText.titleView = nearbyLabel
                self.navBarTitle.isHidden = false
                self.searchBar.text = ""
                //add navbar back button image
                self.refreshTable()
                
            case 2:  //Favourites
                self.tableShown = .favourites
                self.searchBar.isHidden = true
                let favouritesLabel = UILabel()
                favouritesLabel.text = "Favourites"
                favouritesLabel.theme_textColor = Colors.primaryTextColor
                favouritesLabel.font = UIFont(name: "Gotham-Black", size: 16)
                self.navBarTitleText.titleView = favouritesLabel
                self.navBarTitle.isHidden = false
                //add navbar back button image
                self.refreshTable()
                
            case 3:  //Route Planner
                let alertSuccess = UIAlertController(title: "Route Planner Functionality", message: "Route Planner not yet implemented", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction (title: "Can't wait!", style: UIAlertAction.Style.cancel, handler: nil)
                alertSuccess.addAction(okAction)
                self.present(alertSuccess, animated: true, completion: nil)
            default:
                print("Button clicked has no function connected")
            }
            
        case .locationSearch:
            let completion = searchResults[indexPath.row]
            let searchRequest = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            self.searchBar.resignFirstResponder()
            search.start { (response, error) in
                let coordinate = response?.mapItems[0].placemark.coordinate
                let placemarkName = response?.mapItems[0].placemark.title
                self.bottomSheetDelegate?.centerMapOnLocation(location: CLLocation(latitude: CLLocationDegrees((coordinate?.latitude)!), longitude: CLLocationDegrees((coordinate?.longitude)!)))
                self.searchBar.isHidden = true
                let resultsLabel = UILabel()
                resultsLabel.text = "Stations Near " + String(describing: placemarkName!)
                resultsLabel.font = UIFont(name: "Gotham-Medium", size: 12)
                resultsLabel.sizeToFit()
                resultsLabel.contentMode = .center
                resultsLabel.numberOfLines = 0
                resultsLabel.theme_textColor = Colors.searchTextColor
                self.navBarTitleText.titleView = resultsLabel
                self.navBarTitleText.titleView?.theme_tintColor = Colors.primaryTextColor
                self.navBarTitle.isHidden = false
                self.bottomSheetDelegate?.getEVapi(conditions: (self.bottomSheetDelegate?.setupConditions(latitude: Float((coordinate?.latitude)!), longitude: Float((coordinate?.longitude)!)))!, list2update: .resultsList)
                if completion.subtitle != "Search Nearby"{
                    self.addToRecentFirebase(title: completion.title, subtitle: completion.subtitle, latitude: coordinate!.latitude, longitude: coordinate!.longitude)
                }
            }
            self.searchBar.text = ""
            tableShown = .evResults
            self.refreshTable()
            
        case .evResults:
            let singleStation = bottomSheetDelegate!.getResultsList()[indexPath.row]
            self.pass2detail(evStation2Detail: singleStation)
            
        case .nearby:
            let singleStation = bottomSheetDelegate!.getNearbyList()[indexPath.row]
            self.pass2detail(evStation2Detail: singleStation)
            
        case .favourites:
            let singleStation = bottomSheetDelegate!.getFavouritesList()[indexPath.row]
            self.pass2detail(evStation2Detail: singleStation)
        case .recentSearch:
            let recentClicked = bottomSheetDelegate!.fetchedRecents()[indexPath.row]
            let coordinate = CLLocationCoordinate2D(latitude: recentClicked.latitude, longitude: recentClicked.longitude)
            self.searchBar.resignFirstResponder()
            let placemarkName = recentClicked.title
            self.bottomSheetDelegate?.centerMapOnLocation(location: CLLocation(latitude: CLLocationDegrees(coordinate.latitude), longitude: CLLocationDegrees(coordinate.longitude)))
            self.searchBar.isHidden = true
            let resultsLabel = UILabel()
            resultsLabel.text = "Stations Near " + String(describing: placemarkName)
            resultsLabel.sizeToFit()
            resultsLabel.contentMode = .center
            resultsLabel.numberOfLines = 0
            self.navBarTitleText.titleView = resultsLabel
            self.navBarTitle.isHidden = false
            self.bottomSheetDelegate?.getEVapi(conditions: (self.bottomSheetDelegate?.setupConditions(latitude: Float(recentClicked.latitude), longitude: Float(recentClicked.longitude)))!, list2update: .resultsList)
            self.searchBar.text = ""
            tableShown = .evResults
            self.refreshTable()
        }
    }
    
    func highlightedText(_ text: String, inRanges ranges: [NSValue], size: CGFloat) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let regular = UIFont.systemFont(ofSize: size)
        attributedText.addAttribute(NSAttributedString.Key.font, value:regular, range:NSMakeRange(0, text.count))
        
        let bold = UIFont.boldSystemFont(ofSize: size)
        for value in ranges {
            attributedText.addAttribute(NSAttributedString.Key.font, value:bold, range:value.rangeValue)
        }
        return attributedText
    }
}

extension BottomSheetViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension BottomSheetViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableShown = .locationSearch
        self.refreshTable()
        
        if self.searchCompleter.queryFragment.isEmpty {
            tableShown = .recentSearch
            self.refreshTable()
        }
        if searchResults.count == 0{
            tableShown = .recentSearch
            self.refreshTable()
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension BottomSheetViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        if searchText.isEmpty {
            tableShown = .recentSearch
            self.refreshTable()
        }
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}
