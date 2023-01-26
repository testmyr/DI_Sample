//
//  Networking.swift
//  DI_Sample
//
//  Created by sdk on 29.09.2021.
//

import Foundation

protocol NetworkingProtocol {
    typealias CompletionHandler = (Data?, Bool) -> Void
    func requestReposPage(withSize pageSize: Int, andIndex pageIndex: Int, completion: @escaping CompletionHandler)
}

class Networking: NetworkingProtocol {
    private let timeoutInterval: TimeInterval = 10
    private let initialPage = 1
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Serial queue for the pagination"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private let org: String
    
    init(org: String) {
        self.org = org
    }
    
    /// A pagination request. The 'completion' is called in a global non-main queue; qos: .userInitiated.
    func requestReposPage(withSize pageSize: Int, andIndex pageIndex: Int, completion: @escaping CompletionHandler) {
        assert(pageIndex >= initialPage)
        if pageIndex == initialPage {
            // if it is eg a refresh the previous data isn't needed already
            queue.cancelAllOperations()
        }
        let reposEndPoint = ReposesEndPoint(org: org, pageIndex: pageIndex, pageSize: pageSize)
        
        // could be moved into a separate func in case of others paginations-queues
        guard let url = reposEndPoint.url else { return }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringCacheData
        request.timeoutInterval = timeoutInterval
        let operation = PaginationDataTaskWebOperation(with: request) { success, data in
            DispatchQueue.global(qos: .userInitiated).async {
                completion(data, success)
            }
        }
        queue.addOperation(operation)
    }
}
