//
//  ViewController.swift
//  FourSquareProj
//
//  Created by EricM on 11/6/19.
//  Copyright © 2019 EricM. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController {
  
    @IBOutlet weak var foodSearchBar: UISearchBar!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var collectionOutlet: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}
