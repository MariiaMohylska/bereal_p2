//
//  CommentsViewController.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 10/3/25.
//

import UIKit
import ParseSwift

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    var post: Post?
    private var comments = [Comment]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    private var newComment: String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        queryComments()
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           tapGesture.cancelsTouchesInView = false
           view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
    }
    
    @objc func keyboardWillShow(notification: Notification) {
         if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
             bottomConstraint.constant = keyboardFrame.height + 8 // додати padding
             UIView.animate(withDuration: duration) {
                 self.view.layoutIfNeeded()
             }
         }
     }
     
     @objc func keyboardWillHide(notification: Notification) {
         if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
             bottomConstraint.constant = 0
             UIView.animate(withDuration: duration) {
                 self.view.layoutIfNeeded()
             }
         }
     }
    
    private func queryComments() {
        Task {
            do {
                let query = try Comment.query()
                    .where("post" == post?.toPointer())
                    .include("author")
                    .order(.ascending("createdAt"))
                
                query.find{[weak self] result in
                    switch result{
                    case .success(let comments):
                        self?.comments = comments
                    case .failure(let error):
                        print("Error load of comments: \(error)")
                        self?.showAlert(description: error.localizedDescription)
                    }}
            } catch (let error) {
                print("Error: \(error)")
            }
        }
    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    @IBAction func sendNewComment(_ sender: Any) {
        guard let commentText = commentTextField.text,
        !commentText.isEmpty else {
            return
        }
        
        Task{
            do {
                var comment = Comment()
                comment.post = try post?.toPointer()
                comment.author = SessionManager.currentProfile
                comment.comment = commentText
                
                comment.save { [weak self] result in
                    switch result {
                    case .success(let commentSaved):
                        self?.comments.append(commentSaved)
                        self?.commentTextField.text = ""
                        self?.tableView.reloadData()
                    case .failure(let error):
                        print("Error by saving the comment: \(error)")
                    }
                }
                
            } catch (let error) {
                print("Error seving the post: \(error)")
            }
        }
    }
    
    @IBAction func dismissComments(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: comments[indexPath.row])
    
        return cell
    }
    
    
}
