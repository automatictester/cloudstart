import Foundation

public class InstanceReader {
    static func get() -> [Ec2Instance] {
        var instances = [Ec2Instance]()
        
        let instance_1: Ec2Instance = Ec2Instance()
        instance_1.instanceId = "i-0ebd41b671a9dfaad"
        instance_1.name = "Jenkins Master"
        instance_1.instanceType = "t2.micro"
        instance_1.state = "Running"
        instances.append(instance_1)
        
        let instance_3: Ec2Instance = Ec2Instance()
        instance_3.instanceId = "i-009cc8fd7dd3ac8f4"
        instance_3.name = "Bamboo Server"
        instance_3.instanceType = "t3.medium"
        instance_3.state = "Stopped"
        instances.append(instance_3)
        
        let instance_2: Ec2Instance = Ec2Instance()
        instance_2.instanceId = "i-0abd87b671a9dfaeb"
        instance_2.name = "Jenkins Slave"
        instance_2.instanceType = "t3.medium"
        instance_2.state = "Terminated"
        instances.append(instance_2)
        
        return instances
    }
}
