import AWSEC2
import cloudstart
import XCTest

class InstanceListSorterTest: XCTestCase {

    func testSortInstances() {
        
        let instanceA = Instance(
            instanceId: "i-01b7b3d9384e62101", instanceType: "t2.nano", state: "terminated", name: "ABC Instance"
        )
        let instanceB = Instance(
            instanceId: "i-02b7b3d9384e62102", instanceType: "t2.small", state: "terminated", name: "CloudStart Test"
        )
        let instanceC = Instance(
            instanceId: "i-03b7b3d9384e62102", instanceType: "t2.medium", state: "running", name: "Bamboo Server"
        )
        let instanceD = Instance(
            instanceId: "i-04b7b3d9384e62102", instanceType: "t2.micro", state: "stopped", name: "Jenkins Master"
        )
        
        let unsortedInstances = [instanceA, instanceB, instanceC, instanceD]
        let sortedInstances = InstanceListSorter.sortInstances(unsortedInstances)
        
        XCTAssertEqual(sortedInstances.count, 4)
        XCTAssertEqual(sortedInstances[0].getName(), "Bamboo Server")
        XCTAssertEqual(sortedInstances[1].getName(), "Jenkins Master")
        XCTAssertEqual(sortedInstances[2].getName(), "ABC Instance")
        XCTAssertEqual(sortedInstances[3].getName(), "CloudStart Test")
    }
}
