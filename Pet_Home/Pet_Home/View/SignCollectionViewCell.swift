import UIKit

class SignCollectionViewCell: UICollectionViewCell {
    
    // Name
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = "name".localiz
        }
    }
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.fixTheTextField()
            nameTextField.delegate = self
        }
    }
    
    // Phone Number
    @IBOutlet weak var numberLabel: UILabel! {
        didSet {
            numberLabel.text = "phoneNumber".localiz
        }
    }
    @IBOutlet weak var numberTextField: UITextField! {
        didSet {
            numberTextField.fixTheTextField()
            numberTextField.delegate = self
        }
    }
    
    // Email
    @IBOutlet weak var emailLabel: UILabel! {
        didSet {
            emailLabel.text = "email".localiz
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.fixTheTextField()
            emailTextField.delegate = self
        }
    }
    
    // Password
    @IBOutlet weak var passwordLabel: UILabel! {
        didSet {
            passwordLabel.text = "password".localiz
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.fixTheTextField()
            passwordTextField.delegate = self
        }
    }
    
    // Confirm Password
    @IBOutlet weak var confirmPasswordLabel: UILabel! {
        didSet {
            confirmPasswordLabel.text = "vertifyPassword".localiz
        }
    }
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.fixTheTextField()
            confirmPasswordTextField.delegate = self
        }
    }
    
    // Buttons
    @IBOutlet weak var scrolingButton: UIButton!
    @IBOutlet weak var signButton: UIButton!
    
    // Error Label
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.alpha = 0
        }
    }
}
extension SignCollectionViewCell: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
