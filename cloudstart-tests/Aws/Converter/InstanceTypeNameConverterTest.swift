import cloudstart
import Foundation
import XCTest

class InstanceTypeNameConverterTest: XCTestCase {
    
    func testFrom() {
        XCTAssertEqual(InstanceTypeNameConverter.from("t2_micro"), "t2.micro")
    }
}
