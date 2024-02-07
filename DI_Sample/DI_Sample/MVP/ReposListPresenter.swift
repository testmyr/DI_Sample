//
//  ReposListPresenter.swift
//  DI_Sample
//
//  Created by sdk on 29.09.2021.
//

import Foundation

protocol DataProviderReposesProtocol {
    func fetch(pageWithIndex pageIndex: Int, response: @escaping (Response?) -> Void)
}

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
    private let dataPump: DataProviderReposesProtocol
    
    private let pageSize: Int
    private var pageIndex = 0
    private var isEndOfReposes = false
    
    init(vc: ReposListVCProtocol, networking: NetworkingProtocol, pageSize: Int = 30) {
        view = vc
        dataPump = DataParser(networking: networking, pageSize: pageSize)
        self.pageSize = pageSize
    }
    func start(completion: (()->Void)? = nil) {
        let _ = dataPump.fetch(pageWithIndex: 1) { [weak self] response in
            if let self {
                if let newlyFetchedModels = response?.reposes {
                    self.pageIndex = 1
                    if newlyFetchedModels.count > 0 {
                        self.models = newlyFetchedModels.map({RepoModel(name: $0.name, description: $0.description)})
                        self.isEndOfReposes = newlyFetchedModels.count < self.pageSize
                        self.view?.updateView()
                    } else {
                        self.view?.showErrorAlert(errorText: "No repositories.")
                        self.isEndOfReposes = true
                    }
                } else {
                    if let errorInfo = response?.errorMessage {
                        self.view?.showErrorAlert(errorText: errorInfo.message)
                    }
                    self.pageIndex = 0
                }
                completion?()
            }
        }
    }
    
    func refresh(completion: @escaping (()->Void)) {
        start(completion: completion)
    }
    
    func getNextPage() {
        guard !isEndOfReposes else {
            return
        }
        
        let duePageIndex = models.count / pageSize + 1
        guard duePageIndex > pageIndex else { return }
        pageIndex = duePageIndex
        dataPump.fetch(pageWithIndex: duePageIndex) { [weak self] response in
            if let self {
                if let models = response?.reposes {
                    if models.count > 0 {
                        let newlyFetchedModels = models.map({RepoModel(name: $0.name, description: $0.description)})
                        self.models.append(contentsOf: newlyFetchedModels)
                        self.isEndOfReposes = newlyFetchedModels.count < self.pageSize
                        self.view?.updateViewSync()
                    } else {
                        self.isEndOfReposes = true
                    }
                } else {
                    if let errorInfo = response?.errorMessage {
                        self.view?.showErrorAlert(errorText: errorInfo.message)
                    }
                    self.pageIndex = self.pageIndex - 1
                }
            }
        }
    }
}
