public struct InstanceListSorter {
    
    private init() {}
    
    public static func sortInstances(_ instances: [Instance]) -> [Instance] {
        return instances.sorted { i1, i2 in
            return (i1.getState(), i1.getName()) < (i2.getState(), i2.getName())
        }
    }
}
