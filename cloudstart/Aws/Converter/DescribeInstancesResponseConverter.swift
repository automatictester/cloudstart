import AWSEC2

public struct DescribeInstancesResponseConverter {
    
    private init() {}
    
    public static func toInstanceArray(_ input: Dictionary<String, Array<AWSEC2Reservation>>) -> [Instance] {
        var instanceArray = [Instance]()
        if let reservations = input["reservations"] {
            for reservation in reservations {
                for instance in reservation.instances! {
                    let instanceId = instance.instanceId!
                    let instanceType = getInstanceType(instance)
                    let state = getInstanceState(instance)
                    let name = getName(instance)
                    let newInstance = Instance(instanceId: instanceId, instanceType: instanceType, state: state, name: name)
                    instanceArray.append(newInstance)
                }
            }
        }
        return instanceArray
    }
    
    private static func getInstanceType(_ instance: AWSEC2Instance) -> String {
        let instanceTypeId = instance.instanceType.rawValue
        let instanceTypeRaw = String(describing: CSAWSEC2InstanceType.byId[instanceTypeId])
        return InstanceTypeNameConverter.from(instanceTypeRaw)
    }
    
    private static func getInstanceState(_ instance: AWSEC2Instance) -> String {
        let stateId = instance.state!.name.rawValue
        let stateRaw = String(describing: CSAWSEC2InstanceStateName.byId[stateId])
        return InstanceStateNameConverter.from(stateRaw)
    }
    
    private static func getName(_ instance: AWSEC2Instance) -> String {
        var name = "NAME_NOT_FOUND"
        if (instance.tags != nil) {
            for tag in instance.tags! {
                if (tag.key == "Name" && tag.value != nil && tag.value != "") {
                    name = tag.value!
                }
            }
        }
        return name
    }
}
