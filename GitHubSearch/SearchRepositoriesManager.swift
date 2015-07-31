//
//  SearchRepositoriesManager.swift
//  GitHubSearch
//
//  Created by Hiroki Kato on 2015/07/30.
//  Copyright © 2015年 Hatena Co., Ltd. All rights reserved.
//

import Foundation

/**
Search GitHub repositories with paging
*/
class SearchRepositoriesManager {
    
    let github: GitHubAPI
    let query: String
    
    var networking: Bool = false
    
    var results: [Repository] = []
    var completed: Bool = false
    var page: Int = 1
    
    init?(github: GitHubAPI, query: String) {
        self.github = github
        self.query = query
        if query.characters.isEmpty {
            return nil
        }
    }
    
    /**
    Search
    - Parameters:
      - reload:     Reload
      - completion: Completion handler
    - Returns: True if executed
    */
    func search(reload: Bool, completion: (error: ErrorType?) -> Void) -> Bool {
        if completed || networking {
            return false
        }
        networking = true
        github.request(GitHubAPI.SearchRepositories(query: query, page: reload ? 1 : page)) { (task, response, error) in
            if let response = response {
                if reload {
                    self.results.removeAll()
                    self.page = 1
                }
                self.results.extend(response.items)
                self.completed = response.totalCount <= self.results.count
                self.page++
            }
            self.networking = false
            completion(error: error)
        }
        return true
    }
    
}
