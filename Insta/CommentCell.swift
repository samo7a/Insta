//
//  CommentCell.swift
//  Insta
//
//  Created by Ahmed  Elshetany  on 10/18/21.
//

import UIKit

class CommentCell: UITableViewCell {


	@IBOutlet weak var commentLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		
        // Configure the view for the selected state
    }

}
