//
//  LocationsViewController.swift
//  OnMap
//
//  Created by Olajide Afeez on 01/08/2021.
//

import UIKit

class LocationsViewController: UITableViewController {
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!


    // MARK: Life cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // only download data only if not available
        if !MapService.students.isEmpty {
            self.tableView.reloadData()
        } else {
            ApiClient.getLocations(completion: self.handleDownloadResponse(success:errorMessage:))
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        ApiClient.getLocations(completion: self.handleDownloadResponse(success:errorMessage:))
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "addFromList", sender: nil)
    }

    @IBAction func logoutButtonPressed(_ sender: Any) {

        // Delete user session
        ApiClient.deleteSession { (success, error) in
            
            // Clear data in app and destruct backend object
            MapService.students = []
            
            self.dismiss(animated: true, completion: nil)
        }
    }


    // MARK: UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapService.students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = MapService.students[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)

        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaUrl
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = MapService.students[(indexPath as NSIndexPath).row]
        guard let url = URL(string: location.mediaUrl) else {
            ErrorHandlerService.showAlert(on: self, failure: .invalidUrl, body: "improper url format")
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (success) in
            if !success {
                DispatchQueue.main.async {
                    ErrorHandlerService.showAlert(on: self, failure: .invalidUrl, body: "Unable to open url")
                }
            }
        }
    }


    // MARK: callback helpers

    func handleDownloadResponse(success: Bool, errorMessage: String?) {
        if success {
            self.tableView.reloadData()
        } else {
            ErrorHandlerService.showAlert(on: self, failure: .dataDownloadFailed, body: errorMessage!)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Show homepage in full screen mode
        segue.destination.modalPresentationStyle = .fullScreen
    }
}
