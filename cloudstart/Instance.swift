public struct Instance {
    
    private var instanceId: String
    private var instanceType: String
    private var state: String
    private var name: String
    
    public init(instanceId: String, instanceType: String, state: String, name: String) {
        self.instanceId = instanceId
        self.instanceType = instanceType
        self.state = state
        self.name = name
    }
    
    public func getInstanceId() -> String {
        return instanceId
    }
    
    public func getInstanceType() -> String {
        return instanceType
    }
    
    public func getState() -> String {
        return state
    }
    
    public func getName() -> String {
        return name
    }
}
