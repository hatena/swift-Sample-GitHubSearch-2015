//
//  ApplicationContext.swift
//  GitHubSearch
//
//  Created by Hiroki Kato on 2015/07/30.
//  Copyright © 2015年 Hatena Co., Ltd. All rights reserved.
//

import Foundation

/// States shared in whole app
class ApplicationContext {
    let github: GitHubAPI = GitHubAPI()
}

protocol ApplicationContextSettable: class {
    var appContext: ApplicationContext! { get set }
}