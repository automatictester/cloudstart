import Foundation

class Instances {
    private var instances = [Instance]()
    
    func add(instance: Instance) {
        instances.append(instance)
    }
    
    func get(index: Int) -> Instance {
        return instances[index]
    }
    
    func get(instanceId: String) -> Instance? {
        for instance in instances {
            if(instance.id == instanceId) {
                return instance
            }
        }
        return nil
    }
    
    func size() -> Int {
        return instances.count
    }
}
