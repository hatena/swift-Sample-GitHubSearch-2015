//
//  GitHubSearchUITests.swift
//  GitHubSearchUITests
//
//  Created by Hiroki Kato on 2015/07/29.
//  Copyright © 2015年 Hatena Co., Ltd. All rights reserved.
//

import XCTest

class GitHubSearchUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSearch() {
        let app = XCUIApplication()
        app.tables["Empty list"].searchFields["Search"].tap()
        
        let searchSearchField = app.searchFields["Search"]
        
        searchSearchField.tap()
        let nextKeyboardButton = app.buttons["Next keyboard"]
        nextKeyboardButton.pressForDuration(1.0);
        app.staticTexts["English (US)"].tap()
        
        searchSearchField.typeText("Hatena")
        app.typeText("\n")
        
        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts["hatena/Hatena-Textbook"].tap()
        app.buttons["https://github.com/hatena/Hatena-Textbook"].tap()
        app.buttons["Done"].tap()
        app.navigationBars["Hatena-Textbook"].buttons["GitHub Search"].tap()
    }
    
}
