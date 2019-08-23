import AWSMobileClient

class ApiInvoker {
    
    func authenticate() {
        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest2, credentialsProvider: credentialsProvider)
        AWSAPI_M7D0OMWZFJ_CloudStartClient.register(with: serviceConfiguration!, forKey: "")
        
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if let userState = userState {
                let username = AWSMobileClient.sharedInstance().username!
                let userState = userState.rawValue
                print("Username: \(username), state: \(userState)")
            }
        }
    }
    
    func doInvokeAPI() {
        let invocationClient = AWSAPI_M7D0OMWZFJ_CloudStartClient(forKey: "")
        
        invocationClient.instancesGet().continueWith {(task: AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error)")
            } else if let result = task.result {
                if result is AWSAPI_M7D0OMWZFJ_InstancesGet {
                    let res = result as! AWSAPI_M7D0OMWZFJ_InstancesGet
                    print(String(format:"%@ %@", res.body, res.statusCode))
                } else if result is NSDictionary {
                    let res = result as! NSDictionary
                    print("NSDictionary: \(res)")
                }
            }
            return nil
        }
    }
}
