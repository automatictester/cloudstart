import XCTest

struct InstanceTable {
    
    let table = XCUIApplication().tables.matching(identifier: "instanceTable").element
    
    func getCellByInstanceId(_ instanceId: String) -> XCUIElement {
        return table.cells.element(matching: .cell, identifier: instanceId)
    }
    
    func getCellById(_ id: Int) -> XCUIElement {
        return table.cells.element(boundBy: id)
    }
    
    func instanceCount() -> Int {
        return table.cells.count
    }
}
