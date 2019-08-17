import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTextField.delegate = self
        passwordTextField.delegate = self
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        appDelegate.load()
        if (appDelegate.items.count == 1) {
            userTextField.text = appDelegate.items[0].value(forKeyPath: "name") as? String
            passwordTextField.text = appDelegate.items[0].value(forKeyPath: "password") as? String
        }
    }
    
    @IBAction func loginTouch(_ sender: Any) {
        if (userTextField.text == "") {
            let alertController = UIAlertController(title: "Login failed", message: "Please try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            appDelegate.save(name: userTextField.text ?? "", password: passwordTextField.text ?? "")
            
            self.performSegue(withIdentifier: "doLogin", sender: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            textField.resignFirstResponder()
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
