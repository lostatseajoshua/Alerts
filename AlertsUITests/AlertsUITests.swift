//
//  AlertsUITests.swift
//  AlertsUITests
//
//  Created by Joshua Alvarado on 8/29/16.
//  Copyright © 2016 Joshua Alvarado. All rights reserved.
//

import XCTest

class AlertsUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAlerts() {
        let app = XCUIApplication()
        app.sheets["Action Sheet"].buttons["Okay"].tap()
        app.alerts["0"].buttons["Okay"].tap()
        app.alerts["1"].buttons["Okay"].tap()
        app.alerts["2"].buttons["Okay"].tap()
        app.alerts["3"].buttons["Dispatch"].tap()
        app.alerts["4"].buttons["Okay"].tap()
        app.alerts["5"].buttons["Okay"].tap()
        
        let heyAlert = app.alerts["Hey"]
        let heyAlertTextField = heyAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        heyAlertTextField.typeText("hey")
        XCTAssertNotNil(heyAlertTextField.value)
        XCTAssertEqual(heyAlertTextField.value as! String, "hey")
        heyAlert.buttons["Okay"].tap()
    }
}
