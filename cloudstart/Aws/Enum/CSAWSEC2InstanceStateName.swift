enum CSAWSEC2InstanceStateName: String, CaseIterable {
    case unknown, pending, running, shutting_down, terminated, stopping, stopped

    static var byId: [CSAWSEC2InstanceStateName] {
        return self.allCases
    }
}
