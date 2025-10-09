//
//  CommentCell.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 10/3/25.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Вимикаємо autoresizing masks
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Активуємо constraints
        NSLayoutConstraint.activate([
            // Username
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Comment text
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            commentLabel.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 8),
            commentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            commentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Налаштування лейблів
        commentLabel.numberOfLines = 0
        commentLabel.lineBreakMode = .byWordWrapping
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 14)
    }

    
    func configure(with comment: Comment) {
        print("Comment: \(comment)")
        usernameLabel.text = "\(comment.author?.firstName ?? "") \(comment.author?.lastName ?? "")"
        commentLabel.text = comment.comment
    }
}
