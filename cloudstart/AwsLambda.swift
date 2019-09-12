import AWSLambda
import AWSMobileClient

class AwsLambda {
    
    static func authenticate() {
        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default()?.defaultServiceConfiguration = serviceConfiguration
        
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if userState != nil {
                print("AWSMobileClient initialized successfully")
            }
        }
    }
    
    static func invokeChangeInstanceStateApi(instanceId: String, action: String) {
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        let request = [
            "instanceId": instanceId,
            "action": action
        ]
        
        lambdaInvoker.invokeFunction("instancesPatch", jsonObject: request)
            .continueWith(block: {(task:AWSTask<AnyObject>) -> Any? in
                if let error = task.error as NSError? {
                    if (error.domain == AWSLambdaInvokerErrorDomain) && (AWSLambdaInvokerErrorType.functionError == AWSLambdaInvokerErrorType(rawValue: error.code)) {
                        print("Function error: \(error.userInfo[AWSLambdaInvokerFunctionErrorKey]!)")
                    } else {
                        print("Error: \(error)")
                    }
                    return nil
                } else if let response = task.result as? NSDictionary {
                    let instanceId = response.value(forKey: "instanceId")!
                    let action = response.value(forKey: "action")!
                    let status = response.value(forKey: "status")!
                    let message = response.value(forKey: "message")!
                    print("instanceId: \(instanceId), action: \(action), status: \(status), message: \(message)")
                    NotificationCenter.default.post(name: Notification.Name("InstanceStateChanged"), object: nil)
                }
                return nil
            }
        )
    }
    
    static func invokeGetInstancesApi() {
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        lambdaInvoker.invokeFunction("instancesGet", jsonObject: [:])
            .continueWith(block: {(task:AWSTask<AnyObject>) -> Any? in
                var instanceList = [Instance]()
                if let error = task.error as NSError? {
                    if (error.domain == AWSLambdaInvokerErrorDomain) && (AWSLambdaInvokerErrorType.functionError == AWSLambdaInvokerErrorType(rawValue: error.code)) {
                        print("Function error: \(error.userInfo[AWSLambdaInvokerFunctionErrorKey]!)")
                    } else {
                        print("Error: \(error)")
                    }
                    return nil
                } else if let jsonResponse = task.result as? NSDictionary {
                    if let instances = jsonResponse.allValues[0] as? NSArray {
                        for i in instances {
                            if let instance = i as? NSDictionary {
                                let instanceId = instance.value(forKey: "instanceId") as! String
                                let instanceType = instance.value(forKey: "instanceType") as! String
                                let state = instance.value(forKey: "state") as! String
                                let name = instance.value(forKey: "name") as! String
                                let x = Instance(instanceId: instanceId, instanceType: instanceType, state: state, name: name)
                                x.instanceId = instanceId
                                x.instanceType = instanceType
                                x.name = name
                                x.state = state
                                instanceList.append(x)
                            }
                        }
                    }
                    var notificationData = [String:[Instance]]()
                    notificationData["instances"] = instanceList
                    NotificationCenter.default.post(name: Notification.Name("InstanceListUpdated"), object: nil, userInfo: notificationData)
                }                
                return nil
            }
        )
    }
}
