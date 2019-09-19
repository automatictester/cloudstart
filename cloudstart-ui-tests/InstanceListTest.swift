import XCTest

class InstanceListTest: XCTestCase {
    
    var table = InstanceTable()

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testInstanceCount() {
        let instanceCount = table.instanceCount()
        XCTAssertEqual(instanceCount, 3)
    }
    
    func testJenkinsMasterExists() {
        let instanceId = "i-0ebd41b671a9dfaeb"
        let cell = table.getCellByInstanceId(instanceId)
        
        XCTAssertTrue(cell.staticTexts[instanceId].exists)
        XCTAssertTrue(cell.staticTexts["Jenkins Master - t2.micro - stopped"].exists)
    }
    
    func testBambooServerExists() {
        let instanceId = "i-009cc8fd7dd3ac8f4"
        let cell = table.getCellByInstanceId(instanceId)
        
        XCTAssertTrue(cell.staticTexts[instanceId].exists)
        XCTAssertTrue(cell.staticTexts["Bamboo Server - t3.medium - running"].exists)
    }
    
    func testCloudStartTestExists() {
        let instanceId = "i-05b7b3d9384e62120"
        let cell = table.getCellByInstanceId(instanceId)
        
        XCTAssertTrue(cell.staticTexts[instanceId].exists)
        XCTAssertTrue(cell.staticTexts["CloudStart Test - t2.micro - terminated"].exists)
    }
}
