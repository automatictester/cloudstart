import Network

class NetworkMonitor {
    
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    var connected = false
    
    init() {
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                self.connected = true
                print("network connected")
            } else {
                self.connected = false
                print("network disconnected")
            }
        }
        monitor.start(queue: queue)
    }
}
