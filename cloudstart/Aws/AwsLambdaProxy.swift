struct AwsLambdaProxy {
    
    private init() {}
    
    static func authenticate() {
        #if MOCK_AWS
        AwsLambdaMock.authenticate()
        #else
        AwsLambda.authenticate()
        #endif
    }
    
    static func invokeChangeInstanceStateApi(instanceId: String, action: String) {
        #if MOCK_AWS
        AwsLambdaMock.invokeChangeInstanceStateApi(instanceId: instanceId, action: action)
        #else
        AwsLambda.invokeChangeInstanceStateApi(instanceId: instanceId, action: action)
        #endif
    }
    
    static func invokeGetInstancesApi() {
        #if MOCK_AWS
        AwsLambdaMock.invokeGetInstancesApi()
        #else
        AwsLambda.invokeGetInstancesApi()
        #endif
    }
}
