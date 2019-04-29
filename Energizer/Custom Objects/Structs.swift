//
//  APIstructs.swift
//  GetAPI
//
//  Created by Michalis Neophytou on 01/02/2019.
//  Copyright © 2019 Michalis Neophytou. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import SwiftTheme

struct myMKLocalSearchCompletion: Codable {
    var title: String
    var subtitle: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var timestamp: TimeInterval
}

struct staticMenuCellInfo{
    var label: String
    var icon: UIImage?
    let ID: Int
    let colour: UIColor
}

struct Filter: Equatable{
    var WithinRangeOnly: Bool
    var EVChargerTypeOnly: Bool
    var PriceMax: Int //in pence
    var IsOperationalNow: Bool
    var FastestChargersOnly: Bool
    var minPower: Float
    var minQuantity: Int
}

struct myCarInfo: Codable{
    var carModel: String?
    var carColour: String?
    var carImage: Int?
    var IDinList: Int?
    var isEV: Bool?
    var chargeRemainingRange: Float?
    var chargeRemainingPercentage: Float?
    var milesRemaining: Float?
    var kmRemaining: Float?
    var kWhTotalConsumption: Float?
    var kWhAverageConsumption: Float?
    var milage: Float?
    var dateLastCharge: String?
    var sinceDateLastCharge: String?
}


struct DataProviderStatusType: Codable{
    let IsProviderEnabled: Bool?
    let ID: Int?
    let Title: String?
}

struct DataProvider: Codable{
    let WebsiteURL: String?
    let Comments: String?
    let DataProviderStatusType: DataProviderStatusType?
    let IsRestrictedEdit: Bool?
    let IsOpenDataLicensed: Bool?
    let IsApprovedImport: Bool?
    let License: String?
    let DateLastImported: String?
    let ID: Int?
    let Title: String?
}

struct OperatorInfo: Codable{
    let WebsiteURL: String?
    let Comments: String?
    let PhonePrimaryContact: String?
    let PhoneSecondaryContact: String?
    let IsPrivateIndividual: Bool?
    var AddressInfo: String?
    let BookingURL: String?
    let ContactEmail: String?
    let FaultReportEmail: String?
    let IsRestrictedEdit: Bool?
    let ID: Int?
    let Title: String?
}

struct UsageType: Codable{
    let IsPayAtLocation: Bool?
    let IsMembershipRequired: Bool?
    let IsAccessKeyRequired: Bool?
    let ID: Int?
    let Title: String?
}

struct Country: Codable{
    let ISOCode: String?
    let ContinentCode: String?
    let ID: Int?
    let Title: String?
}

struct AddressInfo: Codable{
    let ID: Int
    let Title: String?
    let AddressLine1: String?
    let AddressLine2: String?
    let Town: String?
    let StateOrProvince: String?
    let Postcode: String?
    let CountryID: Int?
    let Country: Country?
    let Latitude: Float?
    let Longitude: Float?
    let ContactTelephone1: String?
    let ContactTelephone2: String?
    let ContactEmail: String?
    let AccessComments: String?
    let RelatedURL: String?
    var Distance: Float
    var DistanceUnit: Int?
}

struct StatusType: Codable{
    let IsOperational: Bool?
    let IsUserSelectable: Bool?
    let ID: Int?
    let Title: String?
}

struct SubmissionStatus: Codable{
    let IsLive:Bool?
    let ID: Int?
    let Title: String?
}

struct ConnectionType: Codable{
    let FormalName: String?
    let IsDiscontinued: Bool?
    let IsObsolete: Bool?
    let ID: Int?
    let Title: String?
}

struct Level: Codable{
    let Comments: String?
    let IsFastChargeCapable: Bool?
    let ID: Int?
    let Title: String?
}

struct CurrentType: Codable{
    let Description: String?
    let ID: Int?
    let Title: String?
}

struct Connection: Codable{
    let ID: Int?
    let ConnectionTypeID: Int?
    let ConnectionType: ConnectionType?
    let Reference: String?
    let StatusTypeID: Int?
    let StatusType: StatusType?
    let LevelID: Int?
    let Level:Level?
    let Amps: Int?
    let Voltage: Int?
    let PowerKW: Float?
    let CurrentTypeID: Int?
    let CurrentType: CurrentType?
    let Quantity: Int?
    let Comments: String?
}

struct User: Codable {
    let ID: Int?
    let IdentityProvider: String?
    let Identifier: String?
    let CurrentSessionToken: Int?
    let Username: String?
    let Profile: String?
    let Location: String?
    let WebsiteURL: String?
    let ReputationPoints: Int?
    let Permissions: String?
    let PermissionsRequested:Bool?
    let DateCreated: String?
    let DateLastLogin: String?
    let IsProfilePublic: Bool?
    let IsEmergencyChargingProvider: Bool?
    let IsPublicChargingProvider: Bool?
    let Latitude:Float?
    let Longitude: Float?
    let EmailAddress: String?
    let EmailHash: String?
    let ProfileImageURL: URL?
    let IsCurrentSessionTokenValid: Bool?
    let APIKey: Int?
    let SyncedSettings: Int?
}

struct MediaItem: Codable {
    let ID: Int?
    let ChargePointIDL: Int?
    let ItemURL: URL?
    let ItemThumbnailURL: URL?
    let Comment: String?
    let IsEnabled: Bool?
    let IsVideo: Bool?
    let IsFeaturedItem: Bool?
    let IsExternalResource: Bool?
    let MetadataValue: String?
    let User: User?
    let DateCreated: String?
}

struct MetadataFieldOption: Codable{
    let MetadataFieldID: Int?
    let ID: Int?
    let Title: String?
}

struct MetadataValue: Codable{
    let ID: Int?
    let MetadataFieldID: Int?
    let ItemValue: String?
    let MetadataFieldOption: MetadataFieldOption?
    let MetadataFieldOptionID: String?
}

struct ChargePoint: Codable{
    let ID: Int
    let UUID: String
    let ParentChargePointID: String?
    let DataProviderID: Int?
    let DataProvider: DataProvider?
    let DataProvidersReference: String?
    let OperatorID: Int?
    let OperatorInfo: OperatorInfo?
    let OperatorsReference: String?
    let UsageTypeID: Int?
    var UsageType: UsageType?
    var UsageCost: String?
    var AddressInfo:AddressInfo
    var NumberOfPoints: Int?
    let GeneralComments: String?
    let DatePlanned: String?
    let DateLastConfirmed: String?
    let StatusTypeID: Int?
    let StatusType: StatusType?
    let DateLastStatusUpdate: String?
    let DataQualityLevel: Int?
    let DateCreated: String?
    let SubmissionStatusTypeID: Int?
    let SubmissionStatus:SubmissionStatus?
    let UserComments: String? = nil
    let PercentageSimilarity: String?
    let Connections: [Connection]?
    let MediaItems: [MediaItem]?
    let MetadataValues: [MetadataValue]?
    let IsRecentlyVerified: Bool?
    let DateLastVerified: String?
}
