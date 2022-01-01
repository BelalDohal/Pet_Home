import UIKit

class AdoptionPostsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var ownerImageView: UIImageView! {
        didSet {
            ownerImageView.circolarImage()
        }
    }
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var petDescreptionLabel: UILabel!
    @IBOutlet weak var ownerLocationLabel: UILabel!
    // Upload The Cell
    func configure(with adoptionPost:AdoptionPost) -> UICollectionViewCell {
        petNameLabel.text = adoptionPost.petName
        petDescreptionLabel.text = adoptionPost.petDescreption
        petImageView.loadImageUsingCache(with: adoptionPost.imageUrl)
        ownerNameLabel.text = adoptionPost.user.name
        ownerImageView.loadImageUsingCache(with: adoptionPost.user.imageUrl)
        ownerLocationLabel.text = adoptionPost.user.location
        return self
    }
    // No Duplicate "AKA" More than ONE Download
    override func prepareForReuse() {
        ownerImageView.image = nil
        petImageView.image = nil
    }
}
