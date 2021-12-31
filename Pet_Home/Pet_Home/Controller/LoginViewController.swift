import UIKit
import Firebase

class LoginViewController: UIViewController {
    let activityIndicator = UIActivityIndicatorView()
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLaber: UILabel! {
        didSet {
            errorLaber.alpha = 0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func signUpPressed(_ sender: Any) {
        Activity.showIndicator(parentView: self.view, childView: activityIndicator)
    }
    @IBAction func loginPressed(_ sender: Any) {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.errorLaber.text = "Error \(error.localizedDescription)"
                    self.errorLaber.alpha = 1
                    Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                }else {
                    if authResult != nil {
                        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeNavigationContoller") as? UINavigationController {
                            vc.modalPresentationStyle = .fullScreen
                            Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
/*
 */
