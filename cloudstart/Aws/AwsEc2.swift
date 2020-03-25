import AWSEC2

struct AwsEc2 {
    
    private let region = "eu-west-2"
    private var client: AWSEC2?
    
    init() {
        let serviceConfig = getServiceConfig()
        AWSEC2.register(with: serviceConfig, forKey: region)
        client = AWSEC2(forKey: region)
    }
    
    func changeInstanceState(instanceId: String, action: String) {
        switch action {
        case "reboot":
            let request = AWSEC2RebootInstancesRequest()!
            request.instanceIds = [instanceId]
            client!.rebootInstances(request) // TODO: .continueWith(block: ...
        default:
            print("Unknown action: \(action)")
        }
        
    }
    
    func getInstances() {
        let request = AWSEC2DescribeInstancesRequest()!        
        client!.describeInstances(request).continueWith(block: {(task: AWSTask) -> Void in
            if let error = task.error as NSError? {
                let errorDetails = error.userInfo[AWSResponseObjectErrorUserInfoKey] as! Dictionary<String, String>
                let errorMessage = errorDetails["Message"]!
                print("Error: \(errorMessage)")
                let notificationData = ["errorMessage": errorMessage]
                NotificationSender().send(notificationName: "InstanceListUpdateFailed", userInfo: notificationData)
            } else if let response = task.result?.dictionaryValue as! Dictionary<String, Array<AWSEC2Reservation>>? {
                let notificationData = ["instances": DescribeInstancesResponseConverter.toInstanceArray(response)]
                print("Instances: \(notificationData)")
                NotificationSender().send(notificationName: "InstanceListUpdated", userInfo: notificationData)
            }
        })
    }
    
    private func getServiceConfig() -> AWSServiceConfiguration {
        let credentialProvider: AWSStaticCredentialsProvider = AWSStaticCredentialsProvider(
            accessKey: AppConfig.accessKey, secretKey: AppConfig.secretKey
        )
        return AWSServiceConfiguration(region: .EUWest2, credentialsProvider: credentialProvider)
    }
}
