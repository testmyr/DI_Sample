//
//  EndPoint.swift
//  DI_Sample
//
//  Created by sdk on 26.01.2023.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem]  { get }
}

extension Endpoint {
    var baseUrl: String { "api.github.com" }
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseUrl
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}
