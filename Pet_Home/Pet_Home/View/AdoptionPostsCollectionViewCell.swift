import UIKit

class AdoptionPostsTableViewCell: UITableViewCell {
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.circolarImage()
            userImageView.layer.borderWidth = 3
            userImageView.layer.borderColor = UIColor.systemGreen.cgColor
        }
    }
    @IBOutlet weak var petNameAndImageStackView: UIStackView! {
        didSet {
            petNameAndImageStackView.layer.masksToBounds = true
            petNameAndImageStackView.layer.cornerRadius = 15
            petNameAndImageStackView.layer.borderWidth = 1
            petNameAndImageStackView.layer.borderColor = UIColor.systemOrange.cgColor
        }
    }
    @IBOutlet weak var adoptionPostUIView: UIView! {
        didSet {
            adoptionPostUIView.layer.cornerRadius = 15
            adoptionPostUIView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var petDescreptionLabel: UILabel!
    // Upload The Cell
    func configure(with adoptionPost:AdoptionPost) -> UITableViewCell {
        petImageView.loadImageUsingCache(with: adoptionPost.imageUrl)
        userImageView.loadImageUsingCache(with: adoptionPost.user.imageUrl)
        userNameLabel.text = adoptionPost.user.name
        petNameLabel.text = adoptionPost.petName
        petDescreptionLabel.text = adoptionPost.petDescreption
        return self
    }
    // No Duplicate "AKA" More than ONE Download
    override func prepareForReuse() {
        petImageView.image = nil
    }
}
