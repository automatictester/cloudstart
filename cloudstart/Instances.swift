import Foundation

class Instances {
    private var instances = [Instance]()
    
    func add(instance: Instance) {
        instances.append(instance)
    }
    
    func get(index: Int) -> Instance {
        return instances[index]
    }
    
    func size() -> Int {
        return instances.count
    }
}
