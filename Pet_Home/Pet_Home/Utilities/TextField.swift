import UIKit

extension UITextField {
    func fixTheTextField() {
        self.layer.borderWidth = 1
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.layer.borderColor = UIColor.systemGray.cgColor
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        self.leftViewMode = .always
        self.layer.cornerRadius = self.frame.height/4
    }
}
