import UIKit

extension UITextField {
    func fixTheTextField() {
        self.layer.borderWidth = 1
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.layer.borderColor = UIColor.systemGreen.cgColor
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        self.leftViewMode = .always
        self.layer.cornerRadius = 4
    }
}
