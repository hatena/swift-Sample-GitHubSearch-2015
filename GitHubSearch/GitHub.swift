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

import Foundation

import AFNetworking

public typealias JSONObject = [String: AnyObject]

public enum HTTPMethod {
    case Get
}

/**
API endpoint
*/
public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters { get }
    associatedtype ResponseType: JSONDecodable
}

/**
Request parameters
*/
public struct Parameters: DictionaryLiteralConvertible {
    public private(set) var dictionary: [String: AnyObject] = [:]
    public typealias Key = String
    public typealias Value = AnyObject?
    /**
    Initialized from dictionary literals
    */
    public init(dictionaryLiteral elements: (Parameters.Key, Parameters.Value)...) {
        for case let (key, value?) in elements {
            dictionary[key] = value
        }
    }
}

/**
API error

- UnexpectedResponse: Unexpected structure
*/
public enum APIError: ErrorType {
    case UnexpectedResponse
}

/** GitHub API
- SeeAlso: https://developer.github.com/v3/
*/
public class GitHubAPI {
    private let HTTPSessionManager: AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager(baseURL: NSURL(string: "https://api.github.com/"))
        manager.requestSerializer.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return manager
    }()

    public init() {
    }

    /**
    Perform HTTP request for any endpoints.

    - Parameters:
      - endpoint: API endpoint.
      - handler:  Request results handler.
    */
    public func request<Endpoint: APIEndpoint>(endpoint: Endpoint, handler: (task: NSURLSessionDataTask, response: Endpoint.ResponseType?, error: ErrorType?) -> Void) {
        let success = { (task: NSURLSessionDataTask!, response: AnyObject!) -> Void in
            if let JSON = response as? JSONObject {
                do {
                    let response = try Endpoint.ResponseType(JSON: JSON)
                    handler(task: task, response: response, error: nil)
                } catch {
                    handler(task: task, response: nil, error: error)
                }
            } else {
                handler(task: task, response: nil, error: APIError.UnexpectedResponse)
            }
        }
        let failure = { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
            var error = error
            // If the error has any data, put it into "localized failure reason"
            if let errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? NSData,
                let errorDescription = NSString(data: errorData, encoding: NSUTF8StringEncoding) {
                    var userInfo = error.userInfo
                    userInfo[NSLocalizedFailureReasonErrorKey] = errorDescription
                    error = NSError(domain: error.domain, code: error.code, userInfo: userInfo)
            }
            handler(task: task, response: nil, error: error)
        }

        switch endpoint.method {
        case .Get:
            HTTPSessionManager.GET(endpoint.path, parameters: endpoint.parameters.dictionary, success: success, failure: failure)
        }
    }

    // MARK: - Endpoints

    /**
    - SeeAlso: https://developer.github.com/v3/search/#search-repositories
    */
    public struct SearchRepositories: APIEndpoint {
        public var path = "search/repositories"
        public var method = HTTPMethod.Get
        public var parameters: Parameters {
            return [
                "q" : query,
                "page" : page,
            ]
        }
        public typealias ResponseType = SearchResult<Repository>

        public let query: String
        public let page: Int

        /**
        Search repositories

        - Parameters:
          - query: Search query.
          - page:  Page. 1...
        - Returns: Search repositories API endpoint
        */
        public init(query: String, page: Int) {
            self.query = query
            self.page = page
        }
    }
}

/**
JSON decodable type
*/
public protocol JSONDecodable {
    init(JSON: JSONObject) throws
}

/**
JSON decode error

- MissingRequiredKey:   Required key is missing
- UnexpectedType:       Value type is unexpected
- CannotParseURL:       Value cannot be parsed as URL
- CannotParseDate:      Value cannot be parsed as date
*/
public enum JSONDecodeError: ErrorType, CustomDebugStringConvertible {
    case MissingRequiredKey(String)
    case UnexpectedType(key: String, expected: Any.Type, actual: Any.Type)
    case CannotParseURL(key: String, value: String)
    case CannotParseDate(key: String, value: String)

    public var debugDescription: String {
        switch self {
        case .MissingRequiredKey(let key):
            return "JSON Decode Error: Required key '\(key)' missing"
        case let .UnexpectedType(key: key, expected: expected, actual: actual):
            return "JSON Decode Error: Unexpected type '\(actual)' was supplied for '\(key): \(expected)'"
        case let .CannotParseURL(key: key, value: value):
            return "JSON Decode Error: Cannot parse URL '\(value)' for key '\(key)'"
        case let .CannotParseDate(key: key, value: value):
            return "JSON Decode Error: Cannot parse date '\(value)' for key '\(key)'"
        }
    }
}

/**
Search result data
- SeeAlso: https://developer.github.com/v3/search/
*/
public struct SearchResult<ItemType: JSONDecodable>: JSONDecodable {
    public let totalCount: Int
    public let incompleteResults: Bool
    public let items: [ItemType]

    /**
    Initialize from JSON object

    - Parameter JSON: JSON object
    - Throws: JSONDecodeError
    - Returns: SearchResult
    */
    public init(JSON: JSONObject) throws {
        self.totalCount = try getValue(JSON, key: "total_count")
        self.incompleteResults = try getValue(JSON, key: "incomplete_results")
        self.items = try (getValue(JSON, key: "items") as [JSONObject]).mapWithRethrow { return try ItemType(JSON: $0) }
    }
}

/**
Repository data
- SeeAlso: https://developer.github.com/v3/search/#search-repositories
*/
public struct Repository: JSONDecodable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let isPrivate: Bool
    public let HTMLURL: NSURL
    public let description: String?
    public let fork: Bool
    public let URL: NSURL
    public let createdAt: NSDate
    public let updatedAt: NSDate
    public let pushedAt: NSDate?
    public let homepage: String?
    public let size: Int
    public let stargazersCount: Int
    public let watchersCount: Int
    public let language: String?
    public let forksCount: Int
    public let openIssuesCount: Int
    public let masterBranch: String?
    public let defaultBranch: String
    public let score: Double
    public let owner: User

    /**
    Initialize from JSON object

    - Parameter JSON: JSON object
    - Throws: JSONDecodeError
    - Returns: SearchResult
    */
    public init(JSON: JSONObject) throws {
        self.id = try getValue(JSON, key: "id")
        self.name = try getValue(JSON, key: "name")
        self.fullName = try getValue(JSON, key: "full_name")
        self.isPrivate = try getValue(JSON, key: "private")
        self.HTMLURL = try getURL(JSON, key: "html_url")
        self.description = try getOptionalValue(JSON, key: "description")
        self.fork = try getValue(JSON, key: "fork")
        self.URL = try getURL(JSON, key: "url")
        self.createdAt = try getDate(JSON, key: "created_at")
        self.updatedAt = try getDate(JSON, key: "updated_at")
        self.pushedAt = try getOptionalDate(JSON, key: "pushed_at")
        self.homepage = try getOptionalValue(JSON, key: "homepage")
        self.size = try getValue(JSON, key: "size")
        self.stargazersCount = try getValue(JSON, key: "stargazers_count")
        self.watchersCount = try getValue(JSON, key: "watchers_count")
        self.language = try getOptionalValue(JSON, key: "language")
        self.forksCount = try getValue(JSON, key: "forks_count")
        self.openIssuesCount = try getValue(JSON, key: "open_issues_count")
        self.masterBranch = try getOptionalValue(JSON, key: "master_branch")
        self.defaultBranch = try getValue(JSON, key: "default_branch")
        self.score = try getValue(JSON, key: "score")
        self.owner = try User(JSON: getValue(JSON, key: "owner") as JSONObject)
    }
}

/**
User data
- SeeAlso: https://developer.github.com/v3/search/#search-repositories
*/
public struct User: JSONDecodable {
    public let login: String
    public let id: Int
    public let avatarURL: NSURL
    public let gravatarID: String
    public let URL: NSURL
    public let receivedEventsURL: NSURL
    public let type: String

    /**
    Initialize from JSON object

    - Parameter JSON: JSON object
    - Throws: JSONDecodeError
    - Returns: SearchResult
    */
    public init(JSON: JSONObject) throws {
        self.login = try getValue(JSON, key: "login")
        self.id = try getValue(JSON, key: "id")
        self.avatarURL = try getURL(JSON, key: "avatar_url")
        self.gravatarID = try getValue(JSON, key: "gravatar_id")
        self.URL = try getURL(JSON, key: "url")
        self.receivedEventsURL = try getURL(JSON, key: "received_events_url")
        self.type = try getValue(JSON, key: "type")
    }
}


// MARK: - Utilities

/**
Get URL from JSON for key
- Parameters:
  - JSON: JSON object
  - key:  Key
- Throws: JSONDecodeError
- Returns: URL
*/
private func getURL(JSON: JSONObject, key: String) throws -> NSURL {
    let URLString: String = try getValue(JSON, key: key)
    guard let URL = NSURL(string: URLString) else {
        throw JSONDecodeError.CannotParseURL(key: key, value: URLString)
    }
    return URL
}

/**
Get URL from JSON for key
- Parameters:
- JSON: JSON object
- key:  Key
- Throws: JSONDecodeError
- Returns: URL or nil
*/
private func getOptionalURL(JSON: JSONObject, key: String) throws -> NSURL? {
    guard let URLString: String = try getOptionalValue(JSON, key: key) else { return nil }
    guard let URL = NSURL(string: URLString) else {
        throw JSONDecodeError.CannotParseURL(key: key, value: URLString)
    }
    return URL
}

/**
Parse ISO 8601 format date string
- SeeAlso: https://developer.github.com/v3/#schema
*/
private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return formatter
    }()

/**
Get date from JSON for key
- Parameters:
- JSON: JSON object
- key:  Key
- Throws: JSONDecodeError
- Returns: date
*/
private func getDate(JSON: JSONObject, key: String) throws -> NSDate {
    let dateString: String = try getValue(JSON, key: key)
    guard let date = dateFormatter.dateFromString(dateString) else {
        throw JSONDecodeError.CannotParseDate(key: key, value: dateString)
    }
    return date
}

/**
Get date from JSON for key
- Parameters:
- JSON: JSON object
- key:  Key
- Throws: JSONDecodeError
- Returns: date or nil
*/
private func getOptionalDate(JSON: JSONObject, key: String) throws -> NSDate? {
    guard let dateString: String = try getOptionalValue(JSON, key: key) else { return nil }
    guard let date = dateFormatter.dateFromString(dateString) else {
        throw JSONDecodeError.CannotParseDate(key: key, value: dateString)
    }
    return date
}

/**
Get typed value from JSON for key. Type `T` should be inferred from contexts.
- Parameters:
- JSON: JSON object
- key:  Key
- Throws: JSONDecodeError
- Returns: Typed value
*/
private func getValue<T>(JSON: JSONObject, key: String) throws -> T {
    guard let value = JSON[key] else {
        throw JSONDecodeError.MissingRequiredKey(key)
    }
    guard let typedValue = value as? T else {
        throw JSONDecodeError.UnexpectedType(key: key, expected: T.self, actual: value.dynamicType)
    }
    return typedValue
}

/**
Get typed value from JSON for key. Type `T` should be inferred from contexts.
- Parameters:
- JSON: JSON object
- key:  Key
- Throws: JSONDecodeError
- Returns: Typed value or nil
*/
private func getOptionalValue<T>(JSON: JSONObject, key: String) throws -> T? {
    guard let value = JSON[key] else {
        return nil
    }
    if value is NSNull {
        return nil
    }
    guard let typedValue = value as? T else {
        throw JSONDecodeError.UnexpectedType(key: key, expected: T.self, actual: value.dynamicType)
    }
    return typedValue
}

private extension Array {
    /**
    Workaround for `map` with throwing closure
    */
    func mapWithRethrow<T>(@noescape transform: (Array.Generator.Element) throws -> T) rethrows -> [T] {
        var mapped: [T] = []
        for element in self {
            mapped.append(try transform(element))
        }
        return mapped
    }
}
