import AWSMobileClient

class ApiInvoker {
    
    func authenticate() {
        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest2, credentialsProvider: credentialsProvider)
        CloudStartClient.register(with: serviceConfiguration!, forKey: "")
        
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if userState != nil {
                print("AWSMobileClient initialized successfully")
            }
        }
    }
    
    func invokeGetInstancesApi() {
        let invocationClient = CloudStartClient(forKey: "")
        invocationClient.instancesGet().continueWith {(task: AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error)")
            } else if let rawDescribeInstancesResult = task.result {
                if rawDescribeInstancesResult is DescribeInstancesResult {
                    let describeInstancesResult = rawDescribeInstancesResult as! DescribeInstancesResult
                    let instances = describeInstancesResult.instances as! [Ec2Instance]
                    var notificationData = [String:[Ec2Instance]]()
                    notificationData["instances"] = instances
                    NotificationCenter.default.post(name: Notification.Name("InstanceListUpdated"), object: nil, userInfo: notificationData)
                } else if rawDescribeInstancesResult is NSDictionary {
                    let genericResult = rawDescribeInstancesResult as! NSDictionary
                    print("NSDictionary: \(genericResult)")
                }
            }
            return nil
        }
    }
}
