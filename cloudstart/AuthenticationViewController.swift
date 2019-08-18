import UIKit
import CoreData

class AuthenticationViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        if (hasValidCredentials()) {
            self.performSegue(withIdentifier: "doShowInstanceTable", sender: self)
        } else {
            self.performSegue(withIdentifier: "doShowLogin", sender: self)
        }
    }
    
    func hasValidCredentials() -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return false}
        appDelegate.load()
        // TODO: this obviously cannot stay like this once we have AWS SDK in place
        return (appDelegate.items.count == 1) && (appDelegate.items[0].value(forKey: "name") as? String != "")
    }
}
