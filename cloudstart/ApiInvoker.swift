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
    
    func doInvokeAPI() {
        let invocationClient = CloudStartClient(forKey: "")
        
        invocationClient.instancesGet().continueWith {(task: AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error)")
            } else if let result = task.result {
                if result is DescribeInstancesResult {
                    let res = result as! DescribeInstancesResult
                    let xxx = res.instances as! [Ec2Instance]
                    
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
