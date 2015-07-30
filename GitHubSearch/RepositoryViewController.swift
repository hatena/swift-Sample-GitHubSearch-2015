//
//  RepositoryViewController.swift
//  GitHubSearch
//
//  Created by Hiroki Kato on 2015/07/30.
//  Copyright © 2015年 Hatena Co., Ltd. All rights reserved.
//

import UIKit

import SafariServices

class RepositoryViewController: UIViewController, ApplicationContextSettable {
    
    var appContext: ApplicationContext!
    var repository: Repository!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var URLButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = repository.name
        nameLabel.text = repository.fullName
        URLButton.setTitle(repository.HTMLURL.absoluteString, forState: .Normal)
    }
    
    @IBAction func openURL(sender: AnyObject) {
        let safari = SFSafariViewController(URL: repository.HTMLURL)
        safari.delegate = self
        presentViewController(safari, animated: true, completion: nil)
    }

}

extension RepositoryViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
