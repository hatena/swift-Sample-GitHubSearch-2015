//
//  GitHubTests.swift
//  GitHubSearch
//
//  Created by Hiroki Kato on 2015/07/29.
//  Copyright © 2015年 Hatena Co., Ltd. All rights reserved.
//

import XCTest
import OHHTTPStubs

import GitHubSearch

class GitHubTests: XCTestCase {
    
    var github: GitHubAPI!

    override func setUp() {
        super.setUp()
        github = GitHubAPI()
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testSearchRepository() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            guard let components = request.URL.flatMap({ NSURLComponents(URL: $0, resolvingAgainstBaseURL: false) }) else { return false }
            return components.host == "api.github.com" &&
                components.path == "/search/repositories" &&
                (components.queryItems ?? []).contains(NSURLQueryItem(name: "q", value: "Hatena")) &&
                (components.queryItems ?? []).contains(NSURLQueryItem(name: "page", value: "1"))
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(named: "search-repositories_q-Hatena_page-1", inBundle: NSBundle(forClass: self.dynamicType))
        })
        
        let e = expectationWithDescription("API Request")
        github.request(GitHubAPI.SearchRepositories(query: "Hatena", page: 1)) { (task, response, error) -> Void in
            XCTAssert(response != nil)
            XCTAssert(error == nil)
            e.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }

}
