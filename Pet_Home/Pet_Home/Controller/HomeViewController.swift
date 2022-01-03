import UIKit
import Firebase

class HomeViewController: UIViewController {
    var adoptionPosts = [AdoptionPost]()
    var selectedAdoptionPost:AdoptionPost?
    var selectedAdoptionPostImage:UIImage?
    var posterImage:UIImage?
    let navigatedFrom = "Home"
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.circolarImage()
            userImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
            userImageView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addNewPostImageView: UIImageView! {
        didSet {
            addNewPostImageView.circolarImage()
            addNewPostImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPost))
            addNewPostImageView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var adoptionPostCollectionView: UICollectionView! {
        didSet {
            adoptionPostCollectionView.delegate = self
            adoptionPostCollectionView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentUserData()
        getAdoptionPosts()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sendTo = segue.destination as? DetailsViewController
        sendTo?.selectedAdoptionPost = selectedAdoptionPost
        sendTo?.selectedAdoptionPostImage = selectedAdoptionPostImage
        sendTo?.posterImage = posterImage
    }
    // Upload The Current User Data Function.
    func getCurrentUserData() {
        let refrance = Firestore.firestore()
        if let currentUser = Auth.auth().currentUser {
            let currentUserId = currentUser.uid
            refrance.collection("users").document(currentUserId).getDocument { userSnapshot, error in
                if let error = error {
                    print("error geting user Snapshot For User Name",error.localizedDescription)
                }else{
                    if let userSnapshot = userSnapshot {
                        let userData = userSnapshot.data()
                        if let userData = userData {
                            let currentUserData = User(dict: userData)
                            DispatchQueue.main.async {
                                self.userNameLabel.text = currentUserData.name
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
    // Upload The collection View Main Function.
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
                            ref.collection("users").document(userId).getDocument { userSnapshot, error in
                                if let error = error {
                                    print("ERROR user Data",error.localizedDescription)
                                }
                                if let userSnapshot = userSnapshot,
                                   let userData = userSnapshot.data(){
                                    let user = User(dict:userData)
                                    let post = AdoptionPost(dict:post,id:diff.document.documentID,user:user)
                                    self.adoptionPosts.insert(post, at: 0)
                                    DispatchQueue.main.async {
                                        self.adoptionPostCollectionView.reloadData()
                                    }
                                }
                            }
                        }
                    case .modified:
                        let postId = diff.document.documentID
                        if let currentPost = self.adoptionPosts.first(where: {$0.id == postId}),
                           let updateIndex = self.adoptionPosts.firstIndex(where: {$0.id == postId}){
                            let newPost = AdoptionPost(dict:post, id: postId, user: currentPost.user)
                            self.adoptionPosts[updateIndex] = newPost
                            DispatchQueue.main.async {
                                self.adoptionPostCollectionView.reloadData()
                            }
                        }
                    case .removed:
                        let postId = diff.document.documentID
                        if let deleteIndex = self.adoptionPosts.firstIndex(where: {$0.id == postId}){
                            self.adoptionPosts.remove(at: deleteIndex)
                            DispatchQueue.main.async {
                                self.adoptionPostCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adoptionPosts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdoptionPostsCollectionViewCell", for: indexPath) as! AdoptionPostsCollectionViewCell
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        return cell.configure(with: adoptionPosts[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellLayout = CGSize(width: adoptionPostCollectionView.frame.width-15, height: adoptionPostCollectionView.frame.height/2.5)
        return cellLayout
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AdoptionPostsCollectionViewCell
        selectedAdoptionPost = adoptionPosts[indexPath.row]
        selectedAdoptionPostImage = cell.petImageView.image
        posterImage = cell.ownerImageView.image
        collectionView.deselectItem(at: indexPath, animated: false)
        performSegue(withIdentifier: "fromHomeToDetails", sender: self)
    }
    @objc func goToProfile() {
        performSegue(withIdentifier: "fromHomeToProfile", sender: self)
    }
    @objc func goToPost() {
        performSegue(withIdentifier: "fromHomeToPost", sender: self)
    }
}
