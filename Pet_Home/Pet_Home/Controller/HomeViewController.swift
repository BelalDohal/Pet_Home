import UIKit
import Firebase

class HomeViewController: UIViewController {
    var adoptionPosts = [AdoptionPost]()
    var selectedAdoptionPost:AdoptionPost?
    var selectedAdoptionPostImage:UIImage?
    let navigatedFrom = "Home"
    var hiddenSideMenu = true
    // Side Menue
    @IBOutlet weak var mainStackView: UIStackView! {
        didSet {
            //            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSideMenu))
            //            mainStackView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var sideMenuView: UIView! {
        didSet {
            sideMenuView.isHidden = true
            sideMenuView.layer.masksToBounds = true
            sideMenuView.layer.cornerRadius = 10
            sideMenuView.layer.borderColor = UIColor.systemGray2.cgColor
            sideMenuView.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var userImageAndNameView: UIView!
    @IBOutlet weak var gotoProfileButton: UIButton! {
        didSet {
            gotoProfileButton.setTitle(NSLocalizedString("profile", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var newPostButton: UIButton! {
        didSet {
            newPostButton.setTitle(NSLocalizedString("newPost", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var logOutButton: UIButton! {
        didSet {
            logOutButton.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var homeSerachBar: UISearchBar! {
        didSet {
            homeSerachBar.delegate = self
        }
    }
    @IBOutlet weak var leftSideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuSize: NSLayoutConstraint!
    // End of the Side Menue
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.circolarImage()
            userImageView.layer.borderWidth = 3
            userImageView.layer.borderColor = UIColor.systemGreen.cgColor
            userImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
            userImageView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addNewPostBarButton: UIBarButtonItem!
    @IBOutlet weak var userSideMenuButton: UIBarButtonItem!
    @IBOutlet weak var adoptionPostTabelView: UITableView! {
        didSet {
            adoptionPostTabelView.delegate = self
            adoptionPostTabelView.dataSource = self
        }
    }
    @IBOutlet weak var homeNavigationItem: UINavigationItem! {
        didSet {
            homeNavigationItem.title = "home".localiz
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
        sendTo?.navigatedFrom = navigatedFrom
    }
    @IBAction func newPostPressed(_ sender: Any) {
        goToPost()
    }
    @IBAction func sideMenuPressed(_ sender: Any) {
        hideAndShowSideMenu()
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
    @IBAction func profileSideMenuPressed(_ sender: Any) {
        goToProfile()
        hideSideMenu()
    }
    @IBAction func newPostSideMenuPressed(_ sender: Any) {
        goToPost()
        hideSideMenu()
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
                                    self.adoptionPostTabelView.beginUpdates()
                                    if snapshot.documentChanges.count != 1 {
                                        self.adoptionPosts.append(post)
                                        self.adoptionPostTabelView.insertRows(at: [IndexPath(row:self.adoptionPosts.count - 1,section: 0)],with: .automatic)
                                    }else {
                                        self.adoptionPosts.insert(post,at:0)
                                        self.adoptionPostTabelView.insertRows(at: [IndexPath(row: 0,section: 0)],with: .automatic)
                                    }
                                    self.adoptionPostTabelView.endUpdates()
                                }
                            }
                        }
                    case .modified:
                        let postId = diff.document.documentID
                        if let updateIndex = self.adoptionPosts.firstIndex(where: {$0.id == postId}) {
                            self.adoptionPostTabelView.beginUpdates()
                            self.adoptionPostTabelView.deleteRows(at: [IndexPath(row: updateIndex,section: 0)], with: .left)
                            self.adoptionPostTabelView.insertRows(at: [IndexPath(row: updateIndex,section: 0)],with: .left)
                            self.adoptionPostTabelView.endUpdates()
                        }
                    case .removed:
                        let postId = diff.document.documentID
                        if let deleteIndex = self.adoptionPosts.firstIndex(where: {$0.id == postId}){
                            self.adoptionPostTabelView.beginUpdates()
                            self.adoptionPostTabelView.deleteRows(at: [IndexPath(row: deleteIndex,section: 0)], with: .automatic)
                            self.adoptionPostTabelView.endUpdates()
                        }
                    }
                }
            }
        }
        adoptionPostTabelView.reloadData()
    }
    func hideAndShowSideMenu() {
        if hiddenSideMenu {
            UIView.animate(withDuration: 0.3) {
                self.sideMenuView.isHidden = false
                self.leftSideMenuConstraint.constant = -10
                self.view.layoutIfNeeded()
            } completion: { status in
                self.hiddenSideMenu = false
            }
        }else {
            UIView.animate(withDuration: 0.3) {
                self.leftSideMenuConstraint.constant = -270
                self.view.layoutIfNeeded()
            } completion: { status in
                self.hiddenSideMenu = true
                self.sideMenuView.isHidden = true
            }
        }
    }
    @objc func hideSideMenu() {
        if !hiddenSideMenu {
            UIView.animate(withDuration: 0.3) {
                self.leftSideMenuConstraint.constant = -270
                self.view.layoutIfNeeded()
            } completion: { status in
                self.hiddenSideMenu = true
                self.sideMenuView.isHidden = true
            }
        }
    }
    @objc func goToProfile() {
        performSegue(withIdentifier: "fromHomeToProfile", sender: self)
        hideSideMenu()
    }
    @objc func goToPost() {
        performSegue(withIdentifier: "fromHomeToPost", sender: self)
        hideSideMenu()
    }
}
extension HomeViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adoptionPosts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptionPostsTabelViewCell", for: indexPath) as! AdoptionPostsTableViewCell
        return cell.configure(with: adoptionPosts[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AdoptionPostsTableViewCell
        selectedAdoptionPost = adoptionPosts[indexPath.row]
        selectedAdoptionPostImage = cell.petImageView.image
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "fromHomeToDetails", sender: self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return adoptionPostTabelView.frame.width
    }
}
extension HomeViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var filtredData = [AdoptionPost]()
        if searchText == "" {
            getAdoptionPosts()
        }else {
            for i in adoptionPosts {
                if i.petType.lowercased().contains(searchText.lowercased()) || i.petType.lowercased().contains(searchText.lowercased()) || i.user.name.lowercased().contains(searchText.lowercased()) {
                    filtredData.append(i)
                }
            }
            adoptionPosts = filtredData
        }
        adoptionPostTabelView.reloadData()
    }
}

