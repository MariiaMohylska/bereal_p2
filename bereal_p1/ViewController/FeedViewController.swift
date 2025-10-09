//
//  FeedViewController.swift
//  bereal_p1
//
//  Created by Mariia Mohylska on 9/29/25.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController {
    
    
    @IBOutlet weak var tableViewController: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewController.delegate = self
        tableViewController.dataSource = self
        tableViewController.allowsSelection = false
    }
    
    private var posts = [Post]() {
        didSet{
            tableViewController.reloadData()
        }
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryPosts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showComments",
           let destination = segue.destination as? CommentsViewController,
            let post = sender as? Post {
            destination.post = post
        }
    }
    
    private func queryPosts() {
        
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!
        
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate) // <- Only include results created yesterday onwards
            .limit(10)
        
        query.find{[weak self] result in
            switch result{
            case .success(let posts):
                self?.posts = posts
            case .failure(let error):
                print("Error load of posts: \(error)")
                self?.showAlert(description: error.localizedDescription)
            }}
    }
    
    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension FeedViewController: UITableViewDelegate {}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableViewController.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        cell.didCommetsButtonTapped = { [weak self] in
            self?.performSegue(withIdentifier: "showComments", sender: self?.posts[indexPath.row])
        }
        return cell
    }
    
    
}
