import Foundation
import Firebase

struct AdoptionPost {
    var id = ""
    var imageUrl = ""
    var petName = ""
    var petAge = ""
    var petGender = ""
    var petType = ""
    var petColor = ""
    var petSize = ""
    var houseTrained = ""
    var health = ""
    var petDescreption = ""
    var user: User
    var createdAt: Timestamp?
    init (dict:[String:Any],id:String,user:User) {
        if let petName = dict["petName"] as? String,
           let petAge = dict["petAge"] as? String,
           let petGender = dict["petGender"] as? String,
           let petType = dict["petType"] as? String,
           let petColor = dict["petColor"] as? String,
           let petSize = dict["petSize"] as? String,
           let houseTrained = dict["houseTrained"] as? String,
           let health = dict["health"] as? String,
           let petDescreption = dict["petDescreption"] as? String,
           let imageUrl = dict["imageUrl"] as? String,
           let createdAt = dict["createdAt"] as? Timestamp {
            self.petName = petName
            self.petAge = petAge
            self.petGender = petGender
            self.petType = petType
            self.petColor = petColor
            self.petSize = petSize
            self.houseTrained = houseTrained
            self.health = health
            self.petDescreption = petDescreption
            self.imageUrl = imageUrl
            self.createdAt = createdAt
        }
        self.id = id
        self.user = user
    }
}
