import UIKit
import Firebase

class PostViewController: UIViewController {
    let imagePickerController = UIImagePickerController()
    var navigateFrom = "Home"
    @IBOutlet weak var postNavigationItem: UINavigationItem!
    // Labels
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petTypeLabel: UILabel!
    @IBOutlet weak var petColorLabel: UILabel!
    @IBOutlet weak var petSizeLabel: UILabel!
    @IBOutlet weak var betAgeLabel: UILabel!
    @IBOutlet weak var petGenderLabel: UILabel!
    @IBOutlet weak var trainedLabel: UILabel!
    @IBOutlet weak var vaccinatedLabel: UILabel!
    
    @IBOutlet weak var petImageView: UIImageView! {
        didSet {
            petImageView.layer.masksToBounds = true
            petImageView.layer.cornerRadius = 15
            petImageView.layer.borderWidth = 1
            petImageView.layer.borderColor = UIColor.systemGreen.cgColor
            petImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            petImageView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var petDescreptionStackView: UIStackView! {
        didSet {
            petDescreptionStackView.layer.masksToBounds = true
            petDescreptionStackView.layer.cornerRadius = 15
            petDescreptionStackView.layer.borderWidth = 1
            petDescreptionStackView.layer.borderColor = UIColor.systemOrange.cgColor
        }
    }
    // Switches
    @IBOutlet weak var trainedSwitch: UISwitch!
    var trained: (UISwitch) -> String = { trainedSwitch in
        if trainedSwitch.isOn {
            return "Traned"
        }else {
            return "Untraned"
        }
    }
    @IBOutlet weak var vaccinatrdSwitch: UISwitch!
    var vaccinated: (UISwitch) -> String = { vaccinat in
        if vaccinat.isOn {
            return "Vaccinated"
        }else {
            return "Unvaccinated"
        }
    }
    
    @IBOutlet weak var sizeTextField: UITextField! {
        didSet {
            sizeTextField.fixTheTextField()
            sizeTextField.placeholder = "size".localiz
        }
    }
    @IBOutlet weak var colorTextField: UITextField! {
        didSet {
            colorTextField.fixTheTextField()
            colorTextField.placeholder = "color".localiz
        }
    }
    @IBOutlet weak var petNameTextField: UITextField! {
        didSet {
            petNameTextField.fixTheTextField()
            petNameTextField.placeholder = "petName".localiz
        }
    }
    @IBOutlet weak var petAgeTextField: UITextField! {
        didSet {
            petAgeTextField.fixTheTextField()
            petAgeTextField.placeholder = "petAge".localiz
        }
    }
    @IBOutlet weak var petGenderTextField: UITextField! {
        didSet {
            petGenderTextField.fixTheTextField()
            petGenderTextField.placeholder = "petGender".localiz
        }
    }
    @IBOutlet weak var petTypeTextField: UITextField! {
        didSet {
            petTypeTextField.fixTheTextField()
            petTypeTextField.placeholder = "petType".localiz
        }
    }
    @IBOutlet weak var petDescreptionLabel: UILabel! {
        didSet {
            petDescreptionLabel.text = "descreption".localiz
        }
    }
    @IBOutlet weak var petDescreptionTextField: UITextView!
    @IBOutlet weak var creatNewPostButton: UIButton! {
        didSet {
            creatNewPostButton.layer.cornerRadius = creatNewPostButton.frame.height/2
            creatNewPostButton.layer.masksToBounds = true
            creatNewPostButton.layer.borderWidth = 1
            creatNewPostButton.layer.borderColor = UIColor.systemOrange.cgColor
        }
    }
    var selectedAdoptionPost:AdoptionPost?
    var selectedAdoptionPostImage:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        if let selectedAdoptionPost = selectedAdoptionPost,
           let selectedAdoptionPostImage = selectedAdoptionPostImage {
            postNavigationItem.title = "update".localiz
            petImageView.image = selectedAdoptionPostImage
            petNameTextField.text = selectedAdoptionPost.petName
            petAgeTextField.text = selectedAdoptionPost.petAge
            petGenderTextField.text = selectedAdoptionPost.petGender
            petTypeTextField.text = selectedAdoptionPost.petType
            colorTextField.text = selectedAdoptionPost.petColor
            sizeTextField.text = selectedAdoptionPost.petSize
            if selectedAdoptionPost.health == "Vaccinated" {
                vaccinatrdSwitch.isOn = true
            }else {
                vaccinatrdSwitch.isOn = false
            }
            if selectedAdoptionPost.houseTrained == "Untraned" {
                trainedSwitch.isOn = false
            }else {
                trainedSwitch.isOn = true
            }
            petDescreptionTextField.text = selectedAdoptionPost.petDescreption
            creatNewPostButton.setTitle(NSLocalizedString("updatePost", comment: ""), for: .normal)
            let deleteBarButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .plain, target: self, action: #selector(handleDelete))
            deleteBarButton.tintColor = .systemRed
            self.navigationItem.rightBarButtonItem = deleteBarButton
        }else {
            postNavigationItem.title = "newPost".localiz
            creatNewPostButton.setTitle(NSLocalizedString("addPost", comment: ""), for: .normal)
        }
    }
    // Delete
    @objc func handleDelete() {
        let ref = Firestore.firestore().collection("posts")
        if let selectedAdoptionPost = selectedAdoptionPost {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            ref.document(selectedAdoptionPost.id).delete { error in
                if let error = error {
                    print("Error in db delete",error)
                }else {
                    let storageRef = Storage.storage().reference(withPath: "posts/\(selectedAdoptionPost.user.id)/\(selectedAdoptionPost.id)")
                    storageRef.delete { error in
                        if let error = error {
                            print("Error in storage delete",error)
                        } else {
                            if self.navigateFrom == "Home" {
                                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeNavigationContoller") as? UINavigationController {
                                    vc.modalPresentationStyle = .fullScreen
                                    Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
                                    self.present(vc, animated: true, completion: nil)
                                }else{
                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileViewController") as UIViewController
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
    // New Post
    @IBAction func creatNewPostPressed(_ sender: Any) {
        if let image = petImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let petName = petNameTextField.text,
           let petAge = petAgeTextField.text,
           let petGender = petGenderTextField.text,
           let petType = petTypeTextField.text,
           let petDescreption = petDescreptionTextField.text,
           let petSize = sizeTextField.text,
           let petColor = colorTextField.text,
           let currentUser = Auth.auth().currentUser {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            var postId = ""
            if let selectedAdoptionPost = selectedAdoptionPost {
                postId = selectedAdoptionPost.id
            }else {
                postId = "\(Firebase.UUID())"
            }
            let storageRef = Storage.storage().reference(withPath: "posts/\(currentUser.uid)/\(postId)")
            let updloadMeta = StorageMetadata.init()
            updloadMeta.contentType = "image/jpeg"
            storageRef.putData(imageData, metadata: updloadMeta) { storageMeta, error in
                if let error = error {
                    print("Upload error",error.localizedDescription)
                }
                storageRef.downloadURL { url, error in
                    var postData = [String:Any]()
                    if let url = url {
                        let db = Firestore.firestore()
                        let ref = db.collection("posts")
                        if let selectedAdoptionPost = self.selectedAdoptionPost {
                            postData = [
                                "userId":selectedAdoptionPost.user.id,
                                "petName":petName,
                                "petAge":petAge,
                                "petGender":petGender,
                                "petType":petType,
                                "petColor":petColor,
                                "petSize":petSize,
                                "houseTrained":self.trained(self.trainedSwitch),
                                "health":self.vaccinated(self.vaccinatrdSwitch),
                                "petDescreption":petDescreption,
                                "imageUrl":url.absoluteString,
                                "createdAt":selectedAdoptionPost.createdAt ?? FieldValue.serverTimestamp(),
                                "updatedAt": FieldValue.serverTimestamp()
                            ]
                        }else {
                            postData = [
                                "userId":currentUser.uid,
                                "petName":petName,
                                "petAge":petAge,
                                "petGender":petGender,
                                "petType":petType,
                                "petColor":petColor,
                                "petSize":petSize,
                                "houseTrained":self.trained(self.trainedSwitch),
                                "health":self.vaccinated(self.vaccinatrdSwitch),
                                "petDescreption":petDescreption,
                                "imageUrl":url.absoluteString,
                                "createdAt":FieldValue.serverTimestamp(),
                                "updatedAt": FieldValue.serverTimestamp()
                            ]
                        }
                        ref.document(postId).setData(postData) { error in
                            if let error = error {
                                print("FireStore Error",error.localizedDescription)
                            }
                            Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
                            if self.navigateFrom == "Home" {
                                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeNavigationContoller") as? UINavigationController {
                                    vc.modalPresentationStyle = .fullScreen
                                    Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
                                    self.present(vc, animated: true, completion: nil)
                                }else{
                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileViewController") as UIViewController
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
    func showDeleteAlert() {
        let deletePostAlert = UIAlertController(title: "Delete Post", message: "Are you shore you want do delete this post", preferredStyle: .alert)
        deletePostAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { Action in
            let ref = Firestore.firestore().collection("posts")
            if let selectedAdoptionPost = self.selectedAdoptionPost {
                Activity.showIndicator(parentView: self.view, childView: activityIndicator)
                ref.document(selectedAdoptionPost.id).delete { error in
                    if let error = error {
                        print("Error in db delete",error)
                    }else {
                        let storageRef = Storage.storage().reference(withPath: "posts/\(selectedAdoptionPost.user.id)/\(selectedAdoptionPost.id)")
                        storageRef.delete { error in
                            if let error = error {
                                print("Error in storage delete",error)
                            } else {
                                if self.navigateFrom == "Home" {
                                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeNavigationContoller") as? UINavigationController {
                                        vc.modalPresentationStyle = .fullScreen
                                        Activity.removeIndicator(parentView: self.view, childView: activityIndicator)
                                        self.present(vc, animated: true, completion: nil)
                                    }else{
                                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileViewController") as UIViewController
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
        }))
        deletePostAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(deletePostAlert, animated: true)
    }
}
extension PostViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
        let dismessAction = UIAlertAction(title: "Cancle".localiz, style: .destructive) { Action in }
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
        petImageView.image = selectImage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
