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
    
    var food = [LocationClass](){
        didSet{
            collectionOutlet.reloadData()
            print(food)
        }
    }
    var picture = [Item]() {
        didSet{
            collectionOutlet.reloadData()
        }
    }
    
    @IBOutlet weak var foodSearchBar: UISearchBar!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var collectionOutlet: UICollectionView!
    
    let searchRadius: CLLocationDistance = 2000
    var latitude = 40.7243
    var longitude = -74.0018
    private let locationManager = CLLocationManager()
    
    var foodSearchString: String? = nil {
        didSet{
            loadData()
        }
    }
    var locationSearchString: String? = nil {
        didSet{
            
        }
    }
    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("yoooo\(food.count)")
        return food.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 414, height: 128)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pic = food[indexPath.row]
        guard let cell = collectionOutlet.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as? SearchCollectionViewCell else{return UICollectionViewCell()}
//        let url = "\(pic.prefix)147x128\(pic.suffix)"
        ImageHelper.shared.getImage(urlStr: "") { (result) in
            DispatchQueue.main.async {
                switch result{
                case .failure(let error):
                    print(error)
                    cell.searcImageOutlet.image = UIImage(named: "noPic")
                case .success(let image):
                    cell.searcImageOutlet.image = image
                }
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
        //        foodSearchString = foodSearchBar.text
        //        locationSearchString = locationSearchBar.text
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
        switch searchBar {
        case foodSearchBar:
            if let foodText = foodSearchBar.text, foodText != "" {
                collectionOutlet.isHidden = false
            } else {
                collectionOutlet.isHidden = true
            }
            foodSearchString = foodSearchBar.text
            locationSearchString = locationSearchBar.text
        default:
            
            
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
                    self.loadData()
                }
            }
        }
    }
    
    
    //MARK: other Stuff
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadLatLong()
        //loadData()
        locationManager.delegate = self
        locationAuthorization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodSearchBar.delegate = self
        locationSearchBar.delegate = self
        mapOutlet.delegate = self
        collectionOutlet.dataSource = self
        collectionOutlet.delegate = self
        mapOutlet.userTrackingMode = .follow
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: Location
    private func locationAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapOutlet.showsUserLocation = true
            locationManager.delegate = self
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("New location: \(locations)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorozation status changed to \(status.rawValue)")
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        //Call a function to get the current location
        default:
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    func loadData(){
        DispatchQueue.main.async {
            
            APIManager.shared.getCategories(search: self.foodSearchString ?? "", lat: self.latitude, long: self.longitude) { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                    print("heeeeee")
                case .success(let food):
                    self.food = food
                    print(":hahahah")
                    food.forEach { (item) in
                        APIImageManager.shared.getImage(venueID: item.id) { (result) in
                            switch result{
                            case .failure(let error):
                                print(error)
                                print("heeeeeed")
                            case .success(let data):
                                print("yooooooo")
                                self.picture = data
                            }
                        }
                    }
                
                }
            }
        }
    }
    
    
    
    
    
}
