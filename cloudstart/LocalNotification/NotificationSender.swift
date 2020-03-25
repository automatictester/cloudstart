import NotificationCenter

public struct NotificationSender {
    
    public init() {}
    
    public func send(notificationName: String) {
        send(notificationName: notificationName, userInfo: nil)
    }
    
    public func send(notificationName: String, userInfo: Dictionary<String, Any>?) {
        NotificationCenter.default.post(name: Notification.Name(notificationName), object: nil, userInfo: userInfo)
    }
}
