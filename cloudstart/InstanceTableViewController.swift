import AWSAuthCore
import AWSAuthUI
import CoreData
import UIKit

class InstanceTableViewController: UITableViewController {
    
    let apiGateway = ApiGateway()
    var instances = [Instance]() {
        didSet {
            delete()
            for i in instances {
                save(i)
            }
            print("Saved")
        }
    }
    
    var items: [NSManagedObject] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocalDataStore")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func save(_ instance: Instance) {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "LocalDataStore", in: managedContext)
        let newItem = NSManagedObject(entity: entity!, insertInto: managedContext)
        newItem.setValue(instance.instanceId, forKey: "instanceId")
        newItem.setValue(instance.instanceType, forKey: "instanceType")
        newItem.setValue(instance.state, forKey: "state")
        newItem.setValue(instance.name, forKey: "name")
        
        do {
            try managedContext.save()            
        } catch let err as NSError {
            print("Failed to save an item", err)
        }
    }
    
    func delete() {
        let managedContext = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalDataStore")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    
    func load() {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalDataStore")
        do {
            items = try managedContext.fetch(fetchRequest)
            for item in items {
                print(item.value(forKey: "instanceId") as! String)
            }
        } catch let err as NSError {
            print("Failed to fetch items", err)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForInstanceListUpdatedNotification()
        requestInitialTableLoad()
        enableTableRefresh()
        load()
        print("CoreData: \(items.count)")
    }
    
    func registerForInstanceListUpdatedNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(instanceListUpdated), name: Notification.Name("InstanceListUpdated"), object: nil)
    }
    
    func requestInitialTableLoad() {
        apiGateway.authenticate()
        apiGateway.invokeGetInstancesApi()
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
    
    func refreshData(_ notification: Notification) {
        print("Data refreshed")
        let notificationData = notification.userInfo
        instances = notificationData!["instances"] as! [Instance]
    }
    
    func refreshTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // handle table refresh (pull down)
    @objc func refreshInstanceList() {
        apiGateway.invokeGetInstancesApi()
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
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        cell!.selectionStyle = UITableViewCell.SelectionStyle.default
        cell!.textLabel!.text = instances[indexPath.row].instanceId
        cell!.detailTextLabel!.text = "\(instances[indexPath.row].name) - \(instances[indexPath.row].instanceType) - \(instances[indexPath.row].state)"
        if (instances[indexPath.row].state == "terminated") {
            cell!.textLabel?.textColor = UIColor.lightGray
            cell!.detailTextLabel?.textColor = UIColor.lightGray
        }
        
        return cell!
    }
    
    // handle cell touch
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if(instances[indexPath.row].state == "stopped") {
            let startAction: UIAlertAction = UIAlertAction(title: "Start", style: .default) { action -> Void in
                print("starting")
                tableView.deselectRow(at: indexPath, animated: true)
            }
            actionSheetController.addAction(startAction)
        }
        
        if(instances[indexPath.row].state == "running") {
            let rebootAction: UIAlertAction = UIAlertAction(title: "Reboot", style: .default) { action -> Void in
                print("rebooting")
                tableView.deselectRow(at: indexPath, animated: true)
            }
            let stopAction: UIAlertAction = UIAlertAction(title: "Stop", style: .default) { action -> Void in
                print("stopping")
                tableView.deselectRow(at: indexPath, animated: true)
            }
            actionSheetController.addAction(rebootAction)
            actionSheetController.addAction(stopAction)
        }
        
        if(["running", "stopped"].contains(instances[indexPath.row].state)) {
            let terminateAction: UIAlertAction = UIAlertAction(title: "Terminate", style: .destructive) { action -> Void in
                let alertController = UIAlertController(title: "\(self.instances[indexPath.row].name)",
                    message: "Terminate instance \(self.instances[indexPath.row].instanceId)?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .destructive, handler: {(action: UIAlertAction!) in
                    print("terminating")
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
                    print("not terminating")
                })
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                })
            }
            actionSheetController.addAction(terminateAction)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            tableView.deselectRow(at: indexPath, animated: true)
        }
        actionSheetController.addAction(cancelAction)
        
        actionSheetController.popoverPresentationController?.sourceView = tableView
        
        present(actionSheetController, animated: true) {
            print(self.tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "")
        }
    }
}
