//
//  AddLocationController.swift
//  OnMap
//
//  Created by Olajide Afeez on 02/08/2021.
//

import UIKit
import CoreLocation


// MARK: AddLocationViewController: UIViewController

class AddLocationViewController: UIViewController {

    // Indicates if the searched location was posted on the next view.
    var posted: Bool = false

    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var linkTextfield: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    // MARK: Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Returns to the homepage if location was posted
        if posted {
            self.posted = false
            self.dismiss(animated: true, completion: nil)
        }
    }


    // MARK: Actions
    @IBAction func searchButtonPressed(_ sender: Any) {
        startLoading(true)
        posted = false
        
        CLGeocoder().geocodeAddressString(locationTextfield.text ?? "", in: nil, completionHandler: handleGeocodeResponse(placemarks:error:))
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    // MARK: Helper methods

    func startLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        locationTextfield.isEnabled = !loading
        linkTextfield.isEnabled = !loading
        searchButton.isEnabled = !loading
    }

    func handleGeocodeResponse(placemarks: [CLPlacemark]?, error: Error?) {
        DispatchQueue.main.async {
            self.startLoading(false)
            
            if let placemarks = placemarks,
                let location = placemarks.first?.location {
                // Instantiate and present SubmitLocationViewController
                let resultsVc = self.storyboard?.instantiateViewController(identifier: "LocationResultViewController") as! LocationResultViewController
                resultsVc.geoData = GeoData(mapString: self.locationTextfield?.text ?? "", mediaUrl: self.linkTextfield?.text ?? "", latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                resultsVc.previousVC = self
                
                self.navigationController!.pushViewController(resultsVc, animated: true)
            } else {
                ErrorHandlerService.showAlert(on: self, failure: .locationNotFound, body: error?.localizedDescription)
            }
        }
    }
}
