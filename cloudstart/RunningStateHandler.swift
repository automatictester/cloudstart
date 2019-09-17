import UIKit

class RunningStateHandler : StateHandler {
    
    override func expectedState() -> String? {
        return "running"
    }
    
    override func handleHere(instance: Instance, indexPath: IndexPath) {
        let instanceId = instance.getInstanceId()
        let instanceName = instance.getName()
        
        let rebootAction = actionFactory.getRebootInstanceAction(instanceId: instanceId, indexPath: indexPath)
        let stopAction = actionFactory.getStopInstanceAction(instanceId: instanceId, indexPath: indexPath)
        let terminateAction = actionFactory.getTerminateInstanceAction(instanceId: instanceId, indexPath: indexPath, instanceName: instanceName)
        
        alertController.addAction(stopAction)
        alertController.addAction(rebootAction)
        alertController.addAction(terminateAction)
    }
}
