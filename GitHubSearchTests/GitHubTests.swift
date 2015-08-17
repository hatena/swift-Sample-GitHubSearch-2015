// The MIT License (MIT)
//
// Copyright (c) 2015 Hatena Co., Ltd.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

    func testSearchRepository_networkError() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            guard let components = request.URL.flatMap({ NSURLComponents(URL: $0, resolvingAgainstBaseURL: false) }) else { return false }
            return components.host == "api.github.com" &&
                components.path == "/search/repositories" &&
                (components.queryItems ?? []).contains(NSURLQueryItem(name: "q", value: "XML")) &&
                (components.queryItems ?? []).contains(NSURLQueryItem(name: "page", value: "3"))
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil))
        })

        let e = expectationWithDescription("API Request")
        github.request(GitHubAPI.SearchRepositories(query: "XML", page: 3)) { (task, response, error) -> Void in
            XCTAssert(response == nil)
            XCTAssert(error != nil)
            e.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testSearchRepository_rateLimit() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            guard let components = request.URL.flatMap({ NSURLComponents(URL: $0, resolvingAgainstBaseURL: false) }) else { return false }
            return components.host == "api.github.com" &&
                components.path == "/search/repositories" &&
                (components.queryItems ?? []).contains(NSURLQueryItem(name: "q", value: "Markdown")) &&
                (components.queryItems ?? []).contains(NSURLQueryItem(name: "page", value: "13"))
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(named: "error_rate-limit", inBundle: NSBundle(forClass: self.dynamicType))
        })

        let e = expectationWithDescription("API Request")
        github.request(GitHubAPI.SearchRepositories(query: "Markdown", page: 13)) { (task, response, error) -> Void in
            XCTAssert(response == nil)
            XCTAssert(error != nil)
            e.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }

}
