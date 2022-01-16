import UIKit
import Firebase

class ProfileViewController: UIViewController {
    var currentUserAdoptionPosts = [AdoptionPost]()
    var selectedAdoptionPost: AdoptionPost?
    var selectedAdoptionPostImage: UIImage?
    let navigatedFrom = "Profile"
    var hideSettingsMenuSwitch = true
    
    @IBOutlet weak var mainStackViewToDismis: UIStackView! {
        didSet {
            //            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSettingMenu))
            //            mainStackViewToDismis.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.circolarImage()
            userImageView.layer.borderWidth = 3
            userImageView.layer.borderColor = UIColor.systemGreen.cgColor
        }
    }
    @IBOutlet weak var currentUserPostLabel: UILabel! {
        didSet {
            currentUserPostLabel.text = "yourPosts".localiz
        }
    }
    @IBOutlet weak var toChangeProfileButton: UIButton! {
        didSet {
            toChangeProfileButton.setTitle(NSLocalizedString("updateProfile", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var toLanguageButton: UIButton! {
        didSet {
            toLanguageButton.setTitle(NSLocalizedString("languages", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var logoutButton: UIButton! {
        didSet {
            logoutButton.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var currentUserSearchBar: UISearchBar! {
        didSet {
            currentUserSearchBar.delegate = self
        }
    }
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var settingsMenuView: UIView! {
        didSet {
            settingsMenuView.layer.masksToBounds = true
            settingsMenuView.layer.cornerRadius = 15
            settingsMenuView.isHidden = true
            settingsMenuView.layer.borderWidth = 1
            settingsMenuView.layer.borderColor = UIColor.systemOrange.cgColor
        }
    }
    @IBOutlet weak var settingsStack: UIStackView! {
        didSet {
            settingsStack.alpha = 0
        }
    }
    @IBOutlet weak var settingsMenuHeightConstrant: NSLayoutConstraint!
    @IBOutlet weak var settingsMenuWidthConstrant: NSLayoutConstraint!
    @IBOutlet weak var newPostButton: UIButton! {
        didSet {
            newPostButton.setTitle(NSLocalizedString("creatNewPost", comment: ""), for: .normal)
            newPostButton.layer.cornerRadius = newPostButton.frame.height/2
            newPostButton.layer.masksToBounds = true
            newPostButton.layer.borderWidth = 1
            newPostButton.layer.borderColor = UIColor.systemOrange.cgColor
        }
    }
    @IBOutlet weak var userAdoptionPostsCollectionView: UITableView! {
        didSet {
            userAdoptionPostsCollectionView.delegate = self
            userAdoptionPostsCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var userLocationAndCity: UILabel!
    @IBOutlet weak var profileNavigationItem: UINavigationItem!
    @IBOutlet weak var goToSettingsNavegationItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentUserData()
        getAdoptionPosts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sendTo = segue.destination as? DetailsViewController
        sendTo?.selectedAdoptionPost = selectedAdoptionPost
        sendTo?.selectedAdoptionPostImage = selectedAdoptionPostImage
        sendTo?.navigatedFrom = navigatedFrom
    }
    @IBAction func dismesTheSettingView(_ sender: Any) {
        hideSettingMenu()
    }
    @IBAction func settingPressed(_ sender: Any) {
        if hideSettingsMenuSwitch {
            UIView.animate(withDuration: 0.3) {
                self.settingsMenuView.isHidden = false
                self.settingsMenuHeightConstrant.constant = 130
                self.settingsMenuWidthConstrant.constant = 150
                self.settingsStack.alpha = 1
                self.view.layoutIfNeeded()
            } completion: { status in
                self.hideSettingsMenuSwitch = false
            }
        }else {
            UIView.animate(withDuration: 0.3) {
                self.settingsMenuHeightConstrant.constant = 0
                self.settingsMenuWidthConstrant.constant = 0
                self.settingsStack.alpha = 0
                self.view.layoutIfNeeded()
            } completion: { status in
                self.hideSettingsMenuSwitch = true
                self.settingsMenuView.isHidden = true
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
                                self.profileNavigationItem.title = currentUserData.name
                                self.emailLabel.text = currentUserData.email
                                self.phoneNumberLabel.text = currentUserData.phoneNumber
                                self.userLocationAndCity.text = "\(currentUserData.location) - \(currentUserData.city)"
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
                                            self.userAdoptionPostsCollectionView.beginUpdates()
                                            if snapshot.documentChanges.count != 1 {
                                                self.currentUserAdoptionPosts.append(post)
                                                self.userAdoptionPostsCollectionView.insertRows(at: [IndexPath(row:self.currentUserAdoptionPosts.count - 1,section: 0)],with: .automatic)
                                            }else {
                                                self.currentUserAdoptionPosts.insert(post,at:0)
                                                self.userAdoptionPostsCollectionView.insertRows(at: [IndexPath(row: 0,section: 0)],with: .automatic)
                                            }
                                            self.userAdoptionPostsCollectionView.endUpdates()
                                        }
                                    }
                                }
                            }
                        }
                    case .modified:
                        let postId = diff.document.documentID
                        if let updateIndex = self.currentUserAdoptionPosts.firstIndex(where: {$0.id == postId}) {
                            self.userAdoptionPostsCollectionView.beginUpdates()
                            self.userAdoptionPostsCollectionView.deleteRows(at: [IndexPath(row: updateIndex,section: 0)], with: .left)
                            self.userAdoptionPostsCollectionView.insertRows(at: [IndexPath(row: updateIndex,section: 0)],with: .left)
                            self.userAdoptionPostsCollectionView.endUpdates()
                        }
                    case .removed:
                        let postId = diff.document.documentID
                        if let deleteIndex = self.currentUserAdoptionPosts.firstIndex(where: {$0.id == postId}){
                            self.userAdoptionPostsCollectionView.beginUpdates()
                            self.userAdoptionPostsCollectionView.deleteRows(at: [IndexPath(row: deleteIndex,section: 0)], with: .automatic)
                            self.userAdoptionPostsCollectionView.endUpdates()
                        }
                    }
                }
            }
        }
    }
    @objc func hideSettingMenu() {
        if !hideSettingsMenuSwitch {
            UIView.animate(withDuration: 0.3) {
                self.settingsMenuHeightConstrant.constant = 0
                self.settingsMenuWidthConstrant.constant = 0
                self.settingsStack.alpha = 0
                self.view.layoutIfNeeded()
            } completion: { status in
                self.hideSettingsMenuSwitch = true
                self.settingsMenuView.isHidden = true
            }
        }
    }
}
extension ProfileViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUserAdoptionPosts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentUserPosts", for: indexPath) as! AdoptionPostsTableViewCell
        return cell.configure(with: currentUserAdoptionPosts[indexPath.row])
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return userAdoptionPostsCollectionView.frame.width
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AdoptionPostsTableViewCell
        selectedAdoptionPost = currentUserAdoptionPosts[indexPath.row]
        selectedAdoptionPostImage = cell.petImageView.image
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "fromProfileToDetails", sender: self)
    }
}
extension ProfileViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var filtredData = [AdoptionPost]()
        if searchText == "" {
            getAdoptionPosts()
        }else {
            for i in currentUserAdoptionPosts {
                if i.petType.lowercased().contains(searchText.lowercased()) || i.petType.lowercased().contains(searchText.lowercased()) || i.user.name.lowercased().contains(searchText.lowercased()) {
                    filtredData.append(i)
                }
            }
            currentUserAdoptionPosts = filtredData
        }
        userAdoptionPostsCollectionView.reloadData()
    }
}
