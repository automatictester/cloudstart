import AWSAuthCore
import CoreData
import UIKit

class InstanceTableViewController: UITableViewController {
    
    var instances = [Instance]()
    var lambdaError: String?
    
    @IBOutlet weak var status: UIBarButtonItem!
    @IBOutlet weak var error: UIBarButtonItem!
    
    @IBAction func ErrorOnTap(_ sender: Any) {
        showErrorPopup(lambdaError!)
    }
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocalDataStore")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Error loading persistent container: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveCoreData() {
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "LocalDataStore", in: context)
        for instance in instances {
            let newCoreDataItem = NSManagedObject(entity: entity!, insertInto: context)
            newCoreDataItem.setValue(instance.getInstanceId(), forKey: "instanceId")
            newCoreDataItem.setValue(instance.getInstanceType(), forKey: "instanceType")
            newCoreDataItem.setValue(instance.getState(), forKey: "state")
            newCoreDataItem.setValue(instance.getName(), forKey: "name")
        }
        do {
            try context.save()
            print("CoreData saved: \(instances.count)")
        } catch {
            print("CoreData save failed: \(error.localizedDescription)")
        }
    }
    
    func flushCoreData() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalDataStore")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            print("CoreData flushed")
        } catch {
            print("CoreData flush failed: \(error.localizedDescription)")
        }
    }
    
    func loadCoreData() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalDataStore")
        do {
            let coreDataItems = try context.fetch(fetchRequest)
            let tempInstances = fromNSManagedObjectToInstanceArray(coreDataItems)
            instances = InstanceListSorter.sortInstances(tempInstances)
            refreshTable()
            print("CoreData loaded: \(coreDataItems.count)")
        } catch {
            print("CoreData load failed: \(error.localizedDescription)")
        }
    }
    
    func fromNSManagedObjectToInstanceArray(_ objects: [NSManagedObject]) -> [Instance] {
        var instances = [Instance]()
        for object in objects {
            let instanceId = (object.value(forKey: "instanceId") as! String)
            let instanceType = (object.value(forKey: "instanceType") as! String)
            let name = (object.value(forKey: "name") as! String)
            let state = (object.value(forKey: "state") as! String)
            let instance = Instance(instanceId: instanceId, instanceType: instanceType, state: state, name: name)
            instances.append(instance)
        }
        return instances
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationAuthorizer.requestAuthorization()
        registerForNotifications()
        setToolbarFont()
        enableTableRefresh()
        loadCoreData()
        requestInitialTableLoad()
        self.tableView.accessibilityIdentifier = "instanceTable"
    }
    
    func registerForNotifications() {
        registerForInstanceListUpdatedNotification()
        registerForInstanceListUpdateFailedNotification()
        registerForInstanceStateChangedNotification()
    }
    
    func registerForInstanceListUpdatedNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(instanceListUpdated), name: Notification.Name("InstanceListUpdated"), object: nil)
    }
    
    func registerForInstanceListUpdateFailedNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(instanceListUpdateFailed), name: Notification.Name("InstanceListUpdateFailed"), object: nil)
    }
    
    func registerForInstanceStateChangedNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(instanceStateChanged), name: Notification.Name("InstanceStateChanged"), object: nil)
    }
    
    func requestInitialTableLoad() {
        updateStatusBeforeRefresh()
        AwsLambdaProxy.authenticate()
        AwsLambdaProxy.invokeGetInstancesApi()
    }
    
    func enableTableRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshInstanceList), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    func setToolbarFont() {
        status.setTitleTextAttributes(
            [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 14)!],
            for: .normal
        )
        error.setTitleTextAttributes(
            [NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 14)!],
            for: .normal
        )
    }
    
    // handle notification
    @objc func instanceListUpdated(notification: Notification) {
        refreshData(notification)
        refreshTable()
        updateStatusAfterRefresh()
        cleanLambdaInvocationError()
    }
    
    // handle notification
    @objc func instanceListUpdateFailed(notification: Notification) {
        updateStatus("Update failed")
        updateError("Error")
        lambdaError = notification.userInfo!["errorMessage"] as? String
    }
    
    // handle notification
    @objc func instanceStateChanged(notification: Notification) {
        AwsLambdaProxy.invokeGetInstancesApi()
    }
    
    func refreshData(_ notification: Notification) {
        let notificationData = notification.userInfo!
        let tempInstances = notificationData["instances"] as! [Instance]
        print("New data received: \(tempInstances.count)")
        instances = InstanceListSorter.sortInstances(tempInstances)
        flushCoreData()
        saveCoreData()
    }
    
    func refreshTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func updateStatusBeforeRefresh() {
        updateStatus("Updating...")
    }
    
    func updateStatus(_ text: String) {
        DispatchQueue.main.async {
            self.status.title = text
        }
    }
    
    func updateStatusAfterRefresh() {
        let lastUpdatedDate = Date.init()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let text = "Last updated: \(dateFormatterGet.string(from: lastUpdatedDate))"
        updateStatus(text)
    }
    
    func updateError(_ text: String) {
        DispatchQueue.main.async {
            self.error.title = text
        }
    }
    
    func cleanLambdaInvocationError() {
        error.title = " "
        lambdaError = nil
    }
    
    func showErrorPopup(_ message: String) {
        let uppercasedMessage = message.firstUppercased
        let alert = UIAlertController(title: "Error", message: uppercasedMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // handle table refresh (pull down)
    @objc func refreshInstanceList() {
        updateStatusBeforeRefresh()
        AwsLambdaProxy.invokeGetInstancesApi()
        refreshControl?.endRefreshing()
    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instances.count
    }
    
    // populate cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        let instanceId = instances[indexPath.row].getInstanceId()
        let instanceName = instances[indexPath.row].getName()
        let instanceType = instances[indexPath.row].getInstanceType()
        let instanceState = instances[indexPath.row].getState()
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        cell!.selectionStyle = UITableViewCell.SelectionStyle.default
        cell!.textLabel!.text = instanceId
        cell!.detailTextLabel!.text = "\(instanceName) - \(instanceType) - \(instanceState)"
        if (instanceState == "terminated") {
            cell!.textLabel?.textColor = UIColor.secondaryLabel
            cell!.detailTextLabel?.textColor = UIColor.secondaryLabel
        } else {
            cell!.textLabel?.textColor = UIColor.label
            cell!.detailTextLabel?.textColor = UIColor.label
        }
        cell!.accessibilityIdentifier = instanceId
        
        return cell!
    }
    
    // handle cell touch
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertControllerFactory = AlertControllerFactory(tableView: tableView, viewController: self)
        let alertController = alertControllerFactory.getInstance(instance: instances[indexPath.row], indexPath: indexPath)
        alertController.popoverPresentationController?.sourceView = tableView
        present(alertController, animated: true) {
            print(self.tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "")
        }
    }
}
