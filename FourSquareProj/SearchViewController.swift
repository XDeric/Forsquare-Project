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
  
    @IBOutlet weak var foodSearchBar: UISearchBar!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var collectionOutlet: UICollectionView!
    
    
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
        food.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return UICollectionViewCell()
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
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodSearchBar.delegate = self
        locationSearchBar.delegate = self
        locationManager.delegate = self
        mapOutlet.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func loadLatLong(){
        LocaleHelper.shared.getLatLong(fromAddress: locationSearchString ?? "New York") { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let lat, let long, let name):
                self.latitude = lat
                self.longitude = long
            }
        }
    }
    
    func loadData(){
        
    }


}
