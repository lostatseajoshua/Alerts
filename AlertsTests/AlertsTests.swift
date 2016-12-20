//
//  AlertsTests.swift
//  AlertsTests
//
//  Created by Joshua Alvarado on 8/29/16.
//  Copyright © 2016 Joshua Alvarado. All rights reserved.
//

import XCTest
@testable import Alerts

class AlertsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        AlertCoordinator.main.reset()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        AlertCoordinator.main.reset()
    }
    
    func testHighAlertQueue() {
        let alert = Alert(title: "High", message: "Message", priorty: .high, alertActions: nil)
        AlertCoordinator.main.enqueue(alert: alert)
        XCTAssertEqual(AlertCoordinator.main.highPriorityQueue.count, 1)
        XCTAssertEqual(AlertCoordinator.main.defaultPriorityQueue.count, 0)
        XCTAssertEqual(AlertCoordinator.main.lowPriorityQueue.count, 0)
    }
    
    func testDefaultAlertQueue() {
        let alert = Alert(title: "Default", message: "Message", priorty: .medium, alertActions: nil)
        AlertCoordinator.main.enqueue(alert: alert)
        XCTAssertEqual(AlertCoordinator.main.highPriorityQueue.count, 0)
        XCTAssertEqual(AlertCoordinator.main.defaultPriorityQueue.count, 1)
        XCTAssertEqual(AlertCoordinator.main.lowPriorityQueue.count, 0)
    }
    
    func testLowAlertQueue() {
        let alert = Alert(title: "Low", message: "Message", priorty: .low, alertActions: nil)
        AlertCoordinator.main.enqueue(alert: alert)
        XCTAssertEqual(AlertCoordinator.main.highPriorityQueue.count, 0)
        XCTAssertEqual(AlertCoordinator.main.defaultPriorityQueue.count, 0)
        XCTAssertEqual(AlertCoordinator.main.lowPriorityQueue.count, 1)
    }
    
    func testResetOfAlertCoordinator() {
        let alert = Alert(title: "Default", message: "Message", priorty: .medium, alertActions: nil)
        AlertCoordinator.main.enqueue(alert: alert)
        XCTAssertEqual(AlertCoordinator.main.defaultPriorityQueue.count, 1)
        AlertCoordinator.main.reset()
        XCTAssertEqual(AlertCoordinator.main.highPriorityQueue.count, 0)
        XCTAssertEqual(AlertCoordinator.main.defaultPriorityQueue.count, 0)
        XCTAssertEqual(AlertCoordinator.main.lowPriorityQueue.count, 0)
    }
}
