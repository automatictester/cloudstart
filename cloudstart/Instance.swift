public class Instance {
    
    public var instanceId: String!
    public var state: String!
    public var instanceType: String!
    public var name: String!
    
    public init(instanceId: String, instanceType: String, state: String, name: String) {
        self.instanceId = instanceId
        self.instanceType = instanceType
        self.state = state
        self.name = name
    }
}
