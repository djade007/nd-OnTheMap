//
//  SessionResponse.swift
//  OnMap
//
//  Created by Olajide Afeez on 01/08/2021.
//

import Foundation

struct SessionResponse: Codable {
    let account: AccountInfo?
    let session: SessionInfo
}
