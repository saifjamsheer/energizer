//
//  Protocols.swift
//  Energizer
//
//  Created by Michalis Neophytou on 08/04/2019.
//

import Foundation
import UIKit
import MapKit

protocol PassFilterProtocol {
    func filterAllData(filter: Filter)
}

protocol BottomSheetDelegate {
    func updateBottomSheet(frame: CGRect)
    func toggleFilterContainer()
    func getCurrentLong() -> Float
    func getCurrentLat() -> Float
    func setupConditions(latitude: Float, longitude: Float) -> String
    func getNearbyStations()
    func getVehicleRange() -> Float
    func getEVapi(conditions: String, list2update: list2Update)
    func getFavouritesList() -> [ChargePoint]
    func getNearbyList() -> [ChargePoint]
    func getResultsList() -> [ChargePoint]
    func centerMapOnLocation(location: CLLocation)
    func fetchedRecents() -> [myMKLocalSearchCompletion]
    func reloadForNetwork(sender: UIBarButtonItem)
}
