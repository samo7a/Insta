//
//  FeedViewController.swift
//  Insta
//
//  Created by Ahmed  Elshetany  on 10/4/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
	let myRefreshControl = UIRefreshControl()
	var posts = [PFObject]()
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		posts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
		let post = posts[indexPath.row]
		let user = post["author"] as! PFUser
		cell.usernameLabel.text = user.username
		cell.captionLabel.text = post["caption"] as? String
		
		let imageFile = post["image"] as! PFFileObject
		let urlString = imageFile.url!
		let url = URL(string: urlString)!
		cell.photoView.af.setImage(withURL: url)
		return cell
	}
	

	@IBOutlet weak var tableView: UITableView!
	@IBAction func onLogout(_ sender: Any) {
		UserDefaults.standard.set(false, forKey: "isLoggedIn")
		self.dismiss(animated: true, completion: nil)
		
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
		tableView.refreshControl = myRefreshControl

        // Do any additional setup after loading the view.
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadPosts()
		
	}
	@objc func loadPosts(){
		
		let query = PFQuery(className: "Posts")
		query.includeKey("author")
		query.limit = 20
		query.findObjectsInBackground{(posts, error) in
			if posts != nil {
				self.posts.removeAll()
				self.posts = posts!.reversed()
				self.tableView.reloadData()
			}
		}
		self.myRefreshControl.endRefreshing()
	}
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


