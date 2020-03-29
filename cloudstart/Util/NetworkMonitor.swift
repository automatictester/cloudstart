import Network

class NetworkMonitor {
    
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    var connected = false
    
    init() {
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                self.connected = true
                print("Network connected")
            } else {
                self.connected = false
                print("Network disconnected")
            }
        }
        monitor.start(queue: queue)
    }
}
