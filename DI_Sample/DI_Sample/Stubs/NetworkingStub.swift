//
//  NetworkingStub.swift
//  DI_Sample
//
//  Created by sdk on 27.01.2023.
//

import Foundation


class NetworkingStub: NetworkingProtocol {
    private let initialPage = 1
    
    func requestReposPage(withSize pageSize: Int, andIndex pageIndex: Int, completion: @escaping CompletionHandler) {
        assert(pageIndex >= initialPage)
        let reposesIndexes = 1...pageSize
        let reposes: [RepoResponse] = reposesIndexes.map({ RepoResponse(name: "repos #\($0)", description: "page #\(pageIndex)") })
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(reposes) else {
            assertionFailure("Failed encoding")
            DispatchQueue.global(qos: .userInitiated).async {
                completion(nil, false)
            }
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let delay = Double.random(in: 0.5...2.5)
            Thread.sleep(forTimeInterval: delay)
            completion(data, true)
        }
    }
}
