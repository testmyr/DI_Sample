//
//  EndPoint.swift
//  DI_Sample
//
//  Created by sdk on 30.09.2021.
//

import Foundation

protocol Endpoint {
  var path: String { get }
}

struct GithubRepos: Endpoint {
    var path: String {
        // an item
        //"https://jsonblob.com/api/jsonBlob/892924473385435136"
        // an error
        //"https://jsonblob.com/api/jsonBlob/894582684643508224"
        "https://api.github.com/orgs/" + org + "/repos"
    }
    private let org: String
    
    init(org: String) {
        self.org = org
    }
}
