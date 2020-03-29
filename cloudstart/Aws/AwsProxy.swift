struct AwsProxy {
    
    private static let awsClient = Aws()
    private static let awsClientMock = AwsMock()
    
    private init() {}
    
    static func changeInstanceState(instanceId: String, action: String) {
        #if MOCK_AWS
        awsClientMock.invokeChangeInstanceStateApi(instanceId: instanceId, action: action)
        #else
        awsClient.changeInstanceState(instanceId: instanceId, action: action)
        #endif
    }
    
    static func getInstances() {
        #if MOCK_AWS
        awsClientMock.getInstances()
        #else
        awsClient.getInstances()
        #endif
    }
}
