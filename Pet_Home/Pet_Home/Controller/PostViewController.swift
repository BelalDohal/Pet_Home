import UIKit
import Firebase

class PostViewController: UIViewController {
    let imagePickerController = UIImagePickerController()
    let activityIndicator = UIActivityIndicatorView()
    @IBOutlet weak var petImageView: UIImageView! {
        didSet {
            petImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            petImageView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var petNameTextField: UITextField!
    @IBOutlet weak var petAgeTextField: UITextField!
    @IBOutlet weak var petGenderTextField: UITextField!
    @IBOutlet weak var petTypeTextField: UITextField!
    @IBOutlet weak var petDescreptionTextField: UITextView!
    @IBOutlet weak var creatNewPostButton: UIButton! {
        didSet {
            creatNewPostButton.layer.cornerRadius = creatNewPostButton.frame.height/2
            creatNewPostButton.layer.masksToBounds = true
        }
    }
    var selectedAdoptionPost:AdoptionPost?
    var selectedAdoptionPostImage:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        if let selectedAdoptionPost = selectedAdoptionPost,
           let selectedAdoptionPostImage = selectedAdoptionPostImage {
            petImageView.image = selectedAdoptionPostImage
            petNameTextField.text = selectedAdoptionPost.petName
            petAgeTextField.text = selectedAdoptionPost.petAge
            petGenderTextField.text = selectedAdoptionPost.petGender
            petTypeTextField.text = selectedAdoptionPost.petType
            petDescreptionTextField.text = selectedAdoptionPost.petDescreption
            creatNewPostButton.setTitle("Update Post", for: .normal)
            let deleteBarButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .plain, target: self, action: #selector(handleDelete))
            deleteBarButton.tintColor = .systemRed
            self.navigationItem.rightBarButtonItem = deleteBarButton
        }else {
            creatNewPostButton.setTitle("Add Post", for: .normal)
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
    // New Post
    @IBAction func creatNewPostPressed(_ sender: Any) {
        if let image = petImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let petName = petNameTextField.text,
           let petAge = petAgeTextField.text,
           let petGender = petGenderTextField.text,
           let petType = petTypeTextField.text,
           let petDescreption = petDescreptionTextField.text,
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
                            Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}
extension PostViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
        petImageView.image = selectImage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
/*
 */
