import AWSEC2

struct AwsEc2 {
    
    private init() {}
    
    static func getInstances() {
        let serviceConfig = getServiceConfig()
        AWSEC2.register(with: serviceConfig, forKey: "eu-west-2")
        let request: AWSEC2DescribeInstancesRequest = AWSEC2DescribeInstancesRequest()
        let ec2 = AWSEC2(forKey: "eu-west-2")
        
        ec2.describeInstances(request).continueWith(block: {(task: AWSTask) -> Void in
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
    
    private static func getServiceConfig() -> AWSServiceConfiguration {
        let credentialProvider: AWSStaticCredentialsProvider = AWSStaticCredentialsProvider(
            accessKey: AppConfig.accessKey, secretKey: AppConfig.secretKey
        )
        return AWSServiceConfiguration(region: .EUWest2, credentialsProvider: credentialProvider)
    }
}
