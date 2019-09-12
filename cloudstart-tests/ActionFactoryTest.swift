import cloudstart
import XCTest

class ActionFactoryTest: XCTestCase {
    
    let tableView = UITableView()
    let viewController = UIViewController()
    var actionFactory: ActionFactory?
    
    override func setUp() {
        actionFactory = ActionFactory(tableView: tableView, viewController: viewController)
    }
    
    func testGetStartInstanceAction() {
        let action = actionFactory!.getStartInstanceAction(instanceId: "i-05b7b3d9384e62120", indexPath: IndexPath.init())
        XCTAssert(action.title == "Start")
    }
    
    func testGetRebootInstanceAction() {
        let action = actionFactory!.getRebootInstanceAction(instanceId: "i-05b7b3d9384e62120", indexPath: IndexPath.init())
        XCTAssert(action.title == "Reboot")
    }
    
    func testGetStopInstanceAction() {
        let action = actionFactory!.getStopInstanceAction(instanceId: "i-05b7b3d9384e62120", indexPath: IndexPath.init())
        XCTAssert(action.title == "Stop")
    }
    
    func testGetTerminateInstanceAction() {
        let action = actionFactory!.getTerminateInstanceAction(instanceId: "i-05b7b3d9384e62120", indexPath: IndexPath.init(), instanceName: "My Instance")
        XCTAssert(action.title == "Terminate")
    }
    
    func testGetCancel() {
        let action = actionFactory!.getCancel(IndexPath.init())
        XCTAssert(action.title == "Cancel")
    }
}
