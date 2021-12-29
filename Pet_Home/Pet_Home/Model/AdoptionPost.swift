import Foundation
import Firebase

struct AdoptionPost {
    var id = ""
    var petImageUrl = ""
    var petName = ""
    var petAge = ""
    var petGender = ""
    var petType = ""
    var petDescreption = ""
    var user: User
    var creatAt: Timestamp?
    init (dict:[String:Any],id:String,user:User) {
        if let petImageUrl = dict["petImageUrl"] as? String,
           let petName = dict["petname"] as? String,
           let petAge = dict["petAge"] as? String,
           let petGender = dict["petGender"] as? String,
           let petDescreption = dict["petDescreption"] as? String,
           let petType = dict["petType"] as? String {
            self.petImageUrl = petImageUrl
            self.petName = petName
            self.petAge = petAge
            self.petGender = petGender
            self.petType = petType
            self.petDescreption = petDescreption
        }
        self.id = id
        self.user = user
    }
}
