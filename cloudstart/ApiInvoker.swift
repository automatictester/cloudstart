import AWSMobileClient

class ApiInvoker {
    
    func authenticate() {
        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest2, credentialsProvider: credentialsProvider)
        AWSAPI_M7D0OMWZFJ_CloudStartClient.register(with: serviceConfiguration!, forKey: "")
        
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if userState != nil {
                print("AWSMobileClient initialized successfully")
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
                    let xxx = res.instances as! [AWSAPI_M7D0OMWZFJ_InstancesGet_instances_item]
                    
                    print(String(format:"%@", xxx[0].name))
                    print(String(format:"%@", xxx[1].name))
                    print(String(format:"%@", xxx[2].name))
                    
                } else if result is NSDictionary {
                    let res = result as! NSDictionary
                    print("NSDictionary: \(res)")
                }
            }
            return nil
        }
    }
}
