//
//  ReposesEndPoint.swift
//  DI_Sample
//
//  Created by sdk on 30.09.2021.
//

import Foundation

struct ReposesEndPoint: Endpoint {
    let queryItems: [URLQueryItem]
    
    var path: String {
        "/orgs/" + org + "/repos"
    }
    private let org: String
    
    init(org: String, pageIndex: Int, pageSize: Int) {
        self.org = org
        self.queryItems = [URLQueryItem(name: "page", value: "\(pageIndex)"),
                           URLQueryItem(name: "per_page", value: "\(pageSize)")]
    }
}
