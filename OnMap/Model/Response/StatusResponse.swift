//
//  StatusResponse.swift
//  OnMap
//
//  Created by Olajide Afeez on 01/08/2021.
//

import Foundation

struct StatusResponse: Codable {
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code = "status"
        case message = "error"
    }
}
