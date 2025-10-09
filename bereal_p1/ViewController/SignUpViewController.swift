//
//  SignUpViewController.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 9/29/25.
//

import UIKit
import ParseSwift


class SignUpVIewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var passworldField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let username = usernameField.text,
              let email = EmailField.text,
              let password = passworldField.text,
              let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty
        else {
            showAlertMissedFields()
            return
        }
        
        var newUser = User()
        newUser.username = username
        newUser.password = password
        newUser.email = email
        
        newUser.signup{ [weak self] result in
            switch result{
            case .success(let user):
                print("User signed up successfully: \(user)")
                
                var profile = Profile()
                do {
                    profile.user = try user.toPointer()
                } catch {
                    self?.showAlert(description: error.localizedDescription)
                    print("Error creating user pointer: \(error)")
                    return
                }
                profile.firstName = firstName
                profile.lastName = lastName
                
                profile.save{ result in
                    switch result {
                    case .success(let savedProfile):
                        print("Profile saved: \(profile)")
                        
                        SessionManager.currentProfile = savedProfile
                        
                        NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                    case .failure(let error):
                        print("Error while saving profile: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
                print("Error signing up: \(error)")
            }
        }
    }
    
    private func showAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to sign up", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
    
    private func showAlertMissedFields() {
        let alertController = UIAlertController(title: "Ooppss...", message: "We need all fields filled out iin order to sign you up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
}

