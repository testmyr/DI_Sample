//
//  Response.swift
//  DI_Sample
//
//  Created by sdk on 30.09.2021.
//

import Foundation

struct Response: Decodable {
  let reposArray: [RepoResponse]?
  let errorMessage: ErrorInfo?
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            reposArray = try container.decode([RepoResponse].self)
            errorMessage = nil
        } catch let error {
            guard let errorMessage = try? container.decode(ErrorInfo.self) else {
                throw error
            }
            self.errorMessage = errorMessage
            reposArray = nil
        }
    }
}
