//
//  GetLocationResponse.swift
//  OnMap
//
//  Created by Olajide Afeez on 01/08/2021.
//

import Foundation

struct GetLocationsResponse: Codable {
    let results: [Student]
    
    enum CodingKeys: String, CodingKey {
        case results
    }

}
