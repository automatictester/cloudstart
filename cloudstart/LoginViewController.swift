import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginTouch(_ sender: Any) {
        // TODO: login error handling with alert
        self.performSegue(withIdentifier: "doLogin", sender: self)
    }
}
