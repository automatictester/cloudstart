import AWSEC2

class AwsEc2 {
    
    private let region = "eu-west-2"
    private var client: AWSEC2?
    private var backgroundTaskId: UIBackgroundTaskIdentifier?
    
    init() {
        let serviceConfig = getServiceConfig()
        AWSEC2.register(with: serviceConfig, forKey: region)
        client = AWSEC2(forKey: region)
    }
    
    func changeInstanceState(instanceId: String, action: String) {
        DispatchQueue.main.async {
            self.backgroundTaskId = UIApplication.shared.beginBackgroundTask() { self.endChangeInstanceStateTask() }
            switch action {
            case "reboot":
                let request = AWSEC2RebootInstancesRequest()!
                request.instanceIds = [instanceId]
                self.client!.rebootInstances(request).continueWith(block: {(task: AWSTask) -> Void in
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
                self.client!.startInstances(request).continueWith(block: {(task: AWSTask) -> Void in
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
                self.client!.stopInstances(request).continueWith(block: {(task: AWSTask) -> Void in
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
                self.client!.terminateInstances(request).continueWith(block: {(task: AWSTask) -> Void in
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
        client!.describeInstances(request).continueWith(block: {(task: AWSTask) -> Void in
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
                        self.endChangeInstanceStateTask()
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
    
    func getInstances() {
        let request = AWSEC2DescribeInstancesRequest()!        
        client!.describeInstances(request).continueWith(block: {(task: AWSTask) -> Void in
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
