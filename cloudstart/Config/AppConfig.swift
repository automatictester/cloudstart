import Foundation

public enum AppConfig {
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let accessKey: String = {
        guard let accessKey = infoDictionary["ACCESS_KEY"] as? String else {
            fatalError("ACCESS_KEY Key not set in plist")
        }
        return accessKey
    }()
    
    static let secretKey: String = {
        guard let secretKey = infoDictionary["SECRET_KEY"] as? String else {
            fatalError("SECRET_KEY Key not set in plist")
        }
        return secretKey
    }()
}
