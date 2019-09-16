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
        
        XCTAssertEqual(alertController.actions.count, 3)
        XCTAssertEqual(alertController.actions[0].title, "Start")
        XCTAssertEqual(alertController.actions[1].title, "Terminate")
        XCTAssertEqual(alertController.actions[2].title, "Cancel")
    }
    
    func testRunning() {
        let state = "running"
        let instance = Instance(instanceId: instanceId, instanceType: instanceType, state: state, name: instanceName)
        
        let alertController = alertControllerFactory.getInstance(instance: instance, indexPath: IndexPath.init())
        
        XCTAssertEqual(alertController.actions.count, 4)
        XCTAssertEqual(alertController.actions[0].title, "Stop")
        XCTAssertEqual(alertController.actions[1].title, "Reboot")
        XCTAssertEqual(alertController.actions[2].title, "Terminate")
        XCTAssertEqual(alertController.actions[3].title, "Cancel")
    }
    
    func testPending() {
        let state = "pending"
        let instance = Instance(instanceId: instanceId, instanceType: instanceType, state: state, name: instanceName)
        
        let alertController = alertControllerFactory.getInstance(instance: instance, indexPath: IndexPath.init())
        
        XCTAssertEqual(alertController.actions.count, 1)
        XCTAssertEqual(alertController.actions[0].title, "Cancel")
    }
}
