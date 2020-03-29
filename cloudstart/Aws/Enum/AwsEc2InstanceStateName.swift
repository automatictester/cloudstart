enum AwsEc2InstanceStateName: String, CaseIterable {
    case unknown, pending, running, shutting_down, terminated, stopping, stopped

    static var byId: [AwsEc2InstanceStateName] {
        return self.allCases
    }
}
