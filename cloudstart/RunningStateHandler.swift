import UIKit

class RunningStateHandler : StateHandler {
    
    override func expectedState() -> String? {
        return "running"
    }
    
    override func handleHere(instance: Instance, indexPath: IndexPath) {
        let instanceId = instance.instanceId!
        let instanceName = instance.name!
        
        let rebootAction = actionFactory.getRebootInstanceAction(instanceId: instanceId, indexPath: indexPath)
        let stopAction = actionFactory.getStopInstanceAction(instanceId: instanceId, indexPath: indexPath)
        let updateDnsAction = actionFactory.getUpdateDnsAction(instanceId: instanceId, indexPath: indexPath)
        let terminateAction = actionFactory.getTerminateInstanceAction(instanceId: instanceId, indexPath: indexPath, instanceName: instanceName)
        
        alertController.addAction(updateDnsAction)
        alertController.addAction(stopAction)
        alertController.addAction(rebootAction)
        alertController.addAction(terminateAction)
    }
}
