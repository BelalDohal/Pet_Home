import UIKit

class LanguageViewController: UIViewController {
    @IBOutlet weak var laguagesTableView: UITableView! {
        didSet {
            laguagesTableView.delegate = self
            laguagesTableView.dataSource = self
        }
    }
    let languages = ["English","العربية"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBOutlet weak var languageNavigationItem: UINavigationItem! {
        didSet {
            languageNavigationItem.title = "languages".localiz
        }
    }
    func changeTheLanguagePressed(language: String ) {
        if language == "English" {
            UserDefaults.standard.set("setLanguage", forKey: "currentLanguage")
            Bundle.setLanguage("en")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController =                     storyboard.instantiateViewController(withIdentifier: "HomeNavigationContoller") as? UINavigationController
            }
        }else if language == "العربية" {
            UserDefaults.standard.set("ar", forKey: "currentLanguage")
            Bundle.setLanguage("ar")
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeNavigationContoller") as? UINavigationController
            }
        }
    }
}
extension LanguageViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languagesCell", for: indexPath) as! LanguagesTableViewCell
        cell.languageLabel.text = languages[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeTheLanguagePressed(language: languages[indexPath.row])
    }
}
