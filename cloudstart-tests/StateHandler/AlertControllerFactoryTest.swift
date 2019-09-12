import cloudstart
import XCTest

class AlertControllerFactoryTest: XCTestCase {
    
    let alertControllerFactory = AlertControllerFactory(tableView: UITableView(), viewController: UIViewController())
    let instanceId = "i-05b7b3d9384e62120"
    let instanceType = "t3.medium"
    let instanceName = "My Instance"
    
    func testStopped() {
        let state = "stopped"
        let instance = Instance(instanceId: instanceId, instanceType: instanceType, state: state, name: instanceName)
        
        let alertController = alertControllerFactory.getInstance(instance: instance, indexPath: IndexPath.init())
        
        XCTAssert(alertController.actions.count == 3)
        XCTAssert(alertController.actions[0].title == "Start")
        XCTAssert(alertController.actions[1].title == "Terminate")
        XCTAssert(alertController.actions[2].title == "Cancel")
    }
    
    func testRunning() {
        let state = "running"
        let instance = Instance(instanceId: instanceId, instanceType: instanceType, state: state, name: instanceName)
        
        let alertController = alertControllerFactory.getInstance(instance: instance, indexPath: IndexPath.init())
        
        XCTAssert(alertController.actions.count == 4)
        XCTAssert(alertController.actions[0].title == "Stop")
        XCTAssert(alertController.actions[1].title == "Reboot")
        XCTAssert(alertController.actions[2].title == "Terminate")
        XCTAssert(alertController.actions[3].title == "Cancel")
    }
    
    func testPending() {
        let state = "pending"
        let instance = Instance(instanceId: instanceId, instanceType: instanceType, state: state, name: instanceName)
        
        let alertController = alertControllerFactory.getInstance(instance: instance, indexPath: IndexPath.init())
        
        XCTAssert(alertController.actions.count == 1)
        XCTAssert(alertController.actions[0].title == "Cancel")
    }
}
