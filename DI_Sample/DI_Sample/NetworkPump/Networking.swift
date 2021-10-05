//
//  Networking.swift
//  DI_Sample
//
//  Created by sdk on 29.09.2021.
//

import Foundation

fileprivate extension OperationQueue {
    func containsZeroPageOperation() -> Bool {
        return operations.contains(where: { (operation) -> Bool in
            if let operation = operation as? AsyncWebOperation, operation.pageIndex == 0 {
                return true
            }
            return false
        })
    }
}

protocol NetworkingProtocol {
    typealias CompletionHandler = (Data?, Bool) -> Void
    func request(pageWithSize pageSize: Int, andIndex pageIndex: Int, endPoint: Endpoint, completion: @escaping CompletionHandler) -> OperationQueue?
}

class Networking: NetworkingProtocol {
    private(set) lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Serial queue for the pagination"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func request(pageWithSize pageSize: Int, andIndex pageIndex: Int, endPoint: Endpoint, completion: @escaping CompletionHandler) -> OperationQueue? {
        assert(pageIndex > 0)
        guard let url = URL(string: endPoint.path) else { return nil }
        if queue.containsZeroPageOperation() {
            completion(nil, true)
        }
        var request = createRequest(forUrl: url, withPageSize: pageSize, andPageIndex: pageIndex)
        request.timeoutInterval = 10
        let operation = AsyncWebOperationDataTask(with: request) { success, data, _ in
            completion(data, success)
        }
        // in order to ignore all operations follow the refresh operation
        // actually it might be a boolean value but nonetheless
        operation.pageIndex = pageIndex
        queue.addOperation(operation)
        return queue
    }
    
    private func createRequest(forUrl url: URL, withPageSize pageSize: Int, andPageIndex pageIndex: Int) -> URLRequest {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "page", value: "\(pageIndex)"), URLQueryItem(name: "per_page", value: "\(pageSize)")]
        var request = URLRequest(url: (components?.url!)!)
        request.cachePolicy = .reloadIgnoringCacheData
        return request
    }
}
