//
//  APIModel.swift
//  FourSquareProj
//
//  Created by EricM on 11/7/19.
//  Copyright © 2019 EricM. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct Location: Codable {
    let response: Response
}

struct Response: Codable {
    let headerLocation, headerFullLocation, headerLocationGranularity, query: String
    let totalResults: Int
    let suggestedBounds: SuggestedBounds
    let groups: [Group]
}

struct GroupItem: Codable {
    let reasons: Reasons
    let venue: Venue
    let referralID: String
}

struct Reasons: Codable {
    let count: Int
}

// MARK: - Group
struct Group: Codable {
    let type, name: String
    let items: [GroupItem]
    let count: Int?
}

struct SuggestedBounds: Codable {
    let ne, sw: Ne
}
// MARK: - Ne
struct Ne: Codable {
    let lat, lng: Double
}

struct Venue: Codable {
    let name: String
    let location: LocationClass
    let delivery: Delivery?
}

struct Delivery: Codable {
    let id: String
    let url: String
}

struct LocationClass: Codable {
    let address: String
    let lat, lng: Double
    let distance: Int
    let postalCode: String
    let city: String
    let state: String
    let country: String
    let formattedAddress: [String]
}

final class APIManager {
    private init() {}
    static let shared = APIManager()
    
    func getCategories(search: String,lat:Double ,long: Double, completionHandler: @escaping (Result<Response, AppError>) -> Void) {
        let urlStr = "https://api.foursquare.com/v2/venues/explore?client_id=\(Secrets.clientId)&client_secret=\(Secrets.clientSecret)&v=20180323&limit=15&ll=40.7243\(lat),-74.0018\(long)&query=\(search)"
        
         guard let url = URL(string: urlStr) else {
             completionHandler(.failure(.badURL))
             return
         }
         
         NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
             switch result {
             case .failure(let error) :
                 completionHandler(.failure(error))
             case .success(let data):
                 do {
                     let LocationWrapper = try JSONDecoder().decode(Location.self, from: data)
                    completionHandler(.success(LocationWrapper.response))
                 } catch {
                     completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                 }
             }
         }
     }
}









enum LocationFetchingError: Error {
    case error(Error)
    case noErrorMessage
}

class LocaleHelper {
    private init() {}
    
    static let shared = LocaleHelper()
    
    func getLatLong(fromAddress address: String, completionHandler: @escaping (Result<(lat: Double, long: Double, name:String), LocationFetchingError>) -> Void) {
        let geocoder = CLGeocoder()
        DispatchQueue.global(qos: .userInitiated).async {
            geocoder.geocodeAddressString(address){(placemarks, error) -> Void in
                DispatchQueue.main.async {
                    if let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate, let name = placemark.locality  {
                        print(name)
                        completionHandler(.success((coordinate.latitude, coordinate.longitude, name)))
                    } else {
                        let locationError: LocationFetchingError
                        if let error = error {
                            locationError = .error(error)
                        } else {
                            locationError = .noErrorMessage
                        }
                        completionHandler(.failure(locationError))
                    }
                }
            }
        }
    }
}
