//
//  RepoModelNetworking.swift
//  DI_Sample
//
//  Created by sdk on 30.09.2021.
//

import Foundation

struct RepoModelNetworking: Codable {
    var name: String
    var description: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, description
    }
}
