//
//  MapViewController.swift
//  OnMap
//
//  Created by Olajide Afeez on 01/08/2021.
//

import UIKit
import MapKit

// MARK: MapViewController: UIViewController, MKMapViewDelegate
class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Download data only if it is not available
        if !MapService.students.isEmpty {
            self.mapView.addAnnotations(MapService.mapAnnotations)
        } else {
            ApiClient.getLocations(completion: self.handleDownloadResponse(success:errorMessage:))
        }
    }


    // MARK: Actions

    @IBAction func refreshButtonPressed(_ sender: Any) {

        ApiClient.getLocations(completion: self.handleDownloadResponse(success:errorMessage:))

    }

    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "addFromMap", sender: nil)
    }

    @IBAction func logoutButtonPressed(_ sender: Any) {

        // Delete user session
        ApiClient.deleteSession { (success, error) in
            // Clear data in app and destruct backend object
            MapService.students = []

            self.dismiss(animated: true, completion: nil)
        }
    }
    

    // MARK: MKMapView delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView,
           let url = URL(string: (view.annotation?.subtitle ?? "")!) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                if !success {
                    DispatchQueue.main.async {
                        ErrorHandlerService.showAlert(on: self, failure: .invalidUrl, body: "Can not open the url.")
                    }
                }
            }
        } else {
            ErrorHandlerService.showAlert(on: self, failure: .invalidUrl, body: "Invalid url fomat")
        }
    }


    // MARK: Helper and callback methods

    func handleDownloadResponse(success: Bool, errorMessage: String?) {
        if success {
            // Remove former annotations and load freshly downloaded map annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(MapService.mapAnnotations)
        } else {
            ErrorHandlerService.showAlert(on: self, failure: .dataDownloadFailed, body: errorMessage!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.modalPresentationStyle = .fullScreen
    }
}
