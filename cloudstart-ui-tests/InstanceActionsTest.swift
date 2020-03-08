import XCTest

class InstanceActionsTest: XCTestCase {
    
    var table = InstanceTable()
    var actions = InstanceActions()
    
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testStoppedInstanceActions() {
        let cell = table.getCellByInstanceId("i-008d41b671a9dfaeb")
        cell.tap()
        
        XCTAssertEqual(actions.actionCount(), 3)
        XCTAssertTrue(actions.hasActionByName("Start"))
        XCTAssertTrue(actions.hasActionByName("Terminate"))
        XCTAssertTrue(actions.hasActionByName("Cancel"))
        
        actions.getActionByName("Cancel").tap()
    }
    
    func testRunningInstanceActions() {
        let cell = table.getCellByInstanceId("i-009cc8fd7dd3ac8f4")
        cell.tap()
        
        XCTAssertEqual(actions.actionCount(), 4)
        XCTAssertTrue(actions.hasActionByName("Stop"))
        XCTAssertTrue(actions.hasActionByName("Reboot"))
        XCTAssertTrue(actions.hasActionByName("Terminate"))
        XCTAssertTrue(actions.hasActionByName("Cancel"))
        
        actions.getActionByName("Cancel").tap()
    }
    
    func testTerminatedInstanceActions() {
        let cell = table.getCellByInstanceId("i-05b7b3d9384e62120")
        cell.tap()
        
        XCTAssertEqual(actions.actionCount(), 1)
        XCTAssertTrue(actions.hasActionByName("Cancel"))
        
        actions.getActionByName("Cancel").tap()
    }
}
