//
//  ReposListAssemblerStubInjector.swift
//  DI_Sample
//
//  Created by sdk on 27.01.2023.
//

import Foundation


class ReposListAssemblerStubInjector: ReposListAssemblerProtocol {
    func resolve(org: String, view: ReposListVCProtocol) -> ReposListPresenter {
        let networking = NetworkingStub()
        return ReposListPresenter(vc: view, networking: networking)
    }
}
