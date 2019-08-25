import AWSAuthCore
import AWSAuthUI
import UIKit

class InstanceTableViewController: UITableViewController {
    
    let invoker = ApiInvoker()
    var instances = [Ec2Instance]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(instanceListUpdated), name: Notification.Name("InstanceListUpdated"), object: nil)
        invoker.authenticate()
        invoker.invokeGetInstancesApi()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshInstanceList), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    @objc func instanceListUpdated(_ instanceListUpdatedNotification: Notification) {
        print("Instance list updated")
        let notificationData = instanceListUpdatedNotification.userInfo
        instances = notificationData!["instances"] as! [Ec2Instance]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func refreshInstanceList() {
        invoker.invokeGetInstancesApi()
        refreshControl?.endRefreshing()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instances.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        cell!.textLabel!.text = instances[indexPath.row].instanceId
        cell!.detailTextLabel!.text = "\(instances[indexPath.row].name) - \(instances[indexPath.row].instanceType) - \(instances[indexPath.row].state)"
        if (instances[indexPath.row].state == "Terminated") {
            cell!.textLabel?.textColor = UIColor.lightGray
            cell!.detailTextLabel?.textColor = UIColor.lightGray
        }
        
        return cell!
    }
    
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
