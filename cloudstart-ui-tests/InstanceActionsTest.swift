import XCTest

class InstanceActionsTest: XCTestCase {
    
    var table = InstanceTable()
    var actions = InstanceActions()
    
    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testStoppedInstanceActions() {
        let cell = table.getCellByInstanceId("i-0ebd41b671a9dfaeb")
        cell.tap()
        
        XCTAssertEqual(actions.actionCount(), 3)
        XCTAssertTrue(actions.hasActionByName("Start"))
        XCTAssertTrue(actions.hasActionByName("Terminate"))
        XCTAssertTrue(actions.hasActionByName("Cancel"))
        
        actions.getActionByName("Cancel").tap()
    }
}
