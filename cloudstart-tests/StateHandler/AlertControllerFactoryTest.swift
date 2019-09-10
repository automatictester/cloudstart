import cloudstart
import XCTest

class AlertControllerFactoryTest: XCTestCase {
    
    let alertControllerFactory = AlertControllerFactory(tableView: UITableView(), viewController: UIViewController())
    let instance = Instance()!

    override func setUp() {
        instance.instanceId = "i-05b7b3d9384e62120"
        instance.instanceType = "t3.medium"
        instance.name = "My Instance"
    }
    
    func testStopped() {
        instance.state = "stopped"
        let alertController = alertControllerFactory.getInstance(instance: instance, indexPath: IndexPath.init())
        
        XCTAssert(alertController.actions.count == 3)
        XCTAssert(alertController.actions[0].title == "Start")
        XCTAssert(alertController.actions[1].title == "Terminate")
        XCTAssert(alertController.actions[2].title == "Cancel")
    }
    
    func testRunning() {
        instance.state = "running"
        let alertController = alertControllerFactory.getInstance(instance: instance, indexPath: IndexPath.init())
        
        XCTAssert(alertController.actions.count == 5)
        XCTAssert(alertController.actions[0].title == "Update DNS")
        XCTAssert(alertController.actions[1].title == "Stop")
        XCTAssert(alertController.actions[2].title == "Reboot")
        XCTAssert(alertController.actions[3].title == "Terminate")
        XCTAssert(alertController.actions[4].title == "Cancel")
    }
    
    func testPending() {
        instance.state = "pending"
        let alertController = alertControllerFactory.getInstance(instance: instance, indexPath: IndexPath.init())
        
        XCTAssert(alertController.actions.count == 1)
        XCTAssert(alertController.actions[0].title == "Cancel")
    }
}
