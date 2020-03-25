struct AwsLambdaProxy {
    
    private init() {}
    
    static func authenticate() {
        #if MOCK_AWS
        AwsEc2Mock.authenticate()
        #else
        AwsLambda.authenticate()
        #endif
    }
    
    static func invokeChangeInstanceStateApi(instanceId: String, action: String) {
        #if MOCK_AWS
        AwsEc2Mock.invokeChangeInstanceStateApi(instanceId: instanceId, action: action)
        #else
        AwsLambda.invokeChangeInstanceStateApi(instanceId: instanceId, action: action)
        #endif
    }
    
    static func invokeGetInstancesApi() {
        #if MOCK_AWS
        AwsEc2Mock.getInstances()
        #else
        AwsEc2.getInstances()
        #endif
    }
}
