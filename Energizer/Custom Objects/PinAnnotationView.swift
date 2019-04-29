import MapKit

private let clusteringPinIdentifier = "clusterIdentifier"

class RedAnnotationMarker: MKMarkerAnnotationView {
    static let ReuseID = "redAnnotation"
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = clusteringPinIdentifier
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor.init(named: "pinRed")
        glyphImage = UIImage.init(named: "chargingStationIcon")
    }
}

class AmberAnnotationMarker: MKMarkerAnnotationView {
    static let ReuseID = "amberAnnotation"
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = clusteringPinIdentifier
        self.canShowCallout = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// - Tag: DisplayConfiguration
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor.init(named: "pinAmber")
        glyphImage = UIImage.init(named: "chargingStationIcon")
    }
}

class GreenAnnotationMarker: MKMarkerAnnotationView {
    static let ReuseID = "greenAnnotation"
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = clusteringPinIdentifier
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor.init(named: "pinGreen")
        glyphImage = UIImage.init(named: "chargingStationIcon")
    }
}

class FavouriteAnnotationMarker: MKMarkerAnnotationView {
    static let ReuseID = "favouriteAnnotation"
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = nil
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor.init(named: "FavouritesAccent")
        glyphImage = UIImage.init(named: "heartIcon")
    }
}

