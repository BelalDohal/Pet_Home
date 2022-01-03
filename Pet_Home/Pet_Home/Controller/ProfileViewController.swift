import UIKit
import Firebase

class ProfileViewController: UIViewController {
    var currentUserAdoptionPosts = [AdoptionPost]()
    var selectedAdoptionPost: AdoptionPost?
    var selectedAdoptionPostImage: UIImage?
    let navigatedFrom = "Profile"
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.circolarImage()
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
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
    @IBOutlet weak var userAdoptionPostsCollectionView: UICollectionView! {
        didSet {
            userAdoptionPostsCollectionView.delegate = self
            userAdoptionPostsCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var languageSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentUserData()
        getAdoptionPosts()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sendTo = segue.destination as? PostViewController
        sendTo?.selectedAdoptionPost = selectedAdoptionPost
        sendTo?.selectedAdoptionPostImage = selectedAdoptionPostImage
    }
    func getCurrentUserData() {
        let refrance = Firestore.firestore()
        if let currentUser = Auth.auth().currentUser {
            let currentUserId = currentUser.uid
            refrance.collection("users").document(currentUserId).getDocument { userSnapshot, error in
                if let error = error {
                    print("ERROR geting current user snapshot",error.localizedDescription)
                }else{
                    if let userSnapshot = userSnapshot {
                        let userData = userSnapshot.data()
                        if let userData = userData {
                            let currentUserData = User(dict: userData)
                            DispatchQueue.main.async {
                                self.nameLabel.text = currentUserData.name
                                self.emailLabel.text = currentUserData.email
                                self.locationLabel.text = currentUserData.location
                                self.phoneNumberLabel.text = currentUserData.phoneNumber
                                self.userImageView.loadImageUsingCache(with: currentUserData.imageUrl)
                            }
                        }else {
                            print("User data not found or not the same !!!!!!!!!!!!!")
                        }
                    }
                }
            }
        }
    }
    func getAdoptionPosts() {
        let ref = Firestore.firestore()
        ref.collection("posts").order(by: "updatedAt",descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                print("DB ERROR Posts",error.localizedDescription)
            }
            if let snapshot = snapshot {
                snapshot.documentChanges.forEach { diff in
                    let post = diff.document.data()
                    switch diff.type {
                    case .added :
                        if let userId = post["userId"] as? String {
                            if let currentUser = Auth.auth().currentUser {
                                let currentUserId = currentUser.uid
                                if currentUserId == userId {
                                    ref.collection("users").document(userId).getDocument { userSnapshot, error in
                                        if let error = error {
                                            print("ERROR user Data",error.localizedDescription)
                                        }
                                        if let userSnapshot = userSnapshot,
                                           let userData = userSnapshot.data(){
                                            let user = User(dict:userData)
                                            let post = AdoptionPost(dict:post,id:diff.document.documentID,user:user)
                                            self.currentUserAdoptionPosts.insert(post, at: 0)
                                            DispatchQueue.main.async {
                                                self.userAdoptionPostsCollectionView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    case .modified:
                        let postId = diff.document.documentID
                        if let currentPost = self.currentUserAdoptionPosts.first(where: {$0.id == postId}),
                           let updateIndex = self.currentUserAdoptionPosts.firstIndex(where: {$0.id == postId}){
                            let newPost = AdoptionPost(dict:post, id: postId, user: currentPost.user)
                            self.currentUserAdoptionPosts[updateIndex] = newPost
                            DispatchQueue.main.async {
                                self.userAdoptionPostsCollectionView.reloadData()
                            }
                        }
                    case .removed:
                        let postId = diff.document.documentID
                        if let deleteIndex = self.currentUserAdoptionPosts.firstIndex(where: {$0.id == postId}){
                            self.currentUserAdoptionPosts.remove(at: deleteIndex)
                            DispatchQueue.main.async {
                                self.userAdoptionPostsCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
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
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentUserAdoptionPosts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdoptionPostsCollectionViewCell", for: indexPath) as! AdoptionPostsCollectionViewCell
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        return cell.configure(with: currentUserAdoptionPosts[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellLayout = CGSize(width: userAdoptionPostsCollectionView.frame.width-15, height: userAdoptionPostsCollectionView.frame.height/2.5)
        return cellLayout
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AdoptionPostsCollectionViewCell
        selectedAdoptionPost = currentUserAdoptionPosts[indexPath.row]
        selectedAdoptionPostImage = cell.petImageView.image
        collectionView.deselectItem(at: indexPath, animated: false)
        performSegue(withIdentifier: "fromProfileToDetails", sender: self)
    }
}
