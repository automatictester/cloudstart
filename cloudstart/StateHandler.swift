class StateHandler {
    
    private var nextHandler: StateHandler?
    var alertController: UIAlertController
    var actionFactory: ActionFactory
    
    init(actionFactory: ActionFactory, alertController: UIAlertController) {
        self.actionFactory = actionFactory
        self.alertController = alertController
    }
    
    func setNextHandler(_ nextHandler: StateHandler) {
        self.nextHandler = nextHandler
    }
    
    func processHandler(instance: Instance, indexPath: IndexPath) {
        let expectedState = self.expectedState()
        if (instance.state == expectedState || expectedState == nil) {
            handleHere(instance: instance, indexPath: indexPath)
        }
        nextHandler?.processHandler(instance: instance, indexPath: indexPath)
    }
    
    func expectedState() -> String? {
        preconditionFailure("This method must be overriden")
    }
    
    func handleHere(instance: Instance, indexPath: IndexPath) {
        preconditionFailure("This method must be overriden")
    }
}
