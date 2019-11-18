//
//  TableListViewController.swift
//  FourSquareProj
//
//  Created by EricM on 11/17/19.
//  Copyright © 2019 EricM. All rights reserved.
//

import UIKit

class TableListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var venues: [LocationClass]?
        
        @IBOutlet weak var tableViewOutlet: UITableView!
        override func viewDidLoad() {
            super.viewDidLoad()
            tableViewOutlet.delegate = self
            tableViewOutlet.dataSource = self
            tableViewOutlet.reloadData()
        }
    }

    // MARK: - UITableViewDelegate Extension
    extension ResultListVC: UITableViewDelegate, UITableViewDataSource{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return venues!.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = resultTable.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ResultCell
            let data = venues![indexPath.row]
            cell.venueName.text = data.name
            cell.venueImage.image = UIImage(named: "noPic")
            return cell
        }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 150
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
             let detailVc = storyboard?.instantiateViewController(identifier: "detailVc")as! VenueDetailVc
             detailVc.venue = venues![indexPath.row]
             self.navigationController?.pushViewController(detailVc, animated: true)
        }

}
