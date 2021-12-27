import UIKit
import Foundation
// Circler Image
extension UIImageView {
    func circolarImage() {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = true
    }
}

//

