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
    func request(pageWithSize pageSize: Int, andIndex pageIndex: Int, endPoint: Endpoint, completion: @escaping CompletionHandler)
}

class Networking: NetworkingProtocol {
    private(set) lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Serial queue for the pagination"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    /// A pagination request. The completion is called in a non-main queue
    func request(pageWithSize pageSize: Int, andIndex pageIndex: Int, endPoint: Endpoint, completion: @escaping CompletionHandler) {
        assert(pageIndex > 0)
        if pageIndex == 0 {
            // if it is eg a refresh the previous data isn't needed already
            queue.cancelAllOperations()
        }
        guard let url = URL(string: endPoint.path) else { return }
        // might be used in order not to get the data and not to update UI because of due refresh
//        if queue.containsZeroPageOperation() {
//            completion(nil, true)
//            return
//        }
        var request = createRequest(forUrl: url, withPageSize: pageSize, andPageIndex: pageIndex)
        request.timeoutInterval = 10
        weak var weakQueue = queue
        let operation = AsyncWebOperationDataTask(with: request) { success, data, _ in
            if let weakQueue {
                // a completion closure is packed into a 'processingOperation'(at the same queue) in order to cancel it as well within the 'cancelAllOperations()' calling
                // the 'veryHigh' priority value guarantees the invocation before the further requests operations
                let processingOperation = BlockOperation(block: {
                    completion(data, success)
                })
                processingOperation.queuePriority = .veryHigh
                processingOperation.qualityOfService = .userInteractive
                weakQueue.addOperation(processingOperation)
            }
        }
        // in order to ignore all operations follow the refresh operation
        // actually it might be a boolean value but nonetheless
        operation.pageIndex = pageIndex
        queue.addOperation(operation)
    }
    
    private func createRequest(forUrl url: URL, withPageSize pageSize: Int, andPageIndex pageIndex: Int) -> URLRequest {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "page", value: "\(pageIndex)"), URLQueryItem(name: "per_page", value: "\(pageSize)")]
        var request = URLRequest(url: (components?.url!)!)
        request.cachePolicy = .reloadIgnoringCacheData
        return request
    }
}
