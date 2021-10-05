//
//  LoginViewController.swift
//  Insta
//
//  Created by Ahmed  Elshetany  on 10/4/21.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

	@IBOutlet weak var stackConstraint: NSLayoutConstraint!
	private var originalBottomConstraint: CGFloat = 0
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.originalBottomConstraint = stackConstraint.constant
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
	override func viewDidAppear(_ animated: Bool) {
		if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
			self.performSegue(withIdentifier: "loginSegue", sender: self)
		}
	}
	@objc private func keyboardWillShow(notification: Notification){
		if let keyboardsize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
			self.stackConstraint.constant = keyboardsize.cgRectValue.height + 10
			UIView.animate(withDuration: 1, animations: {
				self.view.layoutIfNeeded()
			})
		}
	}
	@objc private func keyboardWillHide(notification: Notification){
		self.stackConstraint.constant = self.originalBottomConstraint
		UIView.animate(withDuration: 1, animations: {
			self.view.layoutIfNeeded()
		})
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
    
	@IBAction func onSignIn(_ sender: Any) {
		PFUser.logInWithUsername(inBackground:usernameField.text!, password:passwordField.text!) {
			(success,error) in
			if (success != nil) {
				self.performSegue(withIdentifier: "loginSegue", sender: self)
				UserDefaults.standard.set(true, forKey: "isLoggedIn")
				// Do stuff after successful login.
			} else {
				// The login failed. Check error to see why.
				print ("Error: \(String(describing: error?.localizedDescription))")
			}
		}
	}
	
	@IBAction func onSignUp(_ sender: Any) {
		let user = PFUser()
		user.username = usernameField.text
		user.password = passwordField.text
		
		user.signUpInBackground() {(success, error) in
			if success {
				self.performSegue(withIdentifier: "loginSegue", sender: nil)
				UserDefaults.standard.set(true, forKey: "isLoggedIn")
			} else {
				print ("Error: \(String(describing: error?.localizedDescription))")
			}
		}
	
	}
//	func keyboardWillShow(notification: NSNotification){
//		if let info = notification.userInfo {
//			let rect:CGRect  = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
//
//			self.view.layoutIfNeeded()
//			UIView.animate(withDuration: 0.25, animations: {
//				self.view.layoutIfNeeded()
//				self.View.constant = rec.height + 20
//			})
//		}
//	}
	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIViewController {
	
	func showToast(message : String, font: UIFont) {
		
		let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
		toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		toastLabel.textColor = UIColor.white
		toastLabel.font = font
		toastLabel.textAlignment = .center;
		toastLabel.text = message
		toastLabel.alpha = 1.0
		toastLabel.layer.cornerRadius = 10;
		toastLabel.clipsToBounds  =  true
		self.view.addSubview(toastLabel)
		UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
			toastLabel.alpha = 0.0
		}, completion: {(isCompleted) in
			toastLabel.removeFromSuperview()
		})
	} }
