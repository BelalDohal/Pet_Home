import UIKit
import Firebase

class DetailsViewController: UIViewController {
    var selectedAdoptionPost:AdoptionPost?
    var selectedAdoptionPostImage:UIImage?
    var posterImage:UIImage?
    var currentUser = Auth.auth().currentUser
    @IBOutlet weak var posterImageView: UIImageView! {
        didSet {
            posterImageView.circolarImage()
        }
    }
    @IBOutlet weak var posterNameLabel: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petAgeLabel: UILabel!
    @IBOutlet weak var petGenderLabel: UILabel!
    @IBOutlet weak var petTypeLabel: UILabel!
    @IBOutlet weak var posterLocationLabel: UILabel!
    @IBOutlet weak var petDescreptionTextView: UITextView!
    @IBOutlet weak var posterNumberLabel: UILabel! {
        didSet {
            posterNumberLabel.layer.cornerRadius = posterNumberLabel.frame.height/2
            posterNumberLabel.layer.masksToBounds = true
            posterNumberLabel.isUserInteractionEnabled = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedAdoptionPost = selectedAdoptionPost,
           let selectedAdoptionPostImage = selectedAdoptionPostImage,
           let posterImage = posterImage {
            let posterId = selectedAdoptionPost.user.id
            posterImageView.image = posterImage
            posterNameLabel.text = selectedAdoptionPost.user.name
            petImageView.image = selectedAdoptionPostImage
            petNameLabel.text = selectedAdoptionPost.petName
            petAgeLabel.text = selectedAdoptionPost.petAge
            petGenderLabel.text = selectedAdoptionPost.petGender
            petTypeLabel.text = selectedAdoptionPost.petType
            posterLocationLabel.text = selectedAdoptionPost.user.location
            petDescreptionTextView.text = selectedAdoptionPost.petDescreption
            posterNumberLabel.text = selectedAdoptionPost.user.phoneNumber
            if let currentUserId = currentUser?.uid,
               currentUserId == posterId {
                posterNumberLabel.text = "Update This Post"
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPost))
                posterNumberLabel.addGestureRecognizer(tapGesture)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sendTo = segue.destination as? PostViewController
        sendTo?.selectedAdoptionPost = selectedAdoptionPost
        sendTo?.selectedAdoptionPostImage = selectedAdoptionPostImage
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
