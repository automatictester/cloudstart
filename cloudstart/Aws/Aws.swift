import AWSEC2
import AWSLambda

class Aws {
    
    private var backgroundTaskId: UIBackgroundTaskIdentifier?
    
    func lazyInit() {
        if AWSServiceManager.default().defaultServiceConfiguration == nil {
            AWSServiceManager.default().defaultServiceConfiguration = getServiceConfig()
        }
    }
    
    func getInstances() {
        lazyInit()
        let request = AWSEC2DescribeInstancesRequest()!
        AWSEC2.default().describeInstances(request).continueWith(block: {(task: AWSTask) -> Void in
            if let error = task.error as NSError? {
                let errorDetails = error.userInfo[AWSResponseObjectErrorUserInfoKey] as! Dictionary<String, String>
                let errorMessage = errorDetails["Message"]!
                print("Error: \(errorMessage)")
                let notificationData = ["errorMessage": errorMessage]
                NotificationSender().send(notificationName: "InstanceListUpdateFailed", userInfo: notificationData)
            } else if let response = task.result?.dictionaryValue as! Dictionary<String, Array<AWSEC2Reservation>>? {
                let notificationData = ["instances": DescribeInstancesResponseConverter.toInstanceArray(response)]
                print("Get instances: \(notificationData)")
                NotificationSender().send(notificationName: "InstanceListUpdated", userInfo: notificationData)
            }
        })
    }
    
    func changeInstanceState(instanceId: String, action: String) {
        lazyInit()
        DispatchQueue.main.async {
            self.backgroundTaskId = UIApplication.shared.beginBackgroundTask() { self.endChangeInstanceStateTask() }
            switch action {
            case "reboot":
                let request = AWSEC2RebootInstancesRequest()!
                request.instanceIds = [instanceId]
                AWSEC2.default().rebootInstances(request).continueWith(block: {(task: AWSTask) -> Void in
                    if let error = task.error as NSError? {
                        self.handleChangeInstanceStateError(error)
                    } else {
                        print("instanceId: \(instanceId), action: \(action)")
                        self.endChangeInstanceStateTask()
                    }
                })
            case "start":
                let request = AWSEC2StartInstancesRequest()!
                request.instanceIds = [instanceId]
                AWSEC2.default().startInstances(request).continueWith(block: {(task: AWSTask) -> Void in
                    if let error = task.error as NSError? {
                        self.handleChangeInstanceStateError(error)
                    } else {
                        print("instanceId: \(instanceId), action: \(action)")
                        self.waitFor(iteration: 1, instanceId: instanceId, action: action, notifiedOfTransitionalStateChange: false)
                    }
                })
            case "stop":
                let request = AWSEC2StopInstancesRequest()!
                request.instanceIds = [instanceId]
                AWSEC2.default().stopInstances(request).continueWith(block: {(task: AWSTask) -> Void in
                    if let error = task.error as NSError? {
                        self.handleChangeInstanceStateError(error)
                    } else {
                        print("instanceId: \(instanceId), action: \(action)")
                        self.waitFor(iteration: 1, instanceId: instanceId, action: action, notifiedOfTransitionalStateChange: false)
                    }
                })
            case "terminate":
                let request = AWSEC2TerminateInstancesRequest()!
                request.instanceIds = [instanceId]
                AWSEC2.default().terminateInstances(request).continueWith(block: {(task: AWSTask) -> Void in
                    if let error = task.error as NSError? {
                        self.handleChangeInstanceStateError(error)
                    } else {
                        print("instanceId: \(instanceId), action: \(action)")
                        self.waitFor(iteration: 1, instanceId: instanceId, action: action, notifiedOfTransitionalStateChange: false)
                    }
                })
            default:
                print("Unknown action: \(action)")
            }
        }
    }
    
    private func waitFor(iteration: Int, instanceId: String, action: String, notifiedOfTransitionalStateChange: Bool) {
        let request = AWSEC2DescribeInstancesRequest()!
        request.instanceIds = [instanceId]
        print("Iteration: \(iteration)")
        let maxIterations = 60
        let sleepTime: TimeInterval = 5
        if iteration >= maxIterations {
            print("Instance \(instanceId) failed to reach its final state within specified time limit of \(maxIterations * Int(sleepTime)) seconds")
            return
        }
        let nextIteration = iteration + 1
        AWSEC2.default().describeInstances(request).continueWith(block: {(task: AWSTask) -> Void in
            if let error = task.error as NSError? {
                let errorDetails = error.userInfo[AWSResponseObjectErrorUserInfoKey] as! Dictionary<String, String>
                let errorMessage = errorDetails["Message"]!
                print("Error: \(errorMessage)")
                self.endChangeInstanceStateTask()
                return
            } else if let response = task.result?.dictionaryValue as! Dictionary<String, Array<AWSEC2Reservation>>? {
                let instances = DescribeInstancesResponseConverter.toInstanceArray(response)
                let transitionalState = ActionToInstanceStateConverter.toTransitional(action)
                let finalState = ActionToInstanceStateConverter.toFinal(action)
                for instance in instances {
                    if instance.getInstanceId() == instanceId && instance.getState() == transitionalState && !notifiedOfTransitionalStateChange {
                        print("Instance '\(instanceId)' reached its expected transitional state '\(transitionalState)'")
                        NotificationSender().send(notificationName: "InstanceStateChanged")
                        InstanceStateChangeNotifier.notifyTransitional(instanceId: instanceId, action: action)
                        Thread.sleep(forTimeInterval: sleepTime)
                        self.waitFor(iteration: nextIteration, instanceId: instanceId, action: action, notifiedOfTransitionalStateChange: true)
                    } else if instance.getInstanceId() == instanceId && instance.getState() == finalState {
                        print("Instance '\(instanceId)' reached its expected final state '\(finalState)'")
                        NotificationSender().send(notificationName: "InstanceStateChanged")
                        InstanceStateChangeNotifier.notifyFinal(instanceId: instanceId, action: action)
                        if action == "stop" || action == "terminate" {
                            self.invokeUpdateDns(instanceId: instanceId, action: "delete")
                        } else if action == "start" {
                            self.invokeUpdateDns(instanceId: instanceId, action: "upsert")
                        } else {
                            self.endChangeInstanceStateTask()
                        }
                        return
                    } else {
                        if iteration < maxIterations {
                            print("Waiting: \(Int(sleepTime)) seconds")
                            Thread.sleep(forTimeInterval: sleepTime)
                            self.waitFor(iteration: nextIteration, instanceId: instanceId, action: action, notifiedOfTransitionalStateChange: notifiedOfTransitionalStateChange)
                        }
                    }
                }
            } else {
                print("No handler configured, returning")
                self.endChangeInstanceStateTask()
                return
            }
        })
    }
    
    private func invokeUpdateDns(instanceId: String, action: String) {
        let lambdaInvoker = AWSLambdaInvoker.default()
        let request = getLambdaInvokeRequest(instanceId: instanceId, action: action)
        lambdaInvoker.invoke(request).continueWith( block: { (task: AWSTask) -> Void in
            if let error = task.error as NSError? {
                if error.domain == AWSLambdaInvokerErrorDomain {
                    print("Lambda function execution error: \(error.userInfo[AWSLambdaInvokerErrorMessageKey]!)")
                } else {
                    print("Service error: \(error.userInfo["Message"]!)")
                }
            } else {
                print("Successful DNS update")
            }
            self.endChangeInstanceStateTask()
        })
    }
    
    private func getLambdaInvokeRequest(instanceId: String, action: String) -> AWSLambdaInvokerInvocationRequest {
        let payload = [
            "instanceId": instanceId,
            "action": action
        ]
        
        let request = AWSLambdaInvokerInvocationRequest()!
        request.functionName = "updateDns"
        request.invocationType = .requestResponse
        request.payload = payload
        
        return request
    }
    
    private func handleChangeInstanceStateError(_ error: NSError) {
        let errorDetails = error.userInfo[AWSResponseObjectErrorUserInfoKey] as! Dictionary<String, String>
        let errorMessage = errorDetails["Message"]!
        print("Error: \(errorMessage)")
        self.endChangeInstanceStateTask()
    }
    
    private func endChangeInstanceStateTask() {
        print("Ending background task")
        UIApplication.shared.endBackgroundTask(backgroundTaskId!)
        backgroundTaskId = UIBackgroundTaskIdentifier.invalid
    }
    
    private func getServiceConfig() -> AWSServiceConfiguration {
        let credentialProvider: AWSStaticCredentialsProvider = AWSStaticCredentialsProvider(
            accessKey: AppConfig.accessKey, secretKey: AppConfig.secretKey
        )
        return AWSServiceConfiguration(region: .EUWest2, credentialsProvider: credentialProvider)
    }
}
