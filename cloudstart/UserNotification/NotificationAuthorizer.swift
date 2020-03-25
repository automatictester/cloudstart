import UserNotifications

struct NotificationAuthorizer {
    
    static let userNotificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    public static func requestAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert)
        userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error processing notification authorization: ", error)
            }
        }
    }
}
