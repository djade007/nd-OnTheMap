//
//  LocationResultViewController.swift
//  OnMap
//
//  Created by Olajide Afeez on 02/08/2021.
//

import UIKit
import MapKit


class LocationResultViewController: UIViewController, MKMapViewDelegate {

    var geoData: GeoData!

    var previousVC: AddLocationViewController!


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPinOnMap()
    }

    
    @IBAction func submitButtonPressed(_ sender: Any) {
        submit()
    }


    // MARK: Helper methods
    func showPinOnMap() {

        let annotation = MKPointAnnotation()

        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(geoData.latitude), longitude: (geoData.longitude))
        annotation.title = geoData.mapString
        annotation.subtitle = geoData.mediaUrl

        // show pin on map
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }

    func submit() {
        startLoading(true)

        // Prompt user before overwriting existing data
        if ApiClient.Auth.location != nil {
            let alertVC = UIAlertController(title: "Would you like to update existing data?", message: "Click UPDATE to proceed or NEW POST to create a new record.", preferredStyle: .alert)

            alertVC.addAction(UIAlertAction(title: "UPDATE", style: .default, handler: {
                (action) in
                ApiClient.updateLocation(geoLocation: self.geoData, completion: self.handlePostResponse(success:errorMessage:))
            }))

            alertVC.addAction(UIAlertAction(title: "NEW POST", style: .default, handler: { (action) in
                ApiClient.saveLocation(geoLocation: self.geoData, completion: self.handlePostResponse(success:errorMessage:))
            }))

            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in
                self.startLoading(false)
            }))

            self.present(alertVC, animated: true, completion: nil)

        } else {
            ApiClient.saveLocation(geoLocation: self.geoData!, completion: self.handlePostResponse(success:errorMessage:))
        }
    }

    func startLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        saveButton.isEnabled = !loading
    }

    func handlePostResponse(success: Bool, errorMessage: String?) {
        self.startLoading(false)

        if success {
            // return to previous screen
            self.previousVC?.posted = true
            self.navigationController?.popViewController(animated: true)

        } else {
            ErrorHandlerService.showAlert(on: self, failure: .submissionFailed, body: errorMessage)
        }
    }
}

extension LocationResultViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "locationPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView != nil {
            pinView?.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return pinView
    }
}
