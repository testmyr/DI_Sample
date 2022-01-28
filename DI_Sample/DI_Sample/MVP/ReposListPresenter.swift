//
//  ReposListPresenter.swift
//  DI_Sample
//
//  Created by sdk on 29.09.2021.
//

import Foundation


protocol ReposListVCProtocol: AnyObject {
    func updateView()
    func updateViewSync()
    func showErrorAlert(errorText: String)
    func showAnimation()
    func hideAnimation()
}

class ReposListPresenter {
    weak var view: ReposListVCProtocol?
    var numberOfModels: Int {
        return models.count
    }
    private(set) var models = [RepoModel]()
    private let dataPump: DataParserProtocol
    
    private let numberOfReposPerPage: Int
    private var reachedTheEndOfList = false
    
    init(vc: ReposListVCProtocol, endPoint: Endpoint, networking: NetworkingProtocol, numberOfReposPerPage: Int = 30) {
        view = vc
        dataPump = DataParser(networking: networking, repos: endPoint, pageSize: numberOfReposPerPage)
        self.numberOfReposPerPage = numberOfReposPerPage
    }
    func start(completion: (()->Void)? = nil) {
        let _ = dataPump.fetch(pageWithIndex: 1) { [weak self] response in
            if let weakSelf = self {
                if let newlyFetchedModels = response?.reposArray {
                    if newlyFetchedModels.count > 0 {
                        weakSelf.models = newlyFetchedModels.map({RepoModel(name: $0.name, description: $0.description)})
                        weakSelf.reachedTheEndOfList = newlyFetchedModels.count < weakSelf.numberOfReposPerPage
                        weakSelf.view?.updateView()
                    } else {
                        weakSelf.view?.showErrorAlert(errorText: "No repositories.")
                        weakSelf.reachedTheEndOfList = true
                    }
                } else if let errorInfo = response?.errorMessage {
                    weakSelf.view?.showErrorAlert(errorText: errorInfo.message)
                }
                completion?()
            }
        }
    }
    
    func refresh(completion: @escaping (()->Void)) {
        start(completion: completion)
    }
    
    func getNextPage() {
        guard !reachedTheEndOfList else {
            return
        }
        
        let duePageIndex = models.count / numberOfReposPerPage + 1
        weak var queue: OperationQueue?
        queue = dataPump.fetch(pageWithIndex: duePageIndex) { [weak self] response in
            if let weakSelf = self {
                let syncUpateOperation = BlockOperation(block: {
                    if let models = response?.reposArray {
                        if models.count > 0 {
                            let newlyFetchedModels = models.map({RepoModel(name: $0.name, description: $0.description)})
                            weakSelf.models.append(contentsOf: newlyFetchedModels)
                            weakSelf.reachedTheEndOfList = newlyFetchedModels.count < weakSelf.numberOfReposPerPage
                            self?.view?.updateViewSync()
                        } else {
                            weakSelf.reachedTheEndOfList = true
                        }
                    } else if let errorInfo = response?.errorMessage {
                        weakSelf.view?.showErrorAlert(errorText: errorInfo.message)
                    }
                })
                
                syncUpateOperation.queuePriority = .veryHigh
                syncUpateOperation.qualityOfService = .userInteractive
                queue?.addOperation(syncUpateOperation)
            }
        }
    }
}
