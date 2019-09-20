//
//  ViewController.swift
//  NanoChallange2
//
//  Created by Hai on 18/09/19.
//  Copyright © 2019 Asep Abdaz. All rights reserved.
//

import UIKit
import CoreLocation
import LocalAuthentication
import CloudKit

class ViewController: UIViewController {
    
    let privateDatabase = CKContainer.default().publicCloudDatabase
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(UIDevice.current.name)
        setupNavbar()
        
        setupTableView()
//        setFirstDataGeo()
        retriveData()
    }
    
    func retriveData() {
        let predicate = NSPredicate(value: true)
        // MARK: Apa itu Note
        let query = CKQuery(recordType: "usersRoar", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "nameAccount", ascending: false)]
        let operation = CKQueryOperation(query: query)
        
        userNames.removeAll()
        nameAccount.removeAll()
        emotions.removeAll()
        notes.removeAll()
        lastUpdate.removeAll()
//        recordIDs.removeAll()
        operation.recordFetchedBlock = { record in
            userNames.append(record["userName"]!)
            nameAccount.append(record["nameAccount"]!)
            emotions.append(record["emotions"]!)
            notes.append(record["notes"]!)
            lastUpdate.append(record["lastDate"]!)
            
            // MARK: Important
            // this use for relation table data
//            recordIDs.append(record.recordID)
            
        }
        
        operation.queryCompletionBlock = { cursor, error in
            DispatchQueue.main.async {
                print("Titles: \(userNames)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                // MARK: Important
                // this use for relation table data
//                print("RecordIDs: \(recordIDs)")
            }
        }
        
        privateDatabase.add(operation)
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        DispatchQueue.main.async {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    func setUpGeofenceForPlayaGrandeBeach() {
        let geofenceRegionCenter = CLLocationCoordinate2DMake(-6.302126,106.652184);
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 400, identifier: "DeveloperAcademy");
        geofenceRegion.notifyOnExit = true;
        geofenceRegion.notifyOnEntry = true;
        self.locationManager.startMonitoring(for: geofenceRegion)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    func setupNavbar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.white
        
        searchController.searchBar.barStyle = .blackTranslucent
        //searchController.definesPresentationContext = true
        
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    
    func setFirstDataGeo() {
        let coordinate = CLLocationCoordinate2DMake(-6.302060, 106.652151);
        let radius = 100.0
        let identifier = NSUUID().uuidString
        let note = "Hai how do you feel today"
        let eventType: Geotification.EventType = .onEntry
        
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        
        add(geotification)
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
    
    func region(with geotification: Geotification) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func startMonitoring(geotification: Geotification) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
            showAlert(withTitle:"Warning", message: message)
        }
        
        let fenceRegion = region(with: geotification)
        locationManager.startMonitoring(for: fenceRegion)
    }
    func add(_ geotification: Geotification) {
        geotifications.append(geotification)
    }
    
    var geotifications: [Geotification] = []
    func saveAllGeotifications() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(geotifications)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
        } catch {
            print("error encoding geotifications")
        }
    }
    var dataUser = ["Asep Abdaz","Syamsul Falah"]
//    var notes = ["hari ini jangan ganggu aku dulu","nanti makan bareng, gw yg bayar"]
    var color: [UIColor] = [.gray, .green]
    
}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else { return UITableViewCell() }
        cell.userAccountLabel.text = nameAccount[indexPath.row]
        cell.notesLabel.text = notes[indexPath.row]
        cell.statusUiView.backgroundColor = color[indexPath.row]
        return cell
    }
    
    
}

