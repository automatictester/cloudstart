import cloudstart
import XCTest

class InstanceListSorterTest: XCTestCase {

    func testSorting() {
        
        let instanceA = [
            "instanceId": "i-01b7b3d9384e62101",
            "instanceType": "t2.nano",
            "name": "ABC Instance",
            "state": "terminated"
        ]
        
        let instanceB = [
            "instanceId": "i-02b7b3d9384e62102",
            "instanceType": "t2.small",
            "name": "CloudStart Test",
            "state": "terminated"
        ]
        
        let instanceC = [
            "instanceId": "i-03b7b3d9384e62102",
            "instanceType": "t3.medium",
            "name": "Bamboo Server",
            "state": "running"
        ]
        
        let instanceD = [
            "instanceId": "i-04b7b3d9384e62102",
            "instanceType": "t2.micro",
            "name": "Jenkins Master",
            "state": "stopped"
        ]
        
        var instances = [NSDictionary]()
        instances.append(instanceA as NSDictionary)
        instances.append(instanceB as NSDictionary)
        instances.append(instanceC as NSDictionary)
        instances.append(instanceD as NSDictionary)
        
        let response: NSDictionary = ["instances": instances]
        let instanceArray = response.toInstanceArray()
        let sortedList = InstanceListSorter.sortInstances(instanceArray)
        
        XCTAssertEqual(sortedList.count, 4)
        XCTAssertEqual(sortedList[0].getName(), "Bamboo Server")
        XCTAssertEqual(sortedList[1].getName(), "Jenkins Master")
        XCTAssertEqual(sortedList[2].getName(), "ABC Instance")
        XCTAssertEqual(sortedList[3].getName(), "CloudStart Test")
    }
}
