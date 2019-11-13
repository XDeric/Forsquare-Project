//
//  ViewController.swift
//  FourSquareProj
//
//  Created by EricM on 11/6/19.
//  Copyright © 2019 EricM. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var food = [Response](){
        didSet{
            collectionOutlet.reloadData()
        }
    }
    var picture = [Responses]()
  
    @IBOutlet weak var foodSearchBar: UISearchBar!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var collectionOutlet: UICollectionView!
    
    let searchRadius: CLLocationDistance = 2000
    var latitude = Double()
    var longitude = Double()
    private let locationManager = CLLocationManager()
    var foodSearchString: String? = nil {
        didSet{
            //mapView.addAnnotations(food.filter{$0.hasValidCoordinates})
        }
    }
    var locationSearchString: String? = nil {
        didSet{
            
        }
    }
    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let foods = food[indexPath.row]
        guard let cell = collectionOutlet.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as? SearchCollectionViewCell else{return UICollectionViewCell()}
        
        APIImageManager.shared.getCategories(venueID: foods.groups[0].items[0].venue.id) { (result) in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let data):
                self.picture = [data]
            }
        }
        let url = "\(picture[indexPath.row].photos.items[0].itemPrefix)" + "500x500" + "\(picture[indexPath.row].photos.items[0].suffix)"
        
        ImageHelper.shared.getImage(urlStr: url) { (result) in
            switch result{
                case .failure(let error):
                    print(error)
                case .success(let image):
                    cell.searcImageOutlet.image = image
                }
            }
        return cell
    }
    
    //MARK: SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let foodText = foodSearchBar.text, foodText != "" {
            collectionOutlet.isHidden = false
        } else {
            collectionOutlet.isHidden = true
        }
        foodSearchString = foodSearchBar.text
        locationSearchString = locationSearchBar.text
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        foodSearchBar.showsCancelButton = true
        locationSearchBar.showsCancelButton = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        foodSearchBar.showsCancelButton = false
        foodSearchBar.resignFirstResponder()
        
        locationSearchBar.showsCancelButton = false
        locationSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         //create activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        locationSearchBar.resignFirstResponder()
        
        //search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = self.locationSearchString
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            activityIndicator.stopAnimating()
            
            if response == nil {
                print(error)
            } else {
                //remove annotations
                let annotations = self.mapOutlet.annotations
                self.mapOutlet.removeAnnotations(annotations)
                
                //get data
                self.latitude = response?.boundingRegion.center.latitude ?? 40.7243
                self.longitude = response?.boundingRegion.center.longitude ?? -74.0018
                
                let newAnnotation = MKPointAnnotation()
                newAnnotation.title = self.locationSearchString
                newAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                self.mapOutlet.addAnnotation(newAnnotation)
                
                //to zoom in the annotation
                let coordinateRegion = MKCoordinateRegion.init(center: newAnnotation.coordinate, latitudinalMeters: self.searchRadius * 2.0, longitudinalMeters: self.searchRadius * 2.0)
                self.mapOutlet.setRegion(coordinateRegion, animated: true)
            }
        }
    }
    
    
    //MARK: other Stuff
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadLatLong()
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodSearchBar.delegate = self
        locationSearchBar.delegate = self
        locationManager.delegate = self
        mapOutlet.delegate = self
        // Do any additional setup after loading the view.
    }
    
//    func loadLatLong(){
//        LocaleHelper.shared.getLatLong(fromAddress: locationSearchString ?? "New York") { (result) in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let lat, let long, let name):
//                self.latitude = lat
//                self.longitude = long
//            }
//        }
//    }
    
    func loadData(){
        APIManager.shared.getCategories(search: foodSearchString ?? "chinese dumplings", lat: latitude, long: longitude) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let food):
                self.food = [food]
            }
        }
    }
    
    
    


}
