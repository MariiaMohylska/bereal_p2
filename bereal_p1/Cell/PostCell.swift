//
//  PostCell.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 9/30/25.
//
import UIKit
import Alamofire
import AlamofireImage
import ParseSwift
import CoreLocation

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postInfo: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    
    private var imageDataRequest: DataRequest?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImage.image = nil
        imageDataRequest?.cancel()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postImage.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        super.awakeFromNib()

        profileImage.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        postInfo.translatesAutoresizingMaskIntoConstraints = false
        postImage.translatesAutoresizingMaskIntoConstraints = false
                captionLabel.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    // Avatar
                    profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                    profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                    profileImage.widthAnchor.constraint(equalToConstant: 40),
                    profileImage.heightAnchor.constraint(equalToConstant: 40),

                    // Username
                    userName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                    userName.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
                    userName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

                    // Location / time
                    postInfo.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 4),
                    postInfo.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
                    postInfo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

                    // Post image
                    postImage.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
                    postImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    postImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    postImage.heightAnchor.constraint(equalTo: postImage.widthAnchor), // квадратна або змінна

                    // Caption
                    captionLabel.topAnchor.constraint(equalTo: postImage.bottomAnchor, constant: 8),
                    captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                    captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                    captionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
                ])
    }
    
    func configure(with post: Post) {
        if let user = post.user {
            userName.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
        }
        
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    self?.postImage.image = image
                case .failure(let error):
                    print("Error fetching image: \(error.localizedDescription)")
                    break
                }
                
            }
        }
        
        captionLabel.text = post.caption
        
//        if let coords = post.location?.toCLLocationCoordinate2D,
//           let createdAt = post.createdAt {
//            
//            getLocationString(from: coords) { place in
//                let timeString = self.timeAgo(from: createdAt)
//                let final = "\(place) * \(timeString)"
//                self.postInfo.text = final
//            }
//        }
        
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        let weeks = Int(interval / 604800)
        
        if minutes < 60 {
            return "\(minutes)m ago"
        } else if hours < 24 {
            return "\(hours)h ago"
        } else if days < 7 {
            return "\(days)d ago"
        } else {
            return "\(weeks)w ago"
        }
    }

     private func getLocationString(from coordinates: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                // можна взяти місто + штат/країну
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                
                if !city.isEmpty && !state.isEmpty {
                    completion("\(city), \(state)")
                } else if let name = placemark.name {
                    completion(name)
                } else {
                    completion("Unknown location")
                }
            } else {
                completion("Unknown location")
            }
        }
    }

}
