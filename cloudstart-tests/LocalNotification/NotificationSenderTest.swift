import cloudstart
import XCTest

class NotificationSenderTest: XCTestCase {
    
    private let notificationName = Notification.Name(rawValue: "TestNotification")
    private let notificationSender = NotificationSender()
    
    func testSend() {
        let _ = expectation(forNotification: notificationName, object: nil)
        notificationSender.send(notificationName: notificationName.rawValue)
        waitForExpectations(timeout: 1)
    }
    
    func testSendWithUserInfo() {
        let handler = { (notification: Notification) -> Bool in
            if let value = notification.userInfo?["key"] as? String {
                XCTAssertEqual(value, "value")
            }
            return true
        }
        expectation(forNotification: notificationName, object: nil, handler: handler)
        
        let operation = BlockOperation(block: {
            self.notificationSender.send(notificationName: self.notificationName.rawValue, userInfo: ["key": "value"])
        })
        operation.start()
        waitForExpectations(timeout: 1)
    }
}
