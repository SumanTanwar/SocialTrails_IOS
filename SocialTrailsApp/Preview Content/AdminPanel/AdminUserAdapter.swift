import UIKit
import SDWebImage

class AdminUserCell: UITableViewCell {
    @IBOutlet weak var imgProfilePicture: UIImageView!
    @IBOutlet weak var txtUserName: UILabel!
    @IBOutlet weak var txtEmail: UILabel!
    @IBOutlet weak var txtRegisteredDate: UILabel!
    @IBOutlet weak var txtStatus: UILabel!

    // Configure the cell with user data
    func configure(with user: Users) {
        txtUserName.text = user.username
        txtEmail.text = user.email
        txtRegisteredDate.text = "Registered on: \(user.createdon)" // Fixed to use the createdon property
        
        if user.profiledeleted || user.admindeleted {
            txtStatus.textColor = .white
            txtStatus.backgroundColor = .red
            txtStatus.text = "Deleted"
        } else if user.suspended {
            txtStatus.textColor = .white
            txtStatus.backgroundColor = UIColor.orange
            txtStatus.text = "Suspended"
        } else {
            txtStatus.isHidden = true
        }

        // Load profile picture
        if let profilePictureURL = user.profilepicture, !profilePictureURL.isEmpty {
            imgProfilePicture.sd_setImage(with: URL(string: profilePictureURL), placeholderImage: UIImage(named: "user"))
        } else {
            imgProfilePicture.image = UIImage(named: "user") // Default image
        }
    }
}
