import UserNotifications

struct InstanceStateChangeNotifier {
    
    private init() {}
    
    static func notifyFinal(instanceId: String, action: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = getFinalStateTitle(action: action)
        notificationContent.body = getFinalStateBody(instanceId: instanceId, action: action)
        notify(notificationContent)
    }
    
    static func notifyTransitional(instanceId: String, action: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = getTransitionalStateTitle(action: action)
        notificationContent.body = getTransitionalStateBody(instanceId: instanceId, action: action)
        notify(notificationContent)
    }
    
    private static func notify(_ notificationContent: UNMutableNotificationContent) {
        let request = UNNotificationRequest(identifier: "instanceStateChangeNotification", content: notificationContent, trigger: nil)
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Error adding notification: ", error)
            }
        }
    }
    
    static func getFinalStateTitle(action: String) -> String {
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
    
    static func getTransitionalStateTitle(action: String) -> String {
        switch action {
        case "start":
            return "Instance starting"
        case "stop":
            return "Instance stopping"
        case "terminate":
            return "Instance terminating"
        default:
            print("Unknown action: ", action)
            return action
        }
    }
    
    static func getFinalStateBody(instanceId: String, action: String) -> String {
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
    
    static func getTransitionalStateBody(instanceId: String, action: String) -> String {
        switch action {
        case "start":
            return "Instance \(instanceId) is starting"
        case "stop":
            return "Instance \(instanceId) is stopping"
        case "terminate":
            return "Instance \(instanceId) is terminating"
        default:
            print("Unknown action: ", action)
            return instanceId
        }
    }
}
