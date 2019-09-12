import UIKit

public class ActionFactory {
    
    private let tableView: UITableView
    private let viewController: UIViewController
    
    public init(tableView: UITableView, viewController: UIViewController) {
        self.tableView = tableView
        self.viewController = viewController
    }
    
    public func getStartInstanceAction(instanceId: String, indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "Start", style: .default) { action -> Void in
            print("starting")
            self.invokeApi(instanceId: instanceId, action: "start")
            self.deselectRow(indexPath)
        }
    }
    
    public func getRebootInstanceAction(instanceId: String, indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "Reboot", style: .default) { action -> Void in
            print("rebooting")
            self.invokeApi(instanceId: instanceId, action: "reboot")
            self.deselectRow(indexPath)
        }
    }
    
    public func getStopInstanceAction(instanceId: String, indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "Stop", style: .default) { action -> Void in
            print("stopping")
            self.invokeApi(instanceId: instanceId, action: "stop")
            self.deselectRow(indexPath)
        }
    }
    
    public func getTerminateInstanceAction(instanceId: String, indexPath: IndexPath, instanceName: String) -> UIAlertAction {
        return UIAlertAction(title: "Terminate", style: .destructive) { action -> Void in
            let alertController = UIAlertController(title: "\(instanceName)",
                message: "Terminate instance \(instanceId)?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive, handler: {(action: UIAlertAction!) in
                print("terminating")
                self.invokeApi(instanceId: instanceId, action: "terminate")
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
                print("not terminating")
            })
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.viewController.present(alertController, animated: true, completion: {
                self.deselectRow(indexPath)
            })
        }
    }
    
    public func getUpdateDnsAction(instanceId: String, indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "Update DNS", style: .default) { action -> Void in
            print("updating dns")
            self.invokeApi(instanceId: instanceId, action: "update-dns")
            self.deselectRow(indexPath)
        }
    }
    
    public func getCancel(_ indexPath: IndexPath) -> UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.deselectRow(indexPath)
        }
    }
    
    private func invokeApi(instanceId: String, action: String) {
        AwsLambda.invokeChangeInstanceStateApi(instanceId: instanceId, action: action)
    }
    
    private func deselectRow(_ at: IndexPath) {
       self.tableView.deselectRow(at: at, animated: true)
    }
}
