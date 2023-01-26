//
//  ReposListAssembler.swift
//  DI_Sample
//
//  Created by sdk on 29.09.2021.
//

import Foundation

protocol ReposListAssemblerProtocol {
    func resolve(org: String) -> ReposListVC
    func resolve(org: String, view: ReposListVCProtocol) -> ReposListPresenter
}

extension ReposListAssemblerProtocol {
    func resolve(org: String = "square") -> ReposListVC {
        let reposView = ReposListVC.instantiate()
        reposView.presenter = resolve(org: org, view: reposView)
        return reposView
    }
    func resolve(org: String, view: ReposListVCProtocol) -> ReposListPresenter {
        let networking = Networking(org: org)
        return ReposListPresenter(vc: view, networking: networking)
    }
}

class ReposListAssemblerInjector: ReposListAssemblerProtocol {
}
