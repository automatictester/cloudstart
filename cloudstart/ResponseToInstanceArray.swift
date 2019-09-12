import Foundation

class ResponseToInstanceArray {
    
    public static func convert(_ response: NSDictionary) -> [Instance] {
        var instanceArray = [Instance]()
        if let instances = response.allValues[0] as? NSArray {
            for instance in instances {
                if let instanceAsDict = instance as? NSDictionary {
                    let instanceId = instanceAsDict.value(forKey: "instanceId") as! String
                    let instanceType = instanceAsDict.value(forKey: "instanceType") as! String
                    let state = instanceAsDict.value(forKey: "state") as! String
                    let name = instanceAsDict.value(forKey: "name") as! String
                    let newInstance = Instance(instanceId: instanceId, instanceType: instanceType, state: state, name: name)
                    instanceArray.append(newInstance)
                }
            }
        }
        return instanceArray
    }
}
