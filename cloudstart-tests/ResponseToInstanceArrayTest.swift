import cloudstart
import Foundation
import XCTest

class ResponseToInstanceArrayTest: XCTestCase {

    func testConvert() {
        
        let instanceA = [
            "instanceId": "i-05b7b3d9384e62101",
            "instanceType": "t2.micro",
            "name": "CloudStart Test A",
            "state": "stopped"
        ]
        
        let instanceB = [
            "instanceId": "i-05b7b3d9384e62102",
            "instanceType": "t2.medium",
            "name": "CloudStart Test B",
            "state": "running"
        ]
        
        var instances = [NSDictionary]()
        instances.append(instanceA as NSDictionary)
        instances.append(instanceB as NSDictionary)
        
        let response: NSDictionary = ["instances": instances]
        
        let instanceArray = ResponseToInstanceArray.convert(response)
        
        XCTAssertEqual(instanceArray.count, 2)
        XCTAssertEqual(instanceArray[0].instanceId, "i-05b7b3d9384e62101")
        XCTAssertEqual(instanceArray[0].instanceType, "t2.micro")
        XCTAssertEqual(instanceArray[0].name, "CloudStart Test A")
        XCTAssertEqual(instanceArray[0].state, "stopped")
        XCTAssertEqual(instanceArray[1].instanceId, "i-05b7b3d9384e62102")
        XCTAssertEqual(instanceArray[1].instanceType, "t2.medium")
        XCTAssertEqual(instanceArray[1].name, "CloudStart Test B")
        XCTAssertEqual(instanceArray[1].state, "running")
    }
}
