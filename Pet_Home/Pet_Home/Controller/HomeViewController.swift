import UIKit
import Firebase

class HomeViewController: UIViewController {
    var adoptionPosts = [AdoptionPost]()
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
        getAdoptionPosts()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    // Upload The collection View Main Function.
    func getAdoptionPosts() {
        let ref = Firestore.firestore()
        ref.collection("posts").order(by: "createdAt",descending: true).addSnapshotListener { snapshot, error in
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
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("AdoptionPosts Count !!!!",adoptionPosts.count)
        print("AdoptionPosts !!!!",adoptionPosts)
        return adoptionPosts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdoptionPostsCollectionViewCell", for: indexPath) as! AdoptionPostsCollectionViewCell
        cell.backgroundColor = .systemBlue
        return cell.configure(with: adoptionPosts[indexPath.row])
    }
    
    
    
    @objc func goToProfile() {
        performSegue(withIdentifier: "fromHomeToProfile", sender: self)
    }
    @objc func goToPost() {
        performSegue(withIdentifier: "fromHomeToPost", sender: self)
    }
}
