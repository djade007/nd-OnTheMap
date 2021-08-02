//
//  ViewController.swift
//  OnMap
//
//  Created by Olajide Afeez on 31/07/2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender:Any) {
        if !validateInput() {
            return;
        }
        
        startLoading(true)

        ApiClient.login(username: emailTextfield.text ?? "", password: passwordTextfield.text ?? "", completion: self.handleLoginResponse(success:errorMessage:))
    }
    
    
    func handleLoginResponse(success: Bool, errorMessage: String?) {
        
        if success {
            // get user data after login
            ApiClient.getUserData(completion: handleUserDataResponse(success:errorMessage:))
        } else {
            startLoading(false)
            ErrorHandlerService.showAlert(on: self, failure: .loginFailed, body: errorMessage)
        }
    }
    
    func handleUserDataResponse(success: Bool, errorMessage: String?) {
        if success {
            self.performSegue(withIdentifier: "Home", sender: nil)
        } else {
            ErrorHandlerService.showAlert(on: self, failure: .userDownloadFailed, body: errorMessage!)
        }
    }
    
    func validateInput() -> Bool {
        if emailTextfield.text?.isEmpty == true {
            ErrorHandlerService.showAlert(on: self, failure: .loginFailed, body: "Please type your email")
            return false
        }
        
        if passwordTextfield.text?.isEmpty == true {
            ErrorHandlerService.showAlert(on: self, failure: .loginFailed, body: "Please input your password")
            return false
        }
        return true
    }
    
    func startLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        emailTextfield.isEnabled = !loading
        passwordTextfield.isEnabled = !loading
        loginButton.isEnabled = !loading
    }
    
    @IBAction func visitSignup(_ sender:Any) {
        if let url = URL(string: "https://auth.udacity.com/sign-up") {
            UIApplication.shared.open(url)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Show homepage in full screen mode
        segue.destination.modalPresentationStyle = .fullScreen
    }


}

