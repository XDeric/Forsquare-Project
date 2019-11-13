//
//  ImageManager.swift
//  FourSquareProj
//
//  Created by EricM on 11/11/19.
//  Copyright © 2019 EricM. All rights reserved.
//

import Foundation
import UIKit


struct Images: Codable {
    let response: Responses
}

// MARK: - Response
struct Responses: Codable {
    let photos: Photos
}

// MARK: - Photos
struct Photos: Codable {
    let count: Int
    let items: [Item]
    let dupesRemoved: Int
}

// MARK: - Item
struct Item: Codable {
    let itemPrefix: String
    let suffix: String
    let width, height: Int
}








class ImageHelper {
    
    private init() {}
    static let shared = ImageHelper()

    func getImage(urlStr: String, completionHandler: @escaping (Result<UIImage, AppError>) -> Void) {

        guard let url = URL(string: urlStr) else {
            completionHandler(.failure(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in

            guard error == nil else {
                completionHandler(.failure(.badURL))
                return
            }
            guard let data = data else {
                completionHandler(.failure(.noDataReceived))
                return
            }
            guard let image = UIImage(data: data) else {
                completionHandler(.failure(.notAnImage))
                return
            }
            completionHandler(.success(image))
            

            }.resume()
    }
}

