import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var items: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTextField.delegate = self
        passwordTextField.delegate = self
        load()
        if (items.count == 1) {
            userTextField.text = items[0].value(forKeyPath: "name") as? String
            passwordTextField.text = items[0].value(forKeyPath: "password") as? String
        }
        
    }
    
    @IBAction func loginTouch(_ sender: Any) {
        if (userTextField.text == "") {
            let alertController = UIAlertController(title: "Login failed", message: "Please try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            save(name: userTextField.text ?? "", password: passwordTextField.text ?? "")
            self.performSegue(withIdentifier: "doLogin", sender: self)
        }
    }
    
    func save(name: String, password: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
        let item = NSManagedObject(entity: entity!, insertInto: managedContext)
        item.setValue(name, forKey: "name")
        item.setValue(password, forKey: "password")
        
        do {
            try managedContext.save()
            items.append(item)
        } catch let err as NSError {
            print("Failed to save an item", err)
        }
    }
    
    func load() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let err as NSError {
            print("Failed to fetch items", err)
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
