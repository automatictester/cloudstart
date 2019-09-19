import Foundation

struct AwsLambdaMock {
    
    private init() {}
    
    static func authenticate() {}
    
    static func invokeChangeInstanceStateApi(instanceId: String, action: String) {
        NotificationCenter.default.post(name: Notification.Name("InstanceStateChanged"), object: nil)
    }
    
    static func invokeGetInstancesApi() {
        let instanceA = [
            "instanceId": "i-0ebd41b671a9dfaeb",
            "instanceType": "t2.micro",
            "name": "Jenkins Master",
            "state": "stopped"
        ]
        
        let instanceB = [
            "instanceId": "i-009cc8fd7dd3ac8f4",
            "instanceType": "t3.medium",
            "name": "Bamboo Server",
            "state": "running"
        ]
        
        let instanceC = [
            "instanceId": "i-05b7b3d9384e62120",
            "instanceType": "t2.micro",
            "name": "CloudStart Test",
            "state": "terminated"
        ]
        
        var instances = [NSDictionary]()
        instances.append(instanceA as NSDictionary)
        instances.append(instanceB as NSDictionary)
        instances.append(instanceC as NSDictionary)
        
        let response: NSDictionary = ["instances": instances]
        
        let notificationData = ["instances": response.toInstanceArray()]
        NotificationCenter.default.post(name: Notification.Name("InstanceListUpdated"), object: nil, userInfo: notificationData)
    }
}
