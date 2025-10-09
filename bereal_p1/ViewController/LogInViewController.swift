//
//  LogInViewController.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 9/29/25.
//

import UIKit
import ParseSwift

class LogInViewController: UIViewController {
    
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        guard let username = usernameField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !password.isEmpty else {
            showAlertMissedFields()
            return
        }
        
        User.login(username: username, password: password){ [weak self] result in
            switch result {
            case .success(let user):
                print("Successfully Logged In as a user \(user)")

                Task {
                    do {
                        let currentUser = try await User.current()   // це не Optional
                        let userPointer = try currentUser.toPointer()
                        
                        let query = Profile.query("user" == userPointer)
                        let profile = try await query.first()
                        
                        SessionManager.currentProfile = profile
                    } catch {
                        print("Failed to fetch user or profile: \(error)")
                    }
                }

                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
            
        }
        
    }
    
    private func showAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to log in", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
    
    private func showAlertMissedFields() {
        let alertController = UIAlertController(title: "Ooppss...", message: "We need all fields filled out in order to log you in.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
}

