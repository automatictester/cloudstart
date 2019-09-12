import UIKit

public class AlertControllerFactory {
    
    private let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private let actionFactory: ActionFactory
    
    public init(tableView: UITableView, viewController: UIViewController) {
        self.actionFactory = ActionFactory(tableView: tableView, viewController: viewController)
    }
    
    public func getInstance(instance: Instance, indexPath: IndexPath) -> UIAlertController {
        let stoppedStateHandler = StoppedStateHandler(actionFactory: actionFactory, alertController: alertController)
        let runningStateHandler = RunningStateHandler(actionFactory: actionFactory, alertController: alertController)
        let defaultHandler = DefaultHandler(actionFactory: actionFactory, alertController: alertController)
        
        stoppedStateHandler.setNextHandler(runningStateHandler)
        runningStateHandler.setNextHandler(defaultHandler)
        
        stoppedStateHandler.processHandler(instance: instance, indexPath: indexPath)
        
        return alertController
    }
}
