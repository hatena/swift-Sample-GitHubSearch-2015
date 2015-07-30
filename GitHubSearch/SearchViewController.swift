//
//  SearchViewController.swift
//  GitHubSearch
//
//  Created by Hiroki Kato on 2015/07/30.
//  Copyright © 2015年 Hatena Co., Ltd. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, ApplicationContextSettable {
    
    var appContext: ApplicationContext!
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.delegate = self
        controller.searchResultsUpdater = self
        return controller
        }()
    
    var searchManager: SearchRepositoriesManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = searchController.searchBar
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchManager?.results.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryCell", forIndexPath: indexPath)

        let repository = searchManager!.results[indexPath.row]
        cell.textLabel?.text = repository.name

        return cell
    }

}

extension SearchViewController: UISearchControllerDelegate {
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        guard let searchManager = SearchRepositoriesManager(github: appContext.github, query: searchText) else { return }
        self.searchManager = searchManager
        searchManager.search { [weak self] (error) in
            if let error = error {
                print(error)
            } else {
                self?.tableView.reloadData()
            }
        }
    }
}
