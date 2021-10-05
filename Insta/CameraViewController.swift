//
//  CameraViewController.swift
//  Insta
//
//  Created by Ahmed  Elshetany  on 10/5/21.
//

import UIKit
import AlamofireImage
import Parse


class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	@IBOutlet weak var stackConstraint: NSLayoutConstraint!
	private var originalBottomConstraint: CGFloat = 0
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var commentField: UITextField!
	@IBAction func onLogout(_ sender: Any) {
		UserDefaults.standard.set(false, forKey: "isLoggedIn")
		self.dismiss(animated: true, completion: nil)
	}
	@IBAction func onCameraButton(_ sender: Any) {
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.allowsEditing = true
		if UIImagePickerController.isSourceTypeAvailable(.camera){
			picker.sourceType = .camera
		} else {
			picker.sourceType = .photoLibrary
		}
		present(picker, animated: true, completion: nil)
	}
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		let image = info[.editedImage] as! UIImage
		let size = CGSize(width: 300, height: 300)
		let scaledImage = image.af.imageScaled(to: size)
		imageView.image = scaledImage
		dismiss(animated: true, completion: nil)
	}
	@IBAction func onSubmit(_ sender: Any) {
		let photo = PFObject(className: "Posts")
		photo["caption"] = commentField.text
		photo["author"] = PFUser.current()!
		let imageData = imageView.image!.pngData()
		let name =  String(photo.hashValue)
		let file = PFFileObject(name: "\(name).png", data: imageData!)
		
		photo["image"] = file
		photo.saveInBackground{ (success, error) in
			if success {
				self.imageView.image = #imageLiteral(resourceName: "image_placeholder")
				self.commentField.text = ""
				self.showToast(message: "Image Posted!", font: .systemFont(ofSize: 12.0))
//				self.dismiss(animated: true, completion: nil)
				print("success")
			} else {
				print("error")
				self.showToast(message: "Error Posting the image, please try again!", font: .systemFont(ofSize: 12.0))
			}
		}
	}
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
