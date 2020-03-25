import AWSEC2
import cloudstart
import Foundation
import XCTest

class DescribeInstancesResponseConverterTest: XCTestCase {
    
    func testToInstanceArray() {
        
        // Simple Name tag
        let instanceA = AWSEC2Instance()!
        instanceA.instanceId = "i-05b7b3d9384e62101"
        let stateA = AWSEC2InstanceState.init()
        stateA?.name = AWSEC2InstanceStateName.shuttingDown
        instanceA.state = stateA
        instanceA.instanceType = AWSEC2InstanceType.t2_micro
        let tagA = AWSEC2Tag()!
        tagA.key = "Name"
        tagA.value = "CloudStart Test A"
        instanceA.tags = [tagA]
        
        // Tags: Name, name
        let instanceB = AWSEC2Instance()!
        instanceB.instanceId = "i-05b7b3d9384e62102"
        let stateB = AWSEC2InstanceState.init()
        stateB?.name = AWSEC2InstanceStateName.running
        instanceB.state = stateB
        instanceB.instanceType = AWSEC2InstanceType.t2_medium
        let tagB1 = AWSEC2Tag()!
        tagB1.key = "Name"
        tagB1.value = "CloudStart Test B"
        let tagB2 = AWSEC2Tag()!
        tagB2.key = "name"
        tagB2.value = "lowercased"
        instanceB.tags = [tagB1, tagB2]
        
        // Name tag ""
        let instanceC = AWSEC2Instance()!
        instanceC.instanceId = "i-05b7b3d9384e62113"
        let stateC = AWSEC2InstanceState.init()
        stateC?.name = AWSEC2InstanceStateName.running
        instanceC.state = stateC
        instanceC.instanceType = AWSEC2InstanceType.t2_medium
        let tagC = AWSEC2Tag()!
        tagC.key = "Name"
        tagC.value = ""
        instanceC.tags = [tagC]
        
        // Name tag nil
        let instanceD = AWSEC2Instance()!
        instanceD.instanceId = "i-05b7b3d9384e62114"
        let stateD = AWSEC2InstanceState.init()
        stateD?.name = AWSEC2InstanceStateName.running
        instanceD.state = stateD
        instanceD.instanceType = AWSEC2InstanceType.t2_medium
        let tagD = AWSEC2Tag()!
        tagD.key = "Name"
        instanceD.tags = [tagD]
        
        // no tags
        let instanceE = AWSEC2Instance()!
        instanceE.instanceId = "i-05b7b3d9384e62115"
        let stateE = AWSEC2InstanceState.init()
        stateE?.name = AWSEC2InstanceStateName.running
        instanceE.state = stateE
        instanceE.instanceType = AWSEC2InstanceType.t2_medium
        
        // Tag other than Name
        let instanceF = AWSEC2Instance()!
        instanceF.instanceId = "i-05b7b3d9384e62116"
        let stateF = AWSEC2InstanceState.init()
        stateF?.name = AWSEC2InstanceStateName.running
        instanceF.state = stateF
        instanceF.instanceType = AWSEC2InstanceType.t2_medium
        let tagF = AWSEC2Tag()!
        tagF.key = "Other"
        tagF.value = "value"
        instanceF.tags = [tagF]
        
        // Tag without key
        let instanceG = AWSEC2Instance()!
        instanceG.instanceId = "i-05b7b3d9384e62117"
        let stateG = AWSEC2InstanceState.init()
        stateG?.name = AWSEC2InstanceStateName.running
        instanceG.state = stateG
        instanceG.instanceType = AWSEC2InstanceType.t2_medium
        let tagG = AWSEC2Tag()!
        tagG.value = "value"
        instanceG.tags = [tagG]
    
        let instances = [instanceA, instanceB, instanceC, instanceD, instanceE, instanceF, instanceG]
        
        let reservation = AWSEC2Reservation()
        reservation?.instances = instances
        
        let reservations = [reservation!]
        
        let response: Dictionary<String, Array<AWSEC2Reservation>> = ["reservations": reservations]
        
        let instanceArray = DescribeInstancesResponseConverter.toInstanceArray(response)
        
        XCTAssertEqual(instanceArray.count, 7)
        XCTAssertEqual(instanceArray[0].getInstanceId(), "i-05b7b3d9384e62101")
        XCTAssertEqual(instanceArray[0].getInstanceType(), "t2.micro")
        XCTAssertEqual(instanceArray[0].getName(), "CloudStart Test A")
        XCTAssertEqual(instanceArray[0].getState(), "shutting-down")
        XCTAssertEqual(instanceArray[1].getInstanceId(), "i-05b7b3d9384e62102")
        XCTAssertEqual(instanceArray[1].getInstanceType(), "t2.medium")
        XCTAssertEqual(instanceArray[1].getName(), "CloudStart Test B")
        XCTAssertEqual(instanceArray[1].getState(), "running")
        XCTAssertEqual(instanceArray[2].getInstanceId(), "i-05b7b3d9384e62113")
        XCTAssertEqual(instanceArray[2].getInstanceType(), "t2.medium")
        XCTAssertEqual(instanceArray[2].getName(), "NAME_NOT_FOUND")
        XCTAssertEqual(instanceArray[2].getState(), "running")
        XCTAssertEqual(instanceArray[3].getInstanceId(), "i-05b7b3d9384e62114")
        XCTAssertEqual(instanceArray[3].getInstanceType(), "t2.medium")
        XCTAssertEqual(instanceArray[3].getName(), "NAME_NOT_FOUND")
        XCTAssertEqual(instanceArray[3].getState(), "running")
        XCTAssertEqual(instanceArray[4].getInstanceId(), "i-05b7b3d9384e62115")
        XCTAssertEqual(instanceArray[4].getInstanceType(), "t2.medium")
        XCTAssertEqual(instanceArray[4].getName(), "NAME_NOT_FOUND")
        XCTAssertEqual(instanceArray[4].getState(), "running")
        XCTAssertEqual(instanceArray[5].getInstanceId(), "i-05b7b3d9384e62116")
        XCTAssertEqual(instanceArray[5].getInstanceType(), "t2.medium")
        XCTAssertEqual(instanceArray[5].getName(), "NAME_NOT_FOUND")
        XCTAssertEqual(instanceArray[5].getState(), "running")
        XCTAssertEqual(instanceArray[6].getInstanceId(), "i-05b7b3d9384e62117")
        XCTAssertEqual(instanceArray[6].getInstanceType(), "t2.medium")
        XCTAssertEqual(instanceArray[6].getName(), "NAME_NOT_FOUND")
        XCTAssertEqual(instanceArray[6].getState(), "running")
    }
}
