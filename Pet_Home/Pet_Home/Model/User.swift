import Foundation
import Firebase

struct User {
    var id = ""
    var name = ""
    var email = ""
    var imageUrl = ""
    var phoneNumber = ""
    init (dict:[String:Any]) {
        if let id = dict["id"] as? String,
           let name = dict["name"] as? String,
           let imageUrl = dict["imageUrl"] as? String,
           let email = dict["email"] as? String,
           let phoneNumber = dict["phoneNumber"] as? String {
            self.id = id
            self.name = name
            self.imageUrl = imageUrl
            self.email = email
            self.phoneNumber = phoneNumber
        }
    }
}
