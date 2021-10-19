//
//  FeedViewController.swift
//  Insta
//
//  Created by Ahmed  Elshetany  on 10/4/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{
	let myRefreshControl = UIRefreshControl()
	var posts = [PFObject]()
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return posts.count
//	}
	func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		let post = posts[section]
		let comments = (post["comments"] as? [PFObject]) ?? []
		
		return comments.count + 2
	}
	func numberOfSections (in tableView: UITableView) -> Int{
		return posts.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let post = posts[indexPath.section]
		let comments = (post["comments"] as? [PFObject]) ?? []
		
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
			
			let user = post["author"] as? PFUser
			cell.usernameLabel.text = user?.username
			cell.captionLabel.text = post["caption"] as? String
			
			let imageFile = post["image"] as! PFFileObject
			let urlString = imageFile.url!
			let url = URL(string: urlString)!
			cell.photoView.af.setImage(withURL: url)
			
			
			return cell
		} else if indexPath.row <= comments.count {
			let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
			let comment = comments[indexPath.row - 1]
			cell.commentLabel.text = comment["text"] as? String
			let user = comment["author"] as! PFUser
			cell.nameLabel.text = user.username
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
			return cell
		}
		
		
	}
	var selectedPost: PFObject!
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
		let post = posts[indexPath.section]
		let comments = post["comments"] as? [PFObject] ?? []
		if indexPath.row == comments.count + 1 {
			showCommentBar = true
			becomeFirstResponder()
			commentBar.inputTextView.becomeFirstResponder()
			selectedPost = post
		}
//
	}
	let commentBar = MessageInputBar()
	var showCommentBar = false
	func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
		let comment = PFObject(className: "Comments")
		comment["text"] = text
		comment["author"] = PFUser.current()!
		comment["post"] = selectedPost

		selectedPost.add(comment, forKey: "comments")
		
		selectedPost.saveInBackground{(success, error) in
			if success {
				
				print("comment save")
			} else {
				print (error ?? "error saving a comment")
			}
		}
		tableView.reloadData()
		commentBar.inputTextView.text = nil
		showCommentBar = false
		becomeFirstResponder()
		commentBar.inputTextView.resignFirstResponder()
		
		
	}
	@objc func keyboardWillbeHidden(note: Notification) {
		commentBar.inputTextView.text = nil
		showCommentBar = false
		becomeFirstResponder()
		commentBar.inputTextView.resignFirstResponder()
	}
	override var inputAccessoryView: UIView? {
		return commentBar
	}
	override var canBecomeFirstResponder: Bool{
		return showCommentBar
	}
	@IBOutlet weak var tableView: UITableView!
	@IBAction func onLogout(_ sender: Any) {
		UserDefaults.standard.set(false, forKey: "isLoggedIn")
		PFUser.logOut()
		self.dismiss(animated: true, completion: nil)
		
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		commentBar.inputTextView.placeholder = "Add Comment ..."
		commentBar.sendButton.title = "Post"
		commentBar.inputTextView.textColor = UIColor(named: "Black")
		commentBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		tableView.keyboardDismissMode = .interactive
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(keyboardWillbeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
		query.includeKeys(["author", "commnets", "comments.author"])
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


