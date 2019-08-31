import AWSMobileClient

class ApiGateway {
    
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
    
    func invokeChangeInstanceStateApi(instanceId: String, action: String) {
        let invocationClient = CloudStartClient(forKey: "")
        let request = ChangeInstanceStateRequest()
        request?.action = action
        invocationClient.instancesInstanceIdPatch(instanceId, body: request!).continueWith {(task: AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error)")
            } else if let rawChangeInstanceStateResponse = task.result {
                if rawChangeInstanceStateResponse is ChangeInstanceStateResponse {
                    let response = rawChangeInstanceStateResponse as! ChangeInstanceStateResponse
                    print("instanceId: \(response.instanceId), action: \(response.action), status: \(response.status), message: \(response.message)")
                } else if rawChangeInstanceStateResponse is NSDictionary {
                    let genericResult = rawChangeInstanceStateResponse as! NSDictionary
                    print("NSDictionary: \(genericResult)")
                }
            }
            return nil
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
                    let instances = describeInstancesResult.instances as! [Instance]
                    var notificationData = [String:[Instance]]()
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
