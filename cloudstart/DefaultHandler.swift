import UIKit

class DefaultHandler : StateHandler {
    
    override func expectedState() -> String? {
        return nil
    }
    
    override func handleHere(instance: Instance, indexPath: IndexPath) {
        let cancelAction = actionFactory.getCancel(indexPath)
        alertController.addAction(cancelAction)
    }
}
