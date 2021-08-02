//
//  ErrorHandlerService.swift
//  OnMap
//
//  Created by Olajide Afeez on 01/08/2021.
//

import UIKit

class ErrorHandlerService {
    enum Errors {
        case loginFailed
        case invalidUrl
        case dataDownloadFailed
        case userDownloadFailed
        case locationNotFound
        case submissionFailed
        case internalError
        
        var explain: String {
            switch self {
            case .loginFailed:
                return "Login failed"
            case .invalidUrl:
                return "Invalid URL"
            case .dataDownloadFailed:
                return "Failed to download data"
            case .userDownloadFailed:
                return "User record not found"
            case .locationNotFound:
                return "Location not found"
            case .submissionFailed:
                return "Failed to submit"
            case .internalError:
                return "An internal error, please try again later."
            }
        }
    }
    
    class func showAlert(on: UIViewController, failure: Errors, body: String? = "An error has occurred") {
        let alertVC = UIAlertController(title: failure.explain, message: body, preferredStyle: .alert)

        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        on.present(alertVC, animated: true, completion: nil)
    }
    
}
