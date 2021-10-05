//
//  DataParser.swift
//  DI_Sample
//
//  Created by sdk on 29.09.2021.
//

import Foundation

import Foundation

protocol DataParserProtocol {
    func fetch(pageWithIndex pageIndex: Int, response: @escaping (Response?) -> Void) -> OperationQueue?
}

class DataParser: DataParserProtocol {
    private let networking: NetworkingProtocol
    private let repos: Endpoint
    
    private let pageSize: Int
    
    init(networking: NetworkingProtocol, repos: Endpoint, pageSize: Int) {
        self.networking = networking
        self.repos = repos
        self.pageSize = pageSize
    }
    
    func fetch(pageWithIndex pageIndex: Int, response: @escaping (Response?) -> Void) -> OperationQueue? {
        return networking.request(pageWithSize: pageSize, andIndex: pageIndex, endPoint: repos) { data, success in
            if !success {
                response(nil)
            }

            // try to parse recieved data into JSON
            let decoded = self.decodeJSON(type: Response.self, data: data)
            response(decoded)
        }
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, data: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = data, let response = try? decoder.decode(type.self, from: data) else {
            return nil
        }
        return response
    }
}
