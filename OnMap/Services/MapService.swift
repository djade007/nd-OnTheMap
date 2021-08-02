//
//  MapService.swift
//  OnMap
//
//  Created by Olajide Afeez on 01/08/2021.
//

import UIKit
import MapKit


class MapService {
    
    static var students = [Student]()

    static var mapAnnotations: [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        
        // create a MKPointAnnotation object for all students
        for student in MapService.students {
            let latitude = CLLocationDegrees(student.latitude)
            let longitude = CLLocationDegrees(student.longitude)

            let annotation = MKPointAnnotation()
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaUrl
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            annotations.append(annotation)
        }
        
        return annotations
    }

    static var userLocations: [Student] {
        if ApiClient.Auth.userKey == "" {
            return []
        } else {
            return MapService.students.filter { (item) -> Bool in
                return item.uniqueKey == ApiClient.Auth.userKey
            }
        }
    }

}
