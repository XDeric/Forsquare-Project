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
    
    func getCategories(search: String, completionHandler: @escaping (Result<[Card], AppError>) -> Void) {
        let urlStr = "https://api.foursquare.com/v2/venues/explore?client_id=\(Secrets.clientId)&client_secret=\(Secrets.clientSecret)&v=20180323&limit=15&ll=40.7243,-74.0018&query=\(search)"


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
                     let FlashCardWrapper = try JSONDecoder().decode(Location.self, from: data)
                    completionHandler(.success(FlashCardWrapper.cards))
                 } catch {
                     completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                 }
             }
         }
     }
}
