import Foundation

public class InstanceReader {
    static func get() -> Instances {
        let instances: Instances = Instances()
        
        let master: Instance = Instance()
        master.name = "Jenkins Master"
        master.status = "Running"
        instances.add(instance: master)
        
        let slave: Instance = Instance()
        slave.name = "Jenkins Slave"
        slave.status = "Terminated"
        instances.add(instance: slave)
        
        return instances
    }
}
