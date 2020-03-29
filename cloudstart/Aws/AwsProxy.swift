struct AwsProxy {
    
    private static let ec2 = AwsEc2()
    
    private init() {}
    
    static func changeInstanceState(instanceId: String, action: String) {
        #if MOCK_AWS
        AwsEc2Mock.invokeChangeInstanceStateApi(instanceId: instanceId, action: action)
        #else
        ec2.changeInstanceState(instanceId: instanceId, action: action)
        #endif
    }
    
    static func getInstances() {
        #if MOCK_AWS
        AwsEc2Mock.getInstances()
        #else
        ec2.getInstances()
        #endif
    }
}
