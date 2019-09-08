import AWSAuthCore
import AWSAuthUI
import CoreData
import UIKit

class InstanceTableViewController: UITableViewController {
    
    var instances = [Instance]()
    
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
            newCoreDataItem.setValue(instance.instanceId, forKey: "instanceId")
            newCoreDataItem.setValue(instance.instanceType, forKey: "instanceType")
            newCoreDataItem.setValue(instance.state, forKey: "state")
            newCoreDataItem.setValue(instance.name, forKey: "name")
        }
        do {
            try context.save()
            print("CoreData saved: \(instances.count)")
        } catch let err as NSError {
            print("CoreData save failed", err)
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
            print("CoreData flush failed")
        }
    }
    
    func loadCoreData() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalDataStore")
        do {
            let coreDataItems = try context.fetch(fetchRequest)
            let tempInstances = fromNSManagedObjectToInstanceArray(coreDataItems)
            instances = tempInstances.sorted(by: { $0.instanceId > $1.instanceId })
            refreshTable()
            print("CoreData loaded: \(coreDataItems.count)")
        } catch let err as NSError {
            print("CoreData load failed", err)
        }
    }
    
    func fromNSManagedObjectToInstanceArray(_ objects: [NSManagedObject]) -> [Instance] {
        var instances = [Instance]()
        for object in objects {
            let instance = Instance()
            instance?.instanceId = (object.value(forKey: "instanceId")! as! String)
            instance?.instanceType = (object.value(forKey: "instanceType") as! String)
            instance?.name = (object.value(forKey: "name") as! String)
            instance?.state = (object.value(forKey: "state") as! String)
            instances.append(instance!)
        }
        return instances
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForInstanceListUpdatedNotification()
        registerForInstanceStateChangedNotification()
        requestInitialTableLoad()
        enableTableRefresh()
        loadCoreData()
    }
    
    func registerForInstanceListUpdatedNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(instanceListUpdated), name: Notification.Name("InstanceListUpdated"), object: nil)
    }
    
    func registerForInstanceStateChangedNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(instanceStateChanged), name: Notification.Name("InstanceStateChanged"), object: nil)
    }
    
    func requestInitialTableLoad() {
        ApiGateway.authenticate()
        ApiGateway.invokeGetInstancesApi()
    }
    
    func enableTableRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshInstanceList), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    // handle notification
    @objc func instanceListUpdated(notification: Notification) {
        refreshData(notification)
        refreshTable()
    }
    
    // handle notification
    @objc func instanceStateChanged(notification: Notification) {
        ApiGateway.invokeGetInstancesApi()
    }
    
    func refreshData(_ notification: Notification) {
        let notificationData = notification.userInfo
        let tempInstances = notificationData!["instances"] as! [Instance]
        print("New data received: \(tempInstances.count)")
        instances = tempInstances.sorted(by: { $0.instanceId > $1.instanceId })
        flushCoreData()
        saveCoreData()
    }
    
    func refreshTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // handle table refresh (pull down)
    @objc func refreshInstanceList() {
        ApiGateway.invokeGetInstancesApi()
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
        let instanceId = instances[indexPath.row].instanceId!
        let instanceName = instances[indexPath.row].name!
        let instanceType = instances[indexPath.row].instanceType!
        let instanceState = instances[indexPath.row].state!
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        cell!.selectionStyle = UITableViewCell.SelectionStyle.default
        cell!.textLabel!.text = instanceId
        cell!.detailTextLabel!.text = "\(instanceName) - \(instanceType) - \(instanceState)"
        if (instanceState == "terminated") {
            cell!.textLabel?.textColor = UIColor.lightGray
            cell!.detailTextLabel?.textColor = UIColor.lightGray
        } else {
            cell!.textLabel?.textColor = UIColor.black
            cell!.detailTextLabel?.textColor = UIColor.black
        }
        
        return cell!
    }
    
    // handle cell touch
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionFactory = ActionFactory(tableView: tableView, viewController: self)
        
        let stoppedStateHandler = StoppedStateHandler(actionFactory: actionFactory, alertController: alertController)
        let runningStateHandler = RunningStateHandler(actionFactory: actionFactory, alertController: alertController)
        let defaultHandler = DefaultHandler(actionFactory: actionFactory, alertController: alertController)
        
        stoppedStateHandler.setNextHandler(runningStateHandler)
        runningStateHandler.setNextHandler(defaultHandler)
        
        stoppedStateHandler.processHandler(instance: instances[indexPath.row], indexPath: indexPath)
        
        alertController.popoverPresentationController?.sourceView = tableView
        present(alertController, animated: true) {
            print(self.tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "")
        }
    }
}
