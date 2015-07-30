//
//  SearchRepositoriesManager.swift
//  GitHubSearch
//
//  Created by Hiroki Kato on 2015/07/30.
//  Copyright © 2015年 Hatena Co., Ltd. All rights reserved.
//

import Foundation

class SearchRepositoriesManager {
    
    let github: GitHubAPI
    let query: String
    
    var results: [Repository] = []
    
    init?(github: GitHubAPI, query: String) {
        self.github = github
        self.query = query
        if query.characters.isEmpty {
            return nil
        }
    }
    
    func search(completion: (error: ErrorType?) -> Void) {
        github.request(GitHubAPI.SearchRepositories(query: query)) { (task, response, error) -> Void in
            if let response = response {
                self.results.extend(response.items)
            }
            completion(error: error)
        }
    }
    
}
