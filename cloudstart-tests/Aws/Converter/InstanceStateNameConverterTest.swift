import cloudstart
import Foundation
import XCTest

class InstanceStateNameConverterTest: XCTestCase {
    
    func testFrom() {
        XCTAssertEqual(InstanceStateNameConverter.from("shutting_down"), "shutting-down")
    }
}
