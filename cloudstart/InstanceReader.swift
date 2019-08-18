import Foundation

public class InstanceReader {
    static func get() -> Instances {
        let instances: Instances = Instances()
        
        let instance_1: Instance = Instance()
        instance_1.id = "i-0ebd41b671a9dfaad"
        instance_1.name = "Jenkins Master"
        instance_1.size = "t2.micro"
        instance_1.status = "Running"
        instances.add(instance: instance_1)
        
        let instance_3: Instance = Instance()
        instance_3.id = "i-009cc8fd7dd3ac8f4"
        instance_3.name = "Bamboo Server"
        instance_3.size = "t3.medium"
        instance_3.status = "Stopped"
        instances.add(instance: instance_3)
        
        let instance_2: Instance = Instance()
        instance_2.id = "i-0abd87b671a9dfaeb"
        instance_2.name = "Jenkins Slave"
        instance_2.size = "t3.medium"
        instance_2.status = "Terminated"
        instances.add(instance: instance_2)
        
        return instances
    }
}
