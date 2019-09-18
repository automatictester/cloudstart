import XCTest

struct InstanceActions {
    
    let sheet = XCUIApplication().sheets.matching(identifier: "instanceActions").element
    
    func hasActionByName(_ name: String) -> Bool {
        return getActionByName(name).exists
    }
    
    func getActionByName(_ name: String) -> XCUIElement {
        return sheet.buttons[name]
    }
    
    func actionCount() -> Int {
        return sheet.buttons.count
    }
}
