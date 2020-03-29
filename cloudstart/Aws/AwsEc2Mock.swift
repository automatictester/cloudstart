struct AwsEc2Mock {
    
    private init() {}
    
    static func getInstances() {
        
        let instanceA = Instance(
            instanceId: "i-008d41b671a9dfaeb", instanceType: "t2.micro", state: "stopped", name: "Jenkins Master"
        )
        let instanceB = Instance(
            instanceId: "i-009cc8fd7dd3ac8f4", instanceType: "t3.medium", state: "running", name: "Bamboo Server"
        )
        let instanceC = Instance(
            instanceId: "i-05b7b3d9384e62120", instanceType: "t2.micro", state: "terminated", name: "CloudStart Test"
        )
        
        var instances = [Instance]()
        instances.append(instanceA)
        instances.append(instanceB)
        instances.append(instanceC)
        
        let notificationData = ["instances": instances]
        NotificationSender().send(notificationName: "InstanceListUpdated", userInfo: notificationData)
    }
    
    static func invokeChangeInstanceStateApi(instanceId: String, action: String) {
        NotificationSender().send(notificationName: "InstanceStateChanged")
    }
}
