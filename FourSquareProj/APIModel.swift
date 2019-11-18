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
import MapKit

struct Location: Codable {
    let response: Venue
}

struct Venue: Codable {
    let venues: [LocationClass]
}

class LocationClass: NSObject, Codable, MKAnnotation {
    let id: String
    let name: String
    let location: Coordinate?
    
    var coordinate: CLLocationCoordinate2D{
       if let lat = location?.lat {
           if let lng = location?.lng{
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
           }
       }
       return CLLocationCoordinate2D()
    }
}

struct Coordinate: Codable{
    let lat: Double
    let lng: Double
    let address: String?
}

final class APIManager {
    private init() {}
    static let shared = APIManager()
    
    func getCategories(search: String,lat:Double ,long: Double, completionHandler: @escaping (Result<[LocationClass], AppError>) -> Void) {
        let urlStr = "https://api.foursquare.com/v2/venues/search?client_id=\(Secrets.clientId)&client_secret=\(Secrets.clientSecret)&v=20191114&limit=2&ll=\(lat),\(long)&query=\(search)"
        //print(urlStr)
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
                    completionHandler(.success(LocationWrapper.response.venues))
                 } catch {
                     completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                 }
             }
         }
     }
}



