import XCTest

class StringProtocolTest: XCTestCase {
    
    func testFirstUppercased() {
        XCTAssertEqual("cannot retrieve list of EC2 instances".firstUppercased, "Cannot retrieve list of EC2 instances")
    }
}
