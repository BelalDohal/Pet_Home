import UIKit
import Firebase

class SignUpViewController: UIViewController {
    let imagePickerController = UIImagePickerController()
    let activityIndicator = UIActivityIndicatorView()
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.circolarImage()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            userImageView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var nameTextField: UITextField! {
        didSet{
            nameTextField.placeholder = "name".localiz
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        didSet{
            emailTextField.placeholder = "email".localiz
        }
    }
    @IBOutlet weak var phoneNumberTextField: UITextField! {
        didSet{
            phoneNumberTextField.placeholder = "phoneNumber".localiz
        }
    }
    @IBOutlet weak var locationTextField: UITextField! {
        didSet{
            locationTextField.placeholder = "location".localiz
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet{
            passwordTextField.placeholder = "password".localiz
        }
    }
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet{
            confirmPasswordTextField.placeholder = "vertifyPassword".localiz
        }
    }
    @IBOutlet weak var validateLabel: UILabel! {
        didSet{
            validateLabel.alpha = 0
        }
    }
    @IBOutlet weak var signUpNavigationItem: UINavigationItem! {
        didSet{
            signUpNavigationItem.title = "signUp".localiz
        }
    }
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.setTitle(NSLocalizedString("signUp", comment: ""), for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
    }
    @IBAction func signUpPressed(_ sender: Any) {
        if let image = userImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let name = nameTextField.text,
           let email = emailTextField.text,
           let phoneNumber = phoneNumberTextField.text,
           let location = locationTextField.text,
           let password = passwordTextField.text,
           let confirmPassword = confirmPasswordTextField.text,
        confirmPassword == password {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.validateLabel.text = "Error Creating User \(error.localizedDescription)"
                    self.validateLabel.alpha = 1
                    Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                }else {
                    if let authResult = authResult {
                        let storageRef = Storage.storage().reference(withPath: "users/\(authResult.user.uid)")
                        let uploadMeta = StorageMetadata.init()
                        uploadMeta.contentType = "image/jpeg"
                        storageRef.putData(imageData, metadata: uploadMeta) { storageMeta, error in
                            if let error = error {
                                self.validateLabel.text = "Sign Up Storage Error \(error.localizedDescription)"
                                self.validateLabel.alpha = 1
                            }else {
                                storageRef.downloadURL { url, error in
                                    if let error = error {
                                        self.validateLabel.text = "Sign Up Storage Download URL Error \(error.localizedDescription)"
                                        self.validateLabel.alpha = 1
                                    }else {
                                        if let url = url {
                                            let db = Firestore.firestore()
                                            let userData: [String:String] = [
                                                "id": authResult.user.uid,
                                                "name": name,
                                                "email": email,
                                                "phoneNumber":phoneNumber,
                                                "location":location,
                                                "imageUrl":url.absoluteString,
                                            ]
                                            db.collection("users").document(authResult.user.uid).setData(userData) { error in
                                                if let error = error {
                                                    self.validateLabel.text = "Sign Up Database Error \(error.localizedDescription)"
                                                    self.validateLabel.alpha = 1
                                                }else {
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
                        }
                    }
                }
            }
        }else {
            if confirmPasswordTextField.text != passwordTextField.text {
                validateLabel.text = "Vertefecation password error"
                validateLabel.alpha = 1
            }else {
                validateLabel.text = "Please fill the empty text fields"
                validateLabel.alpha = 1
            }
        }
    }
}
extension SignUpViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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

/*
 //            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
 //            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
 //                if let error = error {
 //                    self.validateLabel.text = "Error Creating User \(error.localizedDescription)"
 //                    self.validateLabel.alpha = 1
 //                    Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
 //                }else {
 //                    if let authResult = authResult {
 //                        let storageRef = Storage.storage().reference(withPath: "users/\(authResult.user.uid)")
 //                        let uploadMeta = StorageMetadata.init()
 //                        uploadMeta.contentType = "image/jpeg"
 //                        storageRef.putData(imageData, metadata: uploadMeta) { storageMeta, error in
 //                            if let error = error {
 //                                self.validateLabel.text = "Sign Up Storage Error \(error.localizedDescription)"
 //                                self.validateLabel.alpha = 1
 //                            }else {
 //                                storageRef.downloadURL { url, error in
 //                                    if let error = error {
 //                                        self.validateLabel.text = "Sign Up Storage Download URL Error \(error.localizedDescription)"
 //                                        self.validateLabel.alpha = 1
 //                                    }else {
 //                                        if let url = url {
 //                                            let db = Firestore.firestore()
 //                                            let userData: [String:String] = [
 //                                                "id": authResult.user.uid,
 //                                                "name": name,
 //                                                "email": email,
 //                                                "phoneNumber":phoneNumber,
 //                                                "location":location,
 //                                                "imageUrl":url.absoluteString,
 //                                            ]
 //                                            db.collection("users").document(authResult.user.uid).setData(userData) { error in
 //                                                if let error = error {
 //                                                    self.validateLabel.text = "Sign Up Database Error \(error.localizedDescription)"
 //                                                    self.validateLabel.alpha = 1
 //                                                }else {
 //                                                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeNavigationContoller") as? UINavigationController {
 //                                                        vc.modalPresentationStyle = .fullScreen
 //                                                        Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
 //                                                        self.present(vc, animated: true, completion: nil)
 //                                                    }
 //                                                }
 //                                            }
 //                                        }
 //                                    }
 //                                }
 //                            }
 //                        }
 //                    }
 //                }
 //            }
 //        }else {
 //            if confirmPasswordTextField.text != passwordTextField.text {
 //                validateLabel.text = "Vertefecation password error"
 //                validateLabel.alpha = 1
 //            }else {
 //                validateLabel.text = "Please fill the empty text fields"
 //                validateLabel.alpha = 1
 //            }
 */
