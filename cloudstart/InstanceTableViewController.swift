import AWSAuthCore
import AWSAuthUI
import UIKit

class InstanceTableViewController: UITableViewController {
    
    var instances: Instances = InstanceReader.get()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshInstanceList), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    @objc func refreshInstanceList() {
        let invoker = ApiInvoker()
        invoker.authenticate()
        invoker.doInvokeAPI()
        
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instances.size()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        cell!.textLabel!.text = instances.get(index: indexPath.row).id
        cell!.detailTextLabel!.text = "\(instances.get(index: indexPath.row).name) - \(instances.get(index: indexPath.row).size) - \(instances.get(index: indexPath.row).status)"
        if (instances.get(index: indexPath.row).status == "Terminated") {
            cell!.textLabel?.textColor = UIColor.lightGray
            cell!.detailTextLabel?.textColor = UIColor.lightGray
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let instanceId = self.tableView.cellForRow(at: indexPath)?.textLabel?.text
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if(instances.get(instanceId: instanceId!)?.status == "Stopped") {
            let startAction: UIAlertAction = UIAlertAction(title: "Start", style: .default) { action -> Void in
                print("starting")
                tableView.deselectRow(at: indexPath, animated: true)
            }
            actionSheetController.addAction(startAction)
        }
        
        if(instances.get(instanceId: instanceId!)?.status == "Running") {
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
        
        if(["Running", "Stopped"].contains(instances.get(instanceId: instanceId!)?.status)) {
            let terminateAction: UIAlertAction = UIAlertAction(title: "Terminate", style: .destructive) { action -> Void in
                let alertController = UIAlertController(title: "\(self.instances.get(index: indexPath.row).name)",
                    message: "Terminate instance \(self.instances.get(index: indexPath.row).id)?", preferredStyle: .alert)
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
