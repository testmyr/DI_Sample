//
//  PaginationDataTaskWebOperation.swift
//  DI_Sample
//
//  Created by sdk on 30.09.2021.
//

import Foundation

/// Is finished as soon as its 'completion' closure is executed
class PaginationDataTaskWebOperation: WebOperation {

    var task: URLSessionDataTask?
    var completion: ((Bool, Data?) -> ())!

    init(with request: URLRequest, andComletion completion_: @escaping (Bool, Data?) -> ()) {
        super.init()
        self.name = request.url?.path
        let finishCompletion = {
            completion_(false, nil)
            self.state = .finished
        }
        completion = { [weak self] success, data in
            completion_(success, data)
            if let self {
                self.state = .finished
            }
        }
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            var success = false
            defer {
                if let error = error as NSError?, error.code == NSURLErrorCancelled {
                    print("Completed \(String(describing: request.url?.path))")
                    finishCompletion()
                } else {
                    if !success {
                        self?.completion(false, nil)
                    }
                }
            }
            guard let data = data, error == nil else {
                print(response.debugDescription)
                return
            }
            success = true
            self?.completion(true, data)
        }
    }
    
    open override func main() {
        if self.isCancelled {
            state = .finished
        } else {
            if let task = task {
                state = .executing
                task.resume()
            } else {
                state = .finished
            }
        }
    }
    override func cancel() {
        super.cancel()
        if isExecuting {
            if let task = task {
                task.cancel()
            }
        }
    }
}
