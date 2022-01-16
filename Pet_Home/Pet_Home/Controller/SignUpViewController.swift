import UIKit
import Firebase

class SignUpViewController: UIViewController {
    let countries = ["Riyadh","Jeddah","Dammam","Al-Khobar","Dhahran","Al-Ahsa","Qatif","Jubail","Taif","Tabouk","Abha","Al Baha","Jizan","Najran","Hail","Makkah AL-Mukkaramah","AL-Madinah Al-Munawarah","Al Qaseem","Jouf","Yanbu"]
    var filter = [String]()
    let imagePickerController = UIImagePickerController()
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.circolarImage()
            userImageView.layer.borderWidth = 3
            userImageView.layer.borderColor = UIColor.systemGreen.cgColor
            userImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            userImageView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var signUpView: UIStackView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
            signUpView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var signUpNavigationController: UINavigationItem!
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = "name".localiz
        }
    }
    @IBOutlet weak var emailLabel: UILabel! {
        didSet {
            emailLabel.text = "email".localiz
        }
    }
    @IBOutlet weak var locationLabel: UILabel! {
        didSet {
            locationLabel.text = "location".localiz
        }
    }
    @IBOutlet weak var cityLabel: UILabel! {
        didSet {
            cityLabel.text = "city".localiz
        }
    }
    @IBOutlet weak var phoneNumberLabel: UILabel! {
        didSet {
            phoneNumberLabel.text = "phoneNumber".localiz
        }
    }
    @IBOutlet weak var passwordLabel: UILabel! {
        didSet {
            passwordLabel.text = "password".localiz
        }
    }
    @IBOutlet weak var confirmPasswordLabel: UILabel! {
        didSet {
            confirmPasswordLabel.text = "confirmPassword".localiz
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.fixTheTextField()
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.fixTheTextField()
        }
    }
    @IBOutlet weak var locationTextField: UITextField! {
        didSet {
            locationTextField.delegate = self
            locationTextField.addTarget(self, action: #selector(searchRecord(from:)), for: .editingChanged)
            locationTextField.fixTheTextField()
        }
    }
    @IBOutlet weak var cityTextField: UITextField! {
        didSet {
            cityTextField.fixTheTextField()
        }
    }
    @IBOutlet weak var phoneNumberTextField: UITextField! {
        didSet {
            phoneNumberTextField.fixTheTextField()
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.fixTheTextField()
        }
    }
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.fixTheTextField()
        }
    }
    
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.layer.masksToBounds = true
            signUpButton.layer.cornerRadius = signUpButton.frame.height/2
            signUpButton.layer.borderWidth = 1
            signUpButton.layer.borderColor = UIColor.systemOrange.cgColor
            signUpButton.setTitle(NSLocalizedString("signUp", comment: ""), for: .normal)
        }
    }
    
    @IBOutlet weak var locationsTableView: UITableView! {
        didSet {
            locationsTableView.delegate = self
            locationsTableView.dataSource = self
            locationsTableView.alpha = 0
            locationsTableView.isHidden = true
            locationsTableView.backgroundColor = .systemGray6
            locationsTableView.layer.masksToBounds = true
            locationsTableView.layer.cornerRadius = 5
            locationsTableView.layer.borderWidth = 1
            locationsTableView.layer.borderColor = UIColor.systemGray.cgColor
        }
    }
    
    @IBOutlet weak var locationsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationTableViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.alpha = 0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        filter = countries
    }
    @IBAction func signUpPressed() {
        if let image = userImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let name = nameTextField.text,
           let email = emailTextField.text,
           let location = locationTextField.text,
           let city = cityTextField.text,
           let phoneNumber = phoneNumberTextField.text,
           let password = passwordTextField.text,
           let confirmPassword = confirmPasswordTextField.text,
           confirmPassword == password,
           countries.contains(location) {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    if error.localizedDescription == "The email address is badly formatted." {
                        self.errorLabel.text = "errorBadEmail".localiz
                    }else if error.localizedDescription == "The password must be 6 characters long or more." {
                        self.errorLabel.text = "errorPasswordCharacters".localiz
                    }
                    self.errorLabel.alpha = 1
                    Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
                }else {
                    if let authResult = authResult {
                        let storageRef = Storage.storage().reference(withPath: "users/\(authResult.user.uid)")
                        let uploadMeta = StorageMetadata.init()
                        uploadMeta.contentType = "image/jpeg"
                        storageRef.putData(imageData, metadata: uploadMeta) { storageMeta, error in
                            if let error = error {
                                self.errorLabel.text = "Sign Up Storage Error \(error.localizedDescription)"
                                self.errorLabel.alpha = 1
                            }else {
                                storageRef.downloadURL { url, error in
                                    if let error = error {
                                        self.errorLabel.text = "Sign Up Storage Download URL Error \(error.localizedDescription)"
                                        self.errorLabel.alpha = 1
                                    }else {
                                        if let url = url {
                                            let db = Firestore.firestore()
                                            let userData: [String:String] = [
                                                "id": authResult.user.uid,
                                                "name": name,
                                                "email": email,
                                                "phoneNumber":phoneNumber,
                                                "location":location,
                                                "city":city,
                                                "imageUrl":url.absoluteString,
                                            ]
                                            db.collection("users").document(authResult.user.uid).setData(userData) { error in
                                                if let error = error {
                                                    self.errorLabel.text = "Sign Up Database Error \(error.localizedDescription)"
                                                    self.errorLabel.alpha = 1
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
            if confirmPasswordTextField.text != passwordTextField.text {
                errorLabel.text = "vertrficationPaswordError".localiz
                errorLabel.alpha = 1
            }else if phoneNumberTextField.text == nil || nameTextField.text == nil {
                errorLabel.text = "errorEmptySpace".localiz
                errorLabel.alpha = 1
            }else {
                errorLabel.text = "pleaseSellictTheCurrectLocation".localiz
                errorLabel.alpha = 1
            }
        }
    }
    @objc func hideLocationsTableView() {
        UIView.animate(withDuration: 0.3) {
            self.locationsTableView.alpha = 0
            self.locationsTableViewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        } completion: { status in
            self.locationsTableView.isHidden = true
        }
    }
    func displayLocationsTableView() {
        UIView.animate(withDuration: 0.3) {
            self.locationsTableView.alpha = 1
            self.locationsTableViewHeightConstraint.constant = 150
            self.view.layoutIfNeeded()
        } completion: { status in
            self.locationsTableView.isHidden = false
        }
    }
    @objc func searchRecord(from textField:UITextField) {
        displayLocationsTableView()
        filter = []
        if let searchText = textField.text {
            if searchText.isEmpty  {
                filter = countries
            }else {
                for country in countries {
                    if country.lowercased().contains(searchText.lowercased()) {
                        filter.append(country)
                    }
                }
            }
        }
        locationsTableView.reloadData()
    }
    @objc func closeKeyboard() {
        self.view.endEditing(true)
        hideLocationsTableView()
    }
}
extension SignUpViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        var contant = cell.defaultContentConfiguration()
        contant.text = filter[indexPath.row]
        cell.contentConfiguration = contant
        cell.backgroundColor = .systemGray6
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationTextField.text = filter[indexPath.row]
        hideLocationsTableView()
    }
}
extension SignUpViewController:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        displayLocationsTableView()
        return true
    }
}
extension SignUpViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @objc func selectImage() {
        showAlert()
    }
    func showAlert() {
        let alert = UIAlertController(title: "Chose Profile Picture".localiz, message: "Pick From ?".localiz, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera".localiz, style: .default) { Action in
            self.getImage(from: .camera)
        }
        let galaryAction = UIAlertAction(title: "Photo Album".localiz, style: .default) { Action in
            self.getImage(from: .photoLibrary)
        }
        let dismessAction = UIAlertAction(title: "Cancle".localiz, style: .destructive) { Action in
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
