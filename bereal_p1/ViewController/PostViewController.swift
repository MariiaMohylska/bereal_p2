//
//  PostViewController.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 9/30/25.
//

import Foundation
import UIKit
import PhotosUI
import ParseSwift
import CoreLocation

class PostViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    
    private var pickedImage: UIImage?
    private var location: CLLocation?
    var currentLocation: CLLocation?
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isHidden = false
        } else {
            print("❌📷 Camera not available")
            cameraButton.isHidden = true
            return
        }
    }
    
    @IBAction func onViewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    @IBAction func postShareTapped(_ sender: Any) {
        
        guard let image = pickedImage,
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        let imageFile = ParseFile(name: "image.jpeg", data: imageData)
        
        var post = Post()
        
        post.imageFile = imageFile
        post.caption = captionTextField.text
        
        do{
            if let loc = location{
                post.location = try ParseGeoPoint(location: loc)
            }
        } catch(let error) {
            print("Error while adding location: \(error)")
        }
        
            post.user = SessionManager.currentProfile
            post.save{ [weak self] result in
                switch result {
                case .success(let post):
                    
                    SessionManager.currentProfile?.lastUpdated = Date()
                    SessionManager.currentProfile?.save{ result in
                        switch result {
                        case .success(let profile):
                            print("Profile updated! \(profile)")
                        case .failure(let error):
                            print("Failed to update a user: \(error.localizedDescription)")
                        }
                        
                    }
                    DispatchQueue.main.async {
                        print("Post Saved! \(post)")
                        
                        self?.navigationController?.popViewController(animated: true)
                    }
                case . failure(let error) :
                    print(error)
                    self?.showAlert(description: error.localizedDescription)
                }
                
            }
    }
        
    
    @IBAction func selectPhotoTapped(_ sender: Any) {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    DispatchQueue.main.async {
                        self?.presentGoToSettingAlert()
                    }
                }
            }
        } else {
            self.presentImagePicker()
        }
    }
    
    private func presentImagePicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    private func presentGoToSettingAlert() {
        let alertController = UIAlertController(
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert
        )
        
        let settingAction = UIAlertAction(
            title: "Settings", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        
        alertController.addAction(settingAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func takePhotoTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {return}
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else {
                self?.showAlert()
                return
            }
            
            if let error = error {
                self?.showAlert(description: error.localizedDescription)
                return
            } else {
                DispatchQueue.main.async {
                    self?.postImageView.image = image
                    self?.pickedImage = image
                    
                    if let assetId = results.first?.assetIdentifier {
                        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                        if let asset = assets.firstObject {
                            self?.location = asset.location
                        }
                    }
                }
            }
        }
    }
}


extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("Unable to get image")
            return
        }

        
        postImageView.image = image
        pickedImage = image
        
        if let location = currentLocation {
            self.location = location
        }
    }
}

extension PostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            currentLocation = locations.last
        }
}
