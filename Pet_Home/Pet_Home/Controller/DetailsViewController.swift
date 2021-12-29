import UIKit
import Firebase

class DetailsViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView! {
        didSet {
            posterImageView.circolarImage()
        }
    }
    @IBOutlet weak var posterLabel: UILabel!
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petAgeLabel: UILabel!
    @IBOutlet weak var petGender: UILabel!
    @IBOutlet weak var petType: UILabel!
    @IBOutlet weak var posterLocationLabel: UILabel!
    @IBOutlet weak var petDescreptionTextView: UITextView!
    @IBOutlet weak var posterNumberLabel: UILabel! {
        didSet {
            posterNumberLabel.layer.cornerRadius = posterNumberLabel.frame.height/2
            posterNumberLabel.layer.masksToBounds = true
            posterNumberLabel.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPost))
            posterNumberLabel.addGestureRecognizer(tapGesture)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
