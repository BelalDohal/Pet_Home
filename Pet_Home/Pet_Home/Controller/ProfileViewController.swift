import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.circolarImage()
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton! {
        didSet {
            logOutButton.layer.cornerRadius = logOutButton.frame.height/2
            logOutButton.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var newPostButton: UIButton! {
        didSet {
            newPostButton.layer.cornerRadius = newPostButton.frame.height/2
            newPostButton.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var userAdoptionPostsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandingNavigationContoller") as? UINavigationController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        } catch  {
            print("ERROR in signout",error.localizedDescription)
        }
    }
}
