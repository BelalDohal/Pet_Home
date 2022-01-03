import UIKit
import Firebase

class LoginViewController: UIViewController {
    let activityIndicator = UIActivityIndicatorView()
    @IBOutlet weak var logInNavigationItem: UINavigationItem! {
        didSet {
            logInNavigationItem.title = "logIn".localiz
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.placeholder = "email".localiz
        }
    }
    @IBOutlet weak var signUpButton: UIButton! {
        didSet{
            signUpButton.setTitle(NSLocalizedString("signUp", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var logInButton: UIButton! {
        didSet{
            logInButton.setTitle(NSLocalizedString("logIn", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet{
            passwordTextField.placeholder = "password".localiz
        }
    }
    @IBOutlet weak var languageSegmentedController: UISegmentedControl! {
        didSet {
            if let language = UserDefaults.standard.string(forKey: "currentLanguage") {
                switch language {
                case "ar":
                    languageSegmentedController.selectedSegmentIndex = 0
                    
                case "en":
                    languageSegmentedController.selectedSegmentIndex = 1
                default:
                    let localLanguage =  Locale.current.languageCode
                    if localLanguage == "ar" {
                        languageSegmentedController.selectedSegmentIndex = 0
                    }else {
                        languageSegmentedController.selectedSegmentIndex = 1
                    }
                }
            }else {
                let localLanguage =  Locale.current.languageCode
                if localLanguage == "ar" {
                    languageSegmentedController.selectedSegmentIndex = 0
                }else {
                    languageSegmentedController.selectedSegmentIndex = 1
                }
            }
        }
    }
    @IBOutlet weak var errorLaber: UILabel! {
        didSet {
            errorLaber.alpha = 0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func changeTheLanguagePressed(_ sender: UISegmentedControl) {
        if let language = sender.titleForSegment(at: sender.selectedSegmentIndex) {
            if language == "English" {
                UserDefaults.standard.set("setLanguage", forKey: "currentLanguage")
                Bundle.setLanguage("en")
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()
                }
            }else if language == "العربية" {
                UserDefaults.standard.set("ar", forKey: "currentLanguage")
                Bundle.setLanguage("ar")
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()
                }
            }
        }
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
