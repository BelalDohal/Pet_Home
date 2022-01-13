import UIKit
import Firebase

class DetailsViewController: UIViewController {
    var selectedAdoptionPost:AdoptionPost?
    var selectedAdoptionPostImage:UIImage?
    var navigatedFrom = "Details"
    @IBOutlet weak var posterImageView: UIImageView! {
        didSet {
            posterImageView.circolarImage()
            posterImageView.layer.borderWidth = 3
            posterImageView.layer.borderColor = UIColor.systemGreen.cgColor
        }
    }
    @IBOutlet weak var petImageView: UIImageView! {
        didSet {
            petImageView.layer.cornerRadius = 15
            petImageView.layer.masksToBounds = true
            petImageView.layer.borderWidth = 1
            petImageView.layer.borderColor = UIColor.systemGreen.cgColor
        }
    }
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petAgeLabel: UILabel!
    @IBOutlet weak var petGenderLabel: UILabel!
    @IBOutlet weak var petTypeLabel: UILabel!
    @IBOutlet weak var petDescreptionLabel: UILabel!
    @IBOutlet weak var posterNumberLabel: UILabel!
    @IBOutlet weak var moreViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreUIView: UIView! {
        didSet {
            moreUIView.isHidden = true
            moreUIView.alpha = 0
        }
    }
    @IBOutlet weak var petNameAndMoreStackView: UIStackView! {
        didSet {
            petNameAndMoreStackView.layer.cornerRadius = 15
            petNameAndMoreStackView.layer.masksToBounds = true
            petNameAndMoreStackView.layer.borderWidth = 1
            petNameAndMoreStackView.layer.borderColor = UIColor.systemOrange.cgColor
        }
    }
    @IBOutlet weak var userImageAndNumberViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailsNavigatioItem: UINavigationItem!
    @IBOutlet weak var userImageAndNumberStackView: UIStackView! {
        didSet {
            userImageAndNumberStackView.layer.masksToBounds = true
            userImageAndNumberStackView.layer.cornerRadius = userImageAndNumberStackView.frame.height/2
        }
    }
    @IBOutlet weak var petImageViewHeightConstrant: NSLayoutConstraint! 
    var moreViewDisplayed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedAdoptionPost = selectedAdoptionPost,
           let selectedAdoptionPostImage = selectedAdoptionPostImage {
            let posterId = selectedAdoptionPost.user.id
            detailsNavigatioItem.title = selectedAdoptionPost.user.name
            posterImageView.loadImageUsingCache(with: selectedAdoptionPost.user.imageUrl)
            petImageView.image = selectedAdoptionPostImage
            petNameLabel.text = selectedAdoptionPost.petName
            petAgeLabel.text = selectedAdoptionPost.petAge
            petGenderLabel.text = selectedAdoptionPost.petGender
            petTypeLabel.text = selectedAdoptionPost.petType
            posterNumberLabel.text = selectedAdoptionPost.user.phoneNumber
            petDescreptionLabel.text = selectedAdoptionPost.petDescreption
            let currentUserId = Auth.auth().currentUser?.uid
            if let currentUserId = currentUserId,
               currentUserId == posterId {
                userImageAndNumberStackView.isUserInteractionEnabled = true
                posterNumberLabel.text = "Update This Post"
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPost))
                userImageAndNumberStackView.addGestureRecognizer(tapGesture)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sendTo = segue.destination as? PostViewController
        sendTo?.selectedAdoptionPost = selectedAdoptionPost
        sendTo?.selectedAdoptionPostImage = selectedAdoptionPostImage
        sendTo?.navigateFrom = navigatedFrom
    }
    @IBAction func morePressed(_ sender: Any) {
        if moreViewDisplayed == false {
            UIView.animate(withDuration: 0.3) {
                self.petDescreptionLabel.numberOfLines = 3
                self.moreUIView.isHidden = false
                self.moreUIView.alpha = 1
                self.moreViewConstraint.constant = 100
                self.view.layoutIfNeeded()
            } completion: { status in
                self.moreViewDisplayed = true
            }
        }else {
            UIView.animate(withDuration: 0.3) {
                self.moreUIView.isHidden = true
                self.moreUIView.alpha = 0
                self.moreViewConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { status in
                self.moreViewDisplayed = false
                self.petDescreptionLabel.numberOfLines = 0
            }
        }
    }
}
extension DetailsViewController {
    @objc func goToPost() {
        performSegue(withIdentifier: "fromDetailsToPost", sender: self)
    }
    @objc func goToProfile() {
        performSegue(withIdentifier: "fromHomeToProfile", sender: self)
    }
}

/*
 */
