//
//  GitHubTests.swift
//  GitHubSearch
//
//  Created by Hiroki Kato on 2015/07/29.
//  Copyright © 2015年 Hatena Co., Ltd. All rights reserved.
//

import XCTest

import GitHubSearch

class GitHubTests: XCTestCase {
    
    var github: GitHubAPI!

    override func setUp() {
        super.setUp()
        github = GitHubAPI()
    }
    
    func testSearchRepository() {
        let e = expectationWithDescription("API Request")
        github.request(GitHubAPI.SearchRepositories(query: "Hatena")) { (task, response, error) -> Void in
            XCTAssert(response != nil)
            XCTAssert(error == nil)
            e.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }

}
