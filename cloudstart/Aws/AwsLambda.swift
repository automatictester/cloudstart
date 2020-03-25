import AWSLambda
import AWSMobileClient

struct AwsLambda {
    
    static var backgroundTaskId: UIBackgroundTaskIdentifier?
    
    private init() {}
    
    static func authenticate() {        
        let credentialsProvider = AWSMobileClient.default().getCredentialsProvider()
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.EUWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration
        
        AWSMobileClient.default().initialize { (userState, error) in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if let state = userState {
                print("AWSMobileClient initialized successfully. User state: \(state)")
            }
        }
    }
    
    static func invokeChangeInstanceStateApi(instanceId: String, action: String) {
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        let request = [
            "instanceId": instanceId,
            "action": action
        ]
        
        DispatchQueue.main.async {
            backgroundTaskId = UIApplication.shared.beginBackgroundTask() { endChangeInstanceStateTask() }
            lambdaInvoker.invokeFunction("instancesPatch", jsonObject: request)
                .continueWith(block: {(task:AWSTask<AnyObject>) -> Any? in
                    if let error = task.error as NSError? {
                        if (error.domain == AWSLambdaInvokerErrorDomain) && (AWSLambdaInvokerErrorType.functionError == AWSLambdaInvokerErrorType(rawValue: error.code)) {
                            print("Function error: \(error.userInfo[AWSLambdaInvokerFunctionErrorKey]!)")
                        } else {
                            print("Error: \(error)")
                        }
                        endChangeInstanceStateTask()
                        return nil
                    } else if let response = task.result as? NSDictionary {
                        let instanceId = response.value(forKey: "instanceId")! as! String
                        let action = response.value(forKey: "action")! as! String
                        let status = response.value(forKey: "status")!
                        let message = response.value(forKey: "message")!

                        print("instanceId: \(instanceId), action: \(action), status: \(status), message: \(message)")
                        
                        let supportedActioNotifications: Set = ["start", "stop", "terminate"]
                        if (supportedActioNotifications.contains(action)) {
                            NotificationSender().send(notificationName: "InstanceStateChanged")
                            InstanceStateChangeNotifier.notify(instanceId: instanceId, action: action)
                        }
                        endChangeInstanceStateTask()
                    }
                    return nil
                }
            )
        }
    }
    
    static func endChangeInstanceStateTask() {
        print("Ending background task")
        UIApplication.shared.endBackgroundTask(backgroundTaskId!)
        backgroundTaskId = UIBackgroundTaskIdentifier.invalid
    }
}
