import AWSAuthCore
import AWSAuthUI

class AuthenticationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!AWSSignInManager.sharedInstance().isLoggedIn) {
            let config = AWSAuthUIConfiguration()
            config.enableUserPoolsUI = true
            config.disableSignUpButton = true
            config.backgroundColor = UIColor.white
            
            AWSAuthUIViewController.presentViewController(with: self.navigationController!, configuration: config, completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                    if (error == nil) {
                        self.performSegue(withIdentifier: "showInstanceTable", sender: self)
                    } else {
                        print(error?.localizedDescription as Any)
                    }
            })            
        } else {
            self.performSegue(withIdentifier: "showInstanceTable", sender: self)
        }
    }
}
