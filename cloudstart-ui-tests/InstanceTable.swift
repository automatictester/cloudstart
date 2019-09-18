import XCTest

struct InstanceTable {
    
    let table = XCUIApplication().tables.matching(identifier: "instanceTable").element
    
    func getCellByInstanceId(_ instanceId: String) -> XCUIElement {
        return table.cells.element(matching: .cell, identifier: instanceId)
    }
    
    func instanceCount() -> Int {
        return table.cells.count
    }
}
