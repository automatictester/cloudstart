import cloudstart
import Foundation
import XCTest

class ActionToInstanceStateConverterTest: XCTestCase {

    func testToFinal() {
        let running = ActionToInstanceStateConverter.toFinal("start")
        XCTAssertEqual(running, "running")
        let stopped = ActionToInstanceStateConverter.toFinal("stop")
        XCTAssertEqual(stopped, "stopped")
        let terminated = ActionToInstanceStateConverter.toFinal("terminate")
        XCTAssertEqual(terminated, "terminated")
    }

    func testToTransitional() {
        let pending = ActionToInstanceStateConverter.toTransitional("start")
        XCTAssertEqual(pending, "pending")
        let stopping = ActionToInstanceStateConverter.toTransitional("stop")
        XCTAssertEqual(stopping, "stopping")
        let shuttingDown = ActionToInstanceStateConverter.toTransitional("terminate")
        XCTAssertEqual(shuttingDown, "shutting-down")
    }
}
