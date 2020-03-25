import UserNotifications

struct InstanceStateChangeNotifier {
    
    private init() {}
    
    static func notify(instanceId: String, action: String) {
        let userNotificationCenter = UNUserNotificationCenter.current()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = getTitle(action: action)
        notificationContent.body = getBody(instanceId: instanceId, action: action)

        let request = UNNotificationRequest(identifier: "instanceStateChangeNotification", content: notificationContent, trigger: nil)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Error adding notification: ", error)
            }
        }
    }
    
    static func getTitle(action: String) -> String {
        switch action {
        case "start":
            return "Instance started"
        case "stop":
            return "Instance stopped"
        case "terminate":
            return "Instance terminated"
        default:
            print("Unknown action: ", action)
            return action
        }
    }
    
    static func getBody(instanceId: String, action: String) -> String {
        switch action {
        case "start":
            return "Instance \(instanceId) was started"
        case "stop":
            return "Instance \(instanceId) was stopped"
        case "terminate":
            return "Instance \(instanceId) was terminated"
        default:
            print("Unknown action: ", action)
            return instanceId
        }
    }
}
