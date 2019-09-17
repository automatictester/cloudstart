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
        
        let instanceArray = response.toInstanceArray()
        
        XCTAssertEqual(instanceArray.count, 2)
        XCTAssertEqual(instanceArray[0].getInstanceId(), "i-05b7b3d9384e62101")
        XCTAssertEqual(instanceArray[0].getInstanceType(), "t2.micro")
        XCTAssertEqual(instanceArray[0].getName(), "CloudStart Test A")
        XCTAssertEqual(instanceArray[0].getState(), "stopped")
        XCTAssertEqual(instanceArray[1].getInstanceId(), "i-05b7b3d9384e62102")
        XCTAssertEqual(instanceArray[1].getInstanceType(), "t2.medium")
        XCTAssertEqual(instanceArray[1].getName(), "CloudStart Test B")
        XCTAssertEqual(instanceArray[1].getState(), "running")
    }
}
