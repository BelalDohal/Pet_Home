import UIKit
import Firebase

class LandingViewController: UIViewController {
    
    let imagePickerController = UIImagePickerController()
    @IBOutlet weak var signCollectionView: UICollectionView! {
        didSet {
            self.signCollectionView.delegate = self
            self.signCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.circolarImage()
            userImageView.alpha = 0
            userImageView.isHidden = true
            userImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            userImageView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var LanguageSegmentControl: UISegmentedControl! {
        didSet {
            if let language = UserDefaults.standard.string(forKey: "currentLanguage") {
                switch language {
                case "ar":
                    LanguageSegmentControl.selectedSegmentIndex = 1
                    
                case "en":
                    LanguageSegmentControl.selectedSegmentIndex = 0
                default:
                    let localLanguage =  Locale.current.languageCode
                    if localLanguage == "ar" {
                        LanguageSegmentControl.selectedSegmentIndex = 1
                    }else {
                        LanguageSegmentControl.selectedSegmentIndex = 0
                    }
                }
            }else {
                let localLanguage =  Locale.current.languageCode
                if localLanguage == "ar" {
                    LanguageSegmentControl.selectedSegmentIndex = 1
                }else {
                    LanguageSegmentControl.selectedSegmentIndex = 0
                }
            }
        }
    }
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    @IBAction func sellectedLanguage(_ sender: UISegmentedControl) {
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
    @objc func scrollToSignUp() {
        let signUpIndexPath = IndexPath(row: 1, section: 0)
        signCollectionView.scrollToItem(at: signUpIndexPath, at: .centeredHorizontally, animated: true)
        UIView.animate(withDuration: 0.3) {
            self.userImageView.alpha = 1
            self.logoLabel.alpha = 0
            self.userImageView.isHidden = false
            self.view.layoutIfNeeded()
        } completion: { status in
            self.logoLabel.isHidden = true
        }
    }
    @objc func scrollToSignIn() {
        let loginIndexPath = IndexPath(row: 0, section: 0)
        signCollectionView.scrollToItem(at: loginIndexPath, at: .centeredHorizontally, animated: true)
        UIView.animate(withDuration: 0.3) {
            self.userImageView.alpha = 0
            self.logoLabel.alpha = 1
            self.logoLabel.isHidden = false
            self.view.layoutIfNeeded()
        } completion: { status in
            self.userImageView.isHidden = true
        }
    }
    @objc func loginPressed() {
        let signInIndexPath = IndexPath(row: 0, section: 0)
        let cell = self.signCollectionView.cellForItem(at: signInIndexPath) as! SignCollectionViewCell
        if let email = cell.emailTextField.text,
           let password = cell.passwordTextField.text {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    if error.localizedDescription == "The email address is badly formatted." {
                        cell.errorLabel.text = "errorBadEmail".localiz
                    }else if error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                        cell.errorLabel.text = "errorThisUserIsNotFound".localiz
                    }else if error.localizedDescription == "The password is invalid or the user does not have a password." {
                        cell.errorLabel.text = "errorPassword".localiz
                    }
                    cell.errorLabel.alpha = 1
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
            cell.errorLabel.text = "pleaseEnterTheEmailAndThePassword".localiz
            cell.errorLabel.alpha = 1
            Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
        }
    }
    @objc func signUpPressed() {
        let signUpIndexPath = IndexPath(row: 1, section: 0)
        let cell = self.signCollectionView.cellForItem(at: signUpIndexPath) as! SignCollectionViewCell
        if let image = userImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let name = cell.nameTextField.text,
           let email = cell.emailTextField.text,
           let phoneNumber = cell.numberTextField.text,
           let password = cell.passwordTextField.text,
           let confirmPassword = cell.confirmPasswordTextField.text,
        confirmPassword == password {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    if error.localizedDescription == "The email address is badly formatted." {
                        cell.errorLabel.text = "errorBadEmail".localiz
                    }else if error.localizedDescription == "The password must be 6 characters long or more." {
                        cell.errorLabel.text = "errorPasswordCharacters".localiz
                    }
                    cell.errorLabel.alpha = 1
                    Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
                }else {
                    if let authResult = authResult {
                        let storageRef = Storage.storage().reference(withPath: "users/\(authResult.user.uid)")
                        let uploadMeta = StorageMetadata.init()
                        uploadMeta.contentType = "image/jpeg"
                        storageRef.putData(imageData, metadata: uploadMeta) { storageMeta, error in
                            if let error = error {
                                cell.errorLabel.text = "Sign Up Storage Error \(error.localizedDescription)"
                                cell.errorLabel.alpha = 1
                            }else {
                                storageRef.downloadURL { url, error in
                                    if let error = error {
                                        cell.errorLabel.text = "Sign Up Storage Download URL Error \(error.localizedDescription)"
                                        cell.errorLabel.alpha = 1
                                    }else {
                                        if let url = url {
                                            let db = Firestore.firestore()
                                            let userData: [String:String] = [
                                                "id": authResult.user.uid,
                                                "name": name,
                                                "email": email,
                                                "phoneNumber":phoneNumber,
                                                "imageUrl":url.absoluteString,
                                            ]
                                            db.collection("users").document(authResult.user.uid).setData(userData) { error in
                                                if let error = error {
                                                    cell.errorLabel.text = "Sign Up Database Error \(error.localizedDescription)"
                                                    cell.errorLabel.alpha = 1
                                                }else {
                                                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeNavigationContoller") as? UINavigationController {
                                                        vc.modalPresentationStyle = .fullScreen
                                                        Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
                                                        self.present(vc, animated: true, completion: nil)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }else {
            if cell.confirmPasswordTextField.text != cell.passwordTextField.text {
                cell.errorLabel.text = "vertrficationPaswordError".localiz
                cell.errorLabel.alpha = 1
            }
            if cell.numberTextField.text == nil || cell.nameTextField.text == nil {
                cell.errorLabel.text = "errorEmptySpace".localiz
                cell.errorLabel.alpha = 1
            }
        }
    }
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
}

extension LandingViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.signCollectionView.dequeueReusableCell(withReuseIdentifier: "signCell", for: indexPath) as! SignCollectionViewCell
        if indexPath.row == 0 {
            cell.numberTextField.isHidden = true
            cell.numberLabel.isHidden = true
            cell.confirmPasswordLabel.isHidden = true
            cell.confirmPasswordTextField.isHidden = true
            cell.nameLabel.isHidden = true
            cell.nameTextField.isHidden = true
            cell.scrolingButton.setTitle(NSLocalizedString("signUpSlide", comment: ""), for: .normal)
            cell.signButton.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
            cell.scrolingButton.addTarget(self, action: #selector(scrollToSignUp), for: .touchUpInside)
            cell.signButton.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        }else if indexPath.row == 1 {
            cell.numberTextField.isHidden = false
            cell.nameLabel.isHidden = false
            cell.confirmPasswordLabel.isHidden = false
            cell.confirmPasswordTextField.isHidden = false
            cell.nameLabel.isHidden = false
            cell.nameTextField.isHidden = false
            cell.scrolingButton.setTitle(NSLocalizedString("signInSlide", comment: ""), for: .normal)
            cell.signButton.setTitle(NSLocalizedString("signUp", comment: ""), for: .normal)
            cell.scrolingButton.addTarget(self, action: #selector(scrollToSignIn), for: .touchUpInside)
            cell.signButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension LandingViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @objc func selectImage() {
        showAlert()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Chose Profile Picture", message: "Pick From ?", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { Action in
            self.getImage(from: .camera)
        }
        
        let galaryAction = UIAlertAction(title: "Photo Album", style: .default) { Action in
            self.getImage(from: .photoLibrary)
        }
        
        let dismessAction = UIAlertAction(title: "Cancle", style: .destructive) { Action in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cameraAction)
        alert.addAction(galaryAction)
        alert.addAction(dismessAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getImage( from sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        userImageView.image = selectImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
