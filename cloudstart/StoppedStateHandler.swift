class StoppedStateHandler : StateHandler {
    
    override func expectedState() -> String? {
        return "stopped"
    }
    
    override func handleHere(instance: Instance, indexPath: IndexPath) {
        let instanceId = instance.instanceId!
        let instanceName = instance.name!
        
        let startAction = actionFactory.getStartInstanceAction(instanceId: instanceId, indexPath: indexPath)
        let terminateAction = actionFactory.getTerminateInstanceAction(instanceId: instanceId, indexPath: indexPath, instanceName: instanceName)
        
        alertController.addAction(startAction)
        alertController.addAction(terminateAction)
    }
}
