//
//  Classes.swift
//  Energizer
//
//  Created by Michalis Neophytou on 08/04/2019.
//

import Foundation
import UIKit
import MapKit

class routeWithStation: UIButton{
    var chargepoint: ChargePoint?
}

class faveButton: UIButton{
    var chargepoint: ChargePoint?
}

class POIannotation: NSObject, MKAnnotation {
    let title: String?
    let type: Int
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, type: Int, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.type = type
        self.coordinate = coordinate
        super.init()
    }
}

class evStationAnnotation: NSObject, MKAnnotation {
    enum colour{
        case red
        case amber
        case green
    }
    let colour: colour
    let title: String?
    let listInID: Int
    let noOfConnectors: Int
    let coordinate: CLLocationCoordinate2D
    let compatible: Bool
    
    init(title: String, listInID: Int, noOfConnectors: Int, coordinate: CLLocationCoordinate2D, compatible:Bool, colour: colour) {
        self.title = title
        self.listInID = listInID
        self.noOfConnectors = noOfConnectors
        self.coordinate = coordinate
        self.compatible = compatible
        self.colour = colour
        super.init()
    }
    
    var whatID: Int? {
        return listInID
    }
}
