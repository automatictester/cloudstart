import XCTest
import cloudstart

class StringProtocol: XCTestCase {

    func testFirstUppercased() {
        let input = "cannot retrieve list of EC2 instances"
        XCTAssertEqual(input.firstUppercased(), "Cannot retrieve list of EC2 instances")
    }
}
