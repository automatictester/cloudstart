public struct InstanceStateNameConverter {
    
    private init() {}
    
    public static func from(_ value: String) -> String {
        return value.replacingOccurrences(of: "_", with: "-")
    }
}
