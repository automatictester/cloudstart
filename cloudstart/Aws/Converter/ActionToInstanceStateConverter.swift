public struct ActionToInstanceStateConverter {
    
    private init() {}
    
    public static func toFinal(_ action: String) -> String {
        if action == "stop" {
            return "stopped"
        } else if (action == "start") {
            return "running"
        } else if (action == "terminate") {
            return "terminated"
        } else {
            fatalError("Unknown action: \(action)")
        }
    }
    
    public static func toTransitional(_ action: String) -> String {
        if action == "stop" {
            return "stopping"
        } else if (action == "start") {
            return "pending"
        } else if (action == "terminate") {
            return "shutting-down"
        } else {
            fatalError("Unknown action: \(action)")
        }
    }
}
