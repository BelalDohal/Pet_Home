import UIKit
import Firebase

class LoginViewController: UIViewController {
    var languageCode = ""
    @IBOutlet weak var LanguageSegmentControl: UISegmentedControl! {
        didSet {
            if let language = UserDefaults.standard.string(forKey: "currentLanguage") {
                switch language {
                case "ar":
                    LanguageSegmentControl.selectedSegmentIndex = 0
                    
                case "en":
                    LanguageSegmentControl.selectedSegmentIndex = 1
                default:
                    let localLanguage =  Locale.current.languageCode
                    if localLanguage == "ar" {
                        LanguageSegmentControl.selectedSegmentIndex = 0
                    }else {
                        LanguageSegmentControl.selectedSegmentIndex = 1
                    }
                }
            }else {
                let localLanguage =  Locale.current.languageCode
                if localLanguage == "ar" {
                    LanguageSegmentControl.selectedSegmentIndex = 0
                }else {
                    LanguageSegmentControl.selectedSegmentIndex = 1
                }
            }
        }
    }
    
    @IBOutlet weak var emailLabel: UILabel! {
        didSet {
            emailLabel.text = "email".localiz
        }
    }
    @IBOutlet weak var passwordLabel: UILabel! {
        didSet {
            passwordLabel.text = "password".localiz
        }
    }
    @IBOutlet weak var orLabel: UILabel! {
        didSet {
            orLabel.text = "or".localiz
        }
    }
    @IBOutlet weak var petHomeLogoLabel: UILabel! {
        didSet {
            petHomeLogoLabel.text = "petHome".localiz
        }
    }
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.alpha = 0
        }
    }

    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.fixTheTextField()
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.fixTheTextField()
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.masksToBounds = true
            loginButton.layer.cornerRadius = loginButton.frame.height/2
            loginButton.layer.borderWidth = 1
            loginButton.layer.borderColor = UIColor.systemOrange.cgColor
            loginButton.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.layer.masksToBounds = true
            signUpButton.layer.cornerRadius = signUpButton.frame.height/2
            signUpButton.layer.borderWidth = 1
            signUpButton.layer.borderColor = UIColor.systemGreen.cgColor
            signUpButton.setTitle(NSLocalizedString("signUp", comment: ""), for: .normal)
        }
    }
    
    @IBOutlet weak var loginNavigationController: UINavigationItem! {
        didSet {
            loginNavigationController.title = "login".localiz
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func sellectedLanguage(_ sender: UISegmentedControl) {
        if let language = sender.titleForSegment(at: sender.selectedSegmentIndex) {
            if language == "English" {
                UserDefaults.standard.set("en", forKey: "currentLanguage")
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
    @IBAction func loginPressed() {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    if error.localizedDescription == "The email address is badly formatted." {
                        self.errorLabel.text = "errorBadEmail".localiz
                    }else if error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                        self.errorLabel.text = "errorThisUserIsNotFound".localiz
                    }else if error.localizedDescription == "The password is invalid or the user does not have a password." {
                        self.errorLabel.text = "errorPassword".localiz
                    }
                    self.errorLabel.alpha = 1
                    Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
                }else {
                    if authResult != nil {
                        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeNavigationContoller") as? UINavigationController {
                            vc.modalPresentationStyle = .fullScreen
                            Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }
            }
        }else {
            self.errorLabel.text = "pleaseEnterTheEmailAndThePassword".localiz
            self.errorLabel.alpha = 1
            Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
        }
    }
}
