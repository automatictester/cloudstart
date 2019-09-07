import AWSMobileClient

class ApiGateway {
    
    func authenticate() {
        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest2, credentialsProvider: credentialsProvider)
        CloudStartClient.registerClient(withConfiguration: serviceConfiguration!, forKey: "")
        
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if userState != nil {
                print("AWSMobileClient initialized successfully")
            }
        }
    }
    
    func invokeChangeInstanceStateApi(instanceId: String, action: String) {
        let invocationClient = CloudStartClient.client(forKey: "")
        let request = ChangeInstanceStateRequest()
        request?.action = action
        invocationClient.instancesInstanceIdPatch(instanceId: instanceId, body: request!).continueWith {(task: AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error)")
            } else if let response = task.result {
                print("instanceId: \(response.instanceId!), action: \(response.action!), status: \(response.status!), message: \(response.message!)")
                NotificationCenter.default.post(name: Notification.Name("InstanceStateChanged"), object: nil)
            }
            return nil
        }
    }
    
    func invokeGetInstancesApi() {
        let invocationClient = CloudStartClient.client(forKey: "")
        invocationClient.instancesGet().continueWith {(task: AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error)")
            } else if let result = task.result {
                var notificationData = [String:[Instance]]()
                notificationData["instances"] = result.instances
                NotificationCenter.default.post(name: Notification.Name("InstanceListUpdated"), object: nil, userInfo: notificationData)
            }
            return nil
        }
    }
}
